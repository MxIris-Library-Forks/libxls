import libxls

/// A parsed worksheet from an XLS workbook.
///
/// `Worksheet` is a non-copyable value type that owns the underlying C resource.
/// It is only accessible within the `Workbook.withWorksheet(at:_:)` closure,
/// which guarantees the parent workbook outlives the worksheet.
public struct Worksheet: ~Copyable {
    private let handle: UnsafeMutablePointer<xlsWorkSheet>

    /// The number of rows in this worksheet.
    public var rowCount: Int { Int(handle.pointee.rows.lastrow) + 1 }

    /// The number of columns in this worksheet.
    public var columnCount: Int { Int(handle.pointee.rows.lastcol) + 1 }

    /// The default column width for this worksheet.
    public var defaultColumnWidth: UInt16 { handle.pointee.defcolwidth }

    /// Column formatting information.
    public var columnInfos: [ColumnInfo] {
        let colinfo = handle.pointee.colinfo
        let count = Int(colinfo.count)
        var result: [ColumnInfo] = []
        result.reserveCapacity(count)
        for i in 0..<count {
            result.append(ColumnInfo(colinfo.col[i]))
        }
        return result
    }

    /// Get a row at the given index.
    public func row(at index: Int) -> Row? {
        guard index >= 0 && index < rowCount else { return nil }
        return Row(handle.pointee.rows.row[index])
    }

    /// Get a cell at the given row and column indices.
    public func cell(atRow row: Int, column: Int) -> Cell? {
        guard let r = self.row(at: row) else { return nil }
        return r.cell(at: column)
    }

    /// Subscript access to a cell by (row, column).
    public subscript(row: Int, column: Int) -> Cell? {
        cell(atRow: row, column: column)
    }

    /// Iterate over all rows in the worksheet.
    ///
    /// - Parameter body: A closure called for each row.
    public func forEachRow(_ body: (Row) throws -> Void) rethrows {
        for i in 0..<rowCount {
            if let r = row(at: i) {
                try body(r)
            }
        }
    }

    init(handle: UnsafeMutablePointer<xlsWorkSheet>) {
        self.handle = handle
    }

    deinit {
        xls_close_WS(handle)
    }
}
