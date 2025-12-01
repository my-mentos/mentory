//
//  SettingBoardView.swift
//  Mentory
//
//  Created by SJS on 11/17/25.
//
import SwiftUI
import WebKit
import OSLog
import Combine
import UserNotifications

// MARK: Object
class SettingBoardViewModel: ObservableObject {
    // MARK: core
    
    // MARK: state
    
    @Published var isShowingInformationView = false
    
    @Published var selectedDate: Date = Date()
    @Published var isShowingEditingNameSheet = false
    @Published var isShowingReminderPickerSheet = false
    
    @Published var isShowingPrivacyPolicyView = false
    @Published var isShowingLicenseInfoView = false
    @Published var isShowingTermsOfServiceView = false
    
    @Published var isShowingDataDeletionAlert = false
    @Published var notificationStatusText: String = "요청 전"
    
    // MARK: action
    func onAppear(settingBoard: SettingBoard) async {
        settingBoard.loadSavedReminderTime()
        await refreshNotificationStatus()
    }
    
    func refreshNotificationStatus() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            notificationStatusText = "ON"
        case .denied:
            notificationStatusText = "OFF"
        case .notDetermined:
            notificationStatusText = "요청 전"
        @unknown default:
            notificationStatusText = "-"
        }
    }
    
    func didTapReminderStatus(settingBoard: SettingBoard) async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        
        switch settings.authorizationStatus {
        case .notDetermined:
            // 아직 권한 요청 안했으면 팝업을 띄움
            if let reminderCenter = settingBoard.owner?.reminderCenter {
                await reminderCenter.requestAuthorizationIfNeeded()
            }
            await refreshNotificationStatus()
            
        case .denied, .authorized, .provisional, .ephemeral:
            openAppSettings()
            
        @unknown default:
            break
        }
    }
    
    // MARK: 설정 앱 이동
    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}


// MARK: View
struct SettingBoardView: View {
    // MARK: core
    @ObservedObject var settingBoard: SettingBoard
    @ObservedObject var settingBoardViewModel: SettingBoardViewModel
    
    nonisolated let logger = Logger(subsystem: "MentoryiOS.SettingBoardView", category: "Presentation")
    
    
    // MARK: body
    var body: some View {
        NavigationStack {
            ZStack {
                Color.mentoryBackground
                    .ignoresSafeArea()
                
                // 화면에 보이는 Row들
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        HeaderRow
                        SettingSection {
                            EditingNameRow
                            AppSettingsRow
                            ReminderStatusRow
                            ReminderTimeRow
                        }
                        SettingSection {
                            PrivacyPolicyRow
                            LicenseInfoRow
                            TermsOfServiceRow
                        }
                        SettingSection {
                            DataDeletionRow
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 28)
                }
            }
            .task {
                await settingBoardViewModel.onAppear(settingBoard: settingBoard)
            }
        }
    }
    
    
    // MARK: ViewBuilder 모음
    @ViewBuilder
    private var HeaderRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text("설정")
                    .font(.system(size: 34, weight: .black))
                Spacer()
            }
            Text((settingBoard.owner?.getGreetingText())!)
                .font(.system(size: 20, weight: .bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    settingBoardViewModel.isShowingInformationView = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .padding(8)
                            .background(
                                Color.mentorySubCard.opacity(0.9),
                                in: Circle()
                            )
                }
            }
        }
        .sheet(isPresented: $settingBoardViewModel.isShowingInformationView) {
            WebView(url: settingBoard.owner!.informationURL)
        }
    }
    
    @ViewBuilder
    private var EditingNameRow: some View {
        SettingRow(
            iconName: "person.text.rectangle",
            iconBackground: Color.orange,
            title: "이름 변경",
            showDivider: false
        ) {
            Task {
                settingBoard.setUpEditingName()
                settingBoardViewModel.isShowingEditingNameSheet = true
            }
        }
        .sheet(isPresented: $settingBoardViewModel.isShowingEditingNameSheet, onDismiss: {
            Task {
                await settingBoard.editingName?.cancel()
            }
        }) {
            EditingNameSheet(editingName: settingBoard.editingName!)
        }
    }
    
    @ViewBuilder
    private var AppSettingsRow: some View {
        SettingRow(
            iconName: "app.badge.fill",
            iconBackground: Color.blue,
            title: "앱 설정",
            showDivider: false
        ) {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url)
        }
    }
    
    @ViewBuilder
    private var ReminderStatusRow: some View {
        SettingValueRow(
            iconName: "bell.fill",
            iconBackground: .red,
            title: "알림 상태",
            value: settingBoardViewModel.notificationStatusText,
            showDivider: false
        ) {
            Task {
                await settingBoardViewModel.didTapReminderStatus(settingBoard: settingBoard)
            }
        }
    }
    
    
    
    @ViewBuilder
    private var ReminderTimeRow: some View {
        SettingValueRow(
            iconName: "clock.fill",
            iconBackground: Color.purple,
            title: "알림 시간",
            value: settingBoard.formattedReminderTime(),
            showDivider: false
        ) {
            settingBoardViewModel.isShowingReminderPickerSheet = true
        }
        .sheet(isPresented: $settingBoardViewModel.isShowingReminderPickerSheet) {
            ReminderPickerSheet
        }
    }
    
    @ViewBuilder
    private var PrivacyPolicyRow: some View {
        SettingRow(
            iconName: "lock.fill",
            iconBackground: Color.gray,
            title: "개인정보 처리 방침",
            showDivider: false
        ) {
            settingBoardViewModel.isShowingPrivacyPolicyView = true
        }
        .navigationDestination(isPresented: $settingBoardViewModel.isShowingPrivacyPolicyView) {
            PrivacyPolicyView()
        }
    }
    
    @ViewBuilder
    private var LicenseInfoRow: some View {
        SettingRow(
            iconName: "doc.text.fill",
            iconBackground: Color.green,
            title: "라이센스 정보",
            showDivider: false
        ) {
            settingBoardViewModel.isShowingLicenseInfoView = true
        }
        .navigationDestination(isPresented: $settingBoardViewModel.isShowingLicenseInfoView) {
            LicenseInfoView()
        }
    }
    
    @ViewBuilder
    private var TermsOfServiceRow: some View {
        SettingRow(
            iconName: "book.fill",
            iconBackground: Color.blue.opacity(0.8),
            title: "이용 약관",
            showDivider: false
        ) {
            settingBoardViewModel.isShowingTermsOfServiceView = true
        }
        .navigationDestination(isPresented: $settingBoardViewModel.isShowingTermsOfServiceView) {
            TermsOfServiceView()
        }
    }
    
    @ViewBuilder
    private var DataDeletionRow: some View {
        SettingRow(
            iconName: "trash.fill",
            iconBackground: Color.red.opacity(0.85),
            title: "데이터 삭제",
            titleColor: .red,
            showDivider: false
        ) {
            settingBoardViewModel.isShowingDataDeletionAlert = true
        }
        .alert(
            "데이터를 삭제하시겠습니까?",
            isPresented: $settingBoardViewModel.isShowingDataDeletionAlert,
            actions: {
                Button("삭제", role: .destructive) {
                    logger.debug("데이터 삭제 기능 구현 예정")
                }
                Button("취소", role: .cancel) {
                    logger.debug("데이터 삭제 취소 구현 예정")
                }
            },
            message: {
                Text("삭제를 누르면 멘토리 데이터가 모두 제거됩니다.")
            }
        )
    }
    
    // 알림시간설정시트
    private var ReminderPickerSheet: some View {
        NavigationStack {
            VStack(spacing: 16) {
                DatePicker(
                    "알림 시간",
                    selection: $settingBoardViewModel.selectedDate,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .onAppear {
                    settingBoardViewModel.selectedDate = settingBoard.reminderTime
                }
                .onChange(of: settingBoardViewModel.selectedDate, initial: false) { oldDate, newDate in
                    settingBoard.changeReminderTime(to: newDate)
                }
                
                Button("완료") {
                    settingBoardViewModel.isShowingReminderPickerSheet = false
                }
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.mentorySubCard))
                )
            }
            .padding()
            .navigationTitle("알림 설정")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") {
                        settingBoardViewModel.isShowingReminderPickerSheet = false
                    }
                }
            }
        }
        .presentationDetents([.height(320)])
    }
}

// MARK: SettingBoard Components
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
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
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
                    .tint(.mentoryAccentPrimary)
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
                        .foregroundColor(.secondary)
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
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
struct SettingSection<Content: View>: View {
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        LiquidGlassCard {
            VStack(spacing: 0) {
                content()
            }
        }
    }
}




// MARK: Preview
fileprivate struct SettingBoardPreview: View {
    @StateObject var mentoryiOS = MentoryiOS()
    
    var body: some View {
        if let settingBoard = mentoryiOS.settingBoard {
            SettingBoardView(settingBoard: settingBoard, settingBoardViewModel: SettingBoardViewModel())
        } else {
            ProgressView("프리뷰 준비 중")
                .task {
                    mentoryiOS.setUp()
                    
                    let onboarding = mentoryiOS.onboarding!
                    onboarding.nameInput = "김철수"
                    onboarding.next()
                }
        }
    }
}
#Preview {
    SettingBoardPreview()
}
