//
//  File.swift
//
//
//  Created by Crazy凡 on 2022/6/1.
//

import Foundation

public extension FetchOptions {
    enum _URL {
        case http(String)
        case git(String)

        var string: String {
            switch self {
                case .http(let url):
                    return url
                case .git(let url):
                    return url
            }
        }
    }
}

public extension FetchOptions._URL {
    static func http(_ string: String?) -> FetchOptions._URL? {
        guard let string = string else {
            return nil
        }

        return .http(string)
    }

    static func git(_ string: String?) -> FetchOptions._URL? {
        guard let string = string else {
            return nil
        }

        return .git(string)
    }
}

extension FetchOptions._URL: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral: StringLiteralType) {
        if FetchOptions._URL.isGitURL(stringLiteral) {
            self = .git(stringLiteral)
        } else if FetchOptions._URL.isHttpURL(stringLiteral) {
            self = .http(stringLiteral)
        } else {
            fatalError("Invalid URL: \(stringLiteral)")
        }
    }
}

extension FetchOptions._URL {
    static func isStartsWithHttp(_ string: String) -> Bool {
        string.hasPrefix("http") || string.hasPrefix("https")
    }

    /// check a string is a git url
    static func isGitURL(_ string: String) -> Bool {
        string.hasPrefix("git") ||
        (isStartsWithHttp(string) && string.hasSuffix(".git")) ||
        string.hasPrefix("ssh://")
    }

    static func isHttpURL(_ string: String) -> Bool {
        !isGitURL(string) && isStartsWithHttp(string)
    }
}
