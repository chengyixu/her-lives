//
//  AgentDetailView.swift
//  Her Lives
//
//  Detailed view of an individual agent's inner life
//

import SwiftUI
import Charts

struct AgentDetailView: View {
    @ObservedObject var agent: Agent
    @EnvironmentObject var gameWorld: LivingWorld
    @AppStorage("appLanguage") private var language: String = "en"
    @State private var selectedTab = 0
    @State private var showFullMemory = false
    @State private var selectedMemory: Memory?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Agent Header
                    AgentHeaderView(agent: agent)
                    
                    // Tab Selection
                    Picker(language == "en" ? "View" : "查看", selection: $selectedTab) {
                        Label(language == "en" ? "Mind" : "心智", systemImage: "brain").tag(0)
                        Label(language == "en" ? "Heart" : "情感", systemImage: "heart.fill").tag(1)
                        Label(language == "en" ? "Memory" : "记忆", systemImage: "memories").tag(2)
                        Label(language == "en" ? "Social" : "社交", systemImage: "person.3.fill").tag(3)
                        Label(language == "en" ? "Goals" : "目标", systemImage: "target").tag(4)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Tab Content
                    Group {
                        switch selectedTab {
                        case 0:
                            MindView(agent: agent)
                        case 1:
                            HeartView(agent: agent)
                        case 2:
                            MemoryView(agent: agent, selectedMemory: $selectedMemory)
                        case 3:
                            SocialView(agent: agent)
                        case 4:
                            GoalsView(agent: agent)
                        default:
                            EmptyView()
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(UIColor.secondarySystemBackground))
                    )
                    .padding(.horizontal)
                }
            }
            .navigationTitle(agent.name)
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(item: $selectedMemory) { memory in
            MemoryDetailView(memory: memory, agent: agent)
        }
    }
}

// MARK: - Agent Header
struct AgentHeaderView: View {
    @ObservedObject var agent: Agent
    @AppStorage("appLanguage") private var language: String = "en"
    
    var body: some View {
        VStack(spacing: 15) {
            // Agent Avatar
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [agent.personality.primaryColor, agent.personality.secondaryColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 120, height: 120)
                
                Text(agent.name.initials)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Basic Info
            VStack(spacing: 5) {
                Text(agent.name)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(language == "en" ? "\(agent.age) years old • \(agent.profession ?? "Exploring life")" : "\(agent.age) 岁 • \(agent.profession ?? "探索生活")") 
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Current State
                HStack {
                    StateIndicator(
                        icon: agent.consciousness.icon,
                        text: agent.consciousness.description,
                        color: agent.consciousness.color
                    )
                    
                    StateIndicator(
                        icon: "heart.fill",
                        text: agent.emotion.dominantFeeling.rawValue,
                        color: agent.emotion.color
                    )
                }
                .padding(.top, 5)
            }
            
            // Inner Voice
            if !agent.innerVoice.isEmpty {
                Text("\"\(agent.innerVoice)\"")
                    .font(.callout)
                    .italic()
                    .foregroundColor(.secondary)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(UIColor.tertiarySystemBackground))
                    )
                    .padding(.horizontal)
            }
        }
        .padding()
    }
}

// MARK: - Mind View (Cognitive State)
struct MindView: View {
    @ObservedObject var agent: Agent
    @AppStorage("appLanguage") private var language: String = "en"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(language == "en" ? "Cognitive State" : "认知状态")
                .font(.headline)
            
            // Consciousness Level
            ConsciousnessIndicator(consciousness: agent.consciousness)
            
            // Current Thoughts
            VStack(alignment: .leading, spacing: 10) {
                Text(language == "en" ? "Current Thoughts" : "当前思考")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                ForEach(agent.cognitiveOrchestra.activeThoughts, id: \.self) { thought in
                    ThoughtBubble(thought: thought)
                }
            }
            
            // Recent Reflections
            if !agent.reflection.recentReflections.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recent Reflections")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ForEach(agent.reflection.recentReflections.prefix(3)) { systemReflection in
                        ReflectionCard(reflection: CoreReflection(
                            id: systemReflection.id,
                            timestamp: Date(),
                            question: "What patterns do I see?",
                            insight: systemReflection.insights.first?.content ?? systemReflection.summary,
                            evidence: systemReflection.memories,
                            confidence: systemReflection.insights.first?.confidence ?? 0.5,
                            abstractionLevel: systemReflection.depth,
                            emotionalTone: systemReflection.emotionalTone
                        ))
                    }
                }
            }
            
            // Cognitive Load
            CognitiveLoadMeter(load: agent.cognitiveOrchestra.currentLoad)
        }
    }
}

// MARK: - Heart View (Emotional State)
struct HeartView: View {
    @ObservedObject var agent: Agent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Emotional Landscape")
                .font(.headline)
            
            // Emotion Wheel
            EmotionWheel(emotion: agent.emotion)
                .frame(height: 200)
            
            // Mood Trajectory
            MoodChart(moodHistory: agent.mood.history)
                .frame(height: 150)
            
            // Values
            VStack(alignment: .leading, spacing: 10) {
                Text("Core Values")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                ForEach(agent.values.topValues, id: \.name) { value in
                    ValueBar(value: value)
                }
            }
        }
    }
}

// MARK: - Memory View
struct MemoryView: View {
    @ObservedObject var agent: Agent
    @Binding var selectedMemory: Memory?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Memory Statistics
            HStack {
                MemoryStat(label: "Total", value: "\(agent.memoryStream.stream.count)")
                MemoryStat(label: "Short-term", value: "\(agent.memoryStream.shortTerm.count)")
                MemoryStat(label: "Long-term", value: "\(agent.memoryStream.longTerm.count)")
                MemoryStat(label: "Reflections", value: "\(agent.memoryStream.reflections.count)")
            }
            
            Text("Memory Stream")
                .font(.headline)
            
            // Recent Memories
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(agent.memoryStream.stream.suffix(20).reversed()) { memory in
                        MemoryCard(memory: memory)
                            .onTapGesture {
                                selectedMemory = memory
                            }
                    }
                }
            }
            .frame(maxHeight: 400)
        }
    }
}

// MARK: - Social View
struct SocialView: View {
    @ObservedObject var agent: Agent
    @EnvironmentObject var gameWorld: LivingWorld
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Relationships")
                .font(.headline)
            
            // Relationship List
            ForEach(agent.relationships.values.sorted(by: { $0.closeness > $1.closeness })) { relationship in
                RelationshipRow(relationship: relationship, world: gameWorld)
            }
            
            // Social Metrics
            HStack {
                SocialMetric(icon: "person.3.fill", label: "Friends", value: "\(agent.friendCount)")
                SocialMetric(icon: "heart.fill", label: "Close", value: "\(agent.closeRelationshipCount)")
                SocialMetric(icon: "star.fill", label: "Reputation", value: String(format: "%.1f", agent.reputation))
            }
            .padding(.top)
            
            // Cultural Identity
            if !agent.carriedMemes.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Cultural Memes")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ForEach(agent.carriedMemes.prefix(5)) { meme in
                        MemeTag(meme: meme)
                    }
                }
            }
        }
    }
}

// MARK: - Goals View
struct GoalsView: View {
    @ObservedObject var agent: Agent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Aspirations & Plans")
                .font(.headline)
            
            // Current Action
            if let action = agent.currentAction {
                CurrentActionCard(action: action)
            }
            
            // Daily Plan
            if let plan = agent.dailyPlan {
                DailyPlanView(plan: CoreDailyPlan(
                    goals: plan.goals,
                    scheduledActions: plan.timeBlocks.map { timeBlock in
                        let actionType: Action.ActionType
                        let description: String
                        
                        switch timeBlock.activity {
                        case .work:
                            actionType = .work
                            description = "Working"
                        case .socialize:
                            actionType = .socialize
                            description = "Socializing"
                        case .routine(let routineDesc):
                            actionType = .rest
                            description = routineDesc
                        case .personal:
                            actionType = .reflect
                            description = "Personal time"
                        case .explore:
                            actionType = .move
                            description = "Exploring"
                        }
                        
                        return Action(
                            type: actionType,
                            description: description,
                            target: nil,
                            targetAgent: nil,
                            content: nil,
                            importance: timeBlock.priority,
                            duration: TimeInterval(timeBlock.duration * 60)
                        )
                    },
                    priority: 0.5
                ))
            }
            
            // Goals
            VStack(alignment: .leading, spacing: 10) {
                Text("Active Goals")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                ForEach(agent.goals.sorted(by: { $0.priority > $1.priority })) { goal in
                    GoalRow(goal: goal)
                }
            }
            
            // Desires
            if !agent.desires.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Deep Desires")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ForEach(agent.desires.prefix(3)) { desire in
                        DesireCard(desire: desire)
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct StateIndicator: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(text)
                .font(.caption)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(color.opacity(0.2))
        )
    }
}

struct ThoughtBubble: View {
    let thought: String
    
    var body: some View {
        Text(thought)
            .font(.callout)
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.blue.opacity(0.1))
            )
    }
}

struct MemoryCard: View {
    let memory: Memory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: memory.type.icon)
                    .foregroundColor(memory.type.color)
                
                Text(memory.timeAgo)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Importance indicator
                ForEach(0..<Int(memory.importance * 5), id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.yellow)
                }
            }
            
            Text(memory.content)
                .font(.callout)
                .lineLimit(2)
            
            // Emotional tone
            if abs(memory.emotionalValence) > 0.1 {
                HStack {
                    Image(systemName: memory.emotionalValence > 0 ? "face.smiling" : "face.frowning")
                        .font(.caption)
                    Text(String(format: "%.1f", abs(memory.emotionalValence)))
                        .font(.caption)
                }
                .foregroundColor(memory.emotionalValence > 0 ? .green : .red)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.tertiarySystemBackground))
        )
    }
}

struct RelationshipRow: View {
    let relationship: Relationship
    let world: LivingWorld
    
    var body: some View {
        HStack {
            // Other agent's avatar
            Circle()
                .fill(Color.blue.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(getOtherAgentName().initials)
                        .font(.caption)
                )
            
            VStack(alignment: .leading) {
                Text(getOtherAgentName())
                    .font(.subheadline)
                
                // Relationship dimensions
                HStack(spacing: 10) {
                    RelationshipDimension(icon: "heart", value: relationship.dimensions.affection)
                    RelationshipDimension(icon: "shield", value: relationship.dimensions.trust)
                    RelationshipDimension(icon: "star", value: relationship.dimensions.respect)
                }
            }
            
            Spacer()
            
            // Relationship stage
            Text(relationship.stage.capitalized)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(relationship.stageColor.opacity(0.2))
                )
        }
        .padding(.vertical, 5)
    }
    
    func getOtherAgentName() -> String {
        if let agent = world.agents.first(where: { $0.id == relationship.otherAgentId }) {
            return agent.name
        }
        return "Unknown"
    }
}

struct RelationshipDimension: View {
    let icon: String
    let value: Float
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(String(format: "%.1f", value))
                .font(.caption)
        }
        .foregroundColor(colorForValue(value))
    }
    
    func colorForValue(_ value: Float) -> Color {
        if value > 0.7 { return .green }
        if value > 0.3 { return .yellow }
        return .red
    }
}

// MARK: - Missing View Definitions

// Minimal implementations for compilation
struct MemoryDetailView: View {
    let memory: Memory
    let agent: Agent
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text(memory.content)
                    .font(.body)
                
                HStack {
                    Text("Type: \(memory.type.rawValue)")
                    Spacer()
                    Text(memory.timeAgo)
                        .foregroundColor(.secondary)
                }
                
                if memory.emotionalValence != 0 {
                    Text("Emotional Impact: \(String(format: "%.1f", memory.emotionalValence))")
                        .foregroundColor(memory.emotionalValence > 0 ? .green : .red)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Memory Detail")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ConsciousnessIndicator: View {
    let consciousness: ConsciousnessState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Consciousness State")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: consciousness.icon)
                    .foregroundColor(consciousness.color)
                Text(consciousness.description)
                    .font(.callout)
                Spacer()
                
                // Alertness meter
                ProgressView(value: consciousness.alertnessLevel, total: 1.0)
                    .frame(width: 60)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

struct ReflectionCard: View {
    let reflection: CoreReflection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(reflection.question)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(reflection.insight)
                .font(.callout)
            
            HStack {
                Text("Confidence: \(String(format: "%.1f", reflection.confidence))")
                    .font(.caption2)
                Spacer()
                Text(reflection.timestamp.formatted())
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.purple.opacity(0.1))
        )
    }
}

struct CognitiveLoadMeter: View {
    let load: Float
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Cognitive Load")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                ProgressView(value: load, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: loadColor))
                
                Text("\(Int(load * 100))%")
                    .font(.caption)
                    .foregroundColor(loadColor)
            }
            
            Text(loadDescription)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
    
    private var loadColor: Color {
        if load > 0.8 { return .red }
        if load > 0.6 { return .orange }
        if load > 0.4 { return .yellow }
        return .green
    }
    
    private var loadDescription: String {
        if load > 0.8 { return "High load - may affect performance" }
        if load > 0.6 { return "Moderate load - functioning well" }
        if load > 0.4 { return "Light load - plenty of capacity" }
        return "Minimal load - highly available"
    }
}

struct EmotionWheel: View {
    let emotion: EmotionState
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Emotional State")
                .font(.headline)
            
            // Dominant emotion display
            VStack {
                Circle()
                    .fill(emotion.color.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .overlay(
                        VStack {
                            Text(emotion.dominantFeeling.rawValue.capitalized)
                                .font(.caption)
                                .fontWeight(.bold)
                            Text(String(format: "%.1f", emotion.intensity))
                                .font(.caption2)
                        }
                    )
                
                Text(emotion.description)
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
            
            // Basic emotion levels
            VStack(alignment: .leading, spacing: 8) {
                EmotionBar(label: "Happiness", value: emotion.happiness, color: .green)
                EmotionBar(label: "Sadness", value: emotion.sadness, color: .blue)
                EmotionBar(label: "Anger", value: emotion.anger, color: .red)
                EmotionBar(label: "Fear", value: emotion.fear, color: .purple)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

// MARK: - Additional Missing Views

struct MoodChart: View {
    let moodHistory: [String] // Simplified for now
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mood Trajectory")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Rectangle()
                .fill(Color.blue.opacity(0.3))
                .frame(height: 80)
                .overlay(
                    Text("Mood chart visualization")
                        .font(.caption)
                        .foregroundColor(.secondary)
                )
        }
    }
}

struct ValueBar: View {
    let value: (name: String, strength: Float) // Simplified structure
    
    var body: some View {
        HStack {
            Text(value.name)
                .font(.caption)
            Spacer()
            ProgressView(value: value.strength, total: 1.0)
                .frame(width: 100)
            Text(String(format: "%.1f", value.strength))
                .font(.caption2)
        }
        .padding(.vertical, 2)
    }
}

struct MemoryStat: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.headline)
                .foregroundColor(.primary)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.tertiarySystemBackground))
        )
    }
}

struct SocialMetric: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.tertiarySystemBackground))
        )
    }
}

struct MemeTag: View {
    let meme: CulturalMeme
    
    var body: some View {
        Text(meme.content)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(meme.isPositive ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
            )
            .foregroundColor(meme.isPositive ? .green : .orange)
    }
}

struct CurrentActionCard: View {
    let action: Action
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Current Action")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: actionIcon)
                    .foregroundColor(.blue)
                Text(action.description)
                    .font(.callout)
                Spacer()
            }
            
            if let narrative = action.mentalNarrative {
                Text("\"\(narrative)\"")
                    .font(.caption)
                    .italic()
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.blue.opacity(0.1))
        )
    }
    
    private var actionIcon: String {
        switch action.type {
        case .move: return "figure.walk"
        case .speak: return "bubble.right"
        case .work: return "briefcase"
        case .rest: return "bed.double"
        case .eat: return "fork.knife"
        case .socialize: return "person.2"
        case .reflect: return "brain"
        case .create: return "paintbrush"
        case .observe: return "eye"
        case .remember: return "memories"
        }
    }
}

struct DailyPlanView: View {
    let plan: CoreDailyPlan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Daily Plan")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ForEach(plan.scheduledActions.prefix(5), id: \.id) { action in
                HStack {
                    Image(systemName: "circle")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text(action.description)
                        .font(.callout)
                    Spacer()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

struct GoalRow: View {
    let goal: Goal
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(goal.description)
                    .font(.callout)
                
                ProgressView(value: goal.progress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .frame(height: 4)
            }
            
            Spacer()
            
            VStack {
                Text(String(format: "%.0f%%", goal.progress * 100))
                    .font(.caption)
                Text("Priority: \(String(format: "%.1f", goal.priority))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.tertiarySystemBackground))
        )
    }
}

struct DesireCard: View {
    let desire: Desire
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(desire.category.rawValue.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(categoryColor.opacity(0.2))
                    )
                    .foregroundColor(categoryColor)
                
                Spacer()
                
                // Intensity indicator
                ForEach(0..<Int(desire.intensity * 5), id: \.self) { _ in
                    Image(systemName: "heart.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.red)
                }
            }
            
            Text(desire.content)
                .font(.callout)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(categoryColor.opacity(0.1))
        )
    }
    
    private var categoryColor: Color {
        switch desire.category {
        case .belonging: return .blue
        case .achievement: return .green
        case .autonomy: return .orange
        case .purpose: return .purple
        case .pleasure: return .pink
        }
    }
}

// MARK: - Extensions
extension String {
    var initials: String {
        self.components(separatedBy: " ")
            .compactMap { $0.first }
            .map { String($0) }
            .joined()
    }
}