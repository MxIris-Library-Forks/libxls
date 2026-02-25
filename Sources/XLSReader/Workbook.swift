import libxls
import Foundation

/// A parsed XLS workbook.
///
/// `Workbook` is a non-copyable value type that owns the underlying C resources.
/// The compiler enforces unique ownership — instances cannot be copied or shared.
/// Resources are automatically released when the value goes out of scope.
///
/// Not thread-safe. Do not access from multiple threads concurrently.
public struct Workbook: ~Copyable {
    private let handle: UnsafeMutablePointer<xlsWorkBook>
    private var buffer: UnsafeMutablePointer<UInt8>?

    // MARK: - Properties

    /// Whether the workbook uses the 1904 date system (Macintosh default).
    public var uses1904DateSystem: Bool { handle.pointee.is1904 != 0 }

    /// Whether this is a BIFF5 workbook (Excel 5.0/7.0).
    public var isBIFF5: Bool { handle.pointee.is5ver != 0 }

    /// The workbook type.
    public var type: UInt16 { handle.pointee.type }

    /// The index of the currently active sheet.
    public var activeSheetIndex: Int { Int(handle.pointee.activeSheetIdx) }

    /// The codepage used by the workbook.
    public var codepage: UInt16 { handle.pointee.codepage }

    /// The target charset encoding used when opening the workbook.
    public var charset: String { swiftString(handle.pointee.charset) ?? "UTF-8" }

    /// The number of sheets in the workbook.
    public var sheetCount: Int { Int(handle.pointee.sheets.count) }

    /// A collection of sheet metadata.
    public var sheets: SheetCollection { SheetCollection(handle.pointee.sheets) }

    /// All font records in the workbook.
    public var fonts: [Font] {
        let st = handle.pointee.fonts
        let count = Int(st.count)
        var result: [Font] = []
        result.reserveCapacity(count)
        for i in 0..<count {
            result.append(Font(st.font[i]))
        }
        return result
    }

    /// All number format records in the workbook.
    public var numberFormats: [NumberFormat] {
        let st = handle.pointee.formats
        let count = Int(st.count)
        var result: [NumberFormat] = []
        result.reserveCapacity(count)
        for i in 0..<count {
            result.append(NumberFormat(st.format[i]))
        }
        return result
    }

    /// All extended format (XF) records in the workbook.
    public var extendedFormats: [ExtendedFormat] {
        let st = handle.pointee.xfs
        let count = Int(st.count)
        var result: [ExtendedFormat] = []
        result.reserveCapacity(count)
        for i in 0..<count {
            result.append(ExtendedFormat(st.xf[i]))
        }
        return result
    }

    /// The document summary information, if available.
    public var summaryInfo: SummaryInfo? {
        guard let si = xls_summaryInfo(handle) else { return nil }
        defer { xls_close_summaryInfo(si) }
        return SummaryInfo(si)
    }

    // MARK: - Initializers

    /// Open a workbook from a file path.
    ///
    /// - Parameters:
    ///   - path: The file system path to the `.xls` file.
    ///   - charset: The target charset for string conversion (default: `"UTF-8"`).
    /// - Throws: `XLSError` if the file cannot be opened or parsed.
    public init(path: String, charset: String = "UTF-8") throws {
        var error: xls_error_t = .LIBXLS_OK
        guard let wb = xls_open_file(path, charset, &error) else {
            throw XLSError(cCode: error)
        }
        let parseResult = xls_parseWorkBook(wb)
        if parseResult != .LIBXLS_OK {
            xls_close_WB(wb)
            throw XLSError(cCode: parseResult)
        }
        self.handle = wb
        self.buffer = nil
    }

    /// Open a workbook from in-memory data.
    ///
    /// - Parameters:
    ///   - data: The raw bytes of an `.xls` file.
    ///   - charset: The target charset for string conversion (default: `"UTF-8"`).
    /// - Throws: `XLSError` if the data cannot be parsed.
    public init(data: Data, charset: String = "UTF-8") throws {
        let count = data.count
        let buf = UnsafeMutablePointer<UInt8>.allocate(capacity: count)
        data.copyBytes(to: buf, count: count)

        var error: xls_error_t = .LIBXLS_OK
        guard let wb = xls_open_buffer(buf, count, charset, &error) else {
            buf.deallocate()
            throw XLSError(cCode: error)
        }
        let parseResult = xls_parseWorkBook(wb)
        if parseResult != .LIBXLS_OK {
            xls_close_WB(wb)
            buf.deallocate()
            throw XLSError(cCode: parseResult)
        }
        self.handle = wb
        self.buffer = buf
    }

    deinit {
        xls_close_WB(handle)
        buffer?.deallocate()
    }

    // MARK: - Methods

    /// Open and parse a worksheet at the given index, providing access via a closure.
    ///
    /// The worksheet is only valid within the closure body. This ensures the
    /// workbook (which owns the shared string table) outlives the worksheet.
    ///
    /// - Parameters:
    ///   - index: The zero-based sheet index.
    ///   - body: A closure that receives the parsed worksheet.
    /// - Returns: The value returned by the closure.
    /// - Throws: `XLSError` if the sheet cannot be opened or parsed, or any error thrown by the closure.
    public func withWorksheet<R>(at index: Int, _ body: (borrowing Worksheet) throws -> R) throws -> R {
        guard let ws = xls_getWorkSheet(handle, Int32(index)) else {
            throw XLSError(code: .parse)
        }
        let parseResult = xls_parseWorkSheet(ws)
        if parseResult != .LIBXLS_OK {
            xls_close_WS(ws)
            throw XLSError(cCode: parseResult)
        }
        let worksheet = Worksheet(handle: ws)
        return try body(worksheet)
    }
}
