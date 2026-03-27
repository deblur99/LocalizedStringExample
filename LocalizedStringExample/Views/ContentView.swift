//
//  ContentView.swift
//  LocalizedStringExample
//
//  Created by 한현민 on 3/23/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("다국어 문자열 가져오기/내보내기 테스트")
                .bold()
                .padding(.bottom, 4)
            
            Button {
                print(".xcstrings 가져오기")
                // 파일 탐색기 띄워서 .xcstrings Data 가져오기
            } label: {
                Text(".xcstrings 가져오기")
                    .padding(.vertical, 2)
            }
            .buttonStyle(.borderedProminent)
            
            Button {
                print(".strings / .stringsdict 가져오기")
                // 파일 탐색기 띄워서 .strings / .stringsdict Data 가져오기
            } label: {
                Text(".strings / .stringsdict 가져오기")
                    .padding(.vertical, 2)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    ContentView()
//        .environment(\.locale, .init(identifier: "ko"))
//        .environment(\.locale, .init(identifier: "en"))
        .environment(\.locale, .init(identifier: "ja"))
        .frame(width: 300, height: 150)
}
