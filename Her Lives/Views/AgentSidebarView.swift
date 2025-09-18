//
//  AgentSidebarView.swift
//  Her Lives
//
//  Sidebar showing list of agents with quick stats
//

import SwiftUI

struct AgentSidebarView: View {
    @EnvironmentObject var gameWorld: LivingWorld
    @Binding var selectedAgent: Agent?
    @Binding var followingAgent: Agent?
    @State private var searchText = ""
    @State private var sortBy: SortOption = .name
    @State private var filterBy: FilterOption = .all
    @AppStorage("appLanguage") private var language: String = "en"
    
    enum SortOption: String, CaseIterable {
        case name = "Name"
        case mood = "Mood"
        case activity = "Activity"
        case relationships = "Relationships"
    }
    
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case awake = "Awake"
        case sleeping = "Sleeping"
        case happy = "Happy"
        case sad = "Sad"
        case working = "Working"
        case socializing = "Socializing"
    }
    
    var filteredAgents: [Agent] {
        let agents = gameWorld.agents.filter { agent in
            // Search filter
            if !searchText.isEmpty {
                return agent.name.localizedCaseInsensitiveContains(searchText)
            }
            return true
        }.filter { agent in
            // Category filter
            switch filterBy {
            case .all:
                return true
            case .awake:
                return agent.consciousness.state != .sleeping
            case .sleeping:
                return agent.consciousness.state == .sleeping
            case .happy:
                return agent.emotion.dominantFeeling == .happy
            case .sad:
                return agent.emotion.dominantFeeling == .sad
            case .working:
                return agent.currentAction?.type == .work
            case .socializing:
                return agent.currentAction?.type == .socialize
            }
        }
        
        // Sort
        return agents.sorted { (agent1: Agent, agent2: Agent) in
            switch sortBy {
            case .name:
                return agent1.name < agent2.name
            case .mood:
                return agent1.mood.currentMood > agent2.mood.currentMood
            case .activity:
                let a1 = agent1.currentAction?.description ?? "zzz"
                let a2 = agent2.currentAction?.description ?? "zzz"
                return a1 < a2
            case .relationships:
                return agent1.friendCount > agent2.friendCount
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField(language == "en" ? "Search agents..." : "搜索智能体...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(UIColor.tertiarySystemBackground))
                )
                
                // Filters
                HStack(spacing: 5) {
                    Menu {
                        ForEach(FilterOption.allCases, id: \.self) { option in
                            Button(action: { filterBy = option }) {
                                HStack {
                                    Text(option.rawValue)
                                    if filterBy == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: "line.horizontal.3.decrease.circle")
                                .font(.system(size: UIScreen.main.bounds.width * 0.03))
                            Text(filterBy.rawValue)
                                .font(.caption)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color(UIColor.secondarySystemBackground))
                        )
                    }
                    
                    Menu {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button(action: { sortBy = option }) {
                                HStack {
                                    Text(option.rawValue)
                                    if sortBy == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.system(size: 12))
                            Text(sortBy.rawValue)
                                .font(.caption)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color(UIColor.secondarySystemBackground))
                        )
                    }
                }
                
                Divider()
            }
            .padding()
            
            // Agent list
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(filteredAgents) { agent in
                        AgentRowView(
                            agent: agent,
                            isSelected: selectedAgent?.id == agent.id,
                            isFollowing: followingAgent?.id == agent.id
                        )
                        .onTapGesture {
                            withAnimation(.spring()) {
                                selectedAgent = agent
                            }
                        }
                        .contextMenu {
                            Button(action: {
                                followingAgent = followingAgent?.id == agent.id ? nil : agent
                            }) {
                                Label(
                                    followingAgent?.id == agent.id ? "Stop Following" : "Follow",
                                    systemImage: followingAgent?.id == agent.id ? "location.slash" : "location"
                                )
                            }
                            
                            Button(action: {
                                selectedAgent = agent
                            }) {
                                Label("View Details", systemImage: "person.text.rectangle")
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Footer stats - only show if following someone
            if let following = followingAgent {
                VStack(spacing: 5) {
                    Divider()
                    
                    HStack {
                        Spacer()
                        Label("Following \(following.name.components(separatedBy: " ").first ?? "")", systemImage: "location")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.systemBackground).opacity(0.95))
                .shadow(radius: 5)
        )
    }
}

// MARK: - Agent Row View
struct AgentRowView: View {
    @ObservedObject var agent: Agent
    let isSelected: Bool
    let isFollowing: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [agent.personality.primaryColor, agent.personality.secondaryColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 40, height: 40)
                
                Text(agent.name.initials)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                // Status indicator
                Circle()
                    .fill(statusColor)
                    .frame(width: 10, height: 10)
                    .offset(x: 15, y: 15)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: 10, height: 10)
                            .offset(x: 15, y: 15)
                    )
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(agent.name)
                        .font(.subheadline)
                        .fontWeight(isSelected ? .semibold : .regular)
                        .lineLimit(1)
                    
                    if isFollowing {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.blue)
                    }
                }
                
                // Current activity
                HStack(spacing: 4) {
                    Image(systemName: activityIcon)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    
                    Text(activityDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                // Mood and relationships
                HStack(spacing: 8) {
                    // Mood
                    HStack(spacing: 2) {
                        Image(systemName: moodIcon)
                            .font(.system(size: 10))
                        Text(String(format: "%.1f", agent.mood.currentMood))
                            .font(.caption)
                    }
                    .foregroundColor(moodColor)
                    
                    // Friends
                    HStack(spacing: 2) {
                        Image(systemName: "person.2")
                            .font(.system(size: 10))
                        Text("\(agent.friendCount)")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Selection indicator
            if isSelected {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        )
    }
    
    var statusColor: Color {
        switch agent.consciousness.state {
        case .sleeping:
            return .gray
        case .dreaming:
            return .purple
        case .awake:
            return .green
        case .drowsy:
            return .orange
        case .reflecting:
            return .blue
        case .meditating:
            return .indigo
        }
    }
    
    var activityIcon: String {
        guard let action = agent.currentAction else {
            return "moon.zzz"
        }
        
        switch action.type {
        case .work:
            return "briefcase"
        case .socialize:
            return "bubble.left.and.bubble.right"
        case .move:
            return "figure.walk"
        case .rest:
            return "bed.double"
        case .eat:
            return "fork.knife"
        default:
            return "circle"
        }
    }
    
    var activityDescription: String {
        if agent.consciousness.state == .sleeping {
            return "Sleeping"
        }
        return agent.currentAction?.description ?? "Idle"
    }
    
    var moodIcon: String {
        switch agent.emotion.dominantFeeling {
        case .happy:
            return "face.smiling"
        case .sad:
            return "face.frowning"
        case .angry:
            return "face.angry.fill"
        case .fearful:
            return "exclamationmark.triangle"
        case .surprised:
            return "exclamationmark.2"
        case .disgusted:
            return "hand.thumbsdown"
        case .neutral:
            return "circle"
        }
    }
    
    var moodColor: Color {
        // Since currentMood is a String, use emotion valence instead
        let moodValue = agent.emotion.valence
        if moodValue > 0.5 {
            return .green
        } else if moodValue < -0.5 {
            return .red
        } else {
            return .orange
        }
    }
}