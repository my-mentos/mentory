//
//  ContentView.swift
//  SampleCounter
//
//  Created by 김민우 on 11/12/25.
//
import SwiftUI


@MainActor
struct ContentView: View {
    // MARK: core
    @ObservedObject var app: SampleCounter
    
    
    // MARK: body
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.indigo.opacity(0.9), .purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 28) {
                        counterCard
                        counterControls
                        signInSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 40)
                }
            }
            .navigationTitle("Sample Counter")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    
    // MARK: view components
    private var counterCard: some View {
        VStack(spacing: 12) {
            Label("현재 숫자", systemImage: "number.circle")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            Text("\(app.number)")
                .font(.system(size: 76, weight: .black, design: .rounded))
                .foregroundStyle(.primary)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: app.number)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 25, y: 10)
    }
    
    private var counterControls: some View {
        VStack(spacing: 16) {
            HStack(spacing: 18) {
                counterButton(icon: "minus", tint: .orange) {
                    app.decrement()
                }
                counterButton(icon: "plus", tint: .teal) {
                    app.increment()
                }
            }
            Button {
                Task {
                    await app.setUpForm()
                }
            } label: {
                Label("로그인 폼 생성", systemImage: "person.crop.circle.badge.plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    @ViewBuilder
    private var signInSection: some View {
        VStack(spacing: 16) {
            HStack {
                Label(app.isSigned ? "로그인됨" : "로그아웃", systemImage: app.isSigned ? "lock.open.fill" : "lock.fill")
                    .foregroundStyle(app.isSigned ? .green : .red)
                    .font(.headline)
                Spacer()
                Capsule()
                    .fill(app.isSigned ? .green : .red)
                    .frame(width: 80, height: 6)
                    .animation(.easeInOut(duration: 0.25), value: app.isSigned)
            }
            .padding(.horizontal, 4)
            .padding(.top, 4)
            
            if let form = app.signInForm {
                NavigationLink {
                    SignInFormView(form)
                } label: {
                    Label("로그인 화면으로 이동", systemImage: "arrow.right.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            } else {
                Text("아직 로그인 폼이 생성되지 않았습니다. 먼저 폼을 만들어주세요.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
    
    private func counterButton(icon: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title)
                .frame(width: 70, height: 70)
                .background(
                    LinearGradient(colors: [tint.opacity(0.8), tint], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
        .shadow(color: tint.opacity(0.4), radius: 12, y: 6)
        .accessibilityLabel(icon == "plus" ? "숫자 증가" : "숫자 감소")
    }
}


#Preview {
    ContentView(app: SampleCounter())
}
