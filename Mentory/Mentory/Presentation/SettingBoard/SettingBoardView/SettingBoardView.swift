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
    // MARK: action
    
    
    // MARK: value
    
}


// MARK: View
struct SettingBoardView: View {
    @ObservedObject var settingBoard: SettingBoard
    @ObservedObject var settingBoardViewModel: SettingBoardViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 1) 배경
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                // 2) 화면에 보이는 Row들
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        HeaderRow
                        SettingSection {
                            EditingNameRow
                            AppSettingsRow
                            ReminderToggleRow
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
        }
        .modifier(LoadSavedReminderTime(dm: settingBoard))
        
        .modifier(HeaderActionModifier(vm: settingBoardViewModel, dm: settingBoard))
        .modifier(EditingNameActionMofiier(vm: settingBoardViewModel, dm: settingBoard))
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
                }
            }
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
    }
    
    @ViewBuilder
    private var AppSettingsRow: some View {
        SettingRow(
            iconName: "app.badge.fill",
            iconBackground: Color.blue,
            title: "앱 설정",
            showDivider: false
        ) {}
    }
    
    @ViewBuilder
    private var ReminderToggleRow: some View {
        SettingToggleRow(
            iconName: "bell.fill",
            iconBackground: Color.red,
            title: "알림 설정",
            isOn: $settingBoard.isReminderOn,
            showDivider: false
        )
        
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
    }
    
    
    
    // MARK: Modifier 모음
    struct HeaderActionModifier: ViewModifier {
        @ObservedObject var vm: SettingBoardViewModel
        let dm: SettingBoard
        
        func body(content: Content) -> some View {
            content
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            vm.isShowingInformationView = true
                        } label: {
                            Image(systemName: "info.circle")
                        }
                    }
                }
                .sheet(isPresented: $vm.isShowingInformationView) {
                    WebView(url: dm.owner!.informationURL)
                }
        }
    }
    
    struct EditingNameActionMofiier: ViewModifier {
        @ObservedObject var vm: SettingBoardViewModel
        let dm: SettingBoard
        
        func body(content: Content) -> some View {
            content
                .sheet(isPresented: $vm.isShowingEditingNameSheet, onDismiss: {
                    Task {
                        await dm.editingName?.cancel()
                    }
                }) {
                    EditingNameSheet(editingName: dm.editingName!)
                }
        }
    }
    
    struct ReminderTimeActionModifier: ViewModifier {
        @ObservedObject var vm: SettingBoardViewModel
        let dm: SettingBoard
        
        func body(content: Content) -> some View {
            content
                .sheet(isPresented: $vm.isShowingReminderPickerSheet) {
                    //ReminderPickerSheet
                }
        }
    }
    
    struct PrivacyPolicyActionModifier: ViewModifier {
        @ObservedObject var vm: SettingBoardViewModel
        func body(content: Content) -> some View {
            content
                .navigationDestination(isPresented: $vm.isShowingPrivacyPolicyView) {
                    PrivacyPolicyView()
                }
        }
    }
    
    struct LicenseInfoActionModifier: ViewModifier {
        @ObservedObject var vm: SettingBoardViewModel
        func body(content: Content) -> some View {
            content
                .navigationDestination(isPresented: $vm.isShowingLicenseInfoView) {
                    LicenseInfoView()
                }
        }
    }
    
    struct TermsOfServiceActionModifier: ViewModifier {
        @ObservedObject var vm: SettingBoardViewModel
        func body(content: Content) -> some View {
            content
                .navigationDestination(isPresented: $vm.isShowingTermsOfServiceView) {
                    TermsOfServiceView()
                }
        }
    }
    
    struct DataDeletionActionModifier: ViewModifier {
        @ObservedObject var vm: SettingBoardViewModel
        let dm: SettingBoard
        func body(content: Content) -> some View {
            content
                .alert(
                    "데이터를 삭제하시겠습니까?",
                    isPresented: $vm.isShowingDataDeletionAlert,
                    actions: {
                        Button("삭제", role: .destructive) {
                            dm.confirmDataDeletion()
                        }
                        Button("취소", role: .cancel) {
                        }
                    },
                    message: {
                        Text("삭제를 누르면 멘토리 데이터가 모두 제거됩니다.")
                    }
                )
        }
    }
    
    struct LoadSavedReminderTime: ViewModifier {
        let dm: SettingBoard
        func body(content: Content) -> some View {
            content
                .task {
                    dm.loadSavedReminderTime()
                }
        }
    }
    
    
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
                    settingBoard.reminderTime = newDate
                    settingBoard.applyChangedReminderTime()
                }
                
                Button("완료") {
                    settingBoardViewModel.isShowingReminderPickerSheet = false
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
