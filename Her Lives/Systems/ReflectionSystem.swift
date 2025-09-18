//
//  ReflectionSystem.swift
//  Her Lives
//
//  Deep reflection and pattern recognition from life experiences
//

import Foundation

class ReflectionSystem: ObservableObject {
    @Published var recentReflections: [SystemReflection] = []
    @Published var coreInsights: [Insight] = []
    @Published var isReflecting = false
    
    private let reflectionDepth = 3
    private var lastReflectionTime: Date?
    private let minReflectionInterval: TimeInterval = 300 // 5 minutes game time
    
    // MARK: - Reflection Triggers
    
    func shouldReflect(currentTime: GameTime, memoryCount: Int, emotionalIntensity: Float) -> Bool {
        // Check time since last reflection
        if let lastTime = lastReflectionTime {
            let timeDiff = Date().timeIntervalSince(lastTime)
            guard timeDiff > minReflectionInterval else {
                return false
            }
        }
        
        // Trigger conditions
        let enoughMemories = memoryCount > 5
        let emotionalTrigger = emotionalIntensity > 0.7
        let timeOfDayTrigger = currentTime.hour == 23 || currentTime.hour == 6 // Before sleep or after waking
        let randomTrigger = Float.random(in: 0...1) < 0.05 // 5% chance
        
        return enoughMemories && (emotionalTrigger || timeOfDayTrigger || randomTrigger)
    }
    
    // MARK: - Reflection Process
    
    func generateReflection(trigger: String) async -> [SystemReflection] {
        // Generate reflection based on trigger
        let recentMemories = Array(recentReflections.suffix(10))
        return recentMemories
    }
    
    func processDream(_ dreamContent: DreamContent) {
        // Process dream content for insights
        let insight = Insight(
            id: UUID(),
            content: "Dream revealed: \(dreamContent.narrative)",
            type: .emotional,
            confidence: 0.6,
            impact: 0.4,
            actionable: false
        )
        updateCoreInsights(with: [insight])
    }
    
    func reflect(on memories: [Memory], personality: PersonalityVector, relationships: [UUID: Relationship]) -> SystemReflection {
        isReflecting = true
        defer { isReflecting = false }
        
        // Group memories by theme
        let themes = extractThemes(from: memories)
        
        // Find patterns
        let patterns = findPatterns(in: memories, themes: themes)
        
        // Generate insights
        let insights = generateInsights(from: patterns, personality: personality)
        
        // Create reflection
        let reflection = SystemReflection(
            id: UUID(),
            timestamp: GameTime.current,
            memories: memories.map { $0.id },
            themes: themes,
            patterns: patterns,
            insights: insights,
            emotionalTone: calculateEmotionalTone(memories),
            depth: determineDepth(insights)
        )
        
        // Store reflection
        recentReflections.append(reflection)
        if recentReflections.count > 50 {
            recentReflections.removeFirst()
        }
        
        // Update core insights
        updateCoreInsights(with: insights)
        
        lastReflectionTime = Date()
        
        return reflection
    }
    
    // MARK: - Pattern Recognition
    
    private func extractThemes(from memories: [Memory]) -> [String] {
        var themeFrequency: [String: Int] = [:]
        
        for memory in memories {
            let themes = extractMemoryThemes(memory)
            for theme in themes {
                themeFrequency[theme, default: 0] += 1
            }
        }
        
        return themeFrequency
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map { $0.key }
    }
    
    private func extractMemoryThemes(_ memory: Memory) -> [String] {
        var themes: [String] = []
        
        // Extract based on content keywords
        let keywords = memory.content.lowercased().components(separatedBy: " ")
        
        if keywords.contains(where: { ["friend", "talk", "chat", "conversation"].contains($0) }) {
            themes.append("social")
        }
        if keywords.contains(where: { ["work", "task", "project", "job"].contains($0) }) {
            themes.append("work")
        }
        if keywords.contains(where: { ["happy", "joy", "excited", "love"].contains($0) }) {
            themes.append("happiness")
        }
        if keywords.contains(where: { ["sad", "lonely", "miss", "cry"].contains($0) }) {
            themes.append("sadness")
        }
        if keywords.contains(where: { ["eat", "food", "meal", "hungry"].contains($0) }) {
            themes.append("sustenance")
        }
        if keywords.contains(where: { ["think", "wonder", "realize", "understand"].contains($0) }) {
            themes.append("contemplation")
        }
        
        return themes.isEmpty ? ["general"] : themes
    }
    
    private func findPatterns(in memories: [Memory], themes: [String]) -> [Pattern] {
        var patterns: [Pattern] = []
        
        // Temporal patterns
        if let temporalPattern = findTemporalPattern(memories) {
            patterns.append(temporalPattern)
        }
        
        // Emotional patterns
        if let emotionalPattern = findEmotionalPattern(memories) {
            patterns.append(emotionalPattern)
        }
        
        // Social patterns
        if let socialPattern = findSocialPattern(memories) {
            patterns.append(socialPattern)
        }
        
        // Causal patterns
        patterns.append(contentsOf: findCausalPatterns(memories))
        
        return patterns
    }
    
    private func findTemporalPattern(_ memories: [Memory]) -> Pattern? {
        // Look for recurring activities at similar times
        var timeActivities: [Int: [String]] = [:]
        
        for memory in memories {
            let hour = Calendar.current.component(.hour, from: memory.timestamp)
            timeActivities[hour, default: []].append(memory.content)
        }
        
        for (hour, activities) in timeActivities {
            if activities.count > 2 {
                return Pattern(
                    type: .temporal,
                    description: "Tends to \(commonActivity(activities)) around \(hour):00",
                    strength: Float(activities.count) / Float(memories.count),
                    evidence: activities
                )
            }
        }
        
        return nil
    }
    
    private func findEmotionalPattern(_ memories: [Memory]) -> Pattern? {
        let emotions = memories.map { $0.emotionalValence }
        let averageEmotion = emotions.reduce(0, +) / Float(emotions.count)
        
        if abs(averageEmotion) > 0.3 {
            let trend = averageEmotion > 0 ? "positive" : "negative"
            return Pattern(
                type: .emotional,
                description: "Recent experiences have been predominantly \(trend)",
                strength: abs(averageEmotion),
                evidence: memories.filter { abs($0.emotionalValence) > 0.5 }.map { $0.content }
            )
        }
        
        return nil
    }
    
    private func findSocialPattern(_ memories: [Memory]) -> Pattern? {
        let socialMemories = memories.filter { memory in
            memory.participants.count > 0
        }
        
        if socialMemories.count > memories.count / 2 {
            return Pattern(
                type: .social,
                description: "Has been very socially active recently",
                strength: Float(socialMemories.count) / Float(memories.count),
                evidence: socialMemories.map { $0.content }
            )
        }
        
        return nil
    }
    
    private func findCausalPatterns(_ memories: [Memory]) -> [Pattern] {
        var patterns: [Pattern] = []
        
        // Look for cause-effect relationships
        for i in 0..<memories.count-1 {
            let current = memories[i]
            let next = memories[i+1]
            
            // If emotional shift after specific action
            if abs(next.emotionalValence - current.emotionalValence) > 0.5 {
                let cause = current.content
                let effect = next.emotionalValence > current.emotionalValence ? "improved mood" : "worsened mood"
                
                patterns.append(Pattern(
                    type: .causal,
                    description: "\(cause) led to \(effect)",
                    strength: abs(next.emotionalValence - current.emotionalValence),
                    evidence: [current.content, next.content]
                ))
            }
        }
        
        return patterns
    }
    
    // MARK: - Insight Generation
    
    private func generateInsights(from patterns: [Pattern], personality: Personality) -> [Insight] {
        var insights: [Insight] = []
        
        for pattern in patterns {
            if let insight = generateInsightFromPattern(pattern, personality: personality) {
                insights.append(insight)
            }
        }
        
        // Meta-insights from multiple patterns
        if patterns.count > 3 {
            if let metaInsight = generateMetaInsight(from: patterns, personality: personality) {
                insights.append(metaInsight)
            }
        }
        
        return insights
    }
    
    private func generateInsightFromPattern(_ pattern: Pattern, personality: PersonalityVector) -> Insight? {
        switch pattern.type {
        case .temporal:
            return Insight(
                id: UUID(),
                content: "I notice I have routines that structure my day. \(pattern.description)",
                type: .behavioral,
                confidence: pattern.strength,
                impact: 0.3,
                actionable: true
            )
            
        case .emotional:
            let response = personality.openness > 0.5 ?
                "I should explore what's causing this pattern" :
                "I need to be careful about my emotional state"
            return Insight(
                id: UUID(),
                content: "\(pattern.description). \(response)",
                type: .emotional,
                confidence: pattern.strength,
                impact: 0.5,
                actionable: true
            )
            
        case .social:
            let interpretation = personality.extraversion > 0.5 ?
                "This energizes me" :
                "This is exhausting but necessary"
            return Insight(
                id: UUID(),
                content: "\(pattern.description). \(interpretation)",
                type: .social,
                confidence: pattern.strength,
                impact: 0.4,
                actionable: false
            )
            
        case .causal:
            return Insight(
                id: UUID(),
                content: "I've learned that \(pattern.description)",
                type: .causal,
                confidence: pattern.strength,
                impact: 0.6,
                actionable: true
            )
            
        case .cyclical:
            return Insight(
                id: UUID(),
                content: "Life has patterns that repeat: \(pattern.description)",
                type: .philosophical,
                confidence: pattern.strength,
                impact: 0.7,
                actionable: false
            )
        }
    }
    
    private func generateMetaInsight(from patterns: [Pattern], personality: PersonalityVector) -> Insight? {
        let totalStrength = patterns.map { $0.strength }.reduce(0, +) / Float(patterns.count)
        
        if totalStrength > 0.5 {
            return Insight(
                id: UUID(),
                content: "My life is showing clear patterns. I'm becoming more aware of who I am and what drives me.",
                type: .philosophical,
                confidence: totalStrength,
                impact: 0.8,
                actionable: false
            )
        }
        
        return nil
    }
    
    // MARK: - Core Insights Management
    
    private func updateCoreInsights(with newInsights: [Insight]) {
        for insight in newInsights {
            if insight.impact > 0.5 {
                // Check if similar insight exists
                if !coreInsights.contains(where: { existing in
                    similarity(existing.content, insight.content) > 0.7
                }) {
                    coreInsights.append(insight)
                }
            }
        }
        
        // Keep only most impactful insights
        coreInsights.sort { $0.impact > $1.impact }
        if coreInsights.count > 10 {
            coreInsights = Array(coreInsights.prefix(10))
        }
    }
    
    // MARK: - Helper Functions
    
    private func calculateEmotionalTone(_ memories: [Memory]) -> Float {
        guard !memories.isEmpty else { return 0 }
        return memories.map { $0.emotionalValence }.reduce(0, +) / Float(memories.count)
    }
    
    private func determineDepth(_ insights: [Insight]) -> Int {
        let philosophicalCount = insights.filter { $0.type == .philosophical }.count
        if philosophicalCount > 2 { return 3 }
        if philosophicalCount > 0 { return 2 }
        return 1
    }
    
    private func commonActivity(_ activities: [String]) -> String {
        // Find most common words across activities
        var wordFrequency: [String: Int] = [:]
        
        for activity in activities {
            let words = activity.lowercased().components(separatedBy: " ")
            for word in words {
                if word.count > 3 { // Skip small words
                    wordFrequency[word, default: 0] += 1
                }
            }
        }
        
        if let mostCommon = wordFrequency.max(by: { $0.value < $1.value }) {
            return mostCommon.key
        }
        
        return "be active"
    }
    
    private func similarity(_ text1: String, _ text2: String) -> Float {
        let words1 = Set(text1.lowercased().components(separatedBy: " "))
        let words2 = Set(text2.lowercased().components(separatedBy: " "))
        
        let intersection = words1.intersection(words2).count
        let union = words1.union(words2).count
        
        return union > 0 ? Float(intersection) / Float(union) : 0
    }
}

// MARK: - Supporting Types

struct SystemReflection: Identifiable {
    let id: UUID
    let timestamp: GameTime
    let memories: [UUID]
    let themes: [String]
    let patterns: [Pattern]
    let insights: [Insight]
    let emotionalTone: Float
    let depth: Int
    
    var summary: String {
        let themeText = themes.joined(separator: ", ")
        let insightCount = insights.count
        return "Reflected on \(themes.count) themes (\(themeText)) and gained \(insightCount) insights"
    }
}

struct Pattern {
    enum PatternType {
        case temporal, emotional, social, causal, cyclical
    }
    
    let type: PatternType
    let description: String
    let strength: Float
    let evidence: [String]
}

struct Insight: Identifiable {
    enum InsightType {
        case behavioral, emotional, social, causal, philosophical
    }
    
    let id: UUID
    let content: String
    let type: InsightType
    let confidence: Float
    let impact: Float
    let actionable: Bool
    
    var significance: Float {
        confidence * impact
    }
}