//
//  XCStringsData.swift
//  LocalizedStringExample
//
//  Created by 한현민 on 3/25/26.
//

import Foundation

public typealias StringKey = String
public typealias LocalizableItem = [Locale: String]

public nonisolated struct XCStringsData: Sendable, Codable {
    let sourceLanguage: Locale
    /// key: XCStringsItem pairs
    var strings: [StringKey: XCStringsItem]
    var version: String

    static let `default` = XCStringsData(
        sourceLanguage: .en,
        strings: [:],
        version: "1.0"
    )
}

public nonisolated struct XCStringsItem: Sendable, Codable, Hashable {
    var extractionState: XCStringsExtractionState? // 자동 추출 시 생략될 수 있음
    /// locale : localizations pairs
    var localizations: [Locale: XCStringsLocalizationItem]?
    var comment: String?
    var shouldTranslate: Bool?
}

public nonisolated enum XCStringsExtractionState: String, Sendable, Codable {
    case manual
    case migrated
}

public nonisolated struct XCStringsLocalizationItem: Sendable, Codable, Hashable {
    var stringUnit: XCStringsStringUnit?
    var variations: XCStringsVariation?
}

public nonisolated struct XCStringsVariation: Sendable, Codable, Hashable {
    var device: [String: XCStringsLocalizationItem]?
    var plural: [String: XCStringsLocalizationItem]?
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
            print("\n--- Key: \(key) ---")
            print("Extraction State: \(item.extractionState?.rawValue ?? "unknown")")
            print("Should Translate: \(item.shouldTranslate ?? true)")
            print("Comment: \(item.comment ?? "none")")

            guard let localizations = item.localizations else {
                print("  (No localizations found)")
                continue
            }

            for (locale, localization) in localizations {
                // 1. 일반 문자열(stringUnit) 출력
                if let stringUnit = localization.stringUnit {
                    print("  Locale: \(locale), State: \(stringUnit.state.rawValue), Value: \(stringUnit.value)")
                }

                // 2. 변형(variations) 출력
                if let variations = localization.variations {
                    // 기기별 변형 (device) [cite: 9, 10, 11, 12, 13]
                    if let deviceVariations = variations.device {
                        for (device, deviceLoc) in deviceVariations {
                            if let unit = deviceLoc.stringUnit {
                                print("  Locale: \(locale), Device: \(device), State: \(unit.state.rawValue), Value: \(unit.value)")
                            }
                        }
                    }

                    // 복수형 변형 (plural) [cite: 3, 4, 5, 6]
                    if let pluralVariations = variations.plural {
                        for (pluralForm, pluralLoc) in pluralVariations {
                            if let unit = pluralLoc.stringUnit {
                                print("  Locale: \(locale), Plural: \(pluralForm), State: \(unit.state.rawValue), Value: \(unit.value)")
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Initializer from EditorViewModel (Public)

extension XCStringsData {
    public init(from viewModel: EditorViewModel) {
        self.sourceLanguage = viewModel.preference.sourceLanguage
        // textRows의 각 행을 [로케일 문자열: XCStringsItem]으로 변환하여 strings 딕셔너리에 저장
        self.strings = viewModel.textRows.reduce([:]) { result, row in
            var localizations: [Locale: XCStringsLocalizationItem] = [:]
            
            // row에 입력된 로케일별 문자열을 현재 처리중인 딕셔너리의 값 형태로 변환
            row.localizations.forEach { locale, text in
                localizations[locale] = XCStringsLocalizationItem(
                    stringUnit: .init(state: .translated, value: text),
                    variations: .init() // 복수형, 기기 여부 나중에 필요하면 반영
                )
            }

            // 결과 문자열을 로케일의 값으로 하여, result 딕셔너리에 추가
            return [row.key: XCStringsItem(
                extractionState: .manual,
                localizations: localizations,
                comment: row.comment,
                shouldTranslate: nil
            )]
        }
        self.version = "1.1"
    }
}

// MARK: - Sample Data (Internal)

extension XCStringsData {
    static var sampleData: XCStringsData {
        XCStringsData(
            sourceLanguage: .en,
            strings: [
                "login_btn": XCStringsItem(
                    extractionState: .manual,
                    localizations: [
                        .en: XCStringsLocalizationItem(
                            stringUnit: XCStringsStringUnit(
                                state: .translated,
                                value: "Login"
                            )
                        ),
                        .ja: XCStringsLocalizationItem(
                            stringUnit: XCStringsStringUnit(
                                state: .translated,
                                value: "ログイン"
                            )
                        ),
                        .ko: XCStringsLocalizationItem(
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
                        .en: XCStringsLocalizationItem(
                            stringUnit: XCStringsStringUnit(
                                state: .translated,
                                value: "Welcome Home"
                            )
                        ),
                        .ja: XCStringsLocalizationItem(
                            stringUnit: XCStringsStringUnit(
                                state: .translated,
                                value: "お帰りなさい"
                            )
                        ),
                        .ko: XCStringsLocalizationItem(
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
