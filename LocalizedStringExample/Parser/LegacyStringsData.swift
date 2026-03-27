//
//  LegacyStringsData.swift
//  LocalizedStringExample
//
//  Created by 한현민 on 3/25/26.
//

import Foundation

/*
 레거시는 약간의 형변환이 필요함
 기존 경로가 아래와 같다면:
 
 ```
 en.lproj
 |- Localizable.strings
 |- Localizable.stringsdict
 
 ja.lproj
 |- Localizable.strings
 |- Localizable.stringsdict
 
 ko.lproj
 |- Localizable.strings
 |- Localizable.stringsdict
 ```
 
 이것을 구조체에서는 아래처럼 한 곳에 담으면 될 것 같다
 
 일단 .strings는:
 ```swift
 let locale
 var strings: [String: String]
 ```
 
 그 다음 .stringsdict는
 
 ```swift
 let locale
 var stringsDict: [String: [String: String]]
 ```
 
 
 ...
 
 
 */

public nonisolated struct LegacyStringsData: Sendable, Codable {
    let locale: String
}
