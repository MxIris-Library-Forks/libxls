import libxls

/// An extended format record (XF record) from the XLS workbook.
public struct ExtendedFormat: Sendable {
    public let fontIndex: UInt16
    public let formatIndex: UInt16
    public let type: UInt16
    public let alignment: UInt8
    public let rotation: UInt8
    public let indent: UInt8
    public let usedAttributes: UInt8
    public let lineStyle: UInt32
    public let lineColor: UInt32
    public let backgroundColor: UInt16

    init(_ data: st_xf_data) {
        fontIndex = data.font
        formatIndex = data.format
        type = data.type
        alignment = data.align
        rotation = data.rotation
        indent = data.ident
        usedAttributes = data.usedattr
        lineStyle = data.linestyle
        lineColor = data.linecolor
        backgroundColor = data.groundcolor
    }
}
