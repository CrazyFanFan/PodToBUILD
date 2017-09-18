//
//  XCConfig.swift
//  PodSpecToBUILD
//
//  Created by jerry on 4/27/17.
//  Copyright © 2017 jerry. All rights reserved.
//
// Notes:
// Clang uses the right most value for a given flag
// EX:
// clang  S/main.m -Wmacro-redefined
// -Wno-macro-redefined -framework Foundation -DDEBUGG=0 -DDEBUGG=1 -o e
//
// Here the compiler will not emit the warning, since we passed -Wno
// after the -W option was passed

import Foundation

protocol XCConfigValueTransformer {
    func string(forXCConfigValue value: String) -> String
    var xcconfigKey: String { get }
}

enum XCConfigValueTransformerError: Error {
    case unimplemented
}

struct XCConfigTransformer {
    private let registry: [String: XCConfigValueTransformer]

    init(transformers: [XCConfigValueTransformer]) {
        var registry = [String: XCConfigValueTransformer]()
        transformers.forEach { registry[$0.xcconfigKey] = $0 }
        self.registry = registry
    }

    func compilerFlag(forXCConfigKey key: String, XCConfigValue value: String) throws -> [String] {
        // Case insensitve?
        guard let transformer = registry[key] else {
            throw XCConfigValueTransformerError.unimplemented
        }

        let allValues = value.components(separatedBy: CharacterSet.whitespaces)
        return allValues.filter { $0 != "$(inherited)" }
            .map { transformer.string(forXCConfigValue: $0) }
    }

    public static func defaultTransformer() -> XCConfigTransformer {
        return XCConfigTransformer(transformers: [
            OtherCFlagsTransformer(),
            PreprocessorDefinesTransformer(),
            AllowNonModularIncludesInFrameworkModulesTransformer(),
            CXXLibraryTransformer(),
            CXXLanguageStandardTransformer(),
            PreCompilePrefixHeaderTransformer(),
        ])
    }

    public func compilerFlags(forXCConfig xcconfig: [String: String]?) -> [String] {
        if let xcconfig = xcconfig {
            return xcconfig.flatMap { try? compilerFlag(forXCConfigKey: $0, XCConfigValue: $1) }
                .flatMap { $0 }
        }
        return [String]()
    }
}

//  MARK: - Value Transformers

struct OtherCFlagsTransformer: XCConfigValueTransformer {
    var xcconfigKey: String {
        return "OTHER_CFLAGS"
    }

    func string(forXCConfigValue value: String) -> String {
        return value
    }
}

struct PreCompilePrefixHeaderTransformer: XCConfigValueTransformer {
    var xcconfigKey: String {
        return "GCC_PRECOMPILE_PREFIX_HEADER"
    }

    func string(forXCConfigValue _: String) -> String {
        // TODO: Implement precompiled header support in Bazel.
        return ""
    }
}

struct PreprocessorDefinesTransformer: XCConfigValueTransformer {
    var xcconfigKey: String {
        return "GCC_PREPROCESSOR_DEFINITIONS"
    }

    func string(forXCConfigValue value: String) -> String {
        return "-D\(value)"
    }
}

struct AllowNonModularIncludesInFrameworkModulesTransformer: XCConfigValueTransformer {
    var xcconfigKey: String {
        return "CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES"
    }

    func string(forXCConfigValue _: String) -> String {
        return "-Wno-non-modular-include-in-framework-module -Wno-error=noon-modular-include-in-framework-module"
    }
}

struct CXXLanguageStandardTransformer: XCConfigValueTransformer {
    var xcconfigKey: String {
        return "CLANG_CXX_LANGUAGE_STANDARD"
    }

    func string(forXCConfigValue value: String) -> String {
        return "-stdlib=\(value)"
    }
}

struct CXXLibraryTransformer: XCConfigValueTransformer {
    var xcconfigKey: String {
        return "CLANG_CXX_LIBRARY"
    }

    func string(forXCConfigValue value: String) -> String {
        return "-stdlib=\(value)"
    }
}
