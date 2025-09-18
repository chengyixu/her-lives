//
//  TimeControlView.swift
//  Her Lives
//
//  Minimal time HUD for the main world view.
//

import SwiftUI

struct TimeControlView: View {
    @EnvironmentObject var gameWorld: LivingWorld
    
    var body: some View {
        HStack(spacing: 12) {
            // Current time display - ALWAYS RUNNING, NO PAUSE
            VStack(alignment: .leading, spacing: 2) {
                Text(gameWorld.currentTime.timeString)
                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
                Text("Day \(gameWorld.currentTime.day)")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}
