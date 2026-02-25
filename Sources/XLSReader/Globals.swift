import libxls

/// The version string of the underlying libxls C library.
public var version: String {
    String(cString: xls_getVersion())
}

/// The current debug level for libxls diagnostic output.
///
/// Set to a non-zero value to enable debug printing to stdout/stderr.
/// Defaults to `0` (off).
public var debugLevel: Int32 {
    get { _debugLevel }
    set {
        _debugLevel = newValue
        xls(newValue)
    }
}

/// A callback invoked for each FORMULA / ARRAY record during worksheet parsing.
///
/// - Parameters:
///   - recordID: The BIFF record identifier.
///   - data: The raw formula bytes.
public var formulaHandler: FormulaHandler? {
    get { _formulaHandler }
    set {
        _formulaHandler = newValue
        if newValue != nil {
            xls_set_formula_hander { recordID, length, data in
                guard let data else { return }
                _formulaHandler?(recordID, UnsafeBufferPointer(start: data, count: Int(length)))
            }
        } else {
            xls_set_formula_hander(nil)
        }
    }
}

/// The type for a formula record handler callback.
public typealias FormulaHandler = (_ recordID: UInt16, _ data: UnsafeBufferPointer<UInt8>) -> Void

/// Resolve a palette color index to an RGB value.
///
/// - Parameters:
///   - index: The color index from the XLS palette.
///   - defaultColor: The default color to return if the index is not found.
/// - Returns: The resolved RGB color value as a `UInt32`.
public func resolveColor(index: UInt16, default defaultColor: UInt16) -> UInt32 {
    return xls_getColor(index, defaultColor)
}

// MARK: - Private storage

private nonisolated(unsafe) var _debugLevel: Int32 = 0
private nonisolated(unsafe) var _formulaHandler: FormulaHandler?
