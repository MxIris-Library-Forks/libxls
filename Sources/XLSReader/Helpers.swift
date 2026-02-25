import Foundation

/// Convert an optional C string pointer to a Swift `String?`.
/// Returns `nil` if the pointer is `nil`.
func swiftString(_ ptr: UnsafePointer<CChar>?) -> String? {
    guard let ptr else { return nil }
    return String(cString: ptr)
}

/// Convert an optional `BYTE *` (UInt8 pointer) to a Swift `String?`.
/// Returns `nil` if the pointer is `nil`.
func swiftString(_ ptr: UnsafePointer<UInt8>?) -> String? {
    guard let ptr else { return nil }
    return ptr.withMemoryRebound(to: CChar.self, capacity: 1) {
        String(cString: $0)
    }
}
