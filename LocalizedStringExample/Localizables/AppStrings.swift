//
//  AppStrings.swift
//  LocalizedStringExample
//
//  Created by 한현민 on 3/23/26.
//

import SwiftUI

extension AppStrings {
    /// Text, TextField 등에 문자열 전달할 때 사용
    var localized: LocalizedStringKey {
        LocalizedStringKey(self.rawValue)
    }
    
    /// 그 외 일반 String에 문자열 전달할 때 사용
    var text: String {
        String(localized: LocalizedStringResource(stringLiteral: self.rawValue))
    }
}

nonisolated enum AppStrings: String, Sendable {
    case welcomeHome = "welcome_home"
    case loginBtn = "login_btn"
}
