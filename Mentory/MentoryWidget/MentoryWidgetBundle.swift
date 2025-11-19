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
        MentoryWidget()
        MentoryWidgetControl()
        MentoryWidgetLiveActivity()
    }
}
