//
//  AgentDetailCard.swift
//  Her Lives
//
//  Quick detail card for selected agent
//

import SwiftUI

struct AgentDetailCard: View {
    @ObservedObject var agent: Agent
    @Binding var isExpanded: Bool
    @State private var showFullDetails = false
    @AppStorage("appLanguage") private var language: String = "en"
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.top, 8)
                .padding(.bottom, 12)
            
            // Header
            HStack(alignment: .top, spacing: 12) {
                // Avatar with ASCII art
                VStack(spacing: 4) {
                    Text("╔═══╗")
                        .font(.system(.caption, design: .monospaced))
                    Text("║ \(agent.name.initials) ║")
                        .font(.system(.caption, design: .monospaced))
                        .bold()
                    Text("╚═══╝")
                        .font(.system(.caption, design: .monospaced))
                }
                .foregroundColor(agent.personality.primaryColor)
                
                // Complete info
                VStack(alignment: .leading, spacing: 6) {
                    Text(agent.name)
                        .font(.headline)
                    
                    Text(language == "en" ? 
                         "\(agent.age) years • \(agent.profession ?? "Exploring")" :
                         "\(agent.age) 岁 • \(agent.profession ?? "探索中")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Consciousness state
                    HStack(spacing: 4) {
                        Text(language == "en" ? "State:" : "状态:")
                            .font(.caption)
                        Text(agent.consciousness.state.rawValue)
                            .font(.caption)
                            .bold()
                    }
                    
                    // Mood
                    HStack(spacing: 4) {
                        Text(language == "en" ? "Mood:" : "心情:")
                            .font(.caption)
                        Text(agent.mood.currentMood)
                            .font(.caption)
                            .bold()
                    }
                    
                    // Current action
                    if let action = agent.currentAction {
                        HStack(spacing: 4) {
                            Text(language == "en" ? "Doing:" : "正在:")
                                .font(.caption)
                            Text(action.description)
                                .font(.caption)
                                .italic()
                                .lineLimit(1)
                        }
                    }
                }
                
                Spacer()
                
                // Actions
                VStack(spacing: 8) {
                    Button(action: { showFullDetails = true }) {
                        Text("ⓘ")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: { isExpanded.toggle() }) {
                        Text(isExpanded ? "▼" : "▲")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal)
            
            // Inner voice in ASCII box
            if !agent.innerVoice.isEmpty {
                VStack(spacing: 2) {
                    Text("┌" + String(repeating: "─", count: 40) + "┐")
                        .font(.system(.caption, design: .monospaced))
                    Text("│ \(agent.innerVoice)".padding(toLength: 41, withPad: " ", startingAt: 0) + "│")
                        .font(.system(.caption, design: .monospaced))
                        .italic()
                    Text("└" + String(repeating: "─", count: 40) + "┘")
                        .font(.system(.caption, design: .monospaced))
                }
                .foregroundColor(.secondary)
                .padding(.horizontal)
                .padding(.top, 8)
            }
            
            // Expanded content with ASCII
            if isExpanded {
                VStack(spacing: 8) {
                    Text(String(repeating: "═", count: 50))
                        .font(.system(.caption, design: .monospaced))
                    
                    // Quick stats in ASCII
                    VStack(alignment: .leading, spacing: 4) {
                        Text(language == "en" ? "[STATS]" : "[统计]")
                            .font(.system(.caption, design: .monospaced))
                            .bold()
                        
                        HStack(spacing: 15) {
                            Text("♥ \(language == "en" ? "Mood" : "心情"): \(agent.mood.currentMood)")
                                .font(.system(.caption, design: .monospaced))
                            Text("☺ \(language == "en" ? "Friends" : "朋友"): \(agent.friendCount)")
                                .font(.system(.caption, design: .monospaced))
                            Text("◉ \(language == "en" ? "Focus" : "专注"): \(String(format: "%.1f", agent.cognitiveOrchestra.currentLoad))")
                                .font(.system(.caption, design: .monospaced))
                            Text("★ \(language == "en" ? "Goals" : "目标"): \(agent.goals.count)")
                                .font(.system(.caption, design: .monospaced))
                        }
                    }
                    
                    // Current activity
                    if let action = agent.currentAction {
                        CurrentActivityView(action: action)
                    }
                    
                    // Recent thoughts
                    if !agent.cognitiveOrchestra.activeThoughts.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(language == "en" ? "Current Thoughts" : "当前想法")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            ForEach(agent.cognitiveOrchestra.activeThoughts.prefix(3), id: \.self) { thought in
                                HStack {
                                    Image(systemName: "bubble.left")
                                        .font(.system(size: 10))
                                        .foregroundColor(.blue.opacity(0.5))
                                    Text(thought)
                                        .font(.caption)
                                        .lineLimit(1)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(UIColor.tertiarySystemBackground))
                        )
                    }
                    
                    // Emotion details
                    EmotionDetailRow(emotion: agent.emotion)
                    
                    // Recent memories
                    if !agent.memoryStream.stream.isEmpty {
                        RecentMemoriesRow(memories: Array(agent.memoryStream.stream.suffix(3)))
                    }
                    
                    // Relationships preview
                    if !agent.relationships.isEmpty {
                        RelationshipsPreview(relationships: Array(agent.relationships.values.prefix(3)))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .bottom).combined(with: .opacity)
                ))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.systemBackground))
                .shadow(radius: 10)
        )
        .animation(.spring(), value: isExpanded)
        .sheet(isPresented: $showFullDetails) {
            AgentDetailView(agent: agent)
        }
    }
    
    var moodColor: Color {
        switch agent.mood.currentMood.lowercased() {
        case "happy", "joyful", "content", "positive":
            return .green
        case "sad", "depressed", "melancholy", "negative":
            return .red
        case "angry", "frustrated", "irritated":
            return .orange
        case "anxious", "worried", "fearful":
            return .purple
        default:
            return .yellow
        }
    }
}

// MARK: - Supporting Views

struct QuickStat: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 14, weight: .semibold))
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct CurrentActivityView: View {
    let action: PlannedAction
    @AppStorage("appLanguage") private var language: String = "en"
    
    var body: some View {
        HStack {
            Image(systemName: iconForAction)
                .font(.system(size: 14))
                .foregroundColor(.blue)
                .frame(width: 30, height: 30)
                .background(
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(language == "en" ? "Current Activity" : "当前活动")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(action.description)
                    .font(.subheadline)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Duration indicator
            if action.duration > 0 {
                Text("\(action.duration) min")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.gray.opacity(0.1))
                    )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.tertiarySystemBackground))
        )
    }
    
    var iconForAction: String {
        switch action.type {
        case .work: return "briefcase.fill"
        case .socialize: return "person.2.fill"
        case .reflect: return "brain"
        case .move: return "figure.walk"
        case .rest: return "bed.double.fill"
        case .eat: return "fork.knife"
        default: return "circle.fill"
        }
    }
}

struct EmotionDetailRow: View {
    let emotion: Emotion
    @AppStorage("appLanguage") private var language: String = "en"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(language == "en" ? "Emotional State" : "情绪状态")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                // Dominant emotion
                VStack {
                    Image(systemName: emotionIcon(for: emotion.dominantFeeling))
                        .font(.system(size: 20))
                        .foregroundColor(emotion.color)
                    Text(emotion.dominantFeeling.rawValue)
                        .font(.caption)
                }
                
                // Emotion values
                VStack(alignment: .leading, spacing: 4) {
                    EmotionBar(label: "Valence", value: emotion.valence, color: emotion.valence > 0 ? .green : .red)
                    EmotionBar(label: "Arousal", value: emotion.arousal, color: .orange)
                    EmotionBar(label: "Intensity", value: emotion.intensity, color: .purple)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.tertiarySystemBackground))
        )
    }
    
    private func emotionIcon(for emotionType: EmotionType) -> String {
        switch emotionType {
        case .happy: return "face.smiling"
        case .sad: return "cloud.rain"
        case .angry: return "flame"
        case .fearful: return "exclamationmark.triangle"
        case .surprised: return "exclamationmark.bubble"
        case .disgusted: return "hand.thumbsdown"
        case .neutral: return "minus.circle"
        }
    }
}

struct EmotionBar: View {
    let label: String
    let value: Float
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption2)
                .frame(width: 50, alignment: .leading)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(abs(value)), height: 4)
                }
            }
            .frame(height: 4)
            
            Text(String(format: "%.1f", value))
                .font(.caption2)
                .foregroundColor(.secondary)
                .frame(width: 30)
        }
    }
}

struct RecentMemoriesRow: View {
    let memories: [Memory]
    @AppStorage("appLanguage") private var language: String = "en"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(language == "en" ? "Recent Memories" : "最近记忆")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ForEach(memories) { memory in
                HStack {
                    Image(systemName: memory.type.icon)
                        .font(.system(size: 10))
                        .foregroundColor(memory.type.color)
                        .frame(width: 20)
                    
                    Text(memory.content)
                        .font(.caption)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(memory.timeAgo)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.tertiarySystemBackground))
        )
    }
}

struct RelationshipsPreview: View {
    let relationships: [Relationship]
    @AppStorage("appLanguage") private var language: String = "en"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(language == "en" ? "Key Relationships" : "关键关系")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                ForEach(relationships) { relationship in
                    VStack {
                        Circle()
                            .fill(relationship.stageColor.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text(String(format: "%.1f", relationship.closeness))
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            )
                        
                        Text(relationship.stage)
                            .font(.caption2)
                            .lineLimit(1)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.tertiarySystemBackground))
        )
    }
    
    private func emotionIcon(for emotionType: EmotionType) -> String {
        switch emotionType {
        case .happy: return "face.smiling"
        case .sad: return "face.dashed"
        case .angry: return "face.dashed.fill"
        case .fearful: return "face.dashed"
        case .surprised: return "face.dashed"
        case .disgusted: return "face.dashed"
        case .neutral: return "face.dashed"
        }
    }
}