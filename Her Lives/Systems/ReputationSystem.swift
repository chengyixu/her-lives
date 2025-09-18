//
//  ReputationSystem.swift
//  Her Lives
//
//  Tracks how agents are perceived by others based on their actions
//  Inspired by honor systems in Red Dead Redemption 2 and reputation in Cyberpunk 2077
//

import Foundation
import SwiftUI

// MARK: - Reputation Dimensions
struct ReputationDimensions {
    var trustworthiness: Float = 0.5  // 0 = untrustworthy, 1 = very trustworthy
    var kindness: Float = 0.5         // 0 = cruel, 1 = very kind
    var competence: Float = 0.5       // 0 = incompetent, 1 = highly skilled
    var courage: Float = 0.5          // 0 = coward, 1 = brave
    var creativity: Float = 0.5       // 0 = boring, 1 = innovative
    var humor: Float = 0.5            // 0 = serious, 1 = funny
    var generosity: Float = 0.5       // 0 = selfish, 1 = generous
    var wisdom: Float = 0.5           // 0 = foolish, 1 = wise
    
    var overall: Float {
        (trustworthiness + kindness + competence + courage + 
         creativity + humor + generosity + wisdom) / 8.0
    }
    
    func getTitle() -> String {
        // Generate a title based on dominant traits
        let traits = [
            (trustworthiness, "Trusted"),
            (kindness, "Kind"),
            (competence, "Skilled"),
            (courage, "Brave"),
            (creativity, "Creative"),
            (humor, "Jester"),
            (generosity, "Generous"),
            (wisdom, "Wise")
        ]
        
        let dominant = traits.max(by: { $0.0 < $1.0 })
        let overall = self.overall
        
        if overall > 0.8 {
            return "The \(dominant?.1 ?? "Respected")"
        } else if overall > 0.6 {
            return dominant?.1 ?? "Known"
        } else if overall > 0.4 {
            return "Ordinary"
        } else if overall > 0.2 {
            return "Questionable"
        } else {
            return "The Outcast"
        }
    }
}

// MARK: - Reputation Event
struct ReputationEvent {
    let action: String
    let impact: ReputationDimensions
    let witnesses: Set<UUID>
    let timestamp: Date
    let intensity: Float // How strong the impact is
    
    init(action: String, impact: ReputationDimensions, witnesses: Set<UUID>, intensity: Float = 1.0) {
        self.action = action
        self.impact = impact
        self.witnesses = witnesses
        self.timestamp = Date()
        self.intensity = min(max(intensity, 0.1), 2.0) // Cap between 0.1 and 2.0
    }
}

// MARK: - Individual Reputation (how one agent sees another)
class IndividualReputation {
    let observerId: UUID
    let subjectId: UUID
    private(set) var dimensions: ReputationDimensions
    private var events: [ReputationEvent] = []
    private var lastInteraction: Date?
    
    init(observer: UUID, subject: UUID) {
        self.observerId = observer
        self.subjectId = subject
        self.dimensions = ReputationDimensions()
    }
    
    func addObservation(_ event: ReputationEvent) {
        events.append(event)
        
        // Update dimensions based on event
        dimensions.trustworthiness += event.impact.trustworthiness * event.intensity * 0.1
        dimensions.kindness += event.impact.kindness * event.intensity * 0.1
        dimensions.competence += event.impact.competence * event.intensity * 0.1
        dimensions.courage += event.impact.courage * event.intensity * 0.1
        dimensions.creativity += event.impact.creativity * event.intensity * 0.1
        dimensions.humor += event.impact.humor * event.intensity * 0.1
        dimensions.generosity += event.impact.generosity * event.intensity * 0.1
        dimensions.wisdom += event.impact.wisdom * event.intensity * 0.1
        
        // Clamp values between 0 and 1
        dimensions.trustworthiness = min(max(dimensions.trustworthiness, 0), 1)
        dimensions.kindness = min(max(dimensions.kindness, 0), 1)
        dimensions.competence = min(max(dimensions.competence, 0), 1)
        dimensions.courage = min(max(dimensions.courage, 0), 1)
        dimensions.creativity = min(max(dimensions.creativity, 0), 1)
        dimensions.humor = min(max(dimensions.humor, 0), 1)
        dimensions.generosity = min(max(dimensions.generosity, 0), 1)
        dimensions.wisdom = min(max(dimensions.wisdom, 0), 1)
        
        lastInteraction = Date()
    }
    
    func getOpinion() -> String {
        let overall = dimensions.overall
        if overall > 0.8 {
            return "deeply respects"
        } else if overall > 0.6 {
            return "admires"
        } else if overall > 0.4 {
            return "is neutral towards"
        } else if overall > 0.2 {
            return "distrusts"
        } else {
            return "despises"
        }
    }
}

// MARK: - Reputation System
class ReputationSystem: ObservableObject {
    @Published private var reputations: [UUID: [UUID: IndividualReputation]] = [:]
    
    // Get how agent A sees agent B
    func getReputation(observer: UUID, subject: UUID) -> IndividualReputation {
        if reputations[observer] == nil {
            reputations[observer] = [:]
        }
        
        if let existing = reputations[observer]?[subject] {
            return existing
        }
        
        let newRep = IndividualReputation(observer: observer, subject: subject)
        reputations[observer]?[subject] = newRep
        return newRep
    }
    
    // Record an action and its witnesses
    func recordAction(
        actor: UUID,
        action: String,
        actionType: ActionReputationType,
        witnesses: Set<UUID>,
        intensity: Float = 1.0
    ) {
        let impact = actionType.getImpact()
        let event = ReputationEvent(
            action: action,
            impact: impact,
            witnesses: witnesses,
            intensity: intensity
        )
        
        // Each witness forms their own opinion
        for witness in witnesses {
            if witness != actor { // Can't witness own actions for reputation
                let reputation = getReputation(observer: witness, subject: actor)
                reputation.addObservation(event)
            }
        }
    }
    
    // Get consensus reputation (how most people see someone)
    func getConsensusReputation(for agentId: UUID) -> ReputationDimensions {
        var totalDimensions = ReputationDimensions()
        var count = 0
        
        for (_, opinions) in reputations {
            if let opinion = opinions[agentId] {
                totalDimensions.trustworthiness += opinion.dimensions.trustworthiness
                totalDimensions.kindness += opinion.dimensions.kindness
                totalDimensions.competence += opinion.dimensions.competence
                totalDimensions.courage += opinion.dimensions.courage
                totalDimensions.creativity += opinion.dimensions.creativity
                totalDimensions.humor += opinion.dimensions.humor
                totalDimensions.generosity += opinion.dimensions.generosity
                totalDimensions.wisdom += opinion.dimensions.wisdom
                count += 1
            }
        }
        
        if count > 0 {
            totalDimensions.trustworthiness /= Float(count)
            totalDimensions.kindness /= Float(count)
            totalDimensions.competence /= Float(count)
            totalDimensions.courage /= Float(count)
            totalDimensions.creativity /= Float(count)
            totalDimensions.humor /= Float(count)
            totalDimensions.generosity /= Float(count)
            totalDimensions.wisdom /= Float(count)
        }
        
        return totalDimensions
    }
    
    // Check if someone is considered an outcast
    func isOutcast(_ agentId: UUID) -> Bool {
        let consensus = getConsensusReputation(for: agentId)
        return consensus.overall < 0.2
    }
    
    // Check if someone is highly respected
    func isRespected(_ agentId: UUID) -> Bool {
        let consensus = getConsensusReputation(for: agentId)
        return consensus.overall > 0.7
    }
}

// MARK: - Action Types and Their Reputation Impact
enum ActionReputationType {
    case helpStranger
    case shareResource
    case tellJoke
    case solveProblems
    case breakPromise
    case stealFrom
    case insult
    case fightBravely
    case runFromDanger
    case createArt
    case teachOthers
    case spreadGossip
    case defendWeak
    case bullyOthers
    
    func getImpact() -> ReputationDimensions {
        var impact = ReputationDimensions()
        
        // All values start at 0 (no change)
        impact.trustworthiness = 0
        impact.kindness = 0
        impact.competence = 0
        impact.courage = 0
        impact.creativity = 0
        impact.humor = 0
        impact.generosity = 0
        impact.wisdom = 0
        
        switch self {
        case .helpStranger:
            impact.kindness = 0.2
            impact.generosity = 0.1
            impact.trustworthiness = 0.1
            
        case .shareResource:
            impact.generosity = 0.3
            impact.kindness = 0.1
            
        case .tellJoke:
            impact.humor = 0.2
            impact.creativity = 0.05
            
        case .solveProblems:
            impact.competence = 0.2
            impact.wisdom = 0.1
            
        case .breakPromise:
            impact.trustworthiness = -0.4
            impact.kindness = -0.1
            
        case .stealFrom:
            impact.trustworthiness = -0.5
            impact.kindness = -0.3
            impact.generosity = -0.3
            
        case .insult:
            impact.kindness = -0.3
            impact.wisdom = -0.1
            
        case .fightBravely:
            impact.courage = 0.3
            impact.competence = 0.1
            
        case .runFromDanger:
            impact.courage = -0.2
            
        case .createArt:
            impact.creativity = 0.3
            impact.competence = 0.1
            
        case .teachOthers:
            impact.wisdom = 0.2
            impact.kindness = 0.1
            impact.generosity = 0.1
            
        case .spreadGossip:
            impact.trustworthiness = -0.2
            impact.wisdom = -0.1
            
        case .defendWeak:
            impact.courage = 0.2
            impact.kindness = 0.3
            impact.trustworthiness = 0.1
            
        case .bullyOthers:
            impact.kindness = -0.4
            impact.courage = -0.2
            impact.wisdom = -0.2
        }
        
        return impact
    }
}