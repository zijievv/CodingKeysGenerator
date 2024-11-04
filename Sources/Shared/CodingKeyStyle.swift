//
//  CodingKeyStyle.swift
//  CodingKeysGenerator
//
//  Created by zijievv on 04/11/2024.
//

public enum CodingKeyStyle {
    case camelCased
    case kebabCased
    case snakeCased
}

extension CodingKeyStyle {
    package init?(rawText: String) {
        switch rawText {
        case "camelCased": self = .camelCased
        case "kebabCased": self = .kebabCased
        case "snakeCased": self = .snakeCased
        default: return nil
        }
    }
}
