import libxls

/// A font record from the XLS workbook.
public struct Font: Sendable {
    public let name: String?
    public let height: UInt16
    public let flag: UInt16
    public let color: UInt16
    public let bold: UInt16
    public let escapement: UInt16
    public let underline: UInt8
    public let family: UInt8
    public let charset: UInt8

    init(_ data: st_font_data) {
        name = swiftString(data.name)
        height = data.height
        flag = data.flag
        color = data.color
        bold = data.bold
        escapement = data.escapement
        underline = data.underline
        family = data.family
        charset = data.charset
    }
}
