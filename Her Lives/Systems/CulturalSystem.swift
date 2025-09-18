//
//  CulturalSystem.swift
//  Her Lives
//
//  Manages cultural meme transmission, collective beliefs, and cultural evolution
//

import Foundation
import SwiftUI
import Combine

class CulturalSystem: ObservableObject {
    // MARK: - Published Properties
    @Published var activeMemes: [CulturalMeme] = []
    @Published var traditions: [Tradition] = []
    @Published var collectiveBelief: CollectiveBelief = CollectiveBelief()
    @Published var culturalTrends: [CulturalTrend] = []
    @Published var culturalDiversity: Float = 0.5
    
    // MARK: - Internal State
    private var memeTransmissionHistory: [MemeTransmission] = []
    private var evolutionEvents: [EvolutionEvent] = []
    private let mutationRate: Float = 0.01
    private let selectionPressure: Float = 0.1
    
    // Computed Properties
    var dominantMemes: [CulturalMeme] {
        activeMemes.filter { $0.strength > 0.6 }
            .sorted { $0.transmissionCount > $1.transmissionCount }
            .prefix(5)
            .map { $0 }
    }
    
    var culturalComplexity: Float {
        Float(activeMemes.count) / 100.0 + Float(traditions.count) / 20.0
    }
    
    // MARK: - Meme Management
    
    func addMeme(_ meme: CulturalMeme) {
        if !activeMemes.contains(where: { $0.id == meme.id }) {
            activeMemes.append(meme)
            recordEvolutionEvent(.memeIntroduction, meme: meme)
        }
    }
    
    func getAllMemes() -> [CulturalMeme] {
        return activeMemes
    }
    
    func loadMemes(_ memes: [CulturalMeme]) {
        activeMemes = memes
    }
    
    func transmitMeme(_ meme: CulturalMeme, from sender: Agent, to receiver: Agent) -> Bool {
        // Calculate transmission probability
        let baseRate: Float = 0.3
        let personalityFactor = receiver.personality.openness * 0.5
        let relationshipFactor = getRelationshipBonus(sender, receiver)
        let memeResonance = meme.resonatesWith(beliefs: receiver.beliefs) ? 0.3 : 0.0
        
        let transmissionProbability = baseRate + personalityFactor + relationshipFactor + Float(memeResonance)
        
        if Float.random(in: 0...1) < transmissionProbability {
            // Successful transmission
            var transmittedMeme = meme
            
            // Possible mutation during transmission
            if Float.random(in: 0...1) < mutationRate {
                transmittedMeme = mutateMeme(meme)
            }
            
            // Add to receiver
            receiver.adoptMeme(transmittedMeme)
            transmittedMeme.carriers.insert(receiver.id)
            transmittedMeme.transmissionCount += 1
            
            // Update meme in active list
            if let index = activeMemes.firstIndex(where: { $0.id == meme.id }) {
                activeMemes[index] = transmittedMeme
            }
            
            // Record transmission
            recordMemeTransmission(meme, from: sender.id, to: receiver.id, success: true)
            
            return true
        } else {
            // Failed transmission
            recordMemeTransmission(meme, from: sender.id, to: receiver.id, success: false)
            return false
        }
    }
    
    private func mutateMeme(_ originalMeme: CulturalMeme) -> CulturalMeme {
        var mutatedMeme = originalMeme
        
        // Create mutation by adding variation
        let mutations = [
            "modified",
            "adapted",
            "improved",
            "simplified",
            "extended"
        ]
        
        let mutation = mutations.randomElement() ?? "adapted"
        mutatedMeme.mutations.append("\(mutation) version")
        
        // Slightly alter strength
        mutatedMeme.strength += Float.random(in: -0.1...0.1)
        mutatedMeme.strength = max(0, min(1, mutatedMeme.strength))
        
        return mutatedMeme
    }
    
    // MARK: - Cultural Evolution
    
    func evolve(timeStep: TimeInterval) {
        // Apply selection pressure
        applySelection()
        
        // Check for emerging traditions
        checkForNewTraditions()
        
        // Update cultural trends
        updateCulturalTrends()
        
        // Calculate diversity
        calculateDiversity()
        
        // Clean up extinct memes
        pruneExtinctMemes()
    }
    
    private func applySelection() {
        for i in activeMemes.indices {
            let meme = activeMemes[i]
            
            // Memes lose strength if not transmitted
            if meme.transmissionCount == 0 {
                activeMemes[i].strength *= (1.0 - selectionPressure)
            } else {
                // Popular memes gain strength
                let popularityBonus = Float(meme.transmissionCount) / 100.0
                activeMemes[i].strength = min(1.0, meme.strength + popularityBonus * 0.1)
            }
            
            // Reset transmission count for next cycle
            activeMemes[i].transmissionCount = 0
        }
    }
    
    private func checkForNewTraditions() {
        // Look for memes that have become deeply embedded
        let candidateMemes = activeMemes.filter { meme in
            meme.strength > 0.8 && meme.carriers.count > 5
        }
        
        for meme in candidateMemes {
            if !traditions.contains(where: { $0.origin == meme.content }) {
                let tradition = Tradition(
                    id: UUID(),
                    name: meme.content,
                    origin: meme.content,
                    practitioners: meme.carriers,
                    strength: meme.strength,
                    rituals: generateRituals(for: meme)
                )
                
                traditions.append(tradition)
                recordEvolutionEvent(.traditionEmergence, meme: meme)
            }
        }
    }
    
    private func generateRituals(for meme: CulturalMeme) -> [String] {
        let ritualTypes = [
            "daily practice of \(meme.content.lowercased())",
            "weekly gathering to discuss \(meme.content.lowercased())",
            "ceremonial expression of \(meme.content.lowercased())",
            "shared celebration of \(meme.content.lowercased())"
        ]
        
        return [ritualTypes.randomElement() ?? "ritual practice"]
    }
    
    // MARK: - Cultural Analysis
    
    func calculateDiversity() -> Float {
        guard !activeMemes.isEmpty else { return 0.0 }
        
        // If only one meme, no diversity
        if activeMemes.count == 1 {
            culturalDiversity = 0.0
            return culturalDiversity
        }
        
        // Shannon diversity index for memes
        var diversity: Float = 0
        let totalTransmissions = Float(activeMemes.reduce(0) { $0 + $1.transmissionCount + 1 })
        
        for meme in activeMemes {
            let frequency = Float(meme.transmissionCount + 1) / totalTransmissions
            if frequency > 0 {
                diversity -= frequency * log2(frequency)
            }
        }
        
        // Normalize by maximum possible diversity (log2 of number of memes)
        let maxDiversity = log2(Float(activeMemes.count))
        culturalDiversity = maxDiversity > 0 ? diversity / maxDiversity : 0.0
        return culturalDiversity
    }
    
    func establishTradition(_ data: [String: Any]) {
        guard let name = data["name"] as? String,
              let practitioners = data["practitioners"] as? Set<UUID> else { return }
        
        let tradition = Tradition(
            id: UUID(),
            name: name,
            origin: data["origin"] as? String ?? name,
            practitioners: practitioners,
            strength: data["strength"] as? Float ?? 0.5,
            rituals: data["rituals"] as? [String] ?? []
        )
        
        traditions.append(tradition)
    }
    
    func getMemeInfluence(on agent: Agent) -> Float {
        let carriedMemes = agent.carriedMemes
        var totalInfluence: Float = 0
        
        for meme in carriedMemes {
            // Stronger memes have more influence
            totalInfluence += meme.strength
            
            // Memes carried by more agents have network effects
            let networkEffect = Float(meme.carriers.count) / 100.0
            totalInfluence += networkEffect * 0.5
        }
        
        return min(1.0, totalInfluence / Float(max(1, carriedMemes.count)))
    }
    
    // MARK: - Cultural Trends
    
    private func updateCulturalTrends() {
        var trendCounts: [String: Int] = [:]
        
        // Analyze meme categories
        for meme in activeMemes {
            let category = categorizeMeme(meme)
            trendCounts[category, default: 0] += 1
        }
        
        // Update trends
        culturalTrends.removeAll()
        for (category, count) in trendCounts {
            let strength = Float(count) / Float(max(1, activeMemes.count))
            let trend = CulturalTrend(
                name: category,
                strength: strength,
                direction: determineTrendDirection(category),
                participants: Set(activeMemes.filter { categorizeMeme($0) == category }
                    .flatMap { $0.carriers })
            )
            culturalTrends.append(trend)
        }
        
        // Sort by strength
        culturalTrends.sort { $0.strength > $1.strength }
    }
    
    private func categorizeMeme(_ meme: CulturalMeme) -> String {
        let content = meme.content.lowercased()
        
        if content.contains("love") || content.contains("relationship") {
            return "Romance"
        } else if content.contains("work") || content.contains("profession") {
            return "Professional"
        } else if content.contains("creative") || content.contains("art") {
            return "Creative"
        } else if content.contains("community") || content.contains("together") {
            return "Social"
        } else if content.contains("growth") || content.contains("learn") {
            return "Personal Development"
        } else {
            return "General Values"
        }
    }
    
    private func determineTrendDirection(_ category: String) -> TrendDirection {
        // Simple trend analysis based on recent transmissions
        let recentTransmissions = memeTransmissionHistory.suffix(100)
        let categoryTransmissions = recentTransmissions.filter {
            categorizeMeme($0.meme) == category
        }
        
        if categoryTransmissions.count > 10 {
            return .rising
        } else if categoryTransmissions.count < 3 {
            return .declining
        } else {
            return .stable
        }
    }
    
    // MARK: - Collective Beliefs
    
    func updateCollectiveBeliefs(agents: [Agent]) {
        var beliefStrengths: [String: Float] = [:]
        var beliefCounts: [String: Int] = [:]
        
        // Aggregate beliefs across agents
        for agent in agents {
            for belief in agent.beliefs {
                beliefStrengths[belief.content, default: 0] += belief.strength
                beliefCounts[belief.content, default: 0] += 1
            }
        }
        
        // Calculate collective belief strength
        var strongestBeliefs: [(String, Float)] = []
        for (content, totalStrength) in beliefStrengths {
            let count = beliefCounts[content] ?? 1
            let averageStrength = totalStrength / Float(count)
            let prevalence = Float(count) / Float(agents.count)
            
            // Weighted by both strength and prevalence
            let collectiveStrength = averageStrength * prevalence
            strongestBeliefs.append((content, collectiveStrength))
        }
        
        strongestBeliefs.sort { $0.1 > $1.1 }
        
        // Update collective belief
        collectiveBelief = CollectiveBelief(
            dominantBeliefs: strongestBeliefs.prefix(5).map { $0.0 },
            consensus: strongestBeliefs.first?.1 ?? 0.0,
            polarization: calculatePolarization(beliefs: beliefStrengths)
        )
    }
    
    private func calculatePolarization(beliefs: [String: Float]) -> Float {
        guard beliefs.count > 1 else { return 0.0 }
        
        let values = Array(beliefs.values)
        let mean = values.reduce(0, +) / Float(values.count)
        let variance = values.reduce(0) { acc, value in
            acc + pow(value - mean, 2)
        } / Float(values.count)
        
        return min(1.0, sqrt(variance))
    }
    
    // MARK: - Helper Functions
    
    private func getRelationshipBonus(_ sender: Agent, _ receiver: Agent) -> Float {
        if let relationship = receiver.relationships[sender.id] {
            return relationship.closeness * 0.3
        }
        return 0.0
    }
    
    private func recordMemeTransmission(_ meme: CulturalMeme, from: UUID, to: UUID, success: Bool) {
        let transmission = MemeTransmission(
            meme: meme,
            senderId: from,
            receiverId: to,
            timestamp: Date(),
            success: success
        )
        
        memeTransmissionHistory.append(transmission)
        
        // Keep only recent history
        if memeTransmissionHistory.count > 1000 {
            memeTransmissionHistory.removeFirst()
        }
    }
    
    private func recordEvolutionEvent(_ type: EvolutionEventType, meme: CulturalMeme) {
        let event = EvolutionEvent(
            type: type,
            memeId: meme.id,
            timestamp: Date(),
            description: generateEventDescription(type, meme: meme)
        )
        
        evolutionEvents.append(event)
        
        // Keep only recent events
        if evolutionEvents.count > 500 {
            evolutionEvents.removeFirst()
        }
    }
    
    private func generateEventDescription(_ type: EvolutionEventType, meme: CulturalMeme) -> String {
        switch type {
        case .memeIntroduction:
            return "New meme '\(meme.content)' introduced to culture"
        case .traditionEmergence:
            return "Meme '\(meme.content)' evolved into tradition"
        case .memeMutation:
            return "Meme '\(meme.content)' mutated during transmission"
        case .memeExtinction:
            return "Meme '\(meme.content)' disappeared from culture"
        }
    }
    
    private func pruneExtinctMemes() {
        activeMemes.removeAll { meme in
            meme.strength < 0.1 && meme.carriers.isEmpty
        }
    }
}

// MARK: - Supporting Types

struct Tradition: Identifiable {
    let id: UUID
    let name: String
    let origin: String
    var practitioners: Set<UUID>
    var strength: Float
    var rituals: [String]
    var establishedDate: Date = Date()
    
    var description: String {
        "Tradition of \(name) with \(practitioners.count) practitioners"
    }
}

struct CollectiveBelief {
    var dominantBeliefs: [String] = []
    var consensus: Float = 0.0
    var polarization: Float = 0.0
    
    var description: String {
        if dominantBeliefs.isEmpty {
            return "No dominant beliefs yet"
        }
        
        let beliefText = dominantBeliefs.prefix(2).joined(separator: " and ")
        if consensus > 0.7 {
            return "Strong consensus on \(beliefText)"
        } else if polarization > 0.6 {
            return "Polarized views on \(beliefText)"
        } else {
            return "Mixed beliefs about \(beliefText)"
        }
    }
}

struct CulturalTrend: Identifiable {
    let id = UUID()
    let name: String
    var strength: Float
    var direction: TrendDirection
    var participants: Set<UUID>
    
    var description: String {
        let directionEmoji = direction == .rising ? "📈" : 
                           direction == .declining ? "📉" : "➡️"
        return "\(directionEmoji) \(name) (\(Int(strength * 100))%)"
    }
}

enum TrendDirection {
    case rising, declining, stable
}

struct MemeTransmission {
    let meme: CulturalMeme
    let senderId: UUID
    let receiverId: UUID
    let timestamp: Date
    let success: Bool
}

struct EvolutionEvent {
    let type: EvolutionEventType
    let memeId: UUID
    let timestamp: Date
    let description: String
}

enum EvolutionEventType {
    case memeIntroduction, traditionEmergence, memeMutation, memeExtinction
}

// MARK: - Extensions

extension Agent {
    func considerAdoptingMeme(_ meme: CulturalMeme) {
        // Check if meme resonates with agent's personality and beliefs
        let personalityResonance = calculatePersonalityResonance(meme)
        let beliefCompatibility = meme.resonatesWith(beliefs: beliefs) ? 0.3 : 0.0
        
        let adoptionProbability = personalityResonance + Float(beliefCompatibility)
        
        if Float.random(in: 0...1) < adoptionProbability {
            adoptMeme(meme)
        }
    }
    
    private func calculatePersonalityResonance(_ meme: CulturalMeme) -> Float {
        let content = meme.content.lowercased()
        var resonance: Float = 0.0
        
        if content.contains("creative") && personality.creativity > 0.5 {
            resonance += 0.3
        }
        if content.contains("social") && personality.extraversion > 0.5 {
            resonance += 0.3
        }
        if content.contains("growth") && personality.openness > 0.5 {
            resonance += 0.3
        }
        
        return resonance
    }
}