//
//  WorldStatsView.swift
//  Her Lives
//
//  Displays world statistics and metrics
//

import SwiftUI

struct WorldStatsView: View {
    @EnvironmentObject var gameWorld: LivingWorld
    @AppStorage("appLanguage") private var language: String = "en"
    @State private var showDetailedStats = false
    
    var body: some View {
        HStack(spacing: 20) {
            Spacer()
            
            // Happiness
            StatCard(
                icon: "heart.fill",
                label: language == "en" ? "Happiness" : "幸福度",
                value: String(format: "%.1f", averageHappiness),
                color: happinessColor
            )
            
            // Relationships
            StatCard(
                icon: "link",
                label: language == "en" ? "Connections" : "联系",
                value: "\(totalRelationships)",
                color: .purple
            )
            
            // Cultural Diversity
            StatCard(
                icon: "globe",
                label: language == "en" ? "Culture" : "文化",
                value: String(format: "%.1f", gameWorld.culturalSystem.culturalDiversity),
                color: .orange
            )
            
            // More stats button
            Button(action: { showDetailedStats.toggle() }) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: UIScreen.main.bounds.width * 0.035))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
        .sheet(isPresented: $showDetailedStats) {
            DetailedStatsView()
                .environmentObject(gameWorld)
        }
    }
    
    var averageHappiness: Float {
        guard !gameWorld.agents.isEmpty else { return 0 }
        let total = gameWorld.agents.reduce(into: 0) { result, agent in result += Float(agent.mood.currentMood == "happy" ? 1 : agent.mood.currentMood == "sad" ? -1 : 0) }
        return total / Float(gameWorld.agents.count)
    }
    
    var happinessColor: Color {
        if averageHappiness > 0.5 { return .green }
        if averageHappiness < -0.5 { return .red }
        return .yellow
    }
    
    var totalRelationships: Int {
        gameWorld.agents.reduce(0) { $0 + $1.relationships.count }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.system(size: UIScreen.main.bounds.width * 0.035))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: UIScreen.main.bounds.width * 0.04, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: UIScreen.main.bounds.width * 0.025))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

// MARK: - Detailed Stats View
struct DetailedStatsView: View {
    @EnvironmentObject var gameWorld: LivingWorld
    @Environment(\.dismiss) private var dismiss
    @AppStorage("appLanguage") private var language: String = "en"
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack {
                Picker(language == "en" ? "Stats Category" : "统计类别", selection: $selectedTab) {
                    Text(language == "en" ? "Overview" : "总览").tag(0)
                    Text(language == "en" ? "Social" : "社交").tag(1)
                    Text(language == "en" ? "Economic" : "经济").tag(2)
                    Text(language == "en" ? "Cultural" : "文化").tag(3)
                    Text(language == "en" ? "Emergence" : "涌现").tag(4)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                ScrollView {
                    switch selectedTab {
                    case 0:
                        OverviewStats()
                    case 1:
                        SocialStats()
                    case 2:
                        EconomicStats()
                    case 3:
                        CulturalStats()
                    case 4:
                        EmergenceStats()
                    default:
                        EmptyView()
                    }
                }
            }
            .navigationTitle(language == "en" ? "World Statistics" : "世界统计")
            .navigationBarItems(
                trailing: Button(language == "en" ? "Done" : "完成") {
                    dismiss()
                }
            )
        }
    }
}

// MARK: - Overview Stats
struct OverviewStats: View {
    @EnvironmentObject var gameWorld: LivingWorld
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Population Demographics
            GroupBox(label: Label("Population", systemImage: "person.3")) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Total Agents:")
                        Spacer()
                        Text("\(gameWorld.agents.count)")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Average Age:")
                        Spacer()
                        Text("\(Int(gameWorld.agents.reduce(0) { $0 + $1.age } / gameWorld.agents.count))")
                            .fontWeight(.semibold)
                    }
                    
                    // Age distribution
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Age Distribution:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 5) {
                            ForEach(ageGroups, id: \.0) { group, count in
                                VStack {
                                    Rectangle()
                                        .fill(Color.blue.opacity(0.7))
                                        .frame(width: 30, height: CGFloat(count * 10))
                                    Text("\(group)")
                                        .font(.caption2)
                                }
                            }
                        }
                    }
                }
            }
            
            // Mood Overview
            GroupBox(label: Label("Emotional Climate", systemImage: "heart")) {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(emotionStats, id: \.0) { emotion, percentage in
                        HStack {
                            Text(emotion)
                            Spacer()
                            ProgressView(value: percentage, total: 100)
                                .frame(width: 150)
                            Text("\(Int(percentage))%")
                                .font(.caption)
                                .frame(width: 35, alignment: .trailing)
                        }
                    }
                }
            }
            
            // Activity Overview
            GroupBox(label: Label("Current Activities", systemImage: "figure.walk")) {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(activityStats, id: \.0) { activity, count in
                        HStack {
                            Image(systemName: activityIcon(for: activity))
                                .frame(width: 20)
                            Text(activity)
                            Spacer()
                            Text("\(count)")
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    var ageGroups: [(String, Int)] {
        let groups = [
            ("0-20", 0),
            ("21-40", 0),
            ("41-60", 0),
            ("60+", 0)
        ]
        
        var result = groups
        for agent in gameWorld.agents {
            if agent.age <= 20 {
                result[0].1 += 1
            } else if agent.age <= 40 {
                result[1].1 += 1
            } else if agent.age <= 60 {
                result[2].1 += 1
            } else {
                result[3].1 += 1
            }
        }
        return result
    }
    
    var emotionStats: [(String, Double)] {
        var stats: [String: Int] = [:]
        let total = gameWorld.agents.count
        
        for agent in gameWorld.agents {
            let emotion = String(describing: agent.emotion.dominantFeeling)
            stats[emotion, default: 0] += 1
        }
        
        return stats.map { ($0.key, Double($0.value) / Double(total) * 100) }
            .sorted { $0.1 > $1.1 }
    }
    
    var activityStats: [(String, Int)] {
        var stats: [String: Int] = [:]
        
        for agent in gameWorld.agents {
            let activity = agent.currentAction?.type.rawValue ?? "idle"
            stats[activity, default: 0] += 1
        }
        
        return stats.sorted { $0.1 > $1.1 }
    }
    
    func activityIcon(for activity: String) -> String {
        switch activity {
        case "work": return "briefcase"
        case "socialize": return "bubble.left.and.bubble.right"
        case "rest": return "bed.double"
        case "move": return "figure.walk"
        case "eat": return "fork.knife"
        default: return "circle"
        }
    }
}

// MARK: - Social Stats
struct SocialStats: View {
    @EnvironmentObject var gameWorld: LivingWorld
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Relationship Overview
            GroupBox(label: Label("Relationship Network", systemImage: "person.2")) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Total Relationships:")
                        Spacer()
                        Text("\(gameWorld.relationshipNetwork.getAllRelationships().count)")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Average Friends per Agent:")
                        Spacer()
                        Text(String(format: "%.1f", avgFriendsPerAgent))
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Most Connected:")
                        Spacer()
                        Text(mostConnectedAgent?.name ?? "None")
                            .fontWeight(.semibold)
                    }
                }
            }
            
            // Top Relationships
            GroupBox(label: Label("Strongest Bonds", systemImage: "heart.circle")) {
                VStack(alignment: .leading, spacing: 8) {
                    let topFive = Array(topRelationships.prefix(5))
                    ForEach(Array(topFive.enumerated()), id: \.offset) { index, relationship in
                        HStack {
                            Text("\(agentName(relationship.id)) & \(agentName(relationship.otherAgentId))")
                                .font(.caption)
                            Spacer()
                            RelationshipBar(strength: relationship.closeness)
                        }
                    }
                }
            }
            
            // Social Groups
            GroupBox(label: Label("Social Clusters", systemImage: "person.3")) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Detected \(socialClusters.count) social groups")
                        .font(.caption)
                    
                    ForEach(socialClusters.indices, id: \.self) { index in
                        HStack {
                            Circle()
                                .fill(Color.blue.opacity(0.7))
                                .frame(width: 10, height: 10)
                            Text("Group \(index + 1)")
                            Spacer()
                            Text("\(socialClusters[index].count) members")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    var avgFriendsPerAgent: Double {
        guard !gameWorld.agents.isEmpty else { return 0 }
        let total = gameWorld.agents.reduce(0) { $0 + $1.relationships.count }
        return Double(total) / Double(gameWorld.agents.count)
    }
    
    var mostConnectedAgent: Agent? {
        gameWorld.agents.max { $0.relationships.count < $1.relationships.count }
    }
    
    var topRelationships: [Relationship] {
        gameWorld.relationshipNetwork.getAllRelationships()
            .sorted { (r1, r2) in r1.closeness > r2.closeness }
    }
    
    var socialClusters: [[Agent]] {
        // Simple clustering based on mutual relationships
        var clusters: [[Agent]] = []
        var processed = Set<UUID>()
        
        for agent in gameWorld.agents {
            if !processed.contains(agent.id) {
                var cluster = [agent]
                processed.insert(agent.id)
                
                // Find agents with strong mutual relationships
                for relationship in agent.relationships.values {
                    if relationship.closeness > 0.6 {
                        if let other = gameWorld.agents.first(where: { $0.id == relationship.otherAgentId }),
                           !processed.contains(other.id) {
                            cluster.append(other)
                            processed.insert(other.id)
                        }
                    }
                }
                
                if cluster.count > 1 {
                    clusters.append(cluster)
                }
            }
        }
        
        return clusters.sorted { (c1, c2) in c1.count > c2.count }
    }
    
    func agentName(_ id: UUID) -> String {
        gameWorld.agents.first { $0.id == id }?.name.components(separatedBy: " ").first ?? "Unknown"
    }
}

struct RelationshipBar: View {
    let strength: Float
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: geometry.size.width, height: 8)
                    .cornerRadius(4)
                
                Rectangle()
                    .fill(barColor)
                    .frame(width: geometry.size.width * CGFloat(strength), height: 8)
                    .cornerRadius(4)
            }
        }
        .frame(width: 100, height: 8)
    }
    
    var barColor: Color {
        if strength > 0.7 { return .green }
        if strength > 0.4 { return .yellow }
        return .orange
    }
}

// MARK: - Economic Stats
struct EconomicStats: View {
    @EnvironmentObject var gameWorld: LivingWorld
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Economic Overview
            GroupBox(label: Label("Economy", systemImage: "chart.line.uptrend.xyaxis")) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Total Wealth:")
                        Spacer()
                        Text("\(Int(gameWorld.economicSystem.totalWealth))")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Professions:")
                        Spacer()
                        Text("\(gameWorld.economicSystem.professions.count)")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Economic Activity:")
                        Spacer()
                        Text("Basic")
                            .fontWeight(.semibold)
                    }
                }
            }
            
            // Professional Activity
            if !gameWorld.economicSystem.professions.isEmpty {
                GroupBox(label: Label("Professions", systemImage: "building.2")) {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(gameWorld.economicSystem.professions.prefix(5)) { profession in
                            HStack {
                                Text(profession.name)
                                    .font(.caption)
                                Spacer()
                                Text(profession.specialty)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            } else {
                Text("No professions available")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .padding()
    }
}

// MARK: - Cultural Stats
struct CulturalStats: View {
    @EnvironmentObject var gameWorld: LivingWorld
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Cultural Overview
            GroupBox(label: Label("Cultural Evolution", systemImage: "sparkles")) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Cultural Diversity:")
                        Spacer()
                        Text(String(format: "%.2f", gameWorld.culturalSystem.culturalDiversity))
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Active Memes:")
                        Spacer()
                        Text("\(gameWorld.culturalSystem.activeMemes.count)")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Collective Consensus:")
                        Spacer()
                        Text("\(Int(gameWorld.culturalSystem.collectiveBelief.consensus * 100))%")
                            .fontWeight(.semibold)
                    }
                }
            }
            
            // Top Memes
            if !gameWorld.culturalSystem.activeMemes.isEmpty {
                GroupBox(label: Label("Trending Ideas", systemImage: "bubble.left.and.bubble.right")) {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(gameWorld.culturalSystem.activeMemes.prefix(5)) { meme in
                            HStack {
                                Circle()
                                    .fill(meme.isPositive ? Color.green : Color.orange)
                                    .frame(width: 8, height: 8)
                                Text(meme.content)
                                    .font(.caption)
                                    .lineLimit(1)
                                Spacer()
                                Text("Carriers: \(meme.carriers.count)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            
            // Belief System
            GroupBox(label: Label("Collective Beliefs", systemImage: "brain")) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(gameWorld.culturalSystem.collectiveBelief.description)
                        .font(.caption)
                    
                    HStack {
                        Text("Strength:")
                        Spacer()
                        ConsensusBar(consensus: gameWorld.culturalSystem.collectiveBelief.consensus)
                    }
                }
            }
        }
        .padding()
    }
}

struct ConsensusBar: View {
    let consensus: Float
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<10) { i in
                Rectangle()
                    .fill(i < Int(consensus * 10) ? Color.green : Color.gray.opacity(0.3))
                    .frame(width: 20, height: 10)
            }
        }
    }
}

// MARK: - Emergence Stats
struct EmergenceStats: View {
    @EnvironmentObject var gameWorld: LivingWorld
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Emergence Overview
            GroupBox(label: Label("Emergent Phenomena", systemImage: "sparkle")) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Total Phenomena:")
                        Spacer()
                        Text("\(gameWorld.emergentPhenomena.count)")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Complexity Score:")
                        Spacer()
                        Text(String(format: "%.2f", complexityScore))
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Emergence Rate:")
                        Spacer()
                        Text("\(emergenceRate)/hour")
                            .fontWeight(.semibold)
                    }
                }
            }
            
            // Recent Phenomena
            if !gameWorld.emergentPhenomena.isEmpty {
                GroupBox(label: Label("Recent Emergences", systemImage: "clock")) {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(gameWorld.emergentPhenomena.suffix(5).reversed()) { phenomenon in
                            VStack(alignment: .leading, spacing: 5) {
                                Text(phenomenon.type.rawValue.capitalized)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                Text(phenomenon.description)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                HStack {
                                    Text("Impact: \(Int(phenomenon.significance * 100))%")
                                        .font(.caption2)
                                    Spacer()
                                    Text(phenomenon.timestamp.timeAgo)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                            Divider()
                        }
                    }
                }
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "sparkle")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    
                    Text("No emergent phenomena detected yet")
                        .foregroundColor(.secondary)
                    
                    Text("As agents interact, emergent behaviors will appear")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
        }
        .padding()
    }
    
    var complexityScore: Double {
        let agentCount = Double(gameWorld.agents.count)
        let relationshipCount = Double(gameWorld.totalRelationships)
        let memeCount = Double(gameWorld.culturalSystem.activeMemes.count)
        let phenomenaCount = Double(gameWorld.emergentPhenomena.count)
        
        return (agentCount * 0.2 + relationshipCount * 0.3 + memeCount * 0.2 + phenomenaCount * 0.3) / 10
    }
    
    var emergenceRate: Int {
        guard !gameWorld.emergentPhenomena.isEmpty else { return 0 }
        
        let hourAgo = Date().addingTimeInterval(-3600)
        let recentCount = gameWorld.emergentPhenomena.filter { phenomenon in
            phenomenon.timestamp > hourAgo
        }.count
        
        return recentCount
    }
}

// MARK: - Helper Extensions
extension GameTime {
    var timeAgo: String {
        let minutes = self.totalMinutes
        if minutes < 60 {
            return "\(minutes)m ago"
        }
        let hours = minutes / 60
        if hours < 24 {
            return "\(hours)h ago"
        }
        let days = hours / 24
        return "\(days)d ago"
    }
    
    var date: Date {
        Date().addingTimeInterval(-Double(totalMinutes) * 60)
    }
}

// Extensions removed - already defined elsewhere

// MARK: - Complexity Metrics
struct ComplexityMetrics: View {
    @EnvironmentObject var gameWorld: LivingWorld
    
    var body: some View {
        GroupBox(label: Label("System Complexity", systemImage: "network")) {
            VStack(alignment: .leading, spacing: 10) {
                MetricRow(label: "Network Density", value: networkDensity)
                MetricRow(label: "Cultural Entropy", value: culturalEntropy)
                MetricRow(label: "Economic Velocity", value: economicVelocity)
                MetricRow(label: "Social Cohesion", value: socialCohesion)
                
                Divider()
                
                HStack {
                    Text("Complexity Score")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Spacer()
                    Text(String(format: "%.2f", overallComplexity))
                        .fontWeight(.bold)
                }
            }
        }
    }
    
    var networkDensity: Double {
        let maxPossibleRelationships = gameWorld.agents.count * (gameWorld.agents.count - 1) / 2
        guard maxPossibleRelationships > 0 else { return 0 }
        return Double(gameWorld.totalRelationships) / Double(maxPossibleRelationships)
    }
    
    var culturalEntropy: Double {
        guard !gameWorld.culturalSystem.activeMemes.isEmpty else { return 0 }
        return min(1.0, Double(gameWorld.culturalSystem.activeMemes.count) / 20.0)
    }
    
    var economicVelocity: Double {
        guard gameWorld.economicSystem.totalWealth > 0 else { return 0 }
        return min(1.0, Double(gameWorld.economicSystem.professions.count) / 10.0)
    }
    
    var socialCohesion: Double {
        guard !gameWorld.agents.isEmpty else { return 0 }
        let avgRelationships = Double(gameWorld.totalRelationships) / Double(gameWorld.agents.count)
        return min(1.0, avgRelationships / 10.0)
    }
    
    var overallComplexity: Double {
        (networkDensity + culturalEntropy + economicVelocity + socialCohesion) / 4.0 * 10.0
    }
}

struct MetricRow: View {
    let label: String
    let value: Double
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
            Spacer()
            ProgressView(value: value, total: 1.0)
                .frame(width: 100)
            Text(String(format: "%.0f%%", value * 100))
                .font(.caption)
                .frame(width: 40, alignment: .trailing)
        }
    }
}