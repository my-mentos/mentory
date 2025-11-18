//
//  SettingBoardView.swift
//  Mentory
//
//  Created by SJS on 11/17/25.
//

import SwiftUI

struct SettingBoardView: View {
    @ObservedObject var settingBoard: SettingBoard
    @State private var showingReminderPicker = false
    
    private static let reminderFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    private var userName: String {
        settingBoard.owner?.userName ?? "사용자"
    }
    
    var body: some View {
        NavigationStack{
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        header
                        primarySettingsSection
                        legalSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 28)
                }
            }
            .sheet(isPresented: $showingReminderPicker) {
                reminderPickerSheet
            }
        }
        .navigationDestination(isPresented: $settingBoard.isShowingPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .navigationDestination(isPresented: $settingBoard.isShowingLicenseInfo) {   // 👈 추가
            LicenseInfoView()
        }
        .navigationDestination(isPresented: $settingBoard.isShowingTermsOfService) {
            TermsOfServiceView()
        }
    }
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text("설정")
                    .font(.system(size: 34, weight: .black))
                Spacer()
                Button {
                    // info 버튼 액션
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .shadow(radius: 3)
                            .frame(width: 36, height: 36)
                        Text("i")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                    }
                }
            }
            Text(settingBoard.owner?.getGreetingText() ?? "반가워요, userName님!")
                .font(.system(size: 20, weight: .bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var primarySettingsSection: some View {
        SettingSection {
            SettingRow(
                iconName: "person.text.rectangle",
                iconBackground: Color.orange,
                title: "계정 관리",
                subtitle: "이름 변경 / 비밀번호 변경 / 로그아웃 / 데이터 삭제",
                showDivider: true
            )
            
            SettingRow(
                iconName: "app.badge.fill",
                iconBackground: Color.blue,
                title: "앱 설정",
                showDivider: true
            )
            
            SettingToggleRow(
                iconName: "bell.fill",
                iconBackground: Color.red,
                title: "알림 설정",
                isOn: $settingBoard.isReminderOn,
                showDivider: true
            )
            
            SettingValueRow(
                iconName: "clock.fill",
                iconBackground: Color.purple,
                title: "알림 시간",
                value: reminderTimeText,
                showDivider: false
            ) {
                showingReminderPicker = true
            }
        }
    }
    
    private var legalSection: some View {
        SettingSection {
            SettingRow(
                iconName: "lock.fill",
                iconBackground: Color.gray,
                title: "개인정보 처리 방침",
                showDivider: true
            ){
                settingBoard.showPrivacyPolicy()
            }
            
            SettingRow(
                iconName: "doc.text.fill",
                iconBackground: Color.green,
                title: "라이센스 정보",
                showDivider: true
            ){
                settingBoard.showLicenseInfo()  
            }
            
            SettingRow(
                iconName: "book.fill",
                iconBackground: Color.blue.opacity(0.8),
                title: "이용 약관",
                showDivider: false
            ){
                settingBoard.showTermsOfService()   // 👈 추가
            }
        }
    }
    
    private var reminderPickerSheet: some View {
        NavigationStack {
            VStack(spacing: 16) {
                DatePicker(
                    "알림 시간",
                    selection: $settingBoard.reminderTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                
                Button("완료") {
                    showingReminderPicker = false
                }
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                )
            }
            .padding()
            .navigationTitle("알림 설정")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") {
                        showingReminderPicker = false
                    }
                }
            }
        }
        .presentationDetents([.height(320)])
    }
    
    private var reminderTimeText: String {
        Self.reminderFormatter.string(from: settingBoard.reminderTime)
    }
}

struct SettingRow: View {
    var iconName: String
    var iconBackground: Color
    var title: String
    var subtitle: String? = nil
    var showDivider: Bool
    var action: () -> Void = {}
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: action) {
                HStack(spacing: 16) {
                    SettingIcon(systemName: iconName, background: iconBackground)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .foregroundColor(.primary)
                        if let subtitle {
                            Text(subtitle)
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .font(.system(size: 14, weight: .semibold))
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
            }
            .buttonStyle(.plain)
            
            if showDivider {
                Divider()
                    .padding(.leading, 56)
            }
        }
    }
}

struct SettingValueRow: View {
    var iconName: String
    var iconBackground: Color
    var title: String
    var value: String
    var showDivider: Bool
    var action: () -> Void = {}
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: action) {
                HStack(spacing: 16) {
                    SettingIcon(systemName: iconName, background: iconBackground)
                    Text(title)
                        .foregroundColor(.primary)
                    Spacer()
                    Text(value)
                        .foregroundColor(.gray)
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
            }
            .buttonStyle(.plain)
            
            if showDivider {
                Divider()
                    .padding(.leading, 56)
            }
        }
    }
}

struct SettingToggleRow: View {
    var iconName: String
    var iconBackground: Color
    var title: String
    @Binding var isOn: Bool
    var showDivider: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                SettingIcon(systemName: iconName, background: iconBackground)
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .tint(.green)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            
            if showDivider {
                Divider()
                    .padding(.leading, 56)
            }
        }
    }
}

struct SettingSection<Content: View>: View {
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        SettingCard {
            VStack(spacing: 0) {
                content()
            }
        }
    }
}

struct SettingCard<Content: View>: View {
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        content()
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: 28, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(0.4))
            )
            .shadow(color: Color.black.opacity(0.08), radius: 18, x: 0, y: 10)
    }
}

struct SettingIcon: View {
    var systemName: String
    var background: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(background)
                .frame(width: 32, height: 32)
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(width: 40)
    }
}

#Preview {
    let mentory = MentoryiOS()
    mentory.userName = "지석"
    let board = SettingBoard(owner: mentory)
    board.reminderTime = .now
    
    return SettingBoardView(settingBoard: board)
}
