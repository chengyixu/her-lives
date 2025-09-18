//
//  EmergenceDetector.swift
//  Her Lives
//
//  Detects emergent behaviors and phenomena from agent interactions
//

import Foundation
import SwiftUI
import Combine

class EmergenceDetector: ObservableObject {
    // MARK: - Published Properties
    @Published var detectedPhenomena: [EmergentPhenomenon] = []
    @Published var emergenceMetrics: EmergenceMetrics = EmergenceMetrics()
    @Published var patternHistory: [EmergencePattern] = []
    @Published var complexityScore: Float = 0.0
    
    // MARK: - Internal State
    private var observationWindow: [WorldObservation] = []
    private var patternDetectors: [PatternDetector] = []
    private var analysisCache: [String: Any] = [:]
    
    // Detection parameters
    private let observationWindowSize = 100
    private let minimumPatternStrength: Float = 0.6
    private let emergenceThreshold: Float = 0.7
    private let complexityUpdateInterval: TimeInterval = 60.0
    private var lastComplexityUpdate: Date = Date()
    
    // Pattern categories
    private let socialPatterns = SocialPatternDetector()
    private let culturalPatterns = CulturalPatternDetector()
    private let economicPatterns = EconomicPatternDetector()
    private let spatialPatterns = SpatialPatternDetector()
    private let behavioralPatterns = BehavioralPatternDetector()
    
    init() {
        initializeDetectors()
    }
    
    private func initializeDetectors() {
        patternDetectors = [
            socialPatterns,
            culturalPatterns,
            economicPatterns,
            spatialPatterns,
            behavioralPatterns
        ]
    }
    
    // MARK: - Main Detection Loop
    
    func detect(_ observations: WorldObservations) -> [EmergentPhenomenon] {
        // Add to observation window
        let observation = WorldObservation(
            timestamp: Date(),
            agentStates: observations.agentStates,
            relationships: observations.relationships,
            economicActivity: observations.economicActivity,
            culturalMemes: observations.culturalMemes,
            collectiveMood: observations.collectiveMood
        )
        
        addObservation(observation)
        
        // Run pattern detection
        let detectedPatterns = runPatternDetection()
        
        // Analyze for emergence
        let phenomena = analyzeForEmergence(patterns: detectedPatterns)
        
        // Update metrics
        updateEmergenceMetrics()
        
        // Update complexity score
        if Date().timeIntervalSince(lastComplexityUpdate) > complexityUpdateInterval {
            updateComplexityScore()
            lastComplexityUpdate = Date()
        }
        
        // Cache significant phenomena
        for phenomenon in phenomena {
            if phenomenon.significance > emergenceThreshold {
                detectedPhenomena.append(phenomenon)
            }
        }
        
        // Cleanup old phenomena
        cleanupOldPhenomena()
        
        return phenomena
    }
    
    private func addObservation(_ observation: WorldObservation) {
        observationWindow.append(observation)
        
        // Maintain window size
        if observationWindow.count > observationWindowSize {
            observationWindow.removeFirst()
        }
    }
    
    // MARK: - Pattern Detection
    
    private func runPatternDetection() -> [EmergencePattern] {
        var allPatterns: [EmergencePattern] = []
        
        guard observationWindow.count >= 10 else { return allPatterns }
        
        for detector in patternDetectors {
            let patterns = detector.detectPatterns(in: observationWindow)
            allPatterns.append(contentsOf: patterns)
        }
        
        // Filter by strength
        return allPatterns.filter { $0.strength >= minimumPatternStrength }
    }
    
    private func analyzeForEmergence(patterns: [EmergencePattern]) -> [EmergentPhenomenon] {
        var phenomena: [EmergentPhenomenon] = []
        
        // Group patterns by type and analyze
        let groupedPatterns = Dictionary(grouping: patterns) { $0.category }
        
        for (category, categoryPatterns) in groupedPatterns {
            let categoryPhenomena = analyzePatternCategory(category, patterns: categoryPatterns)
            phenomena.append(contentsOf: categoryPhenomena)
        }
        
        // Cross-category emergence analysis
        let crossCategoryPhenomena = analyzeCrossCategoryEmergence(patterns: patterns)
        phenomena.append(contentsOf: crossCategoryPhenomena)
        
        return phenomena
    }
    
    private func analyzePatternCategory(_ category: PatternCategory, patterns: [EmergencePattern]) -> [EmergentPhenomenon] {
        var phenomena: [EmergentPhenomenon] = []
        
        switch category {
        case .social:
            phenomena.append(contentsOf: analyzeSocialEmergence(patterns))
        case .cultural:
            phenomena.append(contentsOf: analyzeCulturalEmergence(patterns))
        case .economic:
            phenomena.append(contentsOf: analyzeEconomicEmergence(patterns))
        case .spatial:
            phenomena.append(contentsOf: analyzeSpatialEmergence(patterns))
        case .behavioral:
            phenomena.append(contentsOf: analyzeBehavioralEmergence(patterns))
        }
        
        return phenomena
    }
    
    // MARK: - Specific Emergence Analysis
    
    private func analyzeSocialEmergence(_ patterns: [EmergencePattern]) -> [EmergentPhenomenon] {
        var phenomena: [EmergentPhenomenon] = []
        
        // Look for social structure formation
        let structurePatterns = patterns.filter { $0.name.contains("structure") || $0.name.contains("hierarchy") }
        if let strongestStructure = structurePatterns.max(by: { $0.strength < $1.strength }),
           strongestStructure.strength > 0.8 {
            
            phenomena.append(EmergentPhenomenon(
                id: UUID(),
                type: .socialStructure,
                name: "Social Hierarchy Formation",
                description: "A clear social hierarchy has emerged among agents",
                affectedAgents: strongestStructure.involvedAgents,
                strength: strongestStructure.strength,
                significance: calculateSignificance(strongestStructure),
                timestamp: Date(),
                data: ["hierarchy_type": strongestStructure.name]
            ))
        }
        
        // Look for movement formation
        let movementPatterns = patterns.filter { $0.name.contains("movement") || $0.name.contains("collective") }
        if movementPatterns.count > 2,
           let averageStrength = calculateAverageStrength(movementPatterns),
           averageStrength > 0.7 {
            
            let allInvolved = Set(movementPatterns.flatMap { $0.involvedAgents })
            
            phenomena.append(EmergentPhenomenon(
                id: UUID(),
                type: .socialMovement,
                name: "Collective Movement",
                description: "Agents have formed a coordinated social movement",
                affectedAgents: allInvolved,
                strength: averageStrength,
                significance: calculateMovementSignificance(allInvolved.count),
                timestamp: Date(),
                data: ["movement": "collective_action", "size": allInvolved.count]
            ))
        }
        
        return phenomena
    }
    
    private func analyzeCulturalEmergence(_ patterns: [EmergencePattern]) -> [EmergentPhenomenon] {
        var phenomena: [EmergentPhenomenon] = []
        
        // Look for tradition formation
        let traditionPatterns = patterns.filter { $0.name.contains("tradition") || $0.name.contains("ritual") }
        if let strongestTradition = traditionPatterns.max(by: { $0.strength < $1.strength }),
           strongestTradition.strength > 0.75 {
            
            phenomena.append(EmergentPhenomenon(
                id: UUID(),
                type: .newTradition,
                name: "Cultural Tradition",
                description: "A new cultural tradition has emerged and taken hold",
                affectedAgents: strongestTradition.involvedAgents,
                strength: strongestTradition.strength,
                significance: calculateSignificance(strongestTradition),
                timestamp: Date(),
                data: ["tradition": strongestTradition.name]
            ))
        }
        
        // Look for belief convergence
        let beliefPatterns = patterns.filter { $0.name.contains("belief") || $0.name.contains("consensus") }
        if beliefPatterns.count > 1 {
            let averageStrength = calculateAverageStrength(beliefPatterns) ?? 0
            if averageStrength > 0.8 {
                
                phenomena.append(EmergentPhenomenon(
                    id: UUID(),
                    type: .culturalShift,
                    name: "Belief Convergence",
                    description: "Agents have converged on shared beliefs",
                    affectedAgents: Set(beliefPatterns.flatMap { $0.involvedAgents }),
                    strength: averageStrength,
                    significance: averageStrength,
                    timestamp: Date(),
                    data: ["consensus_strength": averageStrength]
                ))
            }
        }
        
        return phenomena
    }
    
    private func analyzeEconomicEmergence(_ patterns: [EmergencePattern]) -> [EmergentPhenomenon] {
        var phenomena: [EmergentPhenomenon] = []
        
        // Look for specialization patterns
        let specializationPatterns = patterns.filter { $0.name.contains("specialization") || $0.name.contains("profession") }
        if let strongestSpec = specializationPatterns.max(by: { $0.strength < $1.strength }),
           strongestSpec.strength > 0.7 {
            
            phenomena.append(EmergentPhenomenon(
                id: UUID(),
                type: .economicSpecialization,
                name: "Professional Specialization",
                description: "Agents have developed specialized economic roles",
                affectedAgents: strongestSpec.involvedAgents,
                strength: strongestSpec.strength,
                significance: calculateSignificance(strongestSpec),
                timestamp: Date(),
                data: ["profession": strongestSpec.name]
            ))
        }
        
        // Look for market formation
        let marketPatterns = patterns.filter { $0.name.contains("market") || $0.name.contains("trade") }
        if marketPatterns.count >= 2,
           let averageStrength = calculateAverageStrength(marketPatterns),
           averageStrength > 0.6 {
            
            phenomena.append(EmergentPhenomenon(
                id: UUID(),
                type: .marketEmergence,
                name: "Market Formation",
                description: "A structured market system has emerged",
                affectedAgents: Set(marketPatterns.flatMap { $0.involvedAgents }),
                strength: averageStrength,
                significance: averageStrength * Float(marketPatterns.count) / 3.0,
                timestamp: Date(),
                data: ["market_complexity": marketPatterns.count]
            ))
        }
        
        return phenomena
    }
    
    private func analyzeSpatialEmergence(_ patterns: [EmergencePattern]) -> [EmergentPhenomenon] {
        var phenomena: [EmergentPhenomenon] = []
        
        // Look for territory formation
        let territoryPatterns = patterns.filter { $0.name.contains("territory") || $0.name.contains("cluster") }
        if let strongestTerritory = territoryPatterns.max(by: { $0.strength < $1.strength }),
           strongestTerritory.strength > 0.7 {
            
            phenomena.append(EmergentPhenomenon(
                id: UUID(),
                type: .territoryFormation,
                name: "Territory Establishment",
                description: "Agents have established distinct territories",
                affectedAgents: strongestTerritory.involvedAgents,
                strength: strongestTerritory.strength,
                significance: calculateSignificance(strongestTerritory),
                timestamp: Date(),
                data: ["territory_type": strongestTerritory.name]
            ))
        }
        
        // Look for migration patterns
        let migrationPatterns = patterns.filter { $0.name.contains("migration") || $0.name.contains("movement") }
        if migrationPatterns.count > 1,
           let averageStrength = calculateAverageStrength(migrationPatterns),
           averageStrength > 0.6 {
            
            phenomena.append(EmergentPhenomenon(
                id: UUID(),
                type: .migrationPattern,
                name: "Coordinated Migration",
                description: "Agents are showing coordinated movement patterns",
                affectedAgents: Set(migrationPatterns.flatMap { $0.involvedAgents }),
                strength: averageStrength,
                significance: averageStrength,
                timestamp: Date(),
                data: ["pattern_count": migrationPatterns.count]
            ))
        }
        
        return phenomena
    }
    
    private func analyzeBehavioralEmergence(_ patterns: [EmergencePattern]) -> [EmergentPhenomenon] {
        var phenomena: [EmergentPhenomenon] = []
        
        // Look for collective rituals
        let ritualPatterns = patterns.filter { $0.name.contains("ritual") || $0.name.contains("ceremony") }
        if let strongestRitual = ritualPatterns.max(by: { $0.strength < $1.strength }),
           strongestRitual.strength > 0.8 {
            
            phenomena.append(EmergentPhenomenon(
                id: UUID(),
                type: .collectiveRitual,
                name: "Collective Ritual",
                description: "Agents have spontaneously developed a collective ritual",
                affectedAgents: strongestRitual.involvedAgents,
                strength: strongestRitual.strength,
                significance: calculateSignificance(strongestRitual),
                timestamp: Date(),
                data: ["ritual_type": strongestRitual.name]
            ))
        }
        
        // Look for behavioral synchronization
        let syncPatterns = patterns.filter { $0.name.contains("synchron") || $0.name.contains("coordination") }
        if syncPatterns.count > 2,
           let averageStrength = calculateAverageStrength(syncPatterns),
           averageStrength > 0.7 {
            
            phenomena.append(EmergentPhenomenon(
                id: UUID(),
                type: .behavioralSync,
                name: "Behavioral Synchronization",
                description: "Agents have synchronized their behaviors",
                affectedAgents: Set(syncPatterns.flatMap { $0.involvedAgents }),
                strength: averageStrength,
                significance: averageStrength,
                timestamp: Date(),
                data: ["sync_patterns": syncPatterns.count]
            ))
        }
        
        return phenomena
    }
    
    // MARK: - Cross-Category Analysis
    
    private func analyzeCrossCategoryEmergence(patterns: [EmergencePattern]) -> [EmergentPhenomenon] {
        var phenomena: [EmergentPhenomenon] = []
        
        // Look for multi-dimensional emergence (patterns spanning categories)
        let categoryGroups = Dictionary(grouping: patterns) { $0.category }
        
        if categoryGroups.keys.count >= 3 {
            // Check for systemic emergence
            let systemicEmergence = analyzeSystemicEmergence(categoryGroups)
            phenomena.append(contentsOf: systemicEmergence)
        }
        
        // Look for feedback loops between categories
        let feedbackEmergence = analyzeFeedbackLoops(patterns)
        phenomena.append(contentsOf: feedbackEmergence)
        
        return phenomena
    }
    
    private func analyzeSystemicEmergence(_ categoryGroups: [PatternCategory: [EmergencePattern]]) -> [EmergentPhenomenon] {
        var phenomena: [EmergentPhenomenon] = []
        
        // Calculate systemic coherence
        var totalStrength: Float = 0
        var patternCount = 0
        var allInvolvedAgents: Set<UUID> = []
        
        for (_, patterns) in categoryGroups {
            for pattern in patterns {
                totalStrength += pattern.strength
                patternCount += 1
                allInvolvedAgents.formUnion(pattern.involvedAgents)
            }
        }
        
        let averageStrength = patternCount > 0 ? totalStrength / Float(patternCount) : 0
        
        if averageStrength > 0.75 && categoryGroups.keys.count >= 3 {
            phenomena.append(EmergentPhenomenon(
                id: UUID(),
                type: .systemicEmergence,
                name: "Systemic Coherence",
                description: "Multiple systems are showing coordinated emergence",
                affectedAgents: allInvolvedAgents,
                strength: averageStrength,
                significance: averageStrength * Float(categoryGroups.keys.count) / 5.0,
                timestamp: Date(),
                data: [
                    "categories_involved": categoryGroups.keys.count,
                    "total_patterns": patternCount,
                    "coherence_score": averageStrength
                ]
            ))
        }
        
        return phenomena
    }
    
    private func analyzeFeedbackLoops(_ patterns: [EmergencePattern]) -> [EmergentPhenomenon] {
        var phenomena: [EmergentPhenomenon] = []
        
        // Look for reinforcing patterns across categories
        let socialPatterns = patterns.filter { $0.category == .social }
        let culturalPatterns = patterns.filter { $0.category == .cultural }
        let economicPatterns = patterns.filter { $0.category == .economic }
        
        // Check for social-cultural feedback
        if !socialPatterns.isEmpty && !culturalPatterns.isEmpty {
            let commonAgents = findCommonAgents(socialPatterns, culturalPatterns)
            if commonAgents.count > 3 {
                let avgStrength = ((calculateAverageStrength(socialPatterns) ?? 0) + 
                                 (calculateAverageStrength(culturalPatterns) ?? 0)) / 2
                
                if avgStrength > 0.6 {
                    phenomena.append(EmergentPhenomenon(
                        id: UUID(),
                        type: .feedbackLoop,
                        name: "Social-Cultural Feedback Loop",
                        description: "Social and cultural patterns are reinforcing each other",
                        affectedAgents: commonAgents,
                        strength: avgStrength,
                        significance: avgStrength * 1.2,
                        timestamp: Date(),
                        data: ["feedback_type": "social_cultural"]
                    ))
                }
            }
        }
        
        return phenomena
    }
    
    // MARK: - Metrics and Analysis
    
    private func updateEmergenceMetrics() {
        let recentPhenomena = detectedPhenomena.suffix(50)
        
        emergenceMetrics = EmergenceMetrics(
            totalPhenomena: detectedPhenomena.count,
            averageSignificance: calculateAverageSignificance(Array(recentPhenomena)),
            phenomenaByType: getPhenomenaCountByType(Array(recentPhenomena)),
            emergenceRate: calculateEmergenceRate(),
            systemComplexity: complexityScore
        )
    }
    
    private func updateComplexityScore() {
        guard !observationWindow.isEmpty else { return }
        
        // Calculate complexity based on various factors
        let agentDiversity = calculateAgentDiversity()
        let relationshipComplexity = calculateRelationshipComplexity()
        let culturalComplexity = calculateCulturalComplexity()
        let spatialComplexity = calculateSpatialComplexity()
        let emergentComplexity = calculateEmergentComplexity()
        
        complexityScore = (agentDiversity * 0.2 +
                          relationshipComplexity * 0.3 +
                          culturalComplexity * 0.2 +
                          spatialComplexity * 0.1 +
                          emergentComplexity * 0.2)
    }
    
    private func calculateAgentDiversity() -> Float {
        guard let latestObservation = observationWindow.last else { return 0 }
        
        let agents = latestObservation.agentStates
        guard !agents.isEmpty else { return 0 }
        
        // Simple diversity measure based on emotional states
        var emotionCounts: [String: Int] = [:]
        for agent in agents {
            let emotion = agent.emotion.dominantFeeling.rawValue
            emotionCounts[emotion, default: 0] += 1
        }
        
        // Shannon entropy for diversity
        let total = Float(agents.count)
        var entropy: Float = 0
        
        for count in emotionCounts.values {
            let p = Float(count) / total
            if p > 0 {
                entropy -= p * log2(p)
            }
        }
        
        return entropy / log2(Float(emotionCounts.keys.count))
    }
    
    private func calculateRelationshipComplexity() -> Float {
        guard let latestObservation = observationWindow.last else { return 0 }
        
        let relationships = latestObservation.relationships
        guard !relationships.isEmpty else { return 0 }
        
        // Measure relationship complexity
        var totalComplexity: Float = 0
        
        for relationship in relationships {
            // Complexity based on multiple dimensions being active
            let dimensions = [
                relationship.dimensions.affection,
                relationship.dimensions.trust,
                relationship.dimensions.intimacy,
                relationship.dimensions.conflict
            ]
            
            let activeDimensions = dimensions.filter { abs($0) > 0.2 }.count
            totalComplexity += Float(activeDimensions) / 4.0
        }
        
        return totalComplexity / Float(relationships.count)
    }
    
    private func calculateCulturalComplexity() -> Float {
        guard let latestObservation = observationWindow.last else { return 0 }
        
        let memes = latestObservation.culturalMemes
        guard !memes.isEmpty else { return 0 }
        
        // Cultural complexity based on meme diversity and interactions
        let uniqueCarriers = Set(memes.flatMap { $0.carriers })
        let averageCarriers = Float(memes.reduce(0) { $0 + $1.carriers.count }) / Float(memes.count)
        
        return min(1.0, (Float(uniqueCarriers.count) / 10.0) * (averageCarriers / 5.0))
    }
    
    private func calculateSpatialComplexity() -> Float {
        // Simplified spatial complexity
        return 0.5 // Placeholder
    }
    
    private func calculateEmergentComplexity() -> Float {
        let recentPhenomena = detectedPhenomena.suffix(20)
        guard !recentPhenomena.isEmpty else { return 0 }
        
        let averageSignificance = recentPhenomena.reduce(0) { $0 + $1.significance } / Float(recentPhenomena.count)
        let typeCount = Set(recentPhenomena.map { $0.type }).count
        
        return averageSignificance * Float(typeCount) / Float(EmergentPhenomenonType.allCases.count)
    }
    
    // MARK: - Helper Functions
    
    private func calculateSignificance(_ pattern: EmergencePattern) -> Float {
        let strengthComponent = pattern.strength * 0.6
        let sizeComponent = min(1.0, Float(pattern.involvedAgents.count) / 10.0) * 0.4
        return strengthComponent + sizeComponent
    }
    
    private func calculateMovementSignificance(_ participantCount: Int) -> Float {
        return min(1.0, Float(participantCount) / 8.0)
    }
    
    private func calculateAverageStrength(_ patterns: [EmergencePattern]) -> Float? {
        guard !patterns.isEmpty else { return nil }
        return patterns.reduce(0) { $0 + $1.strength } / Float(patterns.count)
    }
    
    private func findCommonAgents(_ patterns1: [EmergencePattern], _ patterns2: [EmergencePattern]) -> Set<UUID> {
        let agents1 = Set(patterns1.flatMap { $0.involvedAgents })
        let agents2 = Set(patterns2.flatMap { $0.involvedAgents })
        return agents1.intersection(agents2)
    }
    
    private func calculateAverageSignificance(_ phenomena: [EmergentPhenomenon]) -> Float {
        guard !phenomena.isEmpty else { return 0 }
        return phenomena.reduce(0) { $0 + $1.significance } / Float(phenomena.count)
    }
    
    private func getPhenomenaCountByType(_ phenomena: [EmergentPhenomenon]) -> [EmergentPhenomenonType: Int] {
        return Dictionary(grouping: phenomena) { $0.type }
            .mapValues { $0.count }
    }
    
    private func calculateEmergenceRate() -> Float {
        let recentWindow = 24 * 60 // Last 24 hours in minutes
        let cutoffTime = Date().addingTimeInterval(-TimeInterval(recentWindow * 60))
        
        let recentPhenomena = detectedPhenomena.filter { $0.timestamp > cutoffTime }
        return Float(recentPhenomena.count) / Float(recentWindow) * 60 // Per hour
    }
    
    private func cleanupOldPhenomena() {
        let cutoffTime = Date().addingTimeInterval(-7 * 24 * 60 * 60) // Keep for 7 days
        detectedPhenomena.removeAll { $0.timestamp < cutoffTime }
    }
}

// MARK: - Supporting Types

struct WorldObservation {
    let timestamp: Date
    let agentStates: [AgentState]
    let relationships: [Relationship]
    let economicActivity: [Transaction]
    let culturalMemes: [CulturalMeme]
    let collectiveMood: Float
}

struct WorldObservations {
    let agentStates: [AgentState]
    let relationships: [Relationship]
    let economicActivity: [Transaction]
    let culturalMemes: [CulturalMeme]
    let collectiveMood: Float
}

struct EmergentPhenomenon: Identifiable {
    let id: UUID
    let type: EmergentPhenomenonType
    let name: String
    let description: String
    let affectedAgents: Set<UUID>
    let strength: Float
    let significance: Float
    let timestamp: Date
    let data: [String: Any]
    
    var ageInHours: Int {
        Int(Date().timeIntervalSince(timestamp) / 3600)
    }
    
    var participantCount: Int {
        affectedAgents.count
    }
    
    var participants: Set<UUID> {
        affectedAgents
    }
}

enum EmergentPhenomenonType: String, CaseIterable {
    case socialStructure = "Social Structure"
    case socialMovement = "Social Movement"
    case newTradition = "New Tradition"
    case culturalShift = "Cultural Shift"
    case economicSpecialization = "Economic Specialization"
    case marketEmergence = "Market Emergence"
    case territoryFormation = "Territory Formation"
    case migrationPattern = "Migration Pattern"
    case collectiveRitual = "Collective Ritual"
    case behavioralSync = "Behavioral Sync"
    case systemicEmergence = "Systemic Emergence"
    case feedbackLoop = "Feedback Loop"
    case economicTrend = "Economic Trend"
    case collectiveMood = "Collective Mood"
    case spontaneousOrganization = "Spontaneous Organization"
    case informationCascade = "Information Cascade"
    case behavioralContagion = "Behavioral Contagion"
}

struct EmergencePattern: Identifiable {
    let id = UUID()
    let name: String
    let category: PatternCategory
    let strength: Float
    let involvedAgents: Set<UUID>
    let timestamp: Date
    let duration: TimeInterval
    let data: [String: Any]
}

enum PatternCategory {
    case social, cultural, economic, spatial, behavioral
}

struct EmergenceMetrics {
    let totalPhenomena: Int
    let averageSignificance: Float
    let phenomenaByType: [EmergentPhenomenonType: Int]
    let emergenceRate: Float
    let systemComplexity: Float
    
    init() {
        self.totalPhenomena = 0
        self.averageSignificance = 0
        self.phenomenaByType = [:]
        self.emergenceRate = 0
        self.systemComplexity = 0
    }
    
    init(totalPhenomena: Int, averageSignificance: Float, phenomenaByType: [EmergentPhenomenonType: Int], emergenceRate: Float, systemComplexity: Float) {
        self.totalPhenomena = totalPhenomena
        self.averageSignificance = averageSignificance
        self.phenomenaByType = phenomenaByType
        self.emergenceRate = emergenceRate
        self.systemComplexity = systemComplexity
    }
}

// MARK: - Pattern Detectors

protocol PatternDetector {
    func detectPatterns(in observations: [WorldObservation]) -> [EmergencePattern]
}

class SocialPatternDetector: PatternDetector {
    func detectPatterns(in observations: [WorldObservation]) -> [EmergencePattern] {
        var patterns: [EmergencePattern] = []
        
        // Detect social hierarchy formation
        if let hierarchyPattern = detectHierarchyFormation(observations) {
            patterns.append(hierarchyPattern)
        }
        
        // Detect collective movements
        if let movementPattern = detectCollectiveMovement(observations) {
            patterns.append(movementPattern)
        }
        
        return patterns
    }
    
    private func detectHierarchyFormation(_ observations: [WorldObservation]) -> EmergencePattern? {
        guard observations.count > 5 else { return nil }
        
        // Look for consistent respect patterns
        var respectHierarchy: [UUID: Float] = [:]
        
        for observation in observations.suffix(5) {
            for relationship in observation.relationships {
                respectHierarchy[relationship.otherAgentId, default: 0] += relationship.dimensions.respect
            }
        }
        
        let sortedByRespect = respectHierarchy.sorted { $0.value > $1.value }
        
        if sortedByRespect.count > 3 {
            let topRespect = sortedByRespect[0].value
            let secondRespect = sortedByRespect[1].value
            
            if topRespect > secondRespect * 1.5 {
                return EmergencePattern(
                    name: "Social Hierarchy",
                    category: .social,
                    strength: min(1.0, topRespect / 5.0),
                    involvedAgents: Set(respectHierarchy.keys),
                    timestamp: Date(),
                    duration: 0,
                    data: ["hierarchy_strength": topRespect]
                )
            }
        }
        
        return nil
    }
    
    private func detectCollectiveMovement(_ observations: [WorldObservation]) -> EmergencePattern? {
        // Simplified collective movement detection
        guard observations.count > 3 else { return nil }
        
        let recentObservations = observations.suffix(3)
        var moodAlignment: Float = 0
        var participantCount = 0
        
        for observation in recentObservations {
            if observation.collectiveMood > 0.6 || observation.collectiveMood < -0.6 {
                moodAlignment += abs(observation.collectiveMood)
                participantCount = observation.agentStates.count
            }
        }
        
        moodAlignment /= Float(recentObservations.count)
        
        if moodAlignment > 0.7 && participantCount > 5 {
            return EmergencePattern(
                name: "Collective Movement",
                category: .social,
                strength: moodAlignment,
                involvedAgents: Set(recentObservations.last?.agentStates.map { $0.id } ?? []),
                timestamp: Date(),
                duration: 0,
                data: ["mood_alignment": moodAlignment]
            )
        }
        
        return nil
    }
}

class CulturalPatternDetector: PatternDetector {
    func detectPatterns(in observations: [WorldObservation]) -> [EmergencePattern] {
        var patterns: [EmergencePattern] = []
        
        if let traditionPattern = detectTraditionFormation(observations) {
            patterns.append(traditionPattern)
        }
        
        if let consensusPattern = detectBeliefConsensus(observations) {
            patterns.append(consensusPattern)
        }
        
        return patterns
    }
    
    private func detectTraditionFormation(_ observations: [WorldObservation]) -> EmergencePattern? {
        guard observations.count > 10 else { return nil }
        
        // Track meme persistence
        var memeCarrierHistory: [UUID: [Int]] = [:]
        
        for observation in observations {
            for meme in observation.culturalMemes {
                memeCarrierHistory[meme.id, default: []].append(meme.carriers.count)
            }
        }
        
        // Look for memes with growing, stable carrier base
        for (memeId, carrierHistory) in memeCarrierHistory {
            if carrierHistory.count > 5 {
                let recentAverage = Float(carrierHistory.suffix(3).reduce(0, +)) / 3.0
                let olderAverage = Float(carrierHistory.prefix(3).reduce(0, +)) / 3.0
                
                if recentAverage > olderAverage * 1.5 && recentAverage > 3 {
                    let meme = observations.last?.culturalMemes.first { $0.id == memeId }
                    
                    return EmergencePattern(
                        name: "Cultural Tradition",
                        category: .cultural,
                        strength: min(1.0, recentAverage / 8.0),
                        involvedAgents: meme?.carriers ?? Set(),
                        timestamp: Date(),
                        duration: 0,
                        data: ["meme_id": memeId, "carrier_growth": recentAverage / max(olderAverage, 1)]
                    )
                }
            }
        }
        
        return nil
    }
    
    private func detectBeliefConsensus(_ observations: [WorldObservation]) -> EmergencePattern? {
        // Simplified belief consensus detection
        guard let latestObservation = observations.last else { return nil }
        
        let moodConsensus = abs(latestObservation.collectiveMood)
        if moodConsensus > 0.8 {
            return EmergencePattern(
                name: "Belief Consensus",
                category: .cultural,
                strength: moodConsensus,
                involvedAgents: Set(latestObservation.agentStates.map { $0.id }),
                timestamp: Date(),
                duration: 0,
                data: ["consensus_mood": latestObservation.collectiveMood]
            )
        }
        
        return nil
    }
}

class EconomicPatternDetector: PatternDetector {
    func detectPatterns(in observations: [WorldObservation]) -> [EmergencePattern] {
        var patterns: [EmergencePattern] = []
        
        if let specializationPattern = detectSpecialization(observations) {
            patterns.append(specializationPattern)
        }
        
        if let marketPattern = detectMarketFormation(observations) {
            patterns.append(marketPattern)
        }
        
        return patterns
    }
    
    private func detectSpecialization(_ observations: [WorldObservation]) -> EmergencePattern? {
        guard observations.count > 5 else { return nil }
        
        // Track economic activity patterns
        var activityHistory: [String: Int] = [:]
        
        for observation in observations.suffix(5) {
            for transaction in observation.economicActivity {
                activityHistory[transaction.resource, default: 0] += 1
            }
        }
        
        if let dominantResource = activityHistory.max(by: { $0.value < $1.value }) {
            let specialization = Float(dominantResource.value) / Float(max(1, activityHistory.values.reduce(0, +)))
            
            if specialization > 0.6 {
                return EmergencePattern(
                    name: "Economic Specialization",
                    category: .economic,
                    strength: specialization,
                    involvedAgents: Set(), // Would need to track specific agents
                    timestamp: Date(),
                    duration: 0,
                    data: ["resource": dominantResource.key, "specialization_ratio": specialization]
                )
            }
        }
        
        return nil
    }
    
    private func detectMarketFormation(_ observations: [WorldObservation]) -> EmergencePattern? {
        guard observations.count > 3 else { return nil }
        
        let recentTransactionCounts = observations.suffix(3).map { $0.economicActivity.count }
        let averageTransactions = Float(recentTransactionCounts.reduce(0, +)) / 3.0
        
        if averageTransactions > 5 {
            return EmergencePattern(
                name: "Market Formation",
                category: .economic,
                strength: min(1.0, averageTransactions / 10.0),
                involvedAgents: Set(), // Would need transaction participants
                timestamp: Date(),
                duration: 0,
                data: ["transaction_volume": averageTransactions]
            )
        }
        
        return nil
    }
}

class SpatialPatternDetector: PatternDetector {
    func detectPatterns(in observations: [WorldObservation]) -> [EmergencePattern] {
        // Simplified spatial pattern detection
        return []
    }
}

class BehavioralPatternDetector: PatternDetector {
    func detectPatterns(in observations: [WorldObservation]) -> [EmergencePattern] {
        var patterns: [EmergencePattern] = []
        
        if let ritualPattern = detectCollectiveRitual(observations) {
            patterns.append(ritualPattern)
        }
        
        return patterns
    }
    
    private func detectCollectiveRitual(_ observations: [WorldObservation]) -> EmergencePattern? {
        guard observations.count > 5 else { return nil }
        
        // Look for synchronized emotional states
        var emotionSyncCount = 0
        let recentObservations = observations.suffix(3)
        
        for observation in recentObservations {
            let emotions = observation.agentStates.map { $0.emotion.dominantFeeling }
            let emotionCounts = Dictionary(grouping: emotions) { $0 }
            
            if let dominantEmotion = emotionCounts.max(by: { $0.value.count < $1.value.count }) {
                let dominance = Float(dominantEmotion.value.count) / Float(emotions.count)
                if dominance > 0.7 {
                    emotionSyncCount += 1
                }
            }
        }
        
        if emotionSyncCount >= 2 {
            return EmergencePattern(
                name: "Collective Ritual",
                category: .behavioral,
                strength: Float(emotionSyncCount) / 3.0,
                involvedAgents: Set(recentObservations.last?.agentStates.map { $0.id } ?? []),
                timestamp: Date(),
                duration: 0,
                data: ["sync_frequency": emotionSyncCount]
            )
        }
        
        return nil
    }
}