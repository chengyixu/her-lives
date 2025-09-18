//
//  MemoryStream.swift
//  Her Lives
//
//  The breathing memory stream - memories that live, fade, and resurface
//  Based on Stanford's Generative Agents but enhanced with emotional coloring
//

import Foundation
import SwiftUI

class MemoryStream: ObservableObject {
    // MARK: - Properties
    let agentId: UUID
    @Published var stream: [Memory] = []
    @Published var reflections: [MemoryReflection] = []
    @Published var shortTerm: [Memory] = []
    @Published var longTerm: [Memory] = []
    @Published var dreams: [DreamMemory] = []
    
    // Memory indices for fast retrieval
    private var temporalIndex: [Date: [Memory]] = [:]
    private var emotionalIndex: [EmotionType: [Memory]] = [:]
    private var socialIndex: [UUID: [Memory]] = [:]
    private var spatialIndex: [Position: [Memory]] = [:]
    
    // Memory rhythms (circadian influence on encoding)
    private var encodingStrength: Float = 1.0
    private var retrievalBias: RetrievalBias = .balanced
    
    // Stanford's three scoring dimensions
    private let importanceCalculator = ImportanceCalculator.self
    private let recencyDecay = RecencyDecay.self
    private let relevanceEngine = RelevanceEngine.self
    
    // Current consciousness state affects memory
    var consciousnessState: ConsciousnessState.State = .awake {
        didSet {
            updateEncodingStrength()
        }
    }
    
    // MARK: - Initialization
    init(agentId: UUID) {
        self.agentId = agentId
        setupMemoryRhythms()
    }
    
    private func setupMemoryRhythms() {
        // Memory encoding varies throughout the day
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            self.updateMemoryRhythms()
        }
    }
    
    // MARK: - Memory Encoding
    func encode(_ perception: Perception) {
        let memory = createMemory(from: perception)
        
        // Apply encoding strength based on consciousness
        var mutableMemory = memory
        mutableMemory.encodingStrength *= encodingStrength
        
        // Check for prediction error (surprising events are better remembered)
        if let predictionError = calculatePredictionError(perception) {
            if predictionError > 0.5 {
                mutableMemory.importance *= 1.5
                mutableMemory.addTag("surprising")
            }
        }
        
        // Emotional modulation (emotional events are better remembered)
        let emotionalIntensity = perception.emotionalValence.magnitude
        mutableMemory.importance *= (1.0 + emotionalIntensity * 0.5)
        
        let finalMemory = mutableMemory
        
        // Add to stream
        stream.append(finalMemory)
        shortTerm.append(finalMemory)
        
        // Update indices
        updateIndices(with: finalMemory)
        
        // Trigger associations
        triggerAssociations(finalMemory)
        
        // Check if this should trigger reflection
        checkReflectionTrigger()
    }
    
    private func createMemory(from perception: Perception) -> Memory {
        let memory = Memory(
            id: UUID(),
            timestamp: Date(),
            content: perception.content,
            type: mapPerceptionTypeToMemoryType(perception.type),
            
            // Stanford's scoring system
            importance: importanceCalculator.calculate(perception),
            recency: 1.0,
            relevance: 0.0,
            
            // Emotional imprint
            emotionalValence: perception.emotionalValence,
            emotionalIntensity: perception.emotionalIntensity ?? 0.5,
            
            // Context
            location: perception.location,
            participants: perception.participants,
            
            // Cognitive tags
            tags: generateTags(from: perception),
            
            // Subjective time (time perception varies with emotional state)
            subjectiveTime: calculateSubjectiveTime()
        )
        
        return memory
    }
    
    // MARK: - Memory Retrieval (Stanford's approach)
    func retrieve(query: String? = nil, context: Context? = nil, k: Int = 10) -> [Memory] {
        var scoredMemories: [(Memory, Float)] = []
        
        for memory in stream + reflections.map({ $0.asMemory() }) {
            // Calculate Stanford's three scores
            let recencyScore = recencyDecay.calculate(memory.timestamp)
            let importanceScore = memory.importance
            let relevanceScore = query != nil ? 
                relevanceEngine.calculate(memory, query: query!) : 
                relevanceEngine.calculateContextual(memory, context: context)
            
            // Combined score (Stanford's formula)
            let combinedScore = recencyScore + importanceScore + relevanceScore
            
            scoredMemories.append((memory, combinedScore))
        }
        
        // Sort by score and return top k
        scoredMemories.sort { $0.1 > $1.1 }
        return Array(scoredMemories.prefix(k).map { $0.0 })
    }
    
    // MARK: - Reflection Generation (Stanford's approach)
    func shouldReflect() -> Bool {
        // Sum importance of recent memories
        let recentMemories = stream.suffix(100)
        let importanceSum = recentMemories.reduce(0) { $0 + $1.importance }
        
        // Stanford's threshold is 150
        return importanceSum > 150
    }
    
    func generateReflectionQuestions() -> [String] {
        let recentMemories = stream.suffix(100)
        
        // Analyze recent memories for patterns
        let themes = extractThemes(from: Array(recentMemories))
        let emotions = extractEmotionalPatterns(from: Array(recentMemories))
        let socialPatterns = extractSocialPatterns(from: Array(recentMemories))
        
        var questions: [String] = []
        
        // Theme-based questions
        for theme in themes.prefix(2) {
            questions.append("What does my focus on \(theme) reveal about me?")
        }
        
        // Emotion-based questions
        if let dominantEmotion = emotions.first {
            questions.append("Why have I been feeling \(dominantEmotion) lately?")
        }
        
        // Social-based questions
        if let pattern = socialPatterns.first {
            questions.append("What does my relationship with \(pattern) mean to me?")
        }
        
        // Stanford's style: "What are 3 most salient high-level questions?"
        return Array(questions.prefix(3))
    }
    
    func createReflection(question: String, evidence: [Memory]) -> MemoryReflection {
        let insight = synthesizeInsight(from: evidence, addressing: question)
        
        let reflection = MemoryReflection(
            id: UUID(),
            timestamp: Date(),
            question: question,
            insight: insight,
            evidence: evidence.map { $0.id },
            confidence: calculateConfidence(evidence),
            abstractionLevel: determineAbstractionLevel(insight),
            emotionalTone: aggregateEmotionalTone(evidence)
        )
        
        reflections.append(reflection)
        
        // Reflections can reference other reflections (recursive structure)
        checkForMetaReflection(reflection)
        
        return reflection
    }
    
    // MARK: - Association & Ripple Effects
    private func triggerAssociations(_ newMemory: Memory) {
        // Find related memories
        let related = findRelatedMemories(to: newMemory)
        
        for i in stream.indices {
            let memory = stream[i]
            if related.contains(where: { $0.id == memory.id }) {
                // Increase relevance of related memories
                stream[i].relevance += 0.1
                stream[i].lastActivated = Date()
                
                // Strong associations might trigger spontaneous recall
                if stream[i].relevance > 0.8 {
                    triggerSpontaneousRecall(stream[i])
                }
            }
        }
    }
    
    private func findRelatedMemories(to memory: Memory) -> [Memory] {
        var related: [Memory] = []
        
        // Temporal proximity
        let hour = Calendar.current.component(.hour, from: memory.timestamp)
        let roundedTime = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: memory.timestamp) ?? memory.timestamp
        related.append(contentsOf: temporalIndex[roundedTime] ?? [])
        
        // Emotional similarity
        if let emotionType = memory.dominantEmotion {
            related.append(contentsOf: emotionalIndex[emotionType] ?? [])
        }
        
        // Social connections
        for participant in memory.participants {
            related.append(contentsOf: socialIndex[participant] ?? [])
        }
        
        // Spatial proximity
        if let location = memory.location {
            related.append(contentsOf: spatialIndex[location] ?? [])
        }
        
        // Semantic similarity (simplified)
        related.append(contentsOf: findSemanticallySimilar(memory))
        
        return Array(Set(related).prefix(20)) // Limit associations
    }
    
    // MARK: - Memory Consolidation
    func consolidate() {
        // Move important short-term memories to long-term
        let threshold: Float = 0.6
        
        for memory in shortTerm where memory.importance > threshold {
            moveToLongTerm(memory)
        }
        
        // Compress old memories (keep gist, lose details)
        compressOldMemories()
        
        // Strengthen repeated patterns
        reinforcePatterns()
        
        // Clean up weak memories
        forget(threshold: 0.2)
    }
    
    func moveToLongTerm(_ memory: Memory) {
        if let index = shortTerm.firstIndex(where: { $0.id == memory.id }) {
            shortTerm.remove(at: index)
            longTerm.append(memory)
            
            // Long-term memories decay slower
            var mutableMemory = memory
            mutableMemory.decayRate *= 0.5
            longTerm[longTerm.count - 1] = mutableMemory
        }
    }
    
    private func compressOldMemories() {
        let oldThreshold = Date().addingTimeInterval(-7 * 24 * 60 * 60) // 1 week
        
        for i in longTerm.indices where longTerm[i].timestamp < oldThreshold {
            if longTerm[i].compressionLevel < 3 {
                longTerm[i].compress()
            }
        }
    }
    
    // MARK: - Dream Processing
    func addDream(_ dreamContent: DreamContent) {
        let dreamMemory = DreamMemory(
            content: dreamContent,
            timestamp: Date(),
            emotionalResidue: dreamContent.emotionalTone,
            symbols: dreamContent.extractSymbols()
        )
        
        dreams.append(dreamMemory)
        
        // Dreams can influence waking memories
        if dreamContent.isSignificant {
            processDreamInfluence(dreamContent)
        }
    }
    
    private func processDreamInfluence(_ dream: DreamContent) {
        // Find memories related to dream content
        let relatedMemories = findMemoriesRelatedTo(dream)
        
        for i in stream.indices {
            let memory = stream[i]
            if relatedMemories.contains(where: { $0.id == memory.id }) {
                // Dreams can strengthen or weaken memories
                if dream.reinforces(memory) {
                    stream[i].importance += 0.1
                } else if dream.conflicts(with: memory) {
                    stream[i].confidence -= 0.1
                }
                
                // Dreams can create new associations
                if let newAssociation = dream.suggestAssociation(for: memory) {
                    stream[i].associations.append(newAssociation)
                }
            }
        }
    }
    
    // MARK: - Forgetting
    func forget(threshold: Float) {
        // Natural forgetting curve
        let now = Date()
        
        stream = stream.filter { memory in
            let timeSince = now.timeIntervalSince(memory.timestamp)
            let retentionProbability = memory.importance * exp(-memory.decayRate * Float(timeSince))
            
            // Emotional memories are harder to forget
            let emotionalBonus = memory.emotionalIntensity * 0.3
            
            return retentionProbability + emotionalBonus > threshold
        }
        
        // Clean up indices
        cleanupIndices()
    }
    
    // MARK: - Special Memory Types
    func recordAction(_ action: Action) {
        let actionMemory = Memory(
            id: UUID(),
            timestamp: Date(),
            content: "I \(action.description)",
            type: .action,
            importance: action.importance ?? 0.3,
            recency: 1.0,
            relevance: 0.0,
            emotionalValence: 0.0,
            emotionalIntensity: 0.1
        )
        
        var mutableActionMemory = actionMemory
        mutableActionMemory.addTag("self-initiated")
        stream.append(mutableActionMemory)
    }
    
    func addInformation(_ info: Information) {
        let infoMemory = Memory(
            id: UUID(),
            timestamp: Date(),
            content: info.content,
            type: .semantic,
            importance: info.importance,
            recency: 1.0,
            relevance: info.relevance ?? 0.0,
            emotionalValence: 0.0,
            emotionalIntensity: 0.1,
            source: info.source
        )
        
        stream.append(infoMemory)
    }
    
    func addReflection(_ reflection: MemoryReflection) {
        reflections.append(reflection)
        
        // Add to stream as well for retrieval
        let reflectionMemory = reflection.asMemory()
        stream.append(reflectionMemory)
    }
    
    // MARK: - Helper Functions
    private func calculatePredictionError(_ perception: Perception) -> Float? {
        // Compare perception with expected state
        guard let prediction = getLastPrediction() else { return nil }
        
        return perception.calculateDifference(from: prediction)
    }
    
    private func calculateSubjectiveTime() -> TimeInterval {
        // Time perception varies with emotional state and attention
        let baseTime = Date().timeIntervalSince1970
        let emotionalEffect = (1.0 + emotionalModulation())
        let attentionEffect = (1.0 + attentionModulation())
        
        return baseTime * emotionalEffect * attentionEffect
    }
    
    private func updateEncodingStrength() {
        switch consciousnessState {
        case .awake:
            encodingStrength = 1.0
        case .drowsy:
            encodingStrength = 0.7
        case .sleeping:
            encodingStrength = 0.3
        case .dreaming:
            encodingStrength = 1.5 // Dreams can be vivid
        default:
            encodingStrength = 0.8
        }
    }
    
    func getRecentImportanceSum() -> Float {
        stream.suffix(100).reduce(0) { $0 + $1.importance }
    }
    
    func getRandomMemories(count: Int) -> [Memory] {
        Array(stream.shuffled().prefix(count))
    }
    
    func seedWithBackstory() {
        // Create some initial memories to give the agent a past
        let backstoryMemories = BackstoryGenerator.generate(for: agentId)
        stream.append(contentsOf: backstoryMemories)
        
        // Some go directly to long-term
        let importantBackstory = backstoryMemories.filter { $0.importance > 0.7 }
        longTerm.append(contentsOf: importantBackstory)
    }
    func strengthenImportantMemories() {
        for i in stream.indices {
            if stream[i].importance > 0.7 {
                stream[i].importance = min(1.0, stream[i].importance + 0.05)
            }
        }
    }
    
    func getRecentMemories(count: Int) -> [Memory] {
        return stream.sorted { $0.timestamp > $1.timestamp }.prefix(count).map { $0 }
    }
    
    func addMemory(_ memory: Memory) {
        stream.append(memory)
        shortTerm.append(memory)
        
        // Maintain stream size
        if stream.count > 1000 {
            stream.removeFirst()
        }
        
        // Maintain short-term size
        if shortTerm.count > 100 {
            shortTerm.removeFirst()
        }
    }
    
    func consolidateMemories() -> Int {
        let beforeCount = shortTerm.count
        consolidate()
        return beforeCount - shortTerm.count
    }
    
    // Missing helper methods
    private func mapPerceptionTypeToMemoryType(_ type: CorePerception.PerceptionType) -> MemoryType {
        switch type {
        case .visual: return .observation
        case .auditory: return .observation
        case .social: return .social
        case .environmental: return .observation
        case .internalSense: return .reflection
        }
    }
    
    private func generateTags(from perception: CorePerception) -> [String] {
        var tags: [String] = []
        
        if perception.importance > 0.7 {
            tags.append("important")
        }
        if abs(perception.emotionalValence) > 0.5 {
            tags.append("emotional")
        }
        if !perception.participants.isEmpty {
            tags.append("social")
        }
        
        return tags
    }
    
    private func getLastPrediction() -> CorePerception? {
        return nil // Placeholder
    }
    
    private func emotionalModulation() -> Double {
        return 0.0 // Placeholder
    }
    
    private func attentionModulation() -> Double {
        return 0.0 // Placeholder
    }
    
    private func updateMemoryRhythms() {
        // Update memory encoding based on time of day
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 6...9: // Morning peak
            encodingStrength = 1.2
        case 22...24: // Evening decline
            encodingStrength = 0.8
        default:
            encodingStrength = 1.0
        }
    }
    
    private func updateIndices(with memory: Memory) {
        // Update temporal index
        let hour = Calendar.current.component(.hour, from: memory.timestamp)
        let roundedTime = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: memory.timestamp) ?? memory.timestamp
        temporalIndex[roundedTime, default: []].append(memory)
        
        // Update emotional index
        if let emotion = memory.dominantEmotion {
            emotionalIndex[emotion, default: []].append(memory)
        }
        
        // Update social index
        for participant in memory.participants {
            socialIndex[participant, default: []].append(memory)
        }
        
        // Update spatial index
        if let location = memory.location {
            spatialIndex[location, default: []].append(memory)
        }
    }
    
    private func checkReflectionTrigger() {
        if shouldReflect() {
            let questions = generateReflectionQuestions()
            // Could trigger reflection in agent
        }
    }
    
    private func triggerSpontaneousRecall(_ memory: Memory) {
        // Move memory back to the front of attention
        if let index = stream.firstIndex(where: { $0.id == memory.id }) {
            stream[index].lastActivated = Date()
            stream[index].importance = min(1.0, stream[index].importance + 0.1)
        }
    }
    
    private func findSemanticallySimilar(_ memory: Memory) -> [Memory] {
        // Simple semantic similarity based on content overlap
        let words = Set(memory.content.lowercased().components(separatedBy: " "))
        
        return stream.filter { other in
            let otherWords = Set(other.content.lowercased().components(separatedBy: " "))
            let intersection = words.intersection(otherWords)
            return intersection.count > 1 && other.id != memory.id
        }
    }
    
    private func reinforcePatterns() {
        // Strengthen memories that form patterns
        let recentMemories = stream.suffix(50)
        var patterns: [String: [Memory]] = [:]
        
        for memory in recentMemories {
            for tag in memory.tags {
                patterns[tag, default: []].append(memory)
            }
        }
        
        for (_, memories) in patterns {
            if memories.count > 3 {
                for memory in memories {
                    if let index = stream.firstIndex(where: { $0.id == memory.id }) {
                        stream[index].importance = min(1.0, stream[index].importance + 0.05)
                    }
                }
            }
        }
    }
    
    private func cleanupIndices() {
        // Remove references to forgotten memories from indices
        let memoryIds = Set(stream.map { $0.id })
        
        for (key, memories) in temporalIndex {
            temporalIndex[key] = memories.filter { memoryIds.contains($0.id) }
        }
        
        for (key, memories) in emotionalIndex {
            emotionalIndex[key] = memories.filter { memoryIds.contains($0.id) }
        }
        
        for (key, memories) in socialIndex {
            socialIndex[key] = memories.filter { memoryIds.contains($0.id) }
        }
        
        for (key, memories) in spatialIndex {
            spatialIndex[key] = memories.filter { memoryIds.contains($0.id) }
        }
    }
    
    private func extractThemes(from memories: [Memory]) -> [String] {
        var themeCounts: [String: Int] = [:]
        
        for memory in memories {
            for tag in memory.tags {
                themeCounts[tag, default: 0] += 1
            }
        }
        
        return themeCounts.sorted { $0.value > $1.value }.map { $0.key }
    }
    
    private func extractEmotionalPatterns(from memories: [Memory]) -> [String] {
        var emotionCounts: [EmotionType: Int] = [:]
        
        for memory in memories {
            if let emotion = memory.dominantEmotion {
                emotionCounts[emotion, default: 0] += 1
            }
        }
        
        return emotionCounts.sorted { $0.value > $1.value }.map { $0.key.rawValue }
    }
    
    private func extractSocialPatterns(from memories: [Memory]) -> [String] {
        var agentCounts: [UUID: Int] = [:]
        
        for memory in memories {
            for participant in memory.participants {
                agentCounts[participant, default: 0] += 1
            }
        }
        
        return agentCounts.sorted { $0.value > $1.value }.map { $0.key.uuidString }
    }
    
    private func synthesizeInsight(from evidence: [Memory], addressing question: String) -> String {
        // Simple insight synthesis based on evidence patterns
        let themes = extractThemes(from: evidence)
        let dominantTheme = themes.first ?? "experience"
        
        return "I notice patterns in my \(dominantTheme) that suggest \(question.lowercased())"
    }
    
    private func calculateConfidence(_ evidence: [Memory]) -> Float {
        let averageImportance = evidence.reduce(0) { $0 + $1.importance } / Float(max(1, evidence.count))
        return min(1.0, averageImportance)
    }
    
    private func determineAbstractionLevel(_ insight: String) -> Int {
        // Simple abstraction level based on insight complexity
        let words = insight.components(separatedBy: " ")
        let abstractWords = ["meaning", "purpose", "identity", "value", "belief"]
        let abstractCount = words.filter { abstractWords.contains($0.lowercased()) }.count
        
        return min(5, max(1, abstractCount + 1))
    }
    
    private func aggregateEmotionalTone(_ evidence: [Memory]) -> Float {
        guard !evidence.isEmpty else { return 0 }
        return evidence.reduce(0) { $0 + $1.emotionalValence } / Float(evidence.count)
    }
    
    private func checkForMetaReflection(_ reflection: MemoryReflection) {
        // Could generate meta-reflections about patterns in reflections
        if reflections.count > 5 {
            let recentReflections = reflections.suffix(5)
            let themes = recentReflections.map { $0.insight }
            // Could create meta-insight about thinking patterns
        }
    }
    
    private func findMemoriesRelatedTo(_ dream: DreamContent) -> [Memory] {
        // Find memories that might be related to dream content
        let dreamWords = Set(dream.narrative.lowercased().components(separatedBy: " "))
        
        return stream.filter { memory in
            let memoryWords = Set(memory.content.lowercased().components(separatedBy: " "))
            return !dreamWords.intersection(memoryWords).isEmpty
        }
    }
    
    // Duplicate methods removed - already exist above
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case agentId, stream, reflections, shortTerm, longTerm, dreams
    }
}

// MARK: - Supporting Types

struct DreamMemory: Identifiable {
    let id = UUID()
    let content: DreamContent
    let timestamp: Date
    let emotionalResidue: Float
    let symbols: [String]
}

// Additional missing extensions
extension DreamContent {
    var emotionalTone: Float {
        emotions.isEmpty ? 0 : emotions.reduce(0) { $0 + $1.intensity } / Float(emotions.count)
    }
    
    func extractSymbols() -> [String] {
        // Extract symbolic elements from dream narrative
        let words = narrative.lowercased().components(separatedBy: " ")
        let symbols = ["water", "flying", "falling", "house", "animal", "person", "light", "darkness"]
        return words.filter { symbols.contains($0) }
    }
    
    func reinforces(_ memory: Memory) -> Bool {
        // Check if dream reinforces a memory
        let dreamWords = Set(narrative.lowercased().components(separatedBy: " "))
        let memoryWords = Set(memory.content.lowercased().components(separatedBy: " "))
        return !dreamWords.intersection(memoryWords).isEmpty && emotionalTone * memory.emotionalValence > 0
    }
    
    func conflicts(with memory: Memory) -> Bool {
        // Check if dream conflicts with a memory
        let dreamWords = Set(narrative.lowercased().components(separatedBy: " "))
        let memoryWords = Set(memory.content.lowercased().components(separatedBy: " "))
        return !dreamWords.intersection(memoryWords).isEmpty && emotionalTone * memory.emotionalValence < 0
    }
    
    func suggestAssociation(for memory: Memory) -> UUID? {
        // Suggest new associations based on dream content
        if reinforces(memory) {
            return UUID() // Placeholder for new association
        }
        return nil
    }
}

// Additional missing types
struct Information {
    let content: String
    let source: String
    let importance: Float
    let relevance: Float?
}

// Memory-specific reflection type
struct MemoryReflection: Identifiable {
    let id: UUID
    let timestamp: Date
    let question: String
    let insight: String
    let evidence: [UUID]
    let confidence: Float
    let abstractionLevel: Int
    let emotionalTone: Float
    let type: ReflectionType = .general
    
    func asMemory() -> Memory {
        Memory(
            id: UUID(),
            timestamp: timestamp,
            content: insight,
            type: .reflection,
            importance: Float(abstractionLevel) / 5.0,
            recency: 1.0,
            relevance: 0.5,
            emotionalValence: emotionalTone,
            emotionalIntensity: abs(emotionalTone)
        )
    }
    
    var summary: String {
        "Reflected on: \(question) - \(insight)"
    }
    
    var insights: [MemoryReflection] {
        [self] // Simplified for now
    }
}

class BackstoryGenerator {
    static func generate(for agentId: UUID) -> [Memory] {
        let backstoryEvents = [
            "I remember growing up in a small community",
            "I learned to value friendship and cooperation",
            "I discovered my passion for learning new things",
            "I overcame a significant challenge that made me stronger",
            "I formed my first meaningful relationship"
        ]
        
        return backstoryEvents.enumerated().map { index, event in
            Memory(
                id: UUID(),
                timestamp: Date().addingTimeInterval(-TimeInterval(365 * 24 * 60 * 60)), // 1 year ago
                content: event,
                type: .reflection,
                importance: Float.random(in: 0.5...0.8),
                recency: 0.1,
                relevance: 0.7,
                emotionalValence: Float.random(in: -0.2...0.6),
                emotionalIntensity: Float.random(in: 0.3...0.7)
            )
        }
    }
}