import Testing
import libxls

@Test func versionIsAvailable() {
    let versionStr = String(cString: xls_getVersion())
    #expect(versionStr == "1.6.3")
}
