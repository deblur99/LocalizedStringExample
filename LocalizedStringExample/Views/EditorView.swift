//
//  EditorView.swift
//  LocalizedStringExample
//
//  Created by 한현민 on 3/25/26.
//

import SwiftUI

// TODO: 편집기를 XCStrings 구조 기반으로 구현하고, 파일 저장하고 내보내는 기능 붙이기
// TODO: 그 다음에는 Xcode 레거시, 안드로이드 구조로 내보내는 기능 구현하기

// 편집기에는 뭐가 있어야 할까
// - 먼저 칼럼에 무엇이 있어야 하는지 생각하고
// - 행 추가하기
// - 행 선택하기
// - 행 편집하기
// - 행 제거하기
// - 행 검색하기
// - 행 여러개 검색하기
// - 행 정렬하기
// - 로케일 추가하기
// - 특정 키마다 여러 개 로케일 한꺼번에 보고 수정하는 창

/// 편집기에서 사용할 설정 객체 (예: 기본 언어 로케일)
public nonisolated struct EditorPreference: Sendable, Codable {
    /// 기본 언어 로케일
    public var sourceLanguage: Locale = .en
}

/// 편집기에서 사용할 텍스트 행 객체 (id와 열이 속성으로 포함)
public nonisolated struct EditorTextRow: Sendable, Identifiable, Codable {
    public let id: UUID
    public var key: String
    public var comment: String
    public var localizations: LocalizableItem  // 로케일명 : 번역된 텍스트 쌍
    
    public static func newItem() -> EditorTextRow {
        EditorTextRow(
            id: UUID(),
            key: "",
            comment: "",
            localizations: [:]
        )
    }
    
    internal static func sampleItems() -> [EditorTextRow] {
        [
            EditorTextRow(
                id: UUID(),
                key: "greeting",
                comment: "인사말",
                localizations: [
                    .en: "Hello",
                    .ja: "こんにちは"
                ]
            ),
            EditorTextRow(
                id: UUID(),
                key: "farewell",
                comment: "작별 인사",
                localizations: [
                    .en: "Goodbye",
                    .ja: "さようなら"
                ]
            )
        ]
    }
}

@Observable
@MainActor
public final class EditorViewModel {
    /// .xcstrings 불러올 때 저장되는 데이터
    public var preference: EditorPreference = .init()
    public var textRows: [EditorTextRow] = []
    
    /// 선택된 키
    public var selectedId: UUID? = nil
    public var selectedKey: String? = nil
    public var selectedComment: String? = nil
    
    /// 새로 추가할 키
    public var newKey: String = ""
    /// 새로 추가할 값
    public var newValue: String = ""
    
    private var xcStringsData: XCStringsData {
        XCStringsData(from: self)
    }
    
    public func fetchForTesting() {
        self.textRows = EditorTextRow.sampleItems()
    }
    
    public func addNewRow() {
        self.textRows.append(EditorTextRow.newItem())
    }
    
    public func save() {
        guard let fetchedUrl = FileManager().showSavePanel(defaultFileName: "Localizable.xcstrings") else {
            return
        }

        do {
            try XCStringsParser.exportXCStrings(from: xcStringsData, to: fetchedUrl)
        } catch {
            print("파일 저장 실패: \(error)")
        }
    }

    public func load() {
        guard let fetchedUrl = FileManager().showOpenPanel() else {
            return
        }

        do {
            let fetchedData = try XCStringsParser.importXCStrings(from: fetchedUrl)
            self.apply(from: fetchedData)
        } catch {
            print("파일 저장 실패: \(error)")
        }
    }
    
    private func apply(from data: XCStringsData) {
        self.preference.sourceLanguage = data.sourceLanguage
        
        // 문자열 키에 대한 로케일별 다국어 문자열 딕셔너리를 가져와 EditorTextRow 배열 형태로 저장
        var results: [EditorTextRow] = []
        data.strings.forEach { key, xcStringsItem in
            var items: [Locale: String] = [:]
            
            let comment = xcStringsItem.comment
            guard let localizations = xcStringsItem.localizations else {
                return
            }
            
            localizations.forEach { locale, localization in
                guard let stringUnit = localization.stringUnit else {
                    return
                }
                
                items[locale] = stringUnit.value
                
                // variations는 일단 처리하지 않고 무시
            }
            
            results.append(
                EditorTextRow(
                    id: UUID(),
                    key: key,
                    comment: comment ?? "",
                    localizations: items
                )
            )
        }
        self.textRows = results
    }
}

struct EditorView: View {
    @Bindable var vm: EditorViewModel
    
    // 여기서는 현재 편집중인 항목을 임시 저장할 변수 그리고 포커스 중인 항목 표시
    @State private var editingText: String? = nil  // 현재 편집중인 게 없으면 nil 처리
    @State private var focusedKey: UUID? = nil  // 항목은 UUID로 표시
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Editor")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Add Row") {
                            vm.addNewRow()
                        }
                    }
                    
                    ToolbarItem(placement: .secondaryAction) {
                        HStack(spacing: 12) {
                            Button("Load") { vm.load() }
                            Button("Save") { vm.save() }
                        }
                    }
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if vm.textRows.isEmpty {
            VStack(spacing: 16) {
                ContentUnavailableView(
                    "No File Loaded",
                    systemImage: "doc.text",
                    description: Text("Load an .xcstrings file.")
                )
                VStack(spacing: 12) {
                    Button("Load .xcstrings") {
                        vm.load()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Start with Empty Row") {
                        vm.addNewRow()
                    }
                }
            }
            .padding()
            .frame(minWidth: 600, minHeight: 400)
        } else {
            // 프리뷰에서 @Observable + List 조합 쓰면 무조건 크래시 발생
            // -> ScrollView + LazyVStack + ForEach 써야 크래시 안 난다.
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach($vm.textRows) { $row in
                        EditorRowView(row: $row) { vm.selectedId = $0 }
                        Divider()
                    }
                }
            }
        }
    }
}

struct EditorRowView: View {
    @Binding var row: EditorTextRow
    var onSelect: (UUID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 12) {
                Text("Key")
                Text("Locales")
                Text("Comment")
                Text("Remaining Translations")
            }
            .font(.body.bold())

            HStack(spacing: 12) {
                TextField("Key..", text: $row.key)
                TextField("Comment..", text: $row.comment)
                Button {
                    onSelect(row.id)
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 24))
                }
                Text("4 of 6")  // 추가예정
            }
            .font(.body)
        }
    }
}

#Preview("Empty Editor View") {
    @Previewable @State var vm = EditorViewModel()
    EditorView(vm: vm)
}

struct EditorPreviewContainer: View {
    @State private var vm = EditorViewModel()

    var body: some View {
        EditorView(vm: vm)
            .task { vm.fetchForTesting() }
    }
}

#Preview("Editor View") {
    EditorPreviewContainer()
}
