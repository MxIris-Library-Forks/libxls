import libxls

/// Column formatting information from the XLS worksheet.
public struct ColumnInfo: Sendable {
    public let firstColumn: UInt16
    public let lastColumn: UInt16
    public let width: UInt16
    public let xfIndex: UInt16
    public let flags: UInt16
    public var isHidden: Bool { flags & 0x0001 != 0 }

    init(_ data: st_colinfo_data) {
        firstColumn = data.first
        lastColumn = data.last
        width = data.width
        xfIndex = data.xf
        flags = data.flags
    }
}
