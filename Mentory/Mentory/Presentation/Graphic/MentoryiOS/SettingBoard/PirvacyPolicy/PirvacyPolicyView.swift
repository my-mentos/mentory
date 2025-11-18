//
//  PirvacyPolicyView.swift
//  Mentory
//
//  Created by SJS on 11/17/25.
//

import SwiftUI

struct PrivacyPolicyView: View {
    private let sections: [PolicySection] = [
        .init(
            title: "1. 수집하는 개인정보 항목",
            lines: [
                "필수 수집 항목",
                "• 계정 정보: 닉네임(또는 사용자가 입력한 이름)",
                "• 감정 기록 데이터",
                "  - 텍스트 입력 내용",
                "  - 음성 입력 → 텍스트로 변환된 내용",
                "  - 사진 입력 시 사진에 포함된 텍스트 (사진 원본은 로컬 저장 또는 즉시 삭제 선택)",
                "• 앱 사용 정보",
                "  - 기록 작성 시간, 선택된 감정 값",
                "  - 기기 정보(모델명, OS 버전)",
                "  - 앱 오류 로그(Crash log)",
                "선택 수집 항목",
                "• 카메라·사진 접근 권한: 사진 기록 기능 사용 시",
                "• 마이크 접근 권한: 음성 입력 기능 사용 시",
                "※ 허용하지 않아도 기본 기능 이용 가능",
                "자동 수집 정보",
                "• 앱 기능 제공을 위한 최소한의 로그(비식별화)"
            ]
        ),
        .init(
            title: "2. 개인정보의 수집 및 이용 목적",
            lines: [
                "• 감정 기록·분석 기능 제공",
                "• 감정 변화 패턴 분석 및 리포트 제공",
                "• AI 기반 사고 리프레이밍 기능 제공",
                "• 고객 문의 처리 및 오류 대응",
                "• 개인 맞춤형 알림 제공",
                "• 서비스 품질 개선 및 기능 고도화",
                "• 법령에 따른 의무 준수"
            ]
        ),
        .init(
            title: "3. 개인정보 제3자 제공",
            lines: [
                "• 회사는 원칙적으로 이용자의 개인정보를 외부에 제공하지 않습니다.",
                "• 아래의 경우 예외적으로 제공될 수 있습니다.",
                "  - 이용자가 사전에 명시적으로 동의한 경우",
                "  - 법령에 따라 수사기관·정부 기관이 요청하는 경우"
            ]
        ),
        .init(
            title: "4. 개인정보 처리 위탁",
            lines: [
                "• OpenAI / Microsoft Azure: 텍스트 기반 감정 분석 및 AI 응답 생성 – 분석 후 즉시 삭제(비저장)",
                "• Apple: 앱 오류 분석 및 충돌 로그 제공 – iOS 정책에 따름",
                "※ 위탁 업체는 서비스 운영 사정에 따라 변경될 수 있으며, 변경 시 앱 내 공지를 통해 알립니다."
            ]
        ),
        .init(
            title: "5. 개인정보 보관 및 파기",
            lines: [
                "• 앱 삭제 시: 로컬 저장 데이터 즉시 파기",
                "• 회원 탈퇴 요청 시: 서버 저장 데이터 즉시 파기",
                "• 법령에 따른 예외 보관",
                "  - 서비스 이용 관련 기록: 6개월",
                "  - 소비자 분쟁 해결 기록: 3년",
                "파기 방법",
                "• 전자적 정보: 복구 불가능한 방식으로 영구 삭제",
                "• 오프라인 문서(필요 시): 분쇄 또는 소각"
            ]
        ),
        .init(
            title: "6. 이용자의 권리",
            lines: [
                "• 개인정보 열람·정정·삭제 요청",
                "• 개인정보 처리 정지 요구",
                "• 앱 내 데이터 초기화",
                "• 접근 권한 변경(iOS 설정 → Mentory)",
                "요청은 support@mentory.app로 가능하며, 회사는 지체 없이 처리합니다."
            ]
        ),
        .init(
            title: "7. 아동의 개인정보",
            lines: [
                "• 회사는 만 14세 미만 아동의 개인정보를 수집하지 않습니다.",
                "• 만 14세 미만 사용자의 가입이 확인될 경우 즉시 이용을 제한하고 데이터를 삭제합니다."
            ]
        ),
        .init(
            title: "8. 개인정보 보호를 위한 기술적·관리적 조치",
            lines: [
                "• 데이터 전송 구간 암호화(HTTPS/TLS)",
                "• 비식별화 및 최소 수집 원칙",
                "• 감정 기록에 대한 로컬 암호화",
                "• 접근 권한 최소화",
                "• 정기적 보안 점검 및 업데이트"
            ]
        ),
        .init(
            title: "9. 개인정보 보호책임자",
            lines: [
                "• 책임자: Mentory 팀",
                "• 이메일: support@mentory.app"
            ]
        ),
        .init(
            title: "10. 개인정보 처리방침 변경",
            lines: [
                "• 회사는 필요한 경우 개인정보 처리방침을 변경할 수 있습니다.",
                "• 중요 변경 사항은 앱 공지 또는 화면 내 안내를 통해 사전 고지합니다.",
                "• 공지 후 7일 경과 시 변경 내용이 적용됩니다."
            ]
        )
    ]

    private let warningText = """
    원본 음성 파일이나 사진은 서버에 저장하지 않으며,
    AI 분석을 위해 텍스트로 변환된 비식별화 데이터만 외부 API(OpenAI 등)에 전달됩니다.
    """

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                warningBox
                ForEach(sections) { section in
                    PolicySectionView(section: section)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("개인정보 처리방침")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mentory – 개인정보 처리방침")
                .font(.title2.bold())
            Text("최종 업데이트: 2025. 11. 28")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Mentory(이하 “회사”, “앱”)는 「개인정보보호법」, 「정보통신망법」 등 관련 법령을 준수하며, 사용자의 개인정보를 안전하게 관리하기 위하여 다음과 같이 개인정보 처리방침을 수립·공개합니다.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var warningBox: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.yellow)
                .font(.title3)
            Text(warningText)
                .font(.callout)
                .foregroundStyle(.primary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct PolicySectionView: View {
    let section: PolicySection

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

private struct PolicySection: Identifiable {
    let title: String
    let lines: [String]

    var id: String { title }
}
