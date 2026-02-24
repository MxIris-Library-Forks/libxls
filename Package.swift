// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "libxls",
    products: [
        .library(name: "libxls", targets: ["libxls"]),
        .library(name: "XLS", targets: ["XLS"]),
    ],
    targets: [
        .target(
            name: "libxls",
            publicHeadersPath: "include",
            // These macros replicate what autotools' configure script detects.
            cSettings: [
                // Enable iconv-based charset conversion (UTF-16LE → UTF-8, codepage → target encoding).
                // Without this, encoding support falls back to simple memcpy / wcstombs.
                .define("HAVE_ICONV"),
                // iconv()'s 2nd param is `const char **` on some platforms and `char **` on others.
                // macOS uses `char **` (no const), so this expands to empty.
                .define("ICONV_CONST", to: ""),
                // Library version string returned by xls_getVersion().
                .define("PACKAGE_VERSION", to: "\"1.6.3\""),
                // Apple platforms provide <xlocale.h> for thread-safe locale functions.
                // Linux/glibc exposes the same API in <locale.h>, so this is Apple-only.
                .define("HAVE_XLOCALE_H", .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS])),
                // Apple platforms provide wcstombs_l() (BSD extension) for direct locale-aware
                // wide-char conversion. On Linux, the fallback uses uselocale() + wcstombs().
                .define("HAVE_WCSTOMBS_L", .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS])),
                // Lets `#include "config.h"` in C sources find the stub at Sources/libxls/src/config.h.
                .headerSearchPath("src"),
            ],
            linkerSettings: [
                // On Apple platforms iconv is a separate library; on Linux it's part of glibc.
                .linkedLibrary("iconv", .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS])),
            ]
        ),
        .target(
            name: "XLS",
            dependencies: ["libxls"]
        ),
        .testTarget(
            name: "libxlsTests",
            dependencies: ["libxls"]
        ),
        .testTarget(
            name: "XLSTests",
            dependencies: ["XLS"],
            resources: [.copy("Resources")]
        ),
    ]
)
