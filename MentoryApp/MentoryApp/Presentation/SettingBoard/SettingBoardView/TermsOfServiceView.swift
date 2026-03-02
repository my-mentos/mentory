//
//  TermsOfServiceView.swift
//  Mentory
//
//  Created by SJS on 11/17/25.
//

import SwiftUI

struct TermsOfServiceView: View {
    private let sections: [TermsSection] = [
        .init(
            title: "1. 약관의 효력 및 변경",
            lines: [
                "• 본 약관은 서비스 내에 게시하여 이용자에게 공지함으로써 효력이 발생합니다.",
                "• 팀은 관련 법령을 위반하지 않는 범위에서 약관을 변경할 수 있습니다.",
                "• 약관을 변경할 경우 변경 최소 7일 전에 앱 내 공지 또는 화면을 통해 안내합니다.",
                "• 변경 약관 공지 후 사용자가 서비스를 계속 이용하면 변경된 약관에 동의한 것으로 간주합니다."
            ]
        ),
        .init(
            title: "2. 서비스의 제공",
            lines: [
                "• 팀은 다음 기능을 제공합니다.",
                "  - 감정 기록 기능(텍스트/사진/음성)",
                "  - 감정 분석 및 감정 변화 패턴 제공",
                "  - AI 기반 사고 리프레이밍 제안",
                "  - 사용자 맞춤형 알림 및 리마인더",
                "  - 통계·리포트 제공",
                "  - 기타 팀이 추가 개발하여 제공하는 기능"
            ]
        ),
        .init(
            title: "3. 서비스 이용 조건",
            lines: [
                "• 사용자는 만 14세 이상이어야 합니다.",
                "• 일부 기능은 카메라, 사진, 마이크 등 디바이스 권한이 필요할 수 있으며 미허용 시 기능이 제한될 수 있습니다.",
                "• 서비스 이용 과정에서 안정적인 네트워크 환경이 필요합니다."
            ]
        ),
        .init(
            title: "4. 이용자의 의무",
            lines: [
                "• 다음 행위를 해서는 안 됩니다.",
                "  - 허위 정보 입력 또는 타인의 개인정보 도용",
                "  - 앱의 기능을 악용하거나 비정상적으로 이용하는 행위",
                "  - 불법적·유해한 콘텐츠 업로드",
                "  - 팀 또는 제3자의 지식재산권 침해",
                "  - 서비스 운영을 방해하는 자동화 도구/해킹 시도",
                "  - 관련 법령 또는 공공질서에 위반되는 행위",
                "• 위반 시 팀은 서비스 이용을 제한하거나 필요한 조치를 취할 수 있습니다."
            ]
        ),
        .init(
            title: "5. 서비스의 변경 및 중단",
            lines: [
                "• 팀은 서비스의 내용 또는 제공 방식을 변경할 수 있습니다.",
                "• 아래의 경우 서비스 전체 또는 일부를 일시 또는 영구 중단할 수 있습니다.",
                "  - 서비스 개선 및 점검",
                "  - 기술적 문제 발생",
                "  - 천재지변 등 불가항력",
                "• 서비스 중단 시 사전에 안내하며, 긴급한 경우 사후 안내할 수 있습니다."
            ]
        ),
        .init(
            title: "6. 콘텐츠 저작권 및 이용권",
            lines: [
                "• 사용자가 입력한 감정 기록(텍스트/사진/음성)의 권리는 이용자에게 있습니다.",
                "• 이용자는 팀이 아래 목적을 위해 이를 비식별·익명 형태로 사용할 수 있음에 동의합니다.",
                "  - 감정 분석 및 AI 기능 제공",
                "  - 서비스 개선 및 기능 개발",
                "  - 통계·연구 목적",
                "• 서비스가 제공하는 AI 분석 결과 및 콘텐츠의 저작권은 팀 또는 해당 권리자에게 있습니다.",
                "• 이용자는 팀의 사전 허락 없이 앱 내 콘텐츠를 무단 복제·배포할 수 없습니다."
            ]
        ),
        .init(
            title: "7. 면책 조항",
            lines: [
                "• 팀은 아래 사항에 대해 책임을 지지 않습니다.",
                "  - 이용자의 부주의로 인해 발생한 계정 또는 데이터 유출",
                "  - 이용자의 기기 환경 또는 네트워크 문제로 발생한 장애",
                "  - 이용자가 앱 내 AI 분석 결과를 근거로 의사결정을 하여 발생한 결과",
                "  - 본 서비스는 의료 서비스가 아니며 정신건강 전문가의 진단 또는 치료를 대신하지 않습니다."
            ]
        ),
        .init(
            title: "8. 서비스 이용 제한",
            lines: [
                "• 다음 사유가 발생하면 팀은 이용자의 서비스 이용을 제한할 수 있습니다.",
                "  - 약관 위반",
                "  - 비정상적 사용 패턴 또는 과도한 요청",
                "  - 자동화 도구 또는 스크래핑 이용",
                "  - 악성 콘텐츠 업로드",
                "• 사유가 해소될 경우 서비스 재이용이 가능할 수 있습니다."
            ]
        ),
        .init(
            title: "9. 개인정보 보호",
            lines: [
                "• 개인정보 수집·이용·보관·파기 등 모든 절차는 별도로 제공하는 개인정보 처리방침에 따릅니다."
            ]
        ),
        .init(
            title: "10. 계약 해지 및 데이터 삭제",
            lines: [
                "• 사용자는 언제든지 서비스 내에서 데이터 초기화 또는 탈퇴를 요청할 수 있습니다.",
                "• 팀은 이용자의 요청이 확인되면 관련 법령에 따라 데이터를 즉시 삭제합니다."
            ]
        ),
        .init(
            title: "11. 분쟁 해결",
            lines: [
                "• 서비스 이용 중 발생한 분쟁은 이용자와 팀이 협의하여 해결합니다.",
                "• 협의가 어려울 경우 대한민국 법령에 따릅니다."
            ]
        ),
        .init(
            title: "12. 고객 지원",
            lines: [
                "• 서비스 관련 문의는 아래 이메일로 연락할 수 있습니다.",
                "  - 이메일:",
                "  - 운영 주체: Mentory 팀"
            ]
        )
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                ForEach(sections) { section in
                    TermsSectionView(section: section)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("이용 약관")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mentory – 이용약관")
                .font(.title2.bold())
            Text("최종 업데이트: 2025. 11. 18")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("본 약관은 Mentory 팀(이하 \"팀\")이 제공하는 Mentory 앱(이하 \"서비스\")의 이용과 관련하여 팀과 이용자 간의 권리, 의무 및 책임사항을 규정하는 것을 목적으로 합니다.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
}

private struct TermsSectionView: View {
    let section: TermsSection

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(section.title)
                .font(.headline)
            VStack(alignment: .leading, spacing: 6) {
                ForEach(section.lines, id: \.self) { line in
                    Text(line)
                        .font(line.hasPrefix("•") || line.hasPrefix("  -") ? .body : .subheadline)
                        .foregroundStyle(line.hasPrefix("•") || line.hasPrefix("  -") ? Color.primary : Color.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct TermsSection: Identifiable {
    let title: String
    let lines: [String]

    var id: String { title }
}
