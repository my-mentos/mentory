//
//  RecordFormView.swift
//  Mentory
//
//  Created by JAY on 11/17/25.
//

import SwiftUI

struct RecordFormView: View {
    @ObservedObject var recordFormModel: RecordForm
    @StateObject private var mindAnalyzer: MindAnalyzer
    @State private var showAnalyzer = false
    @State private var cachedTextForAnalysis: String = ""
    @State private var showResultView = false
    
    private let mentorCharacters: [MindAnalyzer.CharacterType] = [.A, .B]
    
    init(recordFormModel: RecordForm) {
        self.recordFormModel = recordFormModel
        let analyzer = recordFormModel.mindAnalyzer ?? MindAnalyzer(owner: recordFormModel)
        analyzer.isAnalyzing = false
        analyzer.selectedCharacter = analyzer.selectedCharacter ?? .A
        recordFormModel.mindAnalyzer = analyzer
        _mindAnalyzer = StateObject(wrappedValue: analyzer)
    }
    
    var body: some View {
        Group {
            if showAnalyzer {
                analyzingView
            } else {
                recordView
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .animation(.easeInOut(duration: 0.25), value: showAnalyzer)
        .onReceive(mindAnalyzer.$analyzedResult) { value in
            showResultView = (value?.isEmpty == false)
        }
    }
    
    private var recordView: some View {
        VStack(spacing: 0) {
            recordTopBar
            Divider()
            VStack(spacing: 0) {
                TextField("제목", text: $recordFormModel.titleInput)
                    .font(.title3)
                    .padding(.horizontal)
                    .padding(.top, 12)
                TextEditor(text: $recordFormModel.textInput)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .overlay(
                        Group {
                            if recordFormModel.textInput.isEmpty {
                                Text("글쓰기 시작…")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 12)
                                    .allowsHitTesting(false)
                            }
                        },
                        alignment: .topLeading
                    )
                Spacer()
            }
            Divider()
            bottomToolbar
        }
    }
    
    private var recordTopBar: some View {
        HStack {
            Image(systemName: "bookmark")
                .font(.title3)
                .padding(.leading)
            Spacer()
            Text("11월 17일 월요일")
                .font(.headline)
            Spacer()
            HStack(spacing: 20) {
                Image(systemName: "ellipsis.circle")
                    .font(.title3)
                Button(action: handleSubmitTapped) {
                    Text("완료")
                        .foregroundColor(.purple)
                }
            }
            .padding(.trailing)
        }
        .padding(.vertical, 8)
    }
    
    private var bottomToolbar: some View {
        HStack {
            Spacer()
            Image(systemName: "photo")
            Spacer()
            Image(systemName: "camera")
            Spacer()
            Image(systemName: "waveform")
            Spacer()
        }
        .padding(.vertical, 10)
        .foregroundColor(.gray)
        .background(Color.gray.opacity(0.12))
    }
    
    private var analyzingView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                analyzingHeader
                VStack(spacing: 16) {
                    ForEach(mentorCharacters, id: \.self) { character in
                        CharacterSelectionCard(
                            character: character,
                            isSelected: character == (mindAnalyzer.selectedCharacter ?? .A),
                            action: { mindAnalyzer.selectedCharacter = character }
                        )
                    }
                }
                analyzerButton
                analysisStatus
                resultView
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, y: 6)
            )
            .padding(.horizontal)
            .padding(.top, 32)
        }
    }
    
    private var analyzingHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("누구에게 면담을 요청할까요?")
                .font(.title3.bold())
            Text("오늘의 감정을 가장 잘 표현해줄 멘토를 선택하면 맞춤 리포트를 보내드릴게요.")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
    
    private var analyzerButton: some View {
        Button {
            mindAnalyzer.startAnalyzing()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: mindAnalyzer.isAnalyzing ? "hourglass" : "paperplane")
                Text("면담 요청하기")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(canRequestAnalysis && mindAnalyzer.isAnalyzing == false ? Color.purple : Color.gray.opacity(0.35))
            )
            .foregroundColor(.white)
        }
        .disabled(canRequestAnalysis == false || mindAnalyzer.isAnalyzing)
    }

    @ViewBuilder
    private var resultView: some View {
        if showResultView {
            ResultView(text: mindAnalyzer.analyzedResult)
        }
    }

    private var canRequestAnalysis: Bool {
        let text = recordFormModel.textInput.trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty == false
    }
    
    @ViewBuilder
    private var analysisStatus: some View {
        if mindAnalyzer.isAnalyzing {
            StatusBadge(text: "선택한 멘토가 답변을 준비 중이에요…")
        } else if let result = mindAnalyzer.analyzedResult, result.isEmpty == false {
            VStack(alignment: .leading, spacing: 12) {
                if let mindType = mindAnalyzer.mindType {
                    MindTypeResultView(mindType: mindType)
                }
                Text(result)
                    .font(.body)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.gray.opacity(0.12))
            )
        } else {
            StatusBadge(text: "면담 요청을 보내면 멘토가 감정 리포트를 작성해드려요.")
        }
    }
    
    private func handleSubmitTapped() {
        recordFormModel.validateInput()
        guard recordFormModel.validationResult == .none else { return }
        cachedTextForAnalysis = recordFormModel.textInput
        showAnalyzer = true
        showResultView = false
        recordFormModel.submit()
        recordFormModel.mindAnalyzer = mindAnalyzer
        recordFormModel.textInput = cachedTextForAnalysis
    }
    
    private func resetToEditor() {
        showAnalyzer = false
        cachedTextForAnalysis = ""
        recordFormModel.titleInput = ""
        recordFormModel.textInput = ""
        recordFormModel.mindAnalyzer = mindAnalyzer
        showResultView = false
        mindAnalyzer.isAnalyzing = false
        mindAnalyzer.mindType = nil
        mindAnalyzer.analyzedResult = nil
    }
}

private struct CharacterSelectionCard: View {
    let character: MindAnalyzer.CharacterType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                CharacterImageView(imageName: character.imageName)
                    .frame(height: 110)
                Text(character.displayName)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(character.description)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(isSelected ? Color.black : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: isSelected ? Color.black.opacity(0.08) : Color.clear, radius: 10, y: 8)
        }
        .buttonStyle(.plain)
    }
}

private struct CharacterImageView: View {
    let imageName: String
    
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
    }
}

private struct StatusBadge: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "sparkles")
                .foregroundColor(.purple)
            Text(text)
                .font(.subheadline)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.gray.opacity(0.12))
        )
    }
}

private struct MindTypeResultView: View {
    let mindType: MindAnalyzer.MindType
    
    var body: some View {
        HStack(spacing: 12) {
            Text(mindType.emoji)
                .font(.largeTitle)
            VStack(alignment: .leading, spacing: 4) {
                Text(mindType.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(mindType.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(mindType.tint.opacity(0.18))
        )
    }
}

private struct ResultView: View {
    let text: String?
    
    var body: some View {
        Text(text ?? "")
            .font(.body)
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private extension MindAnalyzer.MindType {
    var title: String {
        switch self {
        case .veryUnpleasant: return "매우 불편한 하루"
        case .unPleasant: return "불편한 하루"
        case .slightlyUnpleasant: return "살짝 불편한 하루"
        case .neutral: return "담담한 하루"
        case .slightlyPleasant: return "잔잔한 즐거움"
        case .pleasant: return "기분 좋은 하루"
        case .veryPleasant: return "최고의 하루"
        }
    }
    
    var description: String {
        switch self {
        case .veryUnpleasant:
            return "무거운 감정이 오래 머물렀어요. 스스로를 돌봐주세요."
        case .unPleasant:
            return "피곤함이나 긴장감이 느껴진 하루였어요."
        case .slightlyUnpleasant:
            return "작은 불편함이 마음 한켠에 남아있어요."
        case .neutral:
            return "감정의 파도가 크지 않은 차분한 하루네요."
        case .slightlyPleasant:
            return "잔잔한 행복이 깃든 하루였어요."
        case .pleasant:
            return "긍정적인 에너지가 가득한 하루였어요."
        case .veryPleasant:
            return "설레고 만족스러운 하루!"
        }
    }
    
    var tint: Color {
        switch self {
        case .veryUnpleasant: return .red
        case .unPleasant: return .orange
        case .slightlyUnpleasant: return .yellow
        case .neutral: return .gray
        case .slightlyPleasant: return .teal
        case .pleasant: return .blue
        case .veryPleasant: return .purple
        }
    }
    
    var emoji: String {
        switch self {
        case .veryUnpleasant: return "😣"
        case .unPleasant: return "😕"
        case .slightlyUnpleasant: return "🙁"
        case .neutral: return "😐"
        case .slightlyPleasant: return "🙂"
        case .pleasant: return "😄"
        case .veryPleasant: return "🤩"
        }
    }
}

private extension MindAnalyzer.CharacterType {
    var displayName: String {
        switch self {
        case .A: return "냉스 처리스키"
        case .B: return "알렉산더 지방스"
        }
    }
    
    var description: String {
        switch self {
        case .A: return "냉철한 분석가 초록이가 감정 분석을 도와드릴게요!"
        case .B: return "감성적인 조력자 지방이가 따뜻하게 답해드릴게요!"
        }
    }
    
    var imageName: String {
        switch self {
        case .A: return "bunsuk"
        case .B: return "gureum"
        }
    }
}

#Preview {
    let mentoryiOS = MentoryiOS()
    let todayBoard = TodayBoard(owner: mentoryiOS)
    let recordForm = RecordForm(owner: todayBoard)
    recordForm.titleInput = "테스트"
    recordForm.textInput = "오늘은 팀 프로젝트 준비를 하느라 정신없었어요."
    return RecordFormView(recordFormModel: recordForm)
}
