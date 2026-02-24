import libxls

/// Error thrown when a libxls C API call fails.
public struct XLSError: Error, Sendable, Equatable, CustomStringConvertible {
    /// The underlying C error code (now a proper Swift enum).
    public let code: xls_error_t

    public init(code: xls_error_t) {
        self.code = code
    }

    public var description: String {
        String(cString: xls_getError(code))
    }
}

/// Throw if `code` is not `.ok`.
func xlsCheck(_ code: xls_error_t) throws(XLSError) {
    if code != .LIBXLS_OK {
        throw XLSError(code: code)
    }
}
