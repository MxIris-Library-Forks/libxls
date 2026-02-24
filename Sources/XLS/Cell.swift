import libxls

/// The semantic value of a cell, derived from its BIFF record type and content.
public enum CellValue: Sendable, CustomStringConvertible {
    case blank
    case string(String)
    case number(Double)
    case bool(Bool)
    case error(Int32)
    case unknown

    public var description: String {
        switch self {
        case .blank:
            return ""
        case .string(let s):
            return s
        case .number(let d):
            return "\(d)"
        case .bool(let b):
            return b ? "TRUE" : "FALSE"
        case .error(let e):
            return "#ERR(\(e))"
        case .unknown:
            return "?"
        }
    }
}

/// A single cell from an XLS worksheet, snapshotted as a Swift value type.
public struct Cell: Sendable {
    public let row: UInt16
    public let column: UInt16
    public let xfIndex: UInt16
    public let string: String?
    public let doubleValue: Double
    public let intValue: Int32
    public let width: UInt16
    public let colspan: UInt16
    public let rowspan: UInt16
    public let isHidden: Bool

    private let id: UInt16

    /// The semantic value of this cell.
    public var value: CellValue {
        switch Int32(id) {
        case XLS_RECORD_BLANK, XLS_RECORD_MULBLANK:
            return .blank
        case XLS_RECORD_FORMULA, XLS_RECORD_FORMULA_ALT:
            if intValue == 0 {
                return .number(doubleValue)
            } else if string == "bool" {
                return .bool(doubleValue != 0)
            } else if string == "error" {
                return .error(Int32(doubleValue))
            } else {
                return .string(string ?? "")
            }
        case XLS_RECORD_LABELSST, XLS_RECORD_LABEL, XLS_RECORD_RSTRING:
            return .string(string ?? "")
        case XLS_RECORD_NUMBER, XLS_RECORD_RK, XLS_RECORD_MULRK:
            return .number(doubleValue)
        case XLS_RECORD_BOOLERR:
            return .string(string ?? "")
        default:
            return .unknown
        }
    }

    /// Whether the cell is blank (no content).
    public var isBlank: Bool {
        if case .blank = value { return true }
        return false
    }

    init(_ data: st_cell_data) {
        id = data.id
        row = data.row
        column = data.col
        xfIndex = data.xf
        string = swiftString(data.str)
        doubleValue = data.d
        intValue = data.l
        width = data.width
        colspan = data.colspan
        rowspan = data.rowspan
        isHidden = data.isHidden != 0
    }
}
