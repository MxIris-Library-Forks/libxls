import libxls

/// A single row from an XLS worksheet, snapshotted as a Swift value type.
public struct Row: Sendable {
    public let index: UInt16
    public let firstColumn: UInt16
    public let lastColumn: UInt16
    public let height: UInt16
    public let flags: UInt16
    public let xfIndex: UInt16
    public let xfFlags: UInt8
    public let cells: [Cell]

    /// Get a cell at the given column index.
    public func cell(at column: Int) -> Cell? {
        cells.first { Int($0.column) == column }
    }

    /// Subscript access to a cell by column index.
    public subscript(column: Int) -> Cell? {
        cell(at: column)
    }

    init(_ data: st_row_data) {
        index = data.index
        firstColumn = data.fcell
        lastColumn = data.lcell
        height = data.height
        flags = data.flags
        xfIndex = data.xf
        xfFlags = data.xfflags
        var cellArray: [Cell] = []
        let count = Int(data.cells.count)
        cellArray.reserveCapacity(count)
        for i in 0..<count {
            cellArray.append(Cell(data.cells.cell[i]))
        }
        cells = cellArray
    }
}
