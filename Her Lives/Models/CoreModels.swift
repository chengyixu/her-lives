//
//  CoreModels.swift
//  Her Lives
//
//  Core data models for the Living World
//

import Foundation
import SwiftUI

// MARK: - Memory
struct Memory: Identifiable, Codable, Hashable {
    let id: UUID
    var timestamp: Date
    var content: String
    var type: MemoryType
    
    // Stanford's three dimensions
    var importance: Float
    var recency: Float
    var relevance: Float
    
    // Enhanced properties
    var emotionalValence: Float
    var emotionalIntensity: Float
    var encodingStrength: Float = 1.0
    var decayRate: Float = 0.001
    var compressionLevel: Int = 0
    var confidence: Float = 1.0
    
    // Context
    var location: Position?
    var participants: [UUID] = []
    var tags: [String] = []
    var source: String?
    
    // Associations
    var associations: [UUID] = []
    var lastActivated: Date?
    
    // Subjective time
    var subjectiveTime: TimeInterval?
    
    var timeAgo: String {
        let interval = Date().timeIntervalSince(timestamp)
        if interval < 60 { return "just now" }
        if interval < 3600 { return "\(Int(interval/60))m ago" }
        if interval < 86400 { return "\(Int(interval/3600))h ago" }
        return "\(Int(interval/86400))d ago"
    }
    
    var dominantEmotion: EmotionType? {
        if emotionalIntensity < 0.3 { return nil }
        if emotionalValence > 0.5 { return .happy }
        if emotionalValence < -0.5 { return .sad }
        return nil
    }
    
    mutating func compress() {
        compressionLevel += 1
        // Lose details but keep gist
        if compressionLevel > 1 {
            content = content.components(separatedBy: " ").prefix(10).joined(separator: " ") + "..."
        }
    }
    
    mutating func addTag(_ tag: String) {
        if !tags.contains(tag) {
            tags.append(tag)
        }
    }
}

enum MemoryType: String, Codable {
    case observation, action, social, reflection, dream, semantic
    
    var icon: String {
        switch self {
        case .observation: return "eye"
        case .action: return "figure.walk"
        case .social: return "person.2"
        case .reflection: return "brain"
        case .dream: return "moon.stars"
        case .semantic: return "book"
        }
    }
    
    var color: Color {
        switch self {
        case .observation: return .blue
        case .action: return .green
        case .social: return .orange
        case .reflection: return .purple
        case .dream: return .indigo
        case .semantic: return .gray
        }
    }
}

// MARK: - Reflection
struct CoreReflection: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let question: String
    let insight: String
    let evidence: [UUID]
    let confidence: Float
    let abstractionLevel: Int
    let emotionalTone: Float
    
    var type: ReflectionType = .general
    
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
}

enum ReflectionType: String, Codable {
    case general, pattern, belief, identity, goalRelated
}

// MARK: - Personality
struct PersonalityVector: Codable {
    // Big Five
    var openness: Float = Float.random(in: 0...1)
    var conscientiousness: Float = Float.random(in: 0...1)
    var extraversion: Float = Float.random(in: 0...1)
    var agreeableness: Float = Float.random(in: 0...1)
    var neuroticism: Float = Float.random(in: 0...1)
    
    // Extended traits
    var creativity: Float = Float.random(in: 0...1)
    var empathy: Float = Float.random(in: 0...1)
    var resilience: Float = Float.random(in: 0...1)
    var ambition: Float = Float.random(in: 0...1)
    var curiosity: Float = Float.random(in: 0...1)
    var humor: Float = Float.random(in: 0...1)
    var patience: Float = Float.random(in: 0...1)
    
    var description: String {
        var traits: [String] = []
        
        if openness > 0.7 { traits.append("open-minded") }
        if conscientiousness > 0.7 { traits.append("organized") }
        if extraversion > 0.7 { traits.append("outgoing") }
        if agreeableness > 0.7 { traits.append("friendly") }
        if neuroticism > 0.7 { traits.append("sensitive") }
        if creativity > 0.7 { traits.append("creative") }
        
        return traits.joined(separator: ", ")
    }
    
    var primaryColor: Color {
        Color(
            red: Double(openness),
            green: Double(agreeableness),
            blue: Double(conscientiousness)
        )
    }
    
    var secondaryColor: Color {
        Color(
            red: Double(creativity),
            green: Double(empathy),
            blue: Double(curiosity)
        )
    }
    
    mutating func randomizeWithBias(index: Int) {
        // Give each agent a slightly different personality bias
        let bias = Float(index) / 20.0
        
        openness = Float.random(in: 0...1) + bias * Float.random(in: -0.2...0.2)
        conscientiousness = Float.random(in: 0...1) + bias * Float.random(in: -0.2...0.2)
        extraversion = Float.random(in: 0...1) + bias * Float.random(in: -0.2...0.2)
        agreeableness = Float.random(in: 0...1) + bias * Float.random(in: -0.2...0.2)
        neuroticism = Float.random(in: 0...1) + bias * Float.random(in: -0.2...0.2)
        
        // Clamp values
        openness = max(0, min(1, openness))
        conscientiousness = max(0, min(1, conscientiousness))
        extraversion = max(0, min(1, extraversion))
        agreeableness = max(0, min(1, agreeableness))
        neuroticism = max(0, min(1, neuroticism))
    }
    
    mutating func nudge(_ changes: [String: Float]) {
        // Small personality changes from experiences
        for (trait, delta) in changes {
            switch trait {
            case "openness": openness = max(0, min(1, openness + delta))
            case "conscientiousness": conscientiousness = max(0, min(1, conscientiousness + delta))
            case "extraversion": extraversion = max(0, min(1, extraversion + delta))
            case "agreeableness": agreeableness = max(0, min(1, agreeableness + delta))
            case "neuroticism": neuroticism = max(0, min(1, neuroticism + delta))
            case "creativity": creativity = max(0, min(1, creativity + delta))
            case "empathy": empathy = max(0, min(1, empathy + delta))
            default: break
            }
        }
    }
}

// MARK: - Emotion
struct EmotionState: Codable {
    var happiness: Float = 0.5
    var sadness: Float = 0.0
    var anger: Float = 0.0
    var fear: Float = 0.0
    var surprise: Float = 0.0
    var disgust: Float = 0.0
    
    var arousal: Float = 0.5
    var valence: Float = 0.0
    
    var recentEmotions: [EmotionSnapshot] = []
    
    var dominantFeeling: EmotionType {
        let emotions: [(EmotionType, Float)] = [
            (.happy, happiness),
            (.sad, sadness),
            (.angry, anger),
            (.fearful, fear),
            (.surprised, surprise),
            (.disgusted, disgust)
        ]
        
        return emotions.max(by: { $0.1 < $1.1 })?.0 ?? .neutral
    }
    
    var intensity: Float {
        max(happiness, sadness, anger, fear, surprise, disgust)
    }
    
    var color: Color {
        switch dominantFeeling {
        case .happy: return .green
        case .sad: return .blue
        case .angry: return .red
        case .fearful: return .purple
        case .surprised: return .yellow
        case .disgusted: return .brown
        case .neutral: return .gray
        }
    }
    
    var description: String {
        if intensity < 0.3 { return "calm" }
        return dominantFeeling.rawValue
    }
    
    mutating func process(_ perceptions: [CorePerception]) {
        for perception in perceptions {
            let impact = perception.emotionalImpact
            
            happiness += impact.happiness
            sadness += impact.sadness
            anger += impact.anger
            fear += impact.fear
            surprise += impact.surprise
            disgust += impact.disgust
            
            // Update arousal and valence
            arousal = (arousal + impact.arousal) / 2
            valence = (valence + impact.valence) / 2
        }
        
        // Emotional regulation (emotions decay over time)
        happiness *= 0.95
        sadness *= 0.95
        anger *= 0.9
        fear *= 0.9
        surprise *= 0.8
        disgust *= 0.9
        
        // Record snapshot
        recentEmotions.append(EmotionSnapshot(
            timestamp: Date(),
            emotion: dominantFeeling,
            intensity: intensity
        ))
        
        // Keep only recent history
        recentEmotions = Array(recentEmotions.suffix(100))
    }
}

enum EmotionType: String, Codable {
    case happy, sad, angry, fearful, surprised, disgusted, neutral
    
    var description: String {
        switch self {
        case .happy: return "happy"
        case .sad: return "sad"
        case .angry: return "angry"
        case .fearful: return "fearful"
        case .surprised: return "surprised"
        case .disgusted: return "disgusted"
        case .neutral: return "neutral"
        }
    }
}

struct EmotionSnapshot: Codable {
    let timestamp: Date
    let emotion: EmotionType
    let intensity: Float
}

// MARK: - Consciousness
struct ConsciousnessState: Codable {
    var state: State = .awake
    var alertnessLevel: Float = 1.0
    var focusTarget: String?
    
    enum State: String, Codable {
        case awake, drowsy, sleeping, dreaming, reflecting, meditating
    }
    
    var icon: String {
        switch state {
        case .awake: return "sun.max"
        case .drowsy: return "moon"
        case .sleeping: return "moon.zzz"
        case .dreaming: return "moon.stars"
        case .reflecting: return "brain"
        case .meditating: return "leaf"
        }
    }
    
    var color: Color {
        switch state {
        case .awake: return .yellow
        case .drowsy: return .orange
        case .sleeping: return .indigo
        case .dreaming: return .purple
        case .reflecting: return .blue
        case .meditating: return .green
        }
    }
    
    var description: String {
        state.rawValue
    }
    
    var isSleeping: Bool {
        state == .sleeping || state == .dreaming
    }
}

// MARK: - Relationship
class Relationship: Identifiable, ObservableObject {
    let id: UUID
    let otherAgentId: UUID
    @Published var dimensions: RelationshipDimensions
    @Published var stage: String = "strangers"
    @Published var sharedHistory: [SharedMemory] = []
    
    var closeness: Float {
        (dimensions.affection + dimensions.trust + dimensions.intimacy) / 3
    }
    
    var currentThought: String? {
        if dimensions.affection > 0.8 {
            return "I care deeply about them"
        } else if dimensions.trust > 0.8 {
            return "I trust them completely"
        } else if dimensions.conflict > 0.5 {
            return "Things are tense between us"
        }
        return nil
    }
    
    var stageColor: Color {
        switch stage {
        case "strangers": return .gray
        case "acquaintances": return .blue
        case "friends": return .green
        case "close_friends": return .orange
        case "romantic": return .pink
        case "family": return .purple
        default: return .gray
        }
    }
    
    init(from agent: Agent, to otherAgent: Agent) {
        self.id = UUID()
        self.otherAgentId = otherAgent.id
        self.dimensions = RelationshipDimensions()
    }
    
    func updateRelationship(with otherAgent: Agent, quality: Float) {
        dimensions.familiarity += 0.01
        dimensions.affection += quality * 0.05
        
        if quality > 0.5 {
            dimensions.trust += 0.02
        }
        
        // Check for stage transitions
        checkStageTransition()
    }
    
    func checkStageTransition() {
        if dimensions.familiarity > 0.1 && stage == "strangers" {
            stage = "acquaintances"
        } else if dimensions.trust > 0.5 && dimensions.affection > 0.3 && stage == "acquaintances" {
            stage = "friends"
        } else if dimensions.intimacy > 0.6 && stage == "friends" {
            stage = "close_friends"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, otherAgentId, dimensions, stage, sharedHistory
    }
}

struct RelationshipDimensions: Codable {
    var affection: Float = 0.0
    var trust: Float = 0.5
    var respect: Float = 0.5
    var attraction: Float = 0.0
    var familiarity: Float = 0.0
    var commitment: Float = 0.0
    var powerBalance: Float = 0.0
    var conflict: Float = 0.0
    var intimacy: Float = 0.0
    
    var description: String {
        if affection > 0.7 && trust > 0.7 {
            return "close and trusting"
        } else if conflict > 0.5 {
            return "conflicted"
        } else if familiarity < 0.3 {
            return "distant"
        }
        return "neutral"
    }
}

struct SharedMemory: Codable {
    let id: UUID
    let timestamp: Date
    let description: String
    let emotionalValence: Float
}

// MARK: - Goals and Desires
struct Goal: Identifiable, Codable {
    let id: UUID
    let type: GoalType
    let description: String
    var priority: Float = 0.5
    var progress: Float = 0.0
    var target: UUID?
    var deadline: Date?
    
    init(type: GoalType, description: String, priority: Float = 0.5, target: UUID? = nil, deadline: Date? = nil) {
        self.id = UUID()
        self.type = type
        self.description = description
        self.priority = priority
        self.target = target
        self.deadline = deadline
    }
    
    enum GoalType: String, Codable {
        case survival, social, professional, creative, personal
    }
}

struct Desire: Identifiable, Codable {
    let id: UUID
    let content: String
    let intensity: Float
    let category: DesireCategory
    
    init(content: String, intensity: Float, category: DesireCategory) {
        self.id = UUID()
        self.content = content
        self.intensity = intensity
        self.category = category
    }
    
    enum DesireCategory: String, Codable {
        case belonging, achievement, autonomy, purpose, pleasure
    }
}

// MARK: - Actions
struct Action: Identifiable {
    let id = UUID()
    let type: ActionType
    let description: String
    var reason: String = ""  // WHY the agent is doing this
    var targetObject: String? // Name of object to interact with
    var target: Position?
    var targetAgent: Agent?
    var content: String?
    var importance: Float?
    var duration: TimeInterval = 60
    
    init(
        type: ActionType,
        target: Position? = nil,
        targetAgent: Agent? = nil,
        targetObject: String? = nil,
        duration: Int = 60,
        description: String,
        reason: String = ""
    ) {
        self.type = type
        self.target = target
        self.targetAgent = targetAgent  
        self.targetObject = targetObject
        self.duration = TimeInterval(duration)
        self.description = description
        self.reason = reason
    }
    
    var mentalNarrative: String? {
        switch type {
        case .move: return "heading somewhere"
        case .speak: return "expressing myself"
        case .work: return "focusing on work"
        case .rest: return "taking a break"
        case .eat: return "satisfying hunger"
        case .socialize: return "connecting with others"
        case .reflect: return "thinking deeply"
        case .create: return "making something"
        default: return nil
        }
    }
    
    var workType: String?
    var creationType: String?
    
    enum ActionType: String, Codable {
        case move, speak, work, rest, eat, socialize, reflect, create, observe, remember
    }
}

// MARK: - Cultural Meme
struct CulturalMeme: Identifiable, Codable {
    let id = UUID()
    let content: String
    var carriers: Set<UUID> = []
    var transmissionCount: Int = 0
    var mutations: [String] = []
    var strength: Float = 0.5
    
    var isPositive: Bool {
        // Simple sentiment analysis based on content
        let positiveWords = ["love", "happiness", "peace", "joy", "hope", "success", "good", "great", "wonderful"]
        let negativeWords = ["hate", "anger", "war", "sadness", "fear", "bad", "terrible", "awful"]
        
        let contentLower = content.lowercased()
        let positiveCount = positiveWords.count { contentLower.contains($0) }
        let negativeCount = negativeWords.count { contentLower.contains($0) }
        
        return positiveCount >= negativeCount
    }
    
    init(content: String) {
        self.content = content
    }
    
    func resonatesWith(beliefs: [Belief]) -> Bool {
        // Simple resonance check
        for belief in beliefs {
            if belief.content.lowercased().contains(content.lowercased()) {
                return true
            }
        }
        return false
    }
    
    func calculateInfluence(on agent: Agent) -> MemeInfluence {
        MemeInfluence(
            valueChanges: [:],
            personalityShift: [:],
            newBelief: nil
        )
    }
}

struct MemeInfluence {
    let valueChanges: [String: Float]
    let personalityShift: [String: Float]
    let newBelief: Belief?
}

// MARK: - Belief
struct Belief: Identifiable, Codable {
    let id = UUID()
    let content: String
    var strength: Float
    let category: BeliefCategory
    
    enum BeliefCategory: String, Codable {
        case moral, factual, personal, cultural, spiritual
    }
}

// MARK: - Supporting Types
struct Position: Codable, Hashable {
    var x: Float
    var y: Float
    var z: Float = 0
}

struct GameTime: Codable {
    // Store the world start date - this persists across instances
    static let worldStartDate: Date = UserDefaults.standard.object(forKey: "worldStartDate") as? Date ?? {
        let date = Date()
        UserDefaults.standard.set(date, forKey: "worldStartDate")
        return date
    }()
    
    // Always use system time
    var daysSinceStart: Int {
        Int(Date().timeIntervalSince(Self.worldStartDate) / 86400)
    }
    
    var hour: Int {
        Calendar.current.component(.hour, from: Date())
    }
    
    var minute: Int {
        Calendar.current.component(.minute, from: Date())
    }
    
    var isNewHour: Bool {
        minute == 0
    }
    
    var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: Date())
    }
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }
    
    mutating func advance() {
        // No need to advance - using system time
    }
    
    func hoursSince(_ other: GameTime) -> Int {
        // Since both times use system time, this doesn't make sense anymore
        // Just return the hour difference in the current day
        return hour - other.hour
    }
    
    static var current: GameTime {
        GameTime()
    }
    
    var formatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, HH:mm"
        return formatter.string(from: Date())
    }
}

struct CorePerception {
    let type: PerceptionType
    let content: String
    var subject: Any?
    let importance: Float
    let emotionalValence: Float
    var emotionalIntensity: Float?
    var location: Position?
    var participants: [UUID] = []
    
    var emotionalImpact: EmotionImpact {
        EmotionImpact(
            happiness: emotionalValence > 0 ? emotionalValence * 0.3 : 0,
            sadness: emotionalValence < 0 ? -emotionalValence * 0.3 : 0,
            anger: 0,
            fear: 0,
            surprise: emotionalIntensity ?? 0 * 0.1,
            disgust: 0,
            arousal: emotionalIntensity ?? 0.5,
            valence: emotionalValence
        )
    }
    
    func calculateDifference(from prediction: CorePerception) -> Float {
        // Simple difference calculation
        abs(importance - prediction.importance) + 
        abs(emotionalValence - prediction.emotionalValence)
    }
    
    enum PerceptionType {
        case visual, auditory, internalSense, social, environmental
    }
}

struct EmotionImpact {
    let happiness: Float
    let sadness: Float
    let anger: Float
    let fear: Float
    let surprise: Float
    let disgust: Float
    let arousal: Float
    let valence: Float
}

// MARK: - Missing Types for LivingWorld

// Update GameTime structure with missing methods
extension GameTime {
    var day: Int {
        daysSinceStart
    }
    
    var totalMinutes: Int {
        daysSinceStart * 24 * 60 + hour * 60 + minute
    }
    
    // Remove invalid init - GameTime always uses system time
}

struct AgentState {
    let id: UUID
    let position: Position
    let consciousness: ConsciousnessState
    let emotion: EmotionState
    let currentAction: Action?
    let energy: Float
}

struct WorldEvent {
    let id = UUID()
    let type: WorldEventType
    let participants: [UUID]
    let description: String
    let timestamp: GameTime
    
    enum WorldEventType {
        case socialInteraction, birthday, celebration, conflict, achievement
    }
}

struct ValueSystem: Codable {
    var values: [String: Float] = [:]
    
    var topValues: [(name: String, strength: Float)] {
        values.sorted { $0.value > $1.value }
              .prefix(5)
              .map { (name: $0.key, strength: $0.value) }
    }
    
    mutating func adjust(_ changes: [String: Float]) {
        for (value, change) in changes {
            values[value, default: 0.5] += change
            values[value] = max(0, min(1, values[value]!))
        }
    }
}

struct CulturalIdentity: Codable {
    var primaryCulture: String = "Universal"
    var culturalValues: [String] = []
    var traditions: [String] = []
    var languages: [String] = ["Common"]
}

struct MoodState: Codable {
    var currentMood: String = "neutral"
    var stability: Float = 0.5
    var volatility: Float = 0.3
    var history: [String] = []
    
    var description: String {
        currentMood
    }
}

struct CoreDailyPlan {
    let goals: [Goal]
    let scheduledActions: [Action]
    let priority: Float
    
    func getCurrentAction() -> Action? {
        scheduledActions.first
    }
    
    func getNextAction() -> Action? {
        scheduledActions.first
    }
}

struct Context {
    let location: Position?
    let timeOfDay: String
    let socialSituation: String?
    let recentEvents: [String]
}

struct CoreAttentionFocus {
    let target: String
    let intensity: Float
    let duration: TimeInterval
}

// Note: Profession is defined in EconomicSystem.swift

// Economics and Governance placeholder systems
class EmergentEconomy: ObservableObject {
    @Published var totalWealth: Float = 10000
    @Published var professions: [Profession] = []
    
    func processTransactions() {
        // Placeholder - would be handled by EconomicSystem
    }
}

class EmergentGovernance: ObservableObject {
    func processDecisions() {
        // Placeholder for governance system
    }
}

class CollectiveConsciousness: ObservableObject {
    @Published var currentMood: Float = 0.0
    
    func update(agents: [Agent]) {
        // Calculate collective mood
        let totalMood = agents.reduce(0) { $0 + $1.emotion.valence }
        currentMood = totalMood / Float(max(1, agents.count))
    }
}

// World save state
struct WorldSaveState {
    let agents: [Agent]
    let time: GameTime
    let relationships: [Relationship]
    let culturalMemes: [CulturalMeme]
    let worldEvents: [WorldEvent]
    let emergentPhenomena: [EmergentPhenomenon]
}

// Goal generator utility
class GoalGenerator {
    static func generateInitialGoals(for agent: Agent) -> [Goal] {
        var goals: [Goal] = []
        
        // Basic survival goals
        goals.append(Goal(
            type: .survival,
            description: "Maintain health and well-being",
            priority: 0.8
        ))
        
        // Social goals based on personality
        if agent.personality.extraversion > 0.5 {
            goals.append(Goal(
                type: .social,
                description: "Form meaningful relationships",
                priority: 0.7
            ))
        }
        
        // Creative goals
        if agent.personality.creativity > 0.6 {
            goals.append(Goal(
                type: .creative,
                description: "Express creativity",
                priority: 0.6
            ))
        }
        
        // Professional goals
        goals.append(Goal(
            type: .professional,
            description: "Find meaningful work",
            priority: 0.5
        ))
        
        return goals
    }
}

// Notification manager
class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func notifyEmergence(_ phenomenon: EmergentPhenomenon) {
        print("✨ Emergence detected: \(phenomenon.name) - \(phenomenon.description)")
    }
}

// Dialogue prompt builder
class DialoguePromptBuilder {
    static func build(interaction: SocialInteraction, world: LivingWorld) -> String {
        let participants = interaction.participants.map { $0.name }.joined(separator: " and ")
        let location = interaction.location
        let context = "\(participants) are interacting at \(location)"
        return context
    }
}


// MARK: - Extensions

extension Float {
    var magnitude: Float {
        abs(self)
    }
}

// MARK: - Missing Type Definitions

// AI Response types
struct AIResponse {
    let content: String
    let confidence: Float
    let tokens: Int
}

// PlannedActivity for QwenService
struct QwenPlannedActivity {
    let hour: Int
    let description: String
    let duration: Int
}

// DailyPlan is defined in PlanningSystem.swift

// Profession is defined in EconomicSystem.swift

// Note: EmergentPhenomenon is defined in EmergenceDetector.swift

// Transaction is defined in EconomicSystem.swift

// Remove duplicate
// PlannedAction as alias
// typealias PlannedAction = Action

// Insight is defined in ReflectionSystem.swift

// Pattern is defined in ReflectionSystem.swift

struct PlannedActivity {
    let name: String
    let duration: TimeInterval
    let priority: Float
    let location: Position?
}

typealias PlannedAction = Action

// Memory retrieval types
enum RetrievalBias {
    case recency
    case importance
    case relevance
    case emotional
    case balanced
}

struct ImportanceCalculator {
    static func calculate(for memory: Memory) -> Float {
        memory.importance
    }
    
    static func calculate(_ perception: CorePerception) -> Float {
        perception.importance
    }
}

struct RecencyDecay {
    static func apply(to memory: Memory, currentTime: Date) -> Float {
        let timeDiff = currentTime.timeIntervalSince(memory.timestamp)
        return Float(exp(-timeDiff / 86400)) // Exponential decay over days
    }
    
    static func calculate(_ timestamp: Date) -> Float {
        let timeDiff = Date().timeIntervalSince(timestamp)
        return Float(exp(-timeDiff / 86400))
    }
}

struct RelevanceEngine {
    static func calculate(memory: Memory, context: String) -> Float {
        // Placeholder relevance calculation
        0.5
    }
    
    static func calculate(_ memory: Memory, query: String) -> Float {
        let memoryWords = Set(memory.content.lowercased().components(separatedBy: " "))
        let queryWords = Set(query.lowercased().components(separatedBy: " "))
        let intersection = memoryWords.intersection(queryWords)
        return Float(intersection.count) / Float(max(1, queryWords.count))
    }
    
    static func calculateContextual(_ memory: Memory, context: Context?) -> Float {
        guard let context = context else { return 0.5 }
        
        var relevance: Float = 0.0
        
        // Location relevance
        if let memoryLocation = memory.location,
           let contextLocation = context.location {
            let distance = memoryLocation.distance(to: contextLocation)
            relevance += max(0, 1.0 - distance / 100.0) * 0.3
        }
        
        // Time relevance
        relevance += 0.3
        
        // Social relevance
        if let socialSituation = context.socialSituation {
            if memory.participants.count > 0 {
                relevance += 0.4
            }
        }
        
        return min(1.0, relevance)
    }
}

// Information is defined in MemoryStream.swift

typealias Personality = PersonalityVector
typealias Perception = CorePerception

// Interaction Memory
struct InteractionMemory: Codable {
    let timestamp: Date
    let type: String
    let content: String
    let emotionalValence: Float
}

// Emotion type alias
typealias Emotion = EmotionState

// Dream system
struct Dream {
    let dreamer: Agent
    let memories: [Memory]
    let emotions: [EmotionSnapshot]
    let desires: [Desire]
    
    func generate() async -> DreamContent {
        DreamContent(
            narrative: "A strange dream about memories and desires",
            emotions: emotions,
            insights: [],
            isSignificant: false
        )
    }
}

struct DreamContent: Codable {
    let narrative: String
    let emotions: [EmotionSnapshot]
    let insights: [String]
    let isSignificant: Bool
}

// MARK: - Missing Type Definitions

// Note: WorldObservations and WorldObservation are defined in EmergenceDetector.swift

// Note: SocialInteraction and InteractionType are defined in RelationshipNetwork.swift

// Note: Dialogue is defined in RelationshipNetwork.swift

// Note: DialogueResponse is defined in QwenAIService.swift

// Note: EmergentPhenomenon and EmergenceType are defined in EmergenceDetector.swift

// Note: Position.distance extension is defined in PhysicalSpace.swift

// Note: Vector2D is defined in PhysicalSpace.swift

// Note: AttentionFocus and DailyPlan are defined in their respective system files

// Decision structure placeholder
struct Decision {
    let id = UUID()
    let description: String
    let alternatives: [String]
    let selectedOption: String?
}

// Note: PlanningSystem and CognitiveOrchestra are defined in their respective system files

// LivingWorld is defined in LivingWorld.swift

// Note: System classes (PhysicalSpace, RelationshipNetwork, CulturalSystem, EmergenceDetector, QwenAIService) 
// are defined in their respective files

// Note: Location is defined in PhysicalSpace.swift

struct GameEnvironment {
    let description: String
    let mood: Float
}