//
//  FileManager.swift
//  LocalizedStringExample
//
//  Created by 한현민 on 3/25/26.
//

import SwiftUI
import UniformTypeIdentifiers  // 확장자 관련 모듈

@MainActor
class FileManager {
    /// 파일 탐색기 열어서 .xcstrings 파일 가져오기
    func showOpenPanel() -> URL? {
        let openPanel = NSOpenPanel()
        
        openPanel.title = "다국어 카탈로그 가져오기"
        openPanel.message = "편집할 .xcstrings 파일을 선택하세요."
        openPanel.allowedContentTypes = [.init(filenameExtension: "xcstrings")!]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = true
        
        return openPanel.runModal() == .OK ? openPanel.url : nil
    }
    
    /// 파일 탐색기 열어서 .xcstrings 파일 저장하기
    func showSavePanel(defaultFileName: String) -> URL? {
        let savePanel = NSSavePanel()

        // 1) 패널 설정
        savePanel.allowedContentTypes = [.init(filenameExtension: "xcstrings")!]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.title = "다국어 카탈로그 저장"
        savePanel.nameFieldStringValue = defaultFileName
        savePanel.message = "문자열 카탈로그를 저장할 위치를 선택하세요."
        
        // 2) 패널 실행
        let response = savePanel.runModal()
        
        // 3) 사용자가 "저장" 버튼을 클릭한 경우 URL 반환, 그렇지 않으면 nil 반환
        return response == .OK ? savePanel.url : nil
    }
}

struct SampleView: View {
    @State private var fetchedUrl: URL? = nil
    
    var body: some View {
        VStack {
            Text("파일 저장 테스트")
                .bold()
                .padding(.bottom)
            
            Text("저장할 파일 URL: \(fetchedUrl?.absoluteString ?? "")")
            
            Button("파일 불러오기") {
                guard let fetchedUrl = FileManager().showOpenPanel() else {
                    return
                }
                
                do {
                    self.fetchedUrl = fetchedUrl
                    let fetchedData = try XCStringsParser.importXCStrings(from: fetchedUrl)
                    fetchedData.describe()
                } catch {
                    print("파일 저장 실패: \(error)")
                }
            }
            
            Button("파일 저장하기") {
                guard let fetchedUrl = FileManager().showSavePanel(defaultFileName: "Localizable.xcstrings") else {
                    return
                }
                
                do {
                    self.fetchedUrl = fetchedUrl
                    try XCStringsParser.exportXCStrings(
                        from: .sampleData,
                        to: fetchedUrl
                    )
                } catch {
                    print("파일 저장 실패: \(error)")
                }
            }
        }
        .padding()
        .frame(width: 300, height: 200)
    }
}

#Preview {
    SampleView()
}
