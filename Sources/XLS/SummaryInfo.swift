import libxls

/// Summary metadata from an XLS workbook's OLE document properties.
public struct SummaryInfo: Sendable {
    public let title: String?
    public let subject: String?
    public let author: String?
    public let keywords: String?
    public let comment: String?
    public let lastAuthor: String?
    public let appName: String?
    public let category: String?
    public let manager: String?
    public let company: String?

    init(_ si: UnsafeMutablePointer<xlsSummaryInfo>) {
        title = swiftString(si.pointee.title)
        subject = swiftString(si.pointee.subject)
        author = swiftString(si.pointee.author)
        keywords = swiftString(si.pointee.keywords)
        comment = swiftString(si.pointee.comment)
        lastAuthor = swiftString(si.pointee.lastAuthor)
        appName = swiftString(si.pointee.appName)
        category = swiftString(si.pointee.category)
        manager = swiftString(si.pointee.manager)
        company = swiftString(si.pointee.company)
    }
}
