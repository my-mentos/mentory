//
//  MindAnalyzerView.swift
//  Mentory
//
//  Created by JAY on 11/17/25.
//
import SwiftUI
import Values

// MARK: View
struct MindAnalyzerView: View {
    // MARK: model
    @State private var showingSubmitAlert = false
    @ObservedObject var mindAnalyzer: MindAnalyzer
    @Namespace private var mentorNamespace
    
    init(
        mindAnalyzer: MindAnalyzer,
    ) {
        self.mindAnalyzer = mindAnalyzer
    }
    
    private var isSelectingStage: Bool {
        !mindAnalyzer.isAnalyzing && !mindAnalyzer.isAnalyzeFinished
    }
    
    private var isGeneratingStage: Bool {
        mindAnalyzer.isAnalyzing
    }
    
    private var isResultStage: Bool {
        !mindAnalyzer.isAnalyzing && mindAnalyzer.isAnalyzeFinished
    }
    
    // MARK: body
    var body: some View {
        MindAnalyzerLayout {
            // Group{
            if isSelectingStage {
                
                Header(
                    title: "누구에게 면담을 요청할까요?",
                    description: "오늘의 감정을 가장 잘 표현해줄 멘토를 선택하면 맞춤 리포트를 보내드릴게요."
                )
                
                CharacterPicker(
                    characters: MentoryCharacter.allCases,
                    selection: $mindAnalyzer.character,
                    namespace: mentorNamespace
                )
                
                AnalyzeButton(
                    iconName: mindAnalyzer.isAnalyzing
                    ? "hourglass" : "paperplane",
                    label: mindAnalyzer.isAnalyzing ? "면담 요청 중" : "면담 요청하기",
                    isActive: !mindAnalyzer.isAnalyzing
                    && mindAnalyzer.character != nil
                ) {
                    showingSubmitAlert = true
                }
                .disabled(
                    mindAnalyzer.character == nil || mindAnalyzer.isAnalyzing
                )
                
                .alert("일기 제출하기", isPresented: $showingSubmitAlert) {
                    Button("취소", role: .cancel) {}
                    Button("제출") {
                        Task {
                            withAnimation {
                                mindAnalyzer.startAnalyze()
                            }
                            
                            await mindAnalyzer.analyze()
                            await mindAnalyzer.updateSuggestions()

                            // Watch로 투두 전송
                            let recordForm = mindAnalyzer.owner!
                            let todayBoard = recordForm.owner!
                            await todayBoard.sendSuggestionsToWatch()

                            withAnimation {
                                mindAnalyzer.stopAnalyze()
                            }
                        }
                    }
                } message: {
                    Text("일기를 제출하면 수정할 수 없습니다.\n제출하시겠습니까?")
                }
                .keyboardShortcut(.defaultAction)
    
                
                AnalyzedResult(
                    readyPrompt: "면담 요청을 보내면 멘토가 감정 리포트를 작성해드려요.",
                    progressPrompt: "선택한 멘토가 답변을 준비 중이에요...",
                    isProgress: false,
                    result: mindAnalyzer.analyzedResult,
                    mindType: mindAnalyzer.mindType
                )
                .allowsHitTesting(false)
            } else if isGeneratingStage {
                if let character = mindAnalyzer.character {
                    CharacterPicker.SelectableCard(
                        character: character,
                        isSelected: true,
                        namespace: mentorNamespace,
                        useMatchedGeometry: true,
                        action: {}
                    )
                    .allowsHitTesting(false)
                }
                
                AnalyzedResult(
                    readyPrompt: "면담 요청을 보내면 멘토가 감정 리포트를 작성해드려요.",
                    progressPrompt: "선택한 멘토가 답변을 준비 중이에요...",
                    isProgress: true,
                    result: mindAnalyzer.analyzedResult,
                    mindType: mindAnalyzer.mindType
                )
            } else if isResultStage {
                
                if let character = mindAnalyzer.character {
                    CharacterPicker.SelectableCard(
                        character: character,
                        isSelected: true,
                        namespace: mentorNamespace,
                        useMatchedGeometry: true,
                        action: {}
                    )
                    .allowsHitTesting(false)
                }
                
                AnalyzedResult(
                    readyPrompt: "면담 요청을 보내면 멘토가 감정 리포트를 작성해드려요.",
                    progressPrompt: "선택한 멘토가 답변을 준비 중이에요...",
                    isProgress: false,
                    result: mindAnalyzer.analyzedResult,
                    mindType: mindAnalyzer.mindType
                )
                ConfirmButton(
                    icon: "checkmark.circle.fill",
                    label: "확인",
                    isPresented: mindAnalyzer.isAnalyzeFinished
                ) {
                    let recordForm = mindAnalyzer.owner!
                    
                    recordForm.finish()
                    mindAnalyzer.finish()
                }
            }
        }
        .navigationBarBackButtonHidden(!isSelectingStage)
    }
}

extension Emotion {
    fileprivate var title: String {
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
    
    fileprivate var description: String {
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
    
    fileprivate var tint: Color {
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
    
    fileprivate var emoji: String {
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

// MARK: Component
private struct Header: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title3.bold())
                .foregroundColor(.primary)
            Text(description)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
}

private struct CharacterPicker: View {
    let characters: [MentoryCharacter]
    @Binding var selection: MentoryCharacter?
    
    let namespace: Namespace.ID?
    
    init(
        characters: [MentoryCharacter],
        selection: Binding<MentoryCharacter?>,
        namespace: Namespace.ID? = nil
    ) {
        self.characters = characters
        self._selection = selection
        self.namespace = namespace
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(characters, id: \.self) { character in
                SelectableCard(
                    character: character,
                    isSelected: character == selection,
                    namespace: namespace,
                    useMatchedGeometry: character == selection
                ) {
                    selection = character
                }
            }
        }
    }
    
    fileprivate struct SelectableCard: View {
        let character: MentoryCharacter
        let isSelected: Bool
        let namespace: Namespace.ID?
        let useMatchedGeometry: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                cardContent
            }
            .buttonStyle(.plain)
        }
        
        @ViewBuilder
        private var cardContent: some View {
            let base = VStack(spacing: 12) {
                Image(character.imageName)
                    .resizable()
                    .scaledToFit()
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
                        .fill(Color.mentoryCard)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(
                            isSelected
                            ? Color.mentoryAccentPrimary
                            : Color(.mentoryBorder),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
                .shadow(
                    color: isSelected ? Color.black.opacity(0.08) : Color.clear,
                    radius: 10,
                    y: 8
                )
            
            // namespace 와 useMatchedGeometry 둘 다 있으면 애니메이션 연결
            if let namespace, useMatchedGeometry {
                base.matchedGeometryEffect(id: character, in: namespace)
            } else {
                base
            }
        }
    }
}

private struct AnalyzeButton: View {
    let iconName: String
    let label: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: iconName)
                Text(label)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        isActive
                        ? Color.mentoryAccentPrimary
                        : Color.mentoryAccentPrimary.opacity(0.35)
                    )
            )
            .foregroundColor(.white)
        }
    }
}

private struct AnalyzedResult: View {
    let readyPrompt: String
    let progressPrompt: String
    let isProgress: Bool
    let result: String?
    let mindType: Emotion?
    
    var body: some View {
        if isProgress {
            StatusBadge(text: progressPrompt)
        } else if let result, result.isEmpty == false {
            VStack(alignment: .leading, spacing: 12) {
                if let mindType {
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
                    .fill(Color(.mentorySubCard))
            )
        } else {
            StatusBadge(text: readyPrompt)
        }
    }
    
    private struct MindTypeResultView: View {
        let mindType: Emotion
        
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
                    .fill(Color(.secondarySystemBackground))
            )
        }
    }
}

private struct ConfirmButton: View {
    let icon: String
    let label: String
    let isPresented: Bool
    let action: () -> Void
    
    var body: some View {
        if isPresented {
            Button(action: self.action) {
                HStack(spacing: 8) {
                    Image(systemName: self.icon)
                    Text(self.label)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.mentoryAccentPrimary)
                )
                .foregroundColor(.white)
            }
        }
    }
}

// MARK: Preview
private struct MindAnalyzerPreview: View {
    @StateObject private var mentoryiOS = MentoryiOS()
    
    var body: some View {
        if let todayBoard = mentoryiOS.todayBoard,
           let recordForm = todayBoard.recordForms.first,
           let mindAnalyzer = recordForm.mindAnalyzer
        {
            MindAnalyzerView(mindAnalyzer: mindAnalyzer)
        } else {
            ProgressView("프리뷰 로딩 중입니다.")
                .task {
                    mentoryiOS.setUp()
                    
                    let onboarding = mentoryiOS.onboarding!
                    onboarding.nameInput = "김깝십"
                    onboarding.next()
                    
                    let todayBoard = mentoryiOS.todayBoard!
                    
                    await todayBoard.setUpRecordForms()
                    let recordForm = todayBoard.recordForms.first!
                    
                    recordForm.titleInput = "SAMPLE-TITLE"
                    recordForm.textInput = "SAMPLE-TEXT"
                    
                    await recordForm.submit()
                }
        }
    }
}

#Preview {
    MindAnalyzerPreview()
}
