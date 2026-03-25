//
//  XCStringsData.swift
//  LocalizedStringExample
//
//  Created by 한현민 on 3/25/26.
//

import Foundation
import Playgrounds

public nonisolated struct XCStringsData: Sendable, Codable {
    let sourceLanguage: String
    /// key: XCStringsItem pairs
    var strings: [String: XCStringsItem]
    var version: String
}

public nonisolated struct XCStringsItem: Sendable, Codable, Hashable {
    var extractionState: XCStringsExtractionState? // 자동 추출 시 생략될 수 있음
    /// locale : localizations pairs
    var localizations: [String: XCStringsLocalizationItem]?
    var comment: String?
}

public nonisolated enum XCStringsExtractionState: String, Sendable, Codable {
    case manual
    case migrated
    // 코드에서 자동 추출된 경우 값이 없을 수 있음
}

public nonisolated struct XCStringsLocalizationItem: Sendable, Codable, Hashable {
    var stringUnit: XCStringsStringUnit?
}

public nonisolated struct XCStringsStringUnit: Sendable, Codable, Hashable {
    var state: XCStringsUnitState
    var value: String
}

public nonisolated enum XCStringsUnitState: String, Sendable, Codable {
    case new
    case translated
    case reviewed
    case needsReview = "needs_review"
}

public extension XCStringsData {
    func describe() {
        print("Source Language: \(sourceLanguage)")
        print("Version: \(version)")
        
        for (key, item) in strings {
            print(
                "Key: \(key), Extraction State: \(item.extractionState?.rawValue ?? "unknown")"
            )
            
            guard let localizations = item.localizations else {
                continue
            }
            
            for (locale, localization) in localizations {
                guard let stringUnit = localization.stringUnit else {
                    continue
                }
                
                print(
                    "  Locale: \(locale), String Unit State: \(stringUnit.state.rawValue), Value: \(stringUnit.value)"
                )
            }
        }
    }
}

// MARK: - Sample Data (Internal)

extension XCStringsData {
    static var sampleData: XCStringsData {
        XCStringsData(
            sourceLanguage: "en",
            strings: [
                "login_btn": XCStringsItem(
                    extractionState: .manual,
                    localizations: [
                        "en": XCStringsLocalizationItem(
                            stringUnit: XCStringsStringUnit(
                                state: .translated,
                                value: "Login"
                            )
                        ),
                        "ja": XCStringsLocalizationItem(
                            stringUnit: XCStringsStringUnit(
                                state: .translated,
                                value: "ログイン"
                            )
                        ),
                        "ko": XCStringsLocalizationItem(
                            stringUnit: XCStringsStringUnit(
                                state: .translated,
                                value: "로그인"
                            )
                        )
                    ]
                ),
                "welcome_home": XCStringsItem(
                    extractionState: .manual,
                    localizations: [
                        "en": XCStringsLocalizationItem(
                            stringUnit: XCStringsStringUnit(
                                state: .translated,
                                value: "Welcome Home"
                            )
                        ),
                        "ja": XCStringsLocalizationItem(
                            stringUnit: XCStringsStringUnit(
                                state: .translated,
                                value: "お帰りなさい"
                            )
                        ),
                        "ko": XCStringsLocalizationItem(
                            stringUnit: XCStringsStringUnit(
                                state: .translated,
                                value: "집에 오신 것을 환영합니다"
                            )
                        )
                    ]
                )
            ],
            version: "1.1"
        )
    }
}
