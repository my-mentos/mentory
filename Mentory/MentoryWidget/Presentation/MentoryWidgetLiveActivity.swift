//
//  MentoryWidgetLiveActivity.swift
//  MentoryWidget
//
//  Created by SJS on 11/19/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct MentoryWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct MentoryWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MentoryWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension MentoryWidgetAttributes {
    fileprivate static var preview: MentoryWidgetAttributes {
        MentoryWidgetAttributes(name: "World")
    }
}

extension MentoryWidgetAttributes.ContentState {
    fileprivate static var smiley: MentoryWidgetAttributes.ContentState {
        MentoryWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: MentoryWidgetAttributes.ContentState {
         MentoryWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: MentoryWidgetAttributes.preview) {
   MentoryWidgetLiveActivity()
} contentStates: {
    MentoryWidgetAttributes.ContentState.smiley
    MentoryWidgetAttributes.ContentState.starEyes
}
