//
//  GeminiView.swift
//  Mentory
//
//  Created by 김민우 on 11/19/25.
//
import SwiftUI
import FirebaseCore
import FirebaseAI  // AI Logic SDK

struct GeminiView: View {
    @State private var prompt: String = ""
    @State private var result: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    // Firebase AI Logic 모델 인스턴스 (lazy 로 늦게 생성)
    private let model: GenerativeModel
        init() {
            // 프리뷰 / 실제 실행 모두 여기서 Firebase 초기화
            if FirebaseApp.app() == nil {
                FirebaseApp.configure()
            }
            
            // Firebase AI Logic 모델 인스턴스 (lazy 로 늦게 생성)
            self.model = FirebaseAI
                    .firebaseAI(backend: .googleAI())
                    .generativeModel(modelName: "gemini-2.5-flash-lite")

        }


    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {

                Text("Gemini 2.5-flash-lite Demo")
                    .font(.title2.bold())

                TextField("프롬프트를 입력하세요…", text: $prompt)
                    .textFieldStyle(.roundedBorder)
                    .padding(.top, 8)

                Button(action: generateResponse) {
                    HStack {
                        if isLoading { ProgressView() }
                        Text("생성하기")
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding()
                .background(Color.blue.opacity(0.85))
                .foregroundColor(.white)
                .cornerRadius(12)
                .disabled(prompt.isEmpty || isLoading)

                if let error = errorMessage {
                    Text("⚠️ 오류: \(error)")
                        .foregroundColor(.red)
                        .font(.subheadline)
                }

                ScrollView {
                    Text(result)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                Spacer()
            }
            .padding()
            .navigationTitle("Gemini 테스트")
        }
    }

    // MARK: - Generate with Gemini
    @MainActor private func generateResponse() {
        guard !prompt.isEmpty else { return }

        isLoading = true
        result = ""
        errorMessage = nil

        Task {
            do {
                let response = try await model.generateContent(prompt)
                if let text = response.text {
                    self.result = text
                } else {
                    self.result = "결과 없음"
                }
            } catch {
                self.errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }
}

#Preview {
    GeminiView()
}

