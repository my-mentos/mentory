//
//  MentoryWidgetBundle.swift
//  MentoryWidget
//
//  Created by SJS on 11/19/25.
//

import WidgetKit
import SwiftUI

@main
struct MentoryWidgetBundle: WidgetBundle {
    var body: some Widget {
        MentoryWidget()              // 기존 일기 위젯 :contentReference[oaicite:0]{index=0}
        MentoryWidgetLiveActivity()  // 기존 Live Activity
        MentoryActionWidget()        // ✅ 오늘의 추천행동 위젯
    }
}
