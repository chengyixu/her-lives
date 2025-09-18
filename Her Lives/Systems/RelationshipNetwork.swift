//
//  RelationshipNetwork.swift
//  Her Lives
//
//  Manages the living network of relationships between agents
//

import Foundation
import SwiftUI

class RelationshipNetwork: ObservableObject {
    @Published private var relationships: [RelationshipKey: Relationship] = [:]
    @Published var socialGroups: [SocialGroup] = []
    @Published var networkMetrics: NetworkMetrics = NetworkMetrics()
    
    // Relationship key for bidirectional lookup
    struct RelationshipKey: Hashable, Codable {
        let agent1: UUID
        let agent2: UUID
        
        init(_ id1: UUID, _ id2: UUID) {
            // Always store in consistent order for bidirectional lookup
            if id1.uuidString < id2.uuidString {
                agent1 = id1
                agent2 = id2
            } else {
                agent1 = id2
                agent2 = id1
            }
        }
    }
    
    // MARK: - Relationship Management
    
    func addRelationship(_ relationship: Relationship) {
        let key = RelationshipKey(relationship.id, relationship.otherAgentId)
        relationships[key] = relationship
        updateNetworkMetrics()
    }
    
    func getRelationship(from agent1: Agent, to agent2: Agent) -> Relationship? {
        let key = RelationshipKey(agent1.id, agent2.id)
        return relationships[key]
    }
    
    func getAllRelationships() -> [Relationship] {
        Array(relationships.values)
    }
    
    func getRelationships(for agentId: UUID) -> [Relationship] {
        relationships.compactMap { key, relationship in
            if key.agent1 == agentId || key.agent2 == agentId {
                return relationship
            }
            return nil
        }
    }
    
    func getFriends(of agent: Agent) -> [Agent] {
        let agentRelationships = getRelationships(for: agent.id)
        return agentRelationships
            .filter { $0.stage == "friends" || $0.stage == "close_friends" }
            .compactMap { relationship in
                // Return the other agent in the relationship
                nil // Need world reference to get actual agents
            }
    }
    
    // MARK: - Relationship Dynamics
    
    func updateRelationship(between agent1: Agent, and agent2: Agent, interaction: SocialInteraction) {
        guard var relationship = getRelationship(from: agent1, to: agent2) else {
            // Create new relationship if doesn't exist
            let newRelationship = Relationship(from: agent1, to: agent2)
            addRelationship(newRelationship)
            return
        }
        
        // Update based on interaction quality
        let quality = interaction.quality
        
        // Familiarity always increases
        relationship.dimensions.familiarity = min(1.0, relationship.dimensions.familiarity + 0.01)
        
        // Other dimensions depend on interaction
        switch interaction.type {
        case .casual:
            relationship.dimensions.affection += quality * 0.01
            
        case .intimate:
            relationship.dimensions.intimacy += quality * 0.03
            relationship.dimensions.affection += quality * 0.02
            relationship.dimensions.trust += quality * 0.01
            
        case .conflict:
            relationship.dimensions.conflict += abs(quality) * 0.05
            relationship.dimensions.trust -= abs(quality) * 0.02
            
            // Conflict resolution can strengthen relationship
            if interaction.resolved {
                relationship.dimensions.trust += 0.03
                relationship.dimensions.intimacy += 0.02
                relationship.dimensions.conflict *= 0.5
            }
            
        case .collaborative:
            relationship.dimensions.trust += quality * 0.02
            relationship.dimensions.respect += quality * 0.02
            
        case .supportive:
            relationship.dimensions.affection += quality * 0.03
            relationship.dimensions.trust += quality * 0.02
            relationship.dimensions.commitment += quality * 0.01
        }
        
        // Add to shared history
        if interaction.isSignificant {
            relationship.sharedHistory.append(SharedMemory(
                id: UUID(),
                timestamp: Date(),
                description: interaction.description,
                emotionalValence: interaction.emotionalTone
            ))
        }
        
        // Check for relationship evolution
        relationship.checkStageTransition()
        
        // Update network metrics
        updateNetworkMetrics()
    }
    
    // MARK: - Relationship Decay
    
    func applyDecay(timePassed: TimeInterval) {
        for (_, relationship) in relationships {
            // Relationships decay without interaction
            let decayFactor = Float(0.001 * timePassed)
            
            // Different aspects decay at different rates
            relationship.dimensions.familiarity -= decayFactor * 0.5  // Slow decay
            relationship.dimensions.affection -= decayFactor * 0.8    // Medium decay
            relationship.dimensions.intimacy -= decayFactor * 1.0     // Fast decay
            
            // Trust decays very slowly
            relationship.dimensions.trust -= decayFactor * 0.3
            
            // Conflict naturally reduces over time
            relationship.dimensions.conflict *= 0.99
            
            // Clamp values
            relationship.dimensions.familiarity = max(0, relationship.dimensions.familiarity)
            relationship.dimensions.affection = max(-1, relationship.dimensions.affection)
            relationship.dimensions.intimacy = max(0, relationship.dimensions.intimacy)
            relationship.dimensions.trust = max(0, relationship.dimensions.trust)
            relationship.dimensions.conflict = max(0, relationship.dimensions.conflict)
            
            // Shared memories protect against complete decay
            let memoryProtection = Float(relationship.sharedHistory.count) * 0.01
            relationship.dimensions.familiarity = max(memoryProtection, relationship.dimensions.familiarity)
        }
    }
    
    // MARK: - Social Groups
    
    func detectSocialGroups(agents: [Agent]) {
        // Use community detection algorithm
        var groups: [SocialGroup] = []
        var visited = Set<UUID>()
        
        for agent in agents {
            if visited.contains(agent.id) { continue }
            
            // Find connected component
            var group = SocialGroup(id: UUID())
            var queue = [agent.id]
            
            while !queue.isEmpty {
                let currentId = queue.removeFirst()
                if visited.contains(currentId) { continue }
                
                visited.insert(currentId)
                group.memberIds.insert(currentId)
                
                // Add strongly connected agents to queue
                let connections = getRelationships(for: currentId)
                    .filter { $0.closeness > 0.5 }
                
                for connection in connections {
                    let otherId = connection.otherAgentId
                    if !visited.contains(otherId) {
                        queue.append(otherId)
                    }
                }
            }
            
            if group.memberIds.count > 1 {
                // Identify group characteristics
                group.identifyCharacteristics(relationships: relationships)
                groups.append(group)
            }
        }
        
        socialGroups = groups
    }
    
    // MARK: - Network Analysis
    
    private func updateNetworkMetrics() {
        let allRelationships = Array(relationships.values)
        
        // Average relationship strength
        let totalStrength = allRelationships.reduce(0) { $0 + $1.closeness }
        networkMetrics.averageStrength = allRelationships.isEmpty ? 0 : totalStrength / Float(allRelationships.count)
        
        // Network density
        let possibleConnections = relationships.count * (relationships.count - 1) / 2
        networkMetrics.density = possibleConnections > 0 ? Float(relationships.count) / Float(possibleConnections) : 0
        
        // Clustering coefficient
        networkMetrics.clusteringCoefficient = calculateClusteringCoefficient()
        
        // Social cohesion
        networkMetrics.socialCohesion = calculateSocialCohesion()
    }
    
    private func calculateClusteringCoefficient() -> Float {
        // Simplified clustering coefficient
        var totalCoefficient: Float = 0
        var count = 0
        
        for (key, _) in relationships {
            let agent1Relationships = getRelationships(for: key.agent1)
            let agent2Relationships = getRelationships(for: key.agent2)
            
            // Find common connections
            let commonConnections = agent1Relationships.filter { rel1 in
                agent2Relationships.contains { rel2 in
                    rel1.otherAgentId == rel2.otherAgentId
                }
            }
            
            if agent1Relationships.count > 1 {
                let coefficient = Float(commonConnections.count) / Float(agent1Relationships.count - 1)
                totalCoefficient += coefficient
                count += 1
            }
        }
        
        return count > 0 ? totalCoefficient / Float(count) : 0
    }
    
    private func calculateSocialCohesion() -> Float {
        // Measure how connected the overall network is
        let strongRelationships = relationships.values.filter { $0.closeness > 0.6 }
        let cohesion = Float(strongRelationships.count) / Float(max(1, relationships.count))
        return cohesion
    }
    
    // MARK: - Relationship Influence
    
    func calculateSocialInfluence(of agent: Agent) -> Float {
        let agentRelationships = getRelationships(for: agent.id)
        
        // Influence based on number and quality of relationships
        var influence: Float = 0
        
        for relationship in agentRelationships {
            // Strong relationships provide more influence
            influence += relationship.dimensions.respect * relationship.closeness
            
            // Leadership position in relationship adds influence
            if relationship.dimensions.powerBalance > 0 {
                influence += relationship.dimensions.powerBalance * 0.5
            }
        }
        
        // Normalize
        return min(1.0, influence / 10.0)
    }
    
    func findInfluencers(threshold: Float = 0.7) -> [UUID] {
        // Find agents with high social influence
        var influencers: [(UUID, Float)] = []
        
        // Need to check all unique agent IDs in relationships
        var agentIds = Set<UUID>()
        for key in relationships.keys {
            agentIds.insert(key.agent1)
            agentIds.insert(key.agent2)
        }
        
        for agentId in agentIds {
            let relationships = getRelationships(for: agentId)
            let influence = relationships.reduce(0) { sum, rel in
                sum + rel.dimensions.respect + rel.closeness
            } / Float(max(1, relationships.count * 2))
            
            if influence > threshold {
                influencers.append((agentId, influence))
            }
        }
        
        return influencers.sorted { $0.1 > $1.1 }.map { $0.0 }
    }
    
    // MARK: - Save/Load
    
    func loadRelationships(_ loaded: [Relationship]) {
        relationships.removeAll()
        for relationship in loaded {
            addRelationship(relationship)
        }
    }
}

// MARK: - Supporting Types

struct SocialGroup {
    let id: UUID
    var memberIds: Set<UUID> = []
    var groupType: GroupType = .informal
    var cohesion: Float = 0
    var leader: UUID?
    var sharedValues: [String] = []
    var groupNorms: [String] = []
    
    enum GroupType {
        case informal, friendship, professional, cultural, movement
    }
    
    mutating func identifyCharacteristics(relationships: [RelationshipNetwork.RelationshipKey: Relationship]) {
        // Determine group cohesion
        var totalCloseness: Float = 0
        var connectionCount = 0
        
        for member1 in memberIds {
            for member2 in memberIds where member1 != member2 {
                let key = RelationshipNetwork.RelationshipKey(member1, member2)
                if let relationship = relationships[key] {
                    totalCloseness += relationship.closeness
                    connectionCount += 1
                }
            }
        }
        
        cohesion = connectionCount > 0 ? totalCloseness / Float(connectionCount) : 0
        
        // Identify potential leader (highest total respect)
        var respectScores: [UUID: Float] = [:]
        for memberId in memberIds {
            respectScores[memberId] = 0
            for otherId in memberIds where memberId != otherId {
                let key = RelationshipNetwork.RelationshipKey(memberId, otherId)
                if let relationship = relationships[key] {
                    respectScores[memberId]! += relationship.dimensions.respect
                }
            }
        }
        
        leader = respectScores.max(by: { $0.value < $1.value })?.key
        
        // Determine group type based on relationships
        if cohesion > 0.7 {
            groupType = .friendship
        } else if memberIds.count > 10 {
            groupType = .movement
        } else {
            groupType = .informal
        }
    }
}

struct NetworkMetrics {
    var averageStrength: Float = 0
    var density: Float = 0
    var clusteringCoefficient: Float = 0
    var socialCohesion: Float = 0
}

enum InteractionType {
    case casual, intimate, conflict, collaborative, supportive
}

struct SocialInteraction {
    let id = UUID()
    let participants: [Agent]
    let type: InteractionType
    var location: Position
    let timestamp: GameTime
    var quality: Float = 0.5
    var emotionalTone: Float = 0
    var resolved: Bool = false
    var description: String = ""
    
    var isSignificant: Bool {
        abs(emotionalTone) > 0.5 || quality > 0.7 || type == .conflict
    }
}

struct SocialDialogue {
    let lines: [String]
    let emotionalTone: Float
    let summary: String
    var interactionQuality: Float = 0.5
    var containedMeme: CulturalMeme?
    
    func otherParticipant(besides agent: Agent) -> Agent? {
        // Would need reference to interaction context
        nil
    }
    
    static func createFallback(for interaction: SocialInteraction) -> SocialDialogue {
        SocialDialogue(
            lines: ["Hello", "Hi there"],
            emotionalTone: 0,
            summary: "Brief greeting"
        )
    }
}

// MARK: - Agent Extensions for Relationships

extension Agent {
    var friendCount: Int {
        relationships.values.filter { 
            $0.stage == "friends" || $0.stage == "close_friends" 
        }.count
    }
    
    var closeRelationshipCount: Int {
        relationships.values.filter { 
            $0.stage == "close_friends" || $0.stage == "romantic" || $0.stage == "family"
        }.count
    }
    
    func updateRelationship(with other: Agent, quality: Float) {
        if let relationship = relationships[other.id] {
            relationship.updateRelationship(with: other, quality: quality)
        } else {
            let newRelationship = Relationship(from: self, to: other)
            relationships[other.id] = newRelationship
            newRelationship.updateRelationship(with: other, quality: quality)
        }
    }
}