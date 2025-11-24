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
    @ObservedObject var mindAnalyzer: MindAnalyzer

    init(_ mindAnalyzer: MindAnalyzer) {
        self.mindAnalyzer = mindAnalyzer
    }


    // MARK: body
    var body: some View {
        MindAnalyzerLayout {
            
            Header(
                title: "누구에게 면담을 요청할까요?",
                description: "오늘의 감정을 가장 잘 표현해줄 멘토를 선택하면 맞춤 리포트를 보내드릴게요."
            )
            
            CharacterPicker(
                characters: MindAnalyzer.CharacterType.allCases,
                selection: $mindAnalyzer.selectedCharacter
            )
            
            AnalyzeButton(
                iconName: mindAnalyzer.isAnalyzing ? "hourglass" : "paperplane",
                label: mindAnalyzer.isAnalyzing ? "면담 요청 중" : "면담 요청하기",
                isActive: !mindAnalyzer.isAnalyzing,
                action: {
                    Task {
                        mindAnalyzer.isAnalyzing = true
                        await mindAnalyzer.startAnalyzing()
                        // MentoryRecord 생성 및 저장
                        await mindAnalyzer.saveRecord()
                        mindAnalyzer.isAnalyzing = false
                    }
                })
            
            AnalyzedResult(
                readyPrompt: "면담 요청을 보내면 멘토가 감정 리포트를 작성해드려요.",
                progressPrompt: "선택한 멘토가 답변을 준비 중이에요...",
                isProgress: mindAnalyzer.isAnalyzing,
                result: mindAnalyzer.analyzedResult,
                mindType: mindAnalyzer.mindType
            )
            
            
            ConfirmButton(
                icon: "checkmark.circle.fill",
                label: "확인",
                isPresented: mindAnalyzer.isAnalyzing == false,
                action: {
                    let recordForm = mindAnalyzer.owner!
                    
                    recordForm.removeForm()
                }
            )
        }
    }
}



fileprivate struct StatusBadge: View {
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



fileprivate extension Emotion {
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

extension MindAnalyzer.CharacterType: CaseIterable {
    static var allCases: [MindAnalyzer.CharacterType] { [.A, .B] }
}

fileprivate extension MindAnalyzer.CharacterType {
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


// MARK: Component
fileprivate struct Header: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title3.bold())
            Text(description)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
}


fileprivate struct CharacterPicker: View {
    let characters: [MindAnalyzer.CharacterType]
    @Binding var selection: MindAnalyzer.CharacterType
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(characters, id: \.self) { character in
                SelectableCard(
                    character: character,
                    isSelected: character == selection
                ) {
                    selection = character
                }
            }
        }
    }
    
    fileprivate struct SelectableCard: View {
        let character: MindAnalyzer.CharacterType
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(spacing: 12) {
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
                        .fill(Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(isSelected ? Color.black : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
                )
                .shadow(color: isSelected ? Color.black.opacity(0.08) : Color.clear, radius: 10, y: 8)
            }
            .buttonStyle(.plain)
        }
    }
}


fileprivate struct AnalyzeButton: View {
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
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(self.isActive ? Color.purple : Color.gray.opacity(0.35))
            )
            .foregroundColor(.white)
        }
    }
}


fileprivate struct AnalyzedResult: View {
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
                    .fill(Color(.secondarySystemBackground))
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
}


fileprivate struct ConfirmButton: View {
    let icon: String
    let label: String
    let isPresented: Bool
    let action: () -> Void
    
    var body: some View {
        if isPresented {
            Button(action: self.action){
                HStack(spacing: 8) {
                    Image(systemName: self.icon)
                    Text(self.label)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.blue)
                )
                .foregroundColor(.white)
            }
        }
    }
}


// MARK: Preview
fileprivate struct MindAnalyzerPreview: View {
    @StateObject private var mentoryiOS = MentoryiOS()
    
    var body: some View {
        if let todayBoard = mentoryiOS.todayBoard,
           let recordForm = todayBoard.recordForm,
           let mindAnalyzer = recordForm.mindAnalyzer {
            MindAnalyzerView(mindAnalyzer)
        } else {
            ProgressView("프리뷰 로딩 중입니다.")
                .task {
                    mentoryiOS.setUp()
                    
                    let onboarding = mentoryiOS.onboarding!
                    onboarding.nameInput = "김깝십"
                    onboarding.next()
                    
                    let todayBoard = mentoryiOS.todayBoard!
                    
                    todayBoard.setUpForm()
                    let recordForm = todayBoard.recordForm!
                    
                    recordForm.titleInput = "SAMPLE-TITLE"
                    recordForm.textInput = "SAMPLE-TEXT"
                    
                    recordForm.submit()
                }
        }
    }
}


#Preview {
    MindAnalyzerPreview()
}
