//
//  SettingBoardView.swift
//  Mentory
//
//  Created by SJS on 11/17/25.
//
import SwiftUI
import WebKit


// MARK: View
struct SettingBoardView: View {
    @ObservedObject var settingBoard: SettingBoard
    @State private var showingReminderPicker = false
    @State private var selectedDate: Date = Date()
    @State private var isShowingRenameSheet = false
    @State private var isShowingTermsOfService = false
    @State private var isShowingDataDeletionAlert = false
    @State private var isShowingInformationView = false
    @State private var isShowingPrivacyPolicy = false
    @State private var isShowingLicenseInfo = false
    
    @FocusState private var isRenameFieldFocused: Bool
    
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
                        dataDeletionSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 28)
                }
            }
            .sheet(isPresented: $isShowingRenameSheet) {
                renameSheet
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingInformationView = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
            }
            .sheet(isPresented: $isShowingInformationView) {
                WebView(url: settingBoard.owner!.informationURL)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("닫기") {
                                isShowingInformationView = false
                            }
                        }
                    }
            }
        }
        .alert(
            "데이터를 삭제하시겠습니까?",
            isPresented: $isShowingDataDeletionAlert,
            actions: {
                Button("삭제", role: .destructive) {
                    settingBoard.confirmDataDeletion()
                }
                Button("취소", role: .cancel) {
                }
            },
            message: {
                Text("삭제를 누르면 멘토리 데이터가 모두 제거됩니다.")
            }
        )
        .task {
            settingBoard.loadSavedReminderTime()
        }
    }
    
    
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text("설정")
                    .font(.system(size: 34, weight: .black))
                Spacer()
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
                title: "이름 변경",
                showDivider: true
            ) {
                // 도메인에는 편집값 초기화만 맡기고
                settingBoard.startRenaming()
                // 시트 표시 여부는 View 상태로 관리
                isShowingRenameSheet = true
            }
            
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
                value: settingBoard.formattedReminderTime(),
                showDivider: false
            ) {
                showingReminderPicker = true
            }
            .sheet(isPresented: $showingReminderPicker) {
                reminderPickerSheet
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
                isShowingPrivacyPolicy = true
            }
            .navigationDestination(isPresented: $isShowingPrivacyPolicy) {
                PrivacyPolicyView()
            }
            
            SettingRow(
                iconName: "doc.text.fill",
                iconBackground: Color.green,
                title: "라이센스 정보",
                showDivider: true
            ){
                isShowingLicenseInfo = true
            }
            .navigationDestination(isPresented: $isShowingLicenseInfo) {
                LicenseInfoView()
            }
            
            SettingRow(
                iconName: "book.fill",
                iconBackground: Color.blue.opacity(0.8),
                title: "이용 약관",
                showDivider: false
            ){
                isShowingTermsOfService = true
            }
            .navigationDestination(isPresented: $isShowingTermsOfService) {
                TermsOfServiceView()
            }
        }
    }
    
    private var dataDeletionSection: some View {
        SettingSection {
            SettingRow(
                iconName: "trash.fill",
                iconBackground: Color.red.opacity(0.85),
                title: "데이터 삭제",
                titleColor: .red,
                showDivider: false
            ) {
                isShowingDataDeletionAlert = true
            }
        }
    }
    
    private var reminderPickerSheet: some View {
        NavigationStack {
            VStack(spacing: 16) {
                DatePicker(
                    "알림 시간",
                    selection: $selectedDate,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .onAppear {
                    selectedDate = settingBoard.reminderTime
                }
                .onChange(of: selectedDate, initial: false) { oldDate, newDate in
                    settingBoard.reminderTime = newDate
                    settingBoard.persistReminderTime()
                }
                
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
    
    private var renameSheet: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextField("새 이름을 입력하세요", text: $settingBoard.editingName)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($isRenameFieldFocused)
                
                Text("변경된 이름은 다음 대화부터 사용돼요.")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .navigationTitle("이름 변경")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") {
                        settingBoard.cancelRenaming()
                        isShowingRenameSheet = false
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("저장") {
                        Task {
                            await settingBoard.commitRename()
                            // 도메인에서 더 이상 sheet 상태를 모르므로
                            // 저장 후 sheet 닫기는 View에서 처리
                            isShowingRenameSheet = false
                        }
                    }
                    .disabled(isRenameSaveDisabled)
                }
            }
        }
        .presentationDetents([.height(200)])
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isRenameFieldFocused = true
            }
        }
    }
    
    private var isRenameSaveDisabled: Bool {
        let trimmed = settingBoard.editingName.trimmingCharacters(in: .whitespacesAndNewlines)
        let currentName = settingBoard.owner?.userName ?? ""
        return trimmed.isEmpty || trimmed == currentName
    }
}

struct SettingRow: View {
    var iconName: String
    var iconBackground: Color
    var title: String
    var subtitle: String? = nil
    var titleColor: Color = .primary
    var showDivider: Bool
    var action: () -> Void = {}
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: action) {
                HStack(spacing: 16) {
                    SettingIcon(systemName: iconName, background: iconBackground)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .foregroundColor(titleColor)
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
                .contentShape(Rectangle())
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
                .contentShape(Rectangle())
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


// MARK: Preview
#Preview {
    let mentory = MentoryiOS()
    mentory.userName = "지석"
    let board = SettingBoard(owner: mentory)
    board.updateReminderTime(.now)
    
    return SettingBoardView(settingBoard: board)
}
