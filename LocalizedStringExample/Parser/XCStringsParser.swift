//
//  XCStringsParser.swift
//  LocalizedStringExample
//
//  Created by 한현민 on 3/25/26.
//

import Foundation

// 1) .xcstrings로부터 JSON 형태 내용을 Codable 구조체 기반으로 가져오기
// 2) 처리한 여러 로케일의 문자열들의 데이터 구조 설계하고, 이 구조 기반의 샘플 데이터 생성하기
// 3) 샘플 데이터를 다시 .xcstrings JSON 형태로 변환하기
// 4) 다시 변환된 .xcstrings JSON 형태의 데이터를 .xcstrings 텍스트 파일로 내보내기

public nonisolated enum XCStringsParser {
    public static func importXCStrings(from url: URL) throws -> XCStringsData {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let xcStringsData = try decoder.decode(XCStringsData.self, from: data)
        return xcStringsData
    }
    
    public static func exportXCStrings(from data: XCStringsData, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .prettyPrinted,         // 들여쓰기 적용
            .sortedKeys,            // 키 정렬
            .withoutEscapingSlashes // 슬래시 (/) 이스케이핑 방지
        ]
        
        let data = try encoder.encode(data)
        try data.write(to: url, options: .atomic)  // .atomic: 쓰기 작업이 완료될 때까지 임시 파일을 사용하여 데이터 손상을 방지함
    }
    
    public static func describe(xcStringsData: XCStringsData) {
        print("Source Language: \(xcStringsData.sourceLanguage)")
        print("Version: \(xcStringsData.version)")
        
        for (key, item) in xcStringsData.strings {
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
