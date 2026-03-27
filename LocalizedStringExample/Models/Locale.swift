//
//  Locales.swift
//  LocalizedStringExample
//
//  Created by 한현민 on 3/27/26.
//

import Foundation

public nonisolated enum Locale: String, CaseIterable, Sendable, Codable {
    // MARK: - Asia
    case ko // 한국어 (South Korea)
    case ja // 일본어 (Japan)
    case zhHans = "zh-Hans" // 중국어 간체 (Simplified Chinese)
    case zhHant = "zh-Hant" // 중국어 번체 (Traditional Chinese)
    
    // MARK: - English
    case en // 영어 (English - 보통 US 기준)
    case enGB = "en-GB" // 영국 영어 (United Kingdom)
    
    // MARK: - Europe
    case fr // 프랑스어 (France)
    case de // 독일어 (Germany)
    case es // 스페인어 (Spain)
    case it // 이탈리아어 (Italy)
    case ru // 러시아어 (Russia)
    
    // MARK: - Others
    case ptBR = "pt-BR" // 포르투갈어 (Brazil)
    case vi // 베트남어 (Vietnam)
    case th // 태국어 (Thailand)
    case id // 인도네시아어 (Indonesia)

    /// 각 로케일의 표시용 이름을 반환하는 계산 속성 (예: "한국어", "English")
    public var localizedName: String {
        switch self {
        case .ko: return "한국어"
        case .en: return "English"
        case .ja: return "日本語"
        case .zhHans: return "简体中文"
        case .zhHant: return "繁體中文"
        case .fr: return "Français"
        case .de: return "Deutsch"
        case .es: return "Español"
        default: return self.rawValue
        }
    }
}
