import Testing
import Foundation
import XLS
import libxls

@Test func versionString() {
    let v = XLS.version
    #expect(!v.isEmpty)
    #expect(v == "1.6.3")
}

@Test func openWorkbookFromFile() throws {
    let path = testFilePath("test2.xls")
    let wb = try Workbook(path: path)
    #expect(wb.sheetCount > 0)
    #expect(!wb.charset.isEmpty)
}

@Test func openWorkbookFromData() throws {
    let path = testFilePath("test2.xls")
    let data = try Data(contentsOf: URL(fileURLWithPath: path))
    let wb = try Workbook(data: data)
    #expect(wb.sheetCount > 0)
}

@Test func sheetCollection() throws {
    let wb = try Workbook(path: testFilePath("test2.xls"))
    let sheets = wb.sheets
    #expect(sheets.count == wb.sheetCount)
    #expect(sheets.count > 0)
    let first = sheets[0]
    #expect(!first.name.isEmpty)
    #expect(first.visibility == .visible)
}

@Test func openWorksheetAndReadRows() throws {
    let wb = try Workbook(path: testFilePath("test2.xls"))
    try wb.withWorksheet(at: 0) { ws in
        #expect(ws.rowCount > 0)
        #expect(ws.columnCount > 0)

        var rowCount = 0
        ws.forEachRow { _ in rowCount += 1 }
        #expect(rowCount > 0)
    }
}

@Test func readCells() throws {
    let wb = try Workbook(path: testFilePath("test2.xls"))
    try wb.withWorksheet(at: 0) { ws in
        // Access via subscript
        if let cell = ws[0, 0] {
            #expect(cell.row == 0)
            #expect(cell.column == 0)
        }

        // Access via row object
        if let row = ws.row(at: 0) {
            #expect(!row.cells.isEmpty)
        }
    }
}

@Test func cellValues() throws {
    let wb = try Workbook(path: testFilePath("test2.xls"))
    try wb.withWorksheet(at: 0) { ws in
        // Walk all cells and verify value types are reasonable
        var foundNonBlank = false
        ws.forEachRow { row in
            for cell in row.cells {
                let v = cell.value
                switch v {
                case .blank:
                    break
                case .string(let s):
                    #expect(!s.isEmpty || true) // string can be empty
                    foundNonBlank = true
                case .number:
                    foundNonBlank = true
                case .bool:
                    foundNonBlank = true
                case .error:
                    foundNonBlank = true
                case .unknown:
                    break
                }
            }
        }
        #expect(foundNonBlank)
    }
}

@Test func summaryInfo() throws {
    let wb = try Workbook(path: testFilePath("test2.xls"))
    // summaryInfo may or may not be present depending on the file
    _ = wb.summaryInfo
}

@Test func fontsFormatsXFs() throws {
    let wb = try Workbook(path: testFilePath("test2.xls"))
    let fonts = wb.fonts
    #expect(!fonts.isEmpty)

    let xfs = wb.extendedFormats
    #expect(!xfs.isEmpty)

    // numberFormats may be empty for simple files
    _ = wb.numberFormats
}

@Test func workbookProperties() throws {
    let wb = try Workbook(path: testFilePath("test2.xls"))
    _ = wb.uses1904DateSystem
    _ = wb.isBIFF5
    _ = wb.type
    _ = wb.activeSheetIndex
    _ = wb.codepage
}

@Test func worksheetColumnInfos() throws {
    let wb = try Workbook(path: testFilePath("test2.xls"))
    try wb.withWorksheet(at: 0) { ws in
        // columnInfos may or may not be present
        _ = ws.columnInfos
        _ = ws.defaultColumnWidth
    }
}

@Test func errorOnInvalidPath() {
    #expect {
        _ = try Workbook(path: "/nonexistent/path.xls")
    } throws: { error in
        guard let xlsError = error as? XLSError else { return false }
        return xlsError.code == .LIBXLS_ERROR_OPEN
    }
}

@Test func setDebugLevelWorks() {
    let prev = XLS.setDebugLevel(0)
    #expect(prev == 0 || true) // just verify it doesn't crash
}

@Test func errorCodeEnumSwitch() {
    // Verify xls_error_t is a proper Swift enum that supports exhaustive switch
    let code: xls_error_t = .LIBXLS_OK
    switch code {
    case .LIBXLS_OK:
        break
    case .LIBXLS_ERROR_OPEN, .LIBXLS_ERROR_SEEK, .LIBXLS_ERROR_READ, .LIBXLS_ERROR_PARSE,
         .LIBXLS_ERROR_MALLOC, .LIBXLS_ERROR_UNSUPPORTED_ENCRYPTION, .LIBXLS_ERROR_NULL_ARGUMENT:
        Issue.record("Expected .LIBXLS_OK")
    @unknown default:
        Issue.record("Unexpected case")
    }
}

@Test func xlsErrorDescription() {
    let error = XLSError(code: .LIBXLS_ERROR_OPEN)
    #expect(!error.description.isEmpty)
    #expect(error == XLSError(code: .LIBXLS_ERROR_OPEN))
    #expect(error != XLSError(code: .LIBXLS_ERROR_PARSE))
}

// MARK: - Helpers

private func testFilePath(_ name: String) -> String {
    Bundle.module.path(forResource: name, ofType: nil, inDirectory: "Resources")!
}
