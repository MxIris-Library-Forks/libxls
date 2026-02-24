import libxls

/// The version string of the underlying libxls C library.
public var version: String {
    String(cString: xls_getVersion())
}

/// Resolve a palette color index to an RGB value.
///
/// - Parameters:
///   - index: The color index from the XLS palette.
///   - defaultColor: The default color to return if the index is not found.
/// - Returns: The resolved RGB color value as a `UInt32`.
public func resolveColor(index: UInt16, default defaultColor: UInt16) -> UInt32 {
    return xls_getColor(index, defaultColor)
}

/// Set the debug level for libxls diagnostic output.
///
/// - Parameter level: The debug level (0 = off).
/// - Returns: The previous debug level.
@discardableResult
public func setDebugLevel(_ level: Int32) -> Int32 {
    return xls(level)
}
