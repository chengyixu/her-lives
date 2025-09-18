//
//  MissingViews.swift
//  Her Lives
//
//  Additional view components
//

import SwiftUI

// MARK: - Agent List View
struct AgentListView: View {
    @EnvironmentObject var gameWorld: LivingWorld
    @State private var selectedAgent: Agent?
    @AppStorage("appLanguage") private var language: String = "en"
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(gameWorld.agents) { agent in
                    HStack {
                    Circle()
                        .fill(agent.personality.primaryColor)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(agent.name.prefix(2))
                                .foregroundColor(.white)
                        )
                    
                    VStack(alignment: .leading) {
                        Text(agent.name)
                            .font(.headline)
                        Text(language == "en" ? 
                             "\(agent.age) years • \(agent.profession ?? "Exploring")" :
                             "\(agent.age) 岁 • \(agent.profession ?? "探索中")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedAgent = agent
                }
                }
            }
            .padding()
        }
        .sheet(item: $selectedAgent) { agent in
            AgentDetailView(agent: agent)
        }
    }
}

// MARK: - Memory Stream View
struct MemoryStreamView: View {
    @EnvironmentObject var gameWorld: LivingWorld
    @State private var selectedAgent: Agent?
    @AppStorage("appLanguage") private var language: String = "en"
    
    var body: some View {
        ScrollView {
            if let agent = selectedAgent ?? gameWorld.agents.first {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(agent.memoryStream.stream.suffix(50).reversed()) { memory in
                        MemoryRow(memory: memory)
                    }
                }
                .padding()
            } else {
                Text(language == "en" ? "No agents available" : "没有可用的智能体")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
            }
        }
    }
}

struct MemoryRow: View {
    let memory: Memory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: memory.type.icon)
                    .foregroundColor(memory.type.color)
                Text(memory.timeAgo)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            Text(memory.content)
                .font(.callout)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

// MARK: - Relationship Network View
struct RelationshipNetworkView: View {
    @EnvironmentObject var gameWorld: LivingWorld
    @AppStorage("appLanguage") private var language: String = "en"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                relationshipsList
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private var relationshipsList: some View {
        ForEach(Array(gameWorld.agents.enumerated()), id: \.offset) { index, agent in
            agentRelationshipCard(for: agent)
        }
    }
    
    @ViewBuilder
    private func agentRelationshipCard(for agent: Agent) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Agent name header
            HStack {
                Text("◆ \(agent.name)")
                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                Spacer()
                Text("\(agent.relationships.count) \(language == "en" ? "connections" : "联系")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 4)
            
            if agent.relationships.isEmpty {
                Text(language == "en" ? "No relationships yet" : "暂无关系")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(agent.relationships.values.sorted(by: { $0.closeness > $1.closeness }).prefix(5)) { relationship in
                        HStack(spacing: 8) {
                            Text("•")
                                .font(.system(size: 12, design: .monospaced))
                            
                            Text(getAgentName(relationship.otherAgentId))
                                .font(.system(size: 13, design: .default))
                                .frame(minWidth: 100, alignment: .leading)
                            
                            Spacer()
                            
                            // Relationship strength bar
                            HStack(spacing: 2) {
                                ForEach(0..<10) { i in
                                    Rectangle()
                                        .fill(i < Int(relationship.closeness * 10) ? Color.green : Color.gray.opacity(0.3))
                                        .frame(width: 8, height: 12)
                                }
                            }
                            
                            Text("\(Int(relationship.closeness * 100))%")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.secondary)
                                .frame(width: 35, alignment: .trailing)
                        }
                    }
                    
                    if agent.relationships.count > 5 {
                        Text("... \(language == "en" ? "and" : "还有") \(agent.relationships.count - 5) \(language == "en" ? "more" : "个")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 2)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
    
    func getAgentName(_ id: UUID) -> String {
        gameWorld.agents.first { $0.id == id }?.name ?? (language == "en" ? "Unknown" : "未知")
    }
}

// RelationshipBar is already defined in WorldStatsView.swift

// MARK: - Culture Evolution View
struct CultureEvolutionView: View {
    @EnvironmentObject var gameWorld: LivingWorld
    @AppStorage("appLanguage") private var language: String = "en"
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                    // Cultural Memes
                    GroupBox(label: Label(language == "en" ? "Active Memes" : "活跃模因", systemImage: "sparkles")) {
                        ForEach(gameWorld.culturalSystem.activeMemes) { meme in
                            HStack {
                                Circle()
                                    .fill(meme.isPositive ? Color.green : Color.orange)
                                    .frame(width: 10, height: 10)
                                Text(meme.content)
                                    .font(.caption)
                                Spacer()
                                Text(language == "en" ? "\(meme.carriers.count) carriers" : "\(meme.carriers.count) 载体")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Beliefs
                    GroupBox(label: Label(language == "en" ? "Collective Beliefs" : "集体信念", systemImage: "brain")) {
                        VStack(alignment: .leading) {
                            Text(gameWorld.culturalSystem.collectiveBelief.description)
                                .font(.caption)
                            HStack {
                                Text("[")
                                ForEach(0..<10, id: \.self) { i in
                                    Text(i < Int(gameWorld.culturalSystem.collectiveBelief.consensus * 10) ? "█" : "░")
                                        .font(.system(.caption, design: .monospaced))
                                }
                                Text("]")
                                Text("\(Int(gameWorld.culturalSystem.collectiveBelief.consensus * 100))%")
                                    .font(.caption)
                            }
                        }
                    }
            }
            .padding()
        }
    }
}

// MARK: - Game Control Bar (removed - functionality moved to top bar)
// Language toggle is now in GameTopBar

// MARK: - Timeline View
struct TimelineView: View {
    @EnvironmentObject var gameWorld: LivingWorld
    @AppStorage("appLanguage") private var language: String = "en"
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Recent Events
                LazyVStack(spacing: 12) {
                    ForEach(Array(gameWorld.worldEvents.suffix(50).enumerated().reversed()), id: \.1.id) { index, event in
                        TimelineEventRow(event: event)
                    }
                }
            }
            .padding()
        }
    }
}

struct TimelineEventRow: View {
    let event: WorldEvent
    
    var body: some View {
        HStack(alignment: .top) {
            Circle()
                .fill(eventColor)
                .frame(width: 12, height: 12)
                .padding(.top, 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.description)
                    .font(.body)
                Text(event.timestamp.formatted)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
    
    private var eventColor: Color {
        switch event.type {
        case .socialInteraction: return .blue
        case .birthday: return .purple
        case .celebration: return .yellow
        case .conflict: return .red
        case .achievement: return .green
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @EnvironmentObject var gameWorld: LivingWorld
    @Environment(\.dismiss) private var dismiss
    @AppStorage("appLanguage") private var language: String = "en"
    @State private var autoSave = true
    @State private var soundEnabled = true
    @State private var notificationsEnabled = true
    
    init() {
        // Default initializer for SwiftUI
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(language == "en" ? "Game Settings" : "游戏设置") {
                    Toggle(language == "en" ? "Auto-Save" : "自动保存", isOn: $autoSave)
                    Toggle(language == "en" ? "Sound Effects" : "音效", isOn: $soundEnabled)
                    Toggle(language == "en" ? "Notifications" : "通知", isOn: $notificationsEnabled)
                }
                
                Section(language == "en" ? "World Settings" : "世界设置") {
                    HStack {
                        Text(language == "en" ? "Agent Count" : "智能体数量")
                        Spacer()
                        Text("\(gameWorld.agents.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text(language == "en" ? "World Size" : "世界大小")
                        Spacer()
                        Text("1000x1000")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(language == "en" ? "About" : "关于") {
                    HStack {
                        Text(language == "en" ? "Version" : "版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Button(language == "en" ? "Reset World" : "重置世界") {
                        gameWorld.reset()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle(language == "en" ? "Settings" : "设置")
            .navigationBarItems(trailing:
                Button(language == "en" ? "Done" : "完成") {
                    dismiss()
                }
            )
        }
    }
}