import libxls

/// Error thrown when a libxls C API call fails.
public struct XLSError: Error, Sendable, Equatable, CustomStringConvertible {
    /// The error code describing the failure.
    public let code: Code

    public init(code: Code) {
        self.code = code
    }

    /// Internal initializer from C error code.
    init(cCode: xls_error_t) {
        self.code = Code(cCode)
    }

    public var description: String {
        String(cString: xls_getError(code.cValue))
    }

    /// Error codes for XLS parsing failures.
    public enum Code: Sendable, Equatable {
        case open
        case seek
        case read
        case parse
        case malloc
        case unsupportedEncryption
        case nullArgument

        /// Convert from the C error code.
        init(_ cCode: xls_error_t) {
            switch cCode {
            case .LIBXLS_ERROR_OPEN: self = .open
            case .LIBXLS_ERROR_SEEK: self = .seek
            case .LIBXLS_ERROR_READ: self = .read
            case .LIBXLS_ERROR_PARSE: self = .parse
            case .LIBXLS_ERROR_MALLOC: self = .malloc
            case .LIBXLS_ERROR_UNSUPPORTED_ENCRYPTION: self = .unsupportedEncryption
            case .LIBXLS_ERROR_NULL_ARGUMENT: self = .nullArgument
            default: self = .parse
            }
        }

        /// Convert to the C error code.
        var cValue: xls_error_t {
            switch self {
            case .open: return .LIBXLS_ERROR_OPEN
            case .seek: return .LIBXLS_ERROR_SEEK
            case .read: return .LIBXLS_ERROR_READ
            case .parse: return .LIBXLS_ERROR_PARSE
            case .malloc: return .LIBXLS_ERROR_MALLOC
            case .unsupportedEncryption: return .LIBXLS_ERROR_UNSUPPORTED_ENCRYPTION
            case .nullArgument: return .LIBXLS_ERROR_NULL_ARGUMENT
            }
        }
    }
}

/// Throw if `code` is not `.LIBXLS_OK`.
func xlsCheck(_ code: xls_error_t) throws(XLSError) {
    if code != .LIBXLS_OK {
        throw XLSError(cCode: code)
    }
}
