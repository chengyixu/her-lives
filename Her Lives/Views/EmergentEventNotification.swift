//
//  EmergentEventNotification.swift
//  Her Lives
//
//  Notification banner for emergent phenomena
//

import SwiftUI
import Foundation

// MARK: - Date Extension
extension Date {
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

struct EmergentEventNotification: View {
    let event: EmergentPhenomenon
    @State private var isAnimating = false
    
    var body: some View {
        VStack {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: iconForType)
                        .font(.system(size: 20))
                        .foregroundColor(iconColor)
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Emergent Phenomenon")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        // Significance indicator
                        SignificanceIndicator(value: event.significance)
                    }
                    
                    Text(event.description)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                    
                    // Participants
                    HStack {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        
                        Text("\(event.participants.count) participants")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(typeLabel)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(iconColor.opacity(0.2))
                            )
                    }
                }
                
                // Close button
                Button(action: {}) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .strokeBorder(
                        LinearGradient(
                            colors: [iconColor, iconColor.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            
            Spacer()
        }
        .padding()
        .onAppear {
            isAnimating = true
        }
    }
    
    var iconForType: String {
        switch event.type {
        case .socialMovement:
            return "person.3.fill"
        case .culturalShift:
            return "globe.americas.fill"
        case .economicTrend:
            return "chart.line.uptrend.xyaxis"
        case .collectiveMood:
            return "heart.circle.fill"
        case .spontaneousOrganization:
            return "burst.fill"
        case .informationCascade:
            return "wave.3.forward"
        case .behavioralContagion:
            return "arrow.triangle.branch"
        @unknown default:
            return "questionmark.circle.fill"
        }
    }
    
    var iconColor: Color {
        switch event.type {
        case .socialMovement:
            return .blue
        case .culturalShift:
            return .purple
        case .economicTrend:
            return .green
        case .collectiveMood:
            return .pink
        case .spontaneousOrganization:
            return .orange
        case .informationCascade:
            return .cyan
        case .behavioralContagion:
            return .yellow
        @unknown default:
            return .gray
        }
    }
    
    var typeLabel: String {
        switch event.type {
        case .socialMovement:
            return "Social"
        case .culturalShift:
            return "Cultural"
        case .economicTrend:
            return "Economic"
        case .collectiveMood:
            return "Mood"
        case .spontaneousOrganization:
            return "Organization"
        case .informationCascade:
            return "Information"
        case .behavioralContagion:
            return "Behavior"
        @unknown default:
            return "Unknown"
        }
    }
}

// MARK: - Significance Indicator
struct SignificanceIndicator: View {
    let value: Float
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5) { index in
                Image(systemName: "star.fill")
                    .font(.system(size: 8))
                    .foregroundColor(
                        Float(index) < value * 5 ? .yellow : .gray.opacity(0.3)
                    )
            }
        }
    }
}

// MARK: - Emergent Event List View
struct EmergentEventListView: View {
    @EnvironmentObject var gameWorld: LivingWorld
    @State private var selectedEvent: EmergentPhenomenon?
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(gameWorld.emergentPhenomena.reversed()) { event in
                        EmergentEventRow(event: event)
                            .onTapGesture {
                                selectedEvent = event
                            }
                    }
                    
                    if gameWorld.emergentPhenomena.isEmpty {
                        EmptyStateView()
                    }
                }
                .padding()
            }
            .navigationTitle("Emergent Phenomena")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(item: $selectedEvent) { event in
            EmergentEventDetailView(event: event)
        }
    }
}

// MARK: - Event Row
struct EmergentEventRow: View {
    let event: EmergentPhenomenon
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: iconForType)
                .font(.system(size: 16))
                .foregroundColor(iconColor)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(iconColor.opacity(0.1))
                )
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(event.description)
                    .font(.subheadline)
                    .lineLimit(2)
                
                HStack {
                    // Time
                    Label(event.timestamp.timeAgo, systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Participants
                    Label("\(event.participants.count)", systemImage: "person.3")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Significance
                    SignificanceIndicator(value: event.significance)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
    
    var iconForType: String {
        switch event.type {
        case .socialMovement: return "person.3.fill"
        case .culturalShift: return "globe"
        case .economicTrend: return "chart.line.uptrend.xyaxis"
        case .collectiveMood: return "heart.circle"
        case .spontaneousOrganization: return "burst"
        case .informationCascade: return "wave.3.forward"
        case .behavioralContagion: return "arrow.triangle.branch"
        @unknown default: return "questionmark.circle"
        }
    }
    
    var iconColor: Color {
        switch event.type {
        case .socialMovement: return .blue
        case .culturalShift: return .purple
        case .economicTrend: return .green
        case .collectiveMood: return .pink
        case .spontaneousOrganization: return .orange
        case .informationCascade: return .cyan
        case .behavioralContagion: return .yellow
        @unknown default: return .gray
        }
    }
}

// MARK: - Event Detail View
struct EmergentEventDetailView: View {
    let event: EmergentPhenomenon
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var gameWorld: LivingWorld
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    EventDetailHeader(event: event)
                    
                    // Description
                    GroupBox {
                        Text(event.description)
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } label: {
                        Label("Description", systemImage: "text.quote")
                    }
                    
                    // Metadata
                    GroupBox {
                        VStack(spacing: 12) {
                            MetadataRow(label: "Type", value: typeLabel)
                            MetadataRow(label: "Significance", value: String(format: "%.2f", event.significance))
                            MetadataRow(label: "Participants", value: "\(event.participants.count) agents")
                            MetadataRow(label: "Duration", value: "Active")
                        }
                    } label: {
                        Label("Details", systemImage: "info.circle")
                    }
                    
                    // Participants
                    if !event.participants.isEmpty {
                        GroupBox {
                            ParticipantsList(participantIds: Array(event.participants))
                        } label: {
                            Label("Participants", systemImage: "person.3")
                        }
                    }
                    
                    // Evidence - commented out as EmergentPhenomenon doesn't have evidence property
                    /*
                    if !event.evidence.isEmpty {
                        GroupBox {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(event.evidence, id: \.self) { evidence in
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.caption)
                                        Text(evidence)
                                            .font(.caption)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                        } label: {
                            Label("Evidence", systemImage: "magnifyingglass")
                        }
                    }
                    */
                    
                    // Impact Analysis
                    GroupBox {
                        ImpactAnalysis(event: event)
                    } label: {
                        Label("Impact Analysis", systemImage: "chart.xyaxis.line")
                    }
                }
                .padding()
            }
            .navigationTitle("Phenomenon Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    dismiss()
                }
            )
        }
    }
    
    var typeLabel: String {
        switch event.type {
        case .socialMovement: return "Social Movement"
        case .culturalShift: return "Cultural Shift"
        case .economicTrend: return "Economic Trend"
        case .collectiveMood: return "Collective Mood"
        case .spontaneousOrganization: return "Spontaneous Organization"
        case .informationCascade: return "Information Cascade"
        case .behavioralContagion: return "Behavioral Contagion"
        @unknown default: return "Unknown"
        }
    }
}

// MARK: - Supporting Views

struct EventDetailHeader: View {
    let event: EmergentPhenomenon
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon
            Image(systemName: iconForType)
                .font(.system(size: 40))
                .foregroundColor(iconColor)
                .padding()
                .background(
                    Circle()
                        .fill(iconColor.opacity(0.1))
                )
            
            // Type label
            Text(typeLabel)
                .font(.headline)
            
            // Time
            Text("Detected \(event.timestamp.timeAgo)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Significance
            HStack {
                Text("Significance:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                SignificanceIndicator(value: event.significance)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
    
    var iconForType: String {
        switch event.type {
        case .socialMovement: return "person.3.fill"
        case .culturalShift: return "globe.americas.fill"
        case .economicTrend: return "chart.line.uptrend.xyaxis"
        case .collectiveMood: return "heart.circle.fill"
        case .spontaneousOrganization: return "burst.fill"
        case .informationCascade: return "wave.3.forward"
        case .behavioralContagion: return "arrow.triangle.branch"
        @unknown default: return "questionmark.circle.fill"
        }
    }
    
    var iconColor: Color {
        switch event.type {
        case .socialMovement: return .blue
        case .culturalShift: return .purple
        case .economicTrend: return .green
        case .collectiveMood: return .pink
        case .spontaneousOrganization: return .orange
        case .informationCascade: return .cyan
        case .behavioralContagion: return .yellow
        @unknown default: return .gray
        }
    }
    
    var typeLabel: String {
        switch event.type {
        case .socialMovement: return "Social Movement"
        case .culturalShift: return "Cultural Shift"
        case .economicTrend: return "Economic Trend"
        case .collectiveMood: return "Collective Mood"
        case .spontaneousOrganization: return "Spontaneous Organization"
        case .informationCascade: return "Information Cascade"
        case .behavioralContagion: return "Behavioral Contagion"
        @unknown default: return "Unknown"
        }
    }
}

struct MetadataRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct ParticipantsList: View {
    let participantIds: [UUID]
    @EnvironmentObject var gameWorld: LivingWorld
    
    var participants: [Agent] {
        participantIds.compactMap { id in
            gameWorld.agents.first { $0.id == id }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(participants.prefix(5)) { agent in
                HStack {
                    Circle()
                        .fill(agent.personality.primaryColor.opacity(0.3))
                        .frame(width: 30, height: 30)
                        .overlay(
                            Text(agent.name.initials)
                                .font(.caption)
                                .fontWeight(.semibold)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(agent.name)
                            .font(.subheadline)
                        Text(agent.currentAction?.description ?? "Idle")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
            
            if participantIds.count > 5 {
                Text("And \(participantIds.count - 5) more...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct ImpactAnalysis: View {
    let event: EmergentPhenomenon
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Potential impacts
            VStack(alignment: .leading, spacing: 8) {
                Text("Potential Impacts")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                ForEach(potentialImpacts, id: \.self) { impact in
                    HStack {
                        Image(systemName: "arrow.right.circle")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text(impact)
                            .font(.caption)
                    }
                }
            }
            
            Divider()
            
            // Metrics
            HStack(spacing: 20) {
                ImpactMetric(label: "Reach", value: "\(event.participants.count)", icon: "person.3")
                ImpactMetric(label: "Strength", value: String(format: "%.1f", event.significance), icon: "bolt.fill")
                ImpactMetric(label: "Duration", value: "Active", icon: "clock")
            }
        }
    }
    
    var potentialImpacts: [String] {
        switch event.type {
        case .socialMovement:
            return [
                "May influence social relationships",
                "Could change group dynamics",
                "Might affect collective beliefs"
            ]
        case .culturalShift:
            return [
                "Alters cultural values",
                "Influences agent behaviors",
                "May create new traditions"
            ]
        case .economicTrend:
            return [
                "Affects wealth distribution",
                "Changes market dynamics",
                "Influences agent professions"
            ]
        case .collectiveMood:
            return [
                "Impacts emotional contagion",
                "Affects social interactions",
                "May trigger cascading moods"
            ]
        case .spontaneousOrganization:
            return [
                "Creates new social structures",
                "Establishes emergent leadership",
                "Forms collective goals"
            ]
        case .informationCascade:
            return [
                "Spreads beliefs rapidly",
                "Influences decision making",
                "May create echo chambers"
            ]
        case .behavioralContagion:
            return [
                "Spreads behaviors virally",
                "Changes social norms",
                "Affects collective actions"
            ]
        @unknown default:
            return [
                "Unknown impact type",
                "May affect system behavior"
            ]
        }
    }
}

struct ImpactMetric: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.blue)
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No Emergent Phenomena Yet")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("As agents interact, emergent behaviors will appear here")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 50)
    }
}