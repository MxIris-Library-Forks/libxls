import libxls

/// A number format (FORMAT record) from the XLS workbook.
public struct NumberFormat: Sendable {
    public let index: UInt16
    public let value: String?

    init(_ data: st_format_data) {
        index = data.index
        value = swiftString(data.value)
    }
}
