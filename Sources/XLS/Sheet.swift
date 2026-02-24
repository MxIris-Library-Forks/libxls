import libxls

/// Visibility state of a worksheet.
public enum SheetVisibility: UInt8, Sendable {
    case visible = 0
    case hidden = 1
    case veryHidden = 2
}

/// Metadata about a single sheet in the workbook.
public struct SheetInfo: Sendable {
    public let name: String
    public let visibility: SheetVisibility
    public let type: UInt8

    init(_ data: st_sheet_data) {
        name = swiftString(data.name) ?? ""
        visibility = SheetVisibility(rawValue: data.visibility) ?? .visible
        type = data.type
    }
}

/// A `RandomAccessCollection` providing access to sheet metadata in a workbook.
public struct SheetCollection: RandomAccessCollection, Sendable {
    public typealias Index = Int
    public typealias Element = SheetInfo

    private let items: [SheetInfo]

    public var startIndex: Int { 0 }
    public var endIndex: Int { items.count }

    public subscript(position: Int) -> SheetInfo {
        items[position]
    }

    init(_ sheets: st_sheet) {
        var result: [SheetInfo] = []
        let count = Int(sheets.count)
        result.reserveCapacity(count)
        for i in 0..<count {
            result.append(SheetInfo(sheets.sheet[i]))
        }
        items = result
    }
}
