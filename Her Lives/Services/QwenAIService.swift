//
//  QwenAIService.swift
//  Her Lives
//
//  Integration with Qwen AI for natural language generation
//

import Foundation
import Combine

// MARK: - Qwen Configuration
class QwenConfiguration {
    static let shared = QwenConfiguration()
    
    private var apiKeys: [String] = []
    private var currentKeyIndex = 0
    
    let baseURL = "https://dashscope.aliyuncs.com/api/v1"
    let model = "qwen-max"
    let temperature: Float = 0.8
    let maxTokens = 2000
    
    func configure(apiKeys: [String]) {
        self.apiKeys = apiKeys
    }
    
    func getCurrentKey() -> String {
        guard !apiKeys.isEmpty else {
            fatalError("No API keys configured for Qwen")
        }
        return apiKeys[currentKeyIndex]
    }
    
    func rotateKey() {
        currentKeyIndex = (currentKeyIndex + 1) % apiKeys.count
    }
}

// MARK: - Qwen AI Service
class QwenAIService: ObservableObject {
    static let shared = QwenAIService()
    
    private let config = QwenConfiguration.shared
    private let session = URLSession.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isProcessing = false
    @Published var lastError: Error?
    
    // Cache for recent responses to reduce API calls
    private var responseCache = LRUCache<String, Any>(capacity: 100)
    
    // MARK: - Main Generation Functions
    
    /// Generate dialogue between agents
    func generateDialogue(prompt: String) async throws -> DialogueResponse {
        let cacheKey = "dialogue_\(prompt.hashValue)"
        
        if let cached = responseCache.get(cacheKey) as? DialogueResponse {
            return cached
        }
        
        let systemPrompt = """
        You are simulating natural dialogue between AI agents in a living world.
        Each agent has their own personality, emotions, memories, and goals.
        Generate realistic, contextual dialogue that reflects their inner states.
        Keep responses concise and natural.
        """
        
        let response = try await callQwenAPI(
            system: systemPrompt,
            user: prompt
        )
        
        let dialogueResponse = parseDialogueResponse(response)
        responseCache.put(cacheKey, dialogueResponse)
        
        return dialogueResponse
    }
    
    /// Generate agent's internal thoughts
    func generateInnerMonologue(
        agent: Agent,
        context: String
    ) async throws -> String {
        let prompt = """
        Agent: \(agent.name)
        Age: \(agent.age)
        Personality: \(agent.personality.description)
        Current emotion: \(agent.emotion.description)
        Current context: \(context)
        
        Generate a brief internal thought (1-2 sentences) that this agent might have in this moment.
        Make it personal, emotional, and true to their character.
        """
        
        let response = try await callQwenAPI(
            system: "Generate realistic internal thoughts for an AI agent.",
            user: prompt
        )
        
        return extractContent(from: response)
    }
    
    /// Generate reflection insights
    func generateReflection(
        memories: [Memory],
        question: String
    ) async throws -> ReflectionInsight {
        let memoryDescriptions = memories.map { $0.content }.joined(separator: "\n")
        
        let prompt = """
        Recent memories:
        \(memoryDescriptions)
        
        Question: \(question)
        
        Generate a thoughtful reflection that:
        1. Identifies patterns in these memories
        2. Draws a meaningful insight
        3. Suggests how this might influence future behavior
        
        Format: [Pattern] -> [Insight] -> [Future implication]
        """
        
        let response = try await callQwenAPI(
            system: "You are helping an AI agent reflect on their experiences and draw meaningful insights.",
            user: prompt
        )
        
        return parseReflectionResponse(response)
    }
    
    /// Generate contextual agent dialogue
    func generateAgentDialogue(
        speaker: Agent,
        listener: Agent,
        context: String,
        emotion: EmotionState,
        relationship: Relationship?
    ) async throws -> String {
        let relationshipDesc = relationship?.dimensions.description ?? "strangers"
        
        let prompt = """
        Speaker: \(speaker.name) (feeling \(emotion.description))
        Listener: \(listener.name)
        Relationship: \(relationshipDesc)
        Context: \(context)
        
        Generate what \(speaker.name) would say in this situation.
        Consider their:
        - Current emotional state
        - Relationship with \(listener.name)
        - Personality traits
        - The context of the conversation
        
        Response should be natural, 1-3 sentences max.
        """
        
        let response = try await callQwenAPI(
            system: "Generate natural, contextual dialogue for AI agents based on their personalities and relationships.",
            user: prompt
        )
        
        return extractContent(from: response)
    }
    
    /// Generate next action based on agent's full cognitive state
    func generateNextAction(
        agent: Agent,
        world: LivingWorld,
        recentMemories: [Memory],
        nearbyAgents: [Agent],
        currentLocation: String,
        nearbyObjects: [Any] = []  // EnvironmentalObject type from EnvironmentalObjects.swift
    ) async throws -> Action {
        let memorySummary = recentMemories.prefix(5).map { $0.content }.joined(separator: "\n")
        let nearbyNames = nearbyAgents.map { $0.name }.joined(separator: ", ")
        let goalsSummary = agent.goals.prefix(3).map { $0.description }.joined(separator: "\n")
        
        // Get relationship details for nearby agents
        let relationshipDetails = nearbyAgents.compactMap { other in
            if let rel = world.relationshipNetwork.getRelationship(from: agent, to: other) {
                return "\(other.name): affection: \(String(format: "%.2f", rel.dimensions.affection))"
            }
            return nil
        }.joined(separator: ", ")
        
        // Get carried items/resources
        let carriedItems = agent.inventory.isEmpty ? "nothing" : agent.inventory.map { "\($0.key) x\($0.value)" }.joined(separator: ", ")
        
        // Get skills and interests
        let skillsList = agent.skills.isEmpty ? "none developed" : agent.skills.map { "\($0.key): \(String(format: "%.1f", $0.value))" }.joined(separator: ", ")
        
        // Get nearby objects description
        // Format nearby objects (expecting EnvironmentalObject with name and description properties)
        let objectsList = nearbyObjects.isEmpty ? "Nothing notable" : nearbyObjects.compactMap { object in
            // Use reflection to get properties if it's an EnvironmentalObject
            let mirror = Mirror(reflecting: object)
            var name: String?
            var desc: String?
            for child in mirror.children {
                if child.label == "name" {
                    name = child.value as? String
                } else if child.label == "description" {
                    desc = child.value as? String
                }
            }
            if let n = name, let d = desc {
                return "\(n): \(d)"
            }
            return nil
        }.joined(separator: "\n")
        
        let prompt = """
        === AGENT FULL STATE ===
        Name: \(agent.name), Age: \(agent.age)
        Profession: \(agent.profession ?? "unemployed")
        Location: \(currentLocation)
        Time: \(GameTime.current.formatted)
        Weather: Clear
        
        === PERSONALITY TRAITS ===
        Extraversion: \(agent.personality.extraversion) (\(agent.personality.extraversion > 0.6 ? "outgoing" : agent.personality.extraversion < 0.4 ? "introverted" : "balanced"))
        Creativity: \(agent.personality.creativity) (\(agent.personality.creativity > 0.6 ? "imaginative" : "practical"))
        Conscientiousness: \(agent.personality.conscientiousness) (\(agent.personality.conscientiousness > 0.6 ? "organized" : "spontaneous"))
        Neuroticism: \(agent.personality.neuroticism) (\(agent.personality.neuroticism > 0.6 ? "anxious" : "calm"))
        Openness: \(agent.personality.openness) (\(agent.personality.openness > 0.6 ? "adventurous" : "traditional"))
        
        === PHYSICAL & EMOTIONAL STATE ===
        Energy: \(agent.energy) (\(agent.energy < 0.3 ? "exhausted" : agent.energy < 0.5 ? "tired" : agent.energy > 0.8 ? "energetic" : "normal"))
        Hunger: \(agent.hunger) (\(agent.hunger > 0.7 ? "very hungry" : agent.hunger > 0.4 ? "getting hungry" : "satisfied"))
        Health: \(agent.health)
        Emotion: \(agent.emotion.dominantFeeling.rawValue) with intensity \(agent.emotion.arousal)
        Mood: \(agent.mood.currentMood)
        Inner thoughts: "\(agent.innerVoice)"
        
        === SOCIAL CONTEXT ===
        Nearby people: \(nearbyNames.isEmpty ? "Alone" : nearbyNames)
        Relationships with nearby: \(relationshipDetails.isEmpty ? "None" : relationshipDetails)
        Social role: \(agent.socialRole ?? "none")
        Recent interactions count: \(agent.recentInteractions.count)
        
        === RECENT MEMORIES (CRITICAL FOR CONTEXT) ===
        \(memorySummary.isEmpty ? "No recent memories" : memorySummary)
        
        === CURRENT GOALS & MOTIVATIONS ===
        \(goalsSummary.isEmpty ? "No specific goals" : goalsSummary)
        
        === INVENTORY & RESOURCES ===
        Carrying: \(carriedItems)
        Money: \(agent.money) credits
        Skills: \(skillsList)
        
        === ENVIRONMENT DETAILS ===
        Available locations nearby: Coffee shop, Library, Park, Market, Town Square, Residential area
        
        Nearby Interactive Objects:
        \(objectsList)
        
        Time of day effects: \(GameTime.current.hour < 6 ? "Very early morning - most places closed" : GameTime.current.hour < 9 ? "Morning - shops opening" : GameTime.current.hour < 12 ? "Late morning - busy time" : GameTime.current.hour < 14 ? "Lunch time" : GameTime.current.hour < 17 ? "Afternoon" : GameTime.current.hour < 20 ? "Evening" : GameTime.current.hour < 22 ? "Night - social time" : "Late night - most sleeping")
        
        Generate a HIGHLY SPECIFIC and REALISTIC action that \(agent.name) would take RIGHT NOW.
        
        Think like games such as Red Dead Redemption 2, The Witcher 3, or GTA - where NPCs have rich, detailed behaviors:
        
        GOOD EXAMPLES of specific actions:
        - "Walk to Johnson's Bakery and buy a fresh croissant while reading the morning newspaper"
        - "Sit by the fountain and sketch the pigeons while eating lunch from my bag"
        - "Approach Sarah to apologize for yesterday's argument about the community garden project"
        - "Head to the library to research medieval architecture for my novel's next chapter"
        - "Visit the market to haggle for fresh tomatoes, then chat with vendor Marcus about his family"
        - "Go to the park bench under the oak tree to practice guitar and maybe earn some tips"
        - "Stop by the pharmacy to pick up aspirin for this headache, then get coffee"
        - "Write in my journal at the quiet corner table in Hobbs Cafe about recent dreams"
        - "Help elderly Mrs. Chen carry her groceries home from the market"
        - "Practice juggling near the town square to entertain kids and improve dexterity"
        - "Search trash bins behind restaurants for useful items (if desperate)"
        - "Climb onto the library roof to watch the sunset and think about life choices"
        - "Start a conversation with the stranger reading Kafka at the coffee shop"
        - "Collect wildflowers from the park to press in my botanical journal"
        - "Fix the broken fence at the community garden using tools from my workshop"
        
        BAD EXAMPLES (too generic):
        - "Go to work"
        - "Explore the area"
        - "Socialize with someone"
        - "Rest"
        - "Look around"
        
        The action MUST:
        1. Be specific to THIS character's personality, memories, and current state
        2. Include details about HOW they do it (reflecting their personality)
        3. Reference specific locations, objects, or people when relevant
        4. Feel like something a real person would do in an open-world game
        5. Consider the time of day and what's realistically available
        
        Format:
        ACTION: [detailed specific action with location/object/person details]
        REASON: [psychological/emotional/practical reason based on their ACTUAL state]
        DURATION: [realistic time in minutes]
        """
        
        let response = try await callQwenAPI(
            system: """
            You are simulating the consciousness of a living person in a rich, dynamic world.
            Channel the depth of characters from games like Red Dead Redemption 2, The Witcher 3, and Cyberpunk 2077.
            
            Every action should feel authentic and emergent, driven by:
            - Deep psychological motivations from their personality and memories
            - Physical needs and emotional states
            - Social dynamics and relationships
            - Environmental opportunities and constraints
            - Personal goals and spontaneous desires
            
            Create actions that feel like they emerge from a real person's consciousness, not scripted behaviors.
            The agent should feel ALIVE - making decisions that surprise, delight, and feel genuinely human.
            """,
            user: prompt
        )
        
        return parseActionResponse(response, agent: agent)
    }
    
    /// Generate creative solutions
    func generateCreativeSolution(
        problem: String,
        constraints: [String],
        agentPersonality: PersonalityVector
    ) async throws -> CreativeSolution {
        let constraintsList = constraints.joined(separator: "\n- ")
        
        let prompt = """
        Problem: \(problem)
        
        Constraints:
        - \(constraintsList)
        
        Agent personality traits:
        Creativity: \(agentPersonality.creativity)
        Openness: \(agentPersonality.openness)
        
        Generate a creative solution that:
        1. Addresses the problem
        2. Works within the constraints
        3. Reflects the agent's creativity level
        4. Could realistically emerge from combining available resources
        
        Format: [Solution idea] -> [How to implement] -> [Why it works]
        """
        
        let response = try await callQwenAPI(
            system: "Generate creative solutions that feel emergent and realistic for AI agents.",
            user: prompt
        )
        
        return parseCreativeSolutionResponse(response)
    }
    
    /// Generate daily plans
    func generateDailyPlan(
        agent: Agent,
        previousDay: String,
        goals: [Goal]
    ) async throws -> DailyPlan {
        let goalsDesc = goals.map { $0.description }.joined(separator: "\n- ")
        
        let prompt = """
        Agent: \(agent.name)
        Profession: \(agent.profession ?? "none")
        Energy level: \(agent.energy)
        Current goals:
        - \(goalsDesc)
        
        Yesterday: \(previousDay)
        
        Generate a realistic daily plan that:
        1. Addresses the agent's goals
        2. Includes necessary activities (eating, resting)
        3. Reflects their energy level
        4. Allows for flexibility and spontaneous interactions
        
        Format as hourly activities from 6 AM to 11 PM.
        """
        
        let response = try await callQwenAPI(
            system: "Create realistic daily plans for AI agents that balance goals, needs, and spontaneity.",
            user: prompt
        )
        
        return parseDailyPlanResponse(response)
    }
    
    // MARK: - API Call Implementation
    private func callQwenAPI(system: String, user: String) async throws -> String {
        let url = URL(string: "\(config.baseURL)/services/aigc/text-generation/generation")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(config.getCurrentKey())", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": config.model,
            "input": [
                "messages": [
                    ["role": "system", "content": system],
                    ["role": "user", "content": user]
                ]
            ],
            "parameters": [
                "temperature": config.temperature,
                "max_tokens": config.maxTokens,
                "top_p": 0.9,
                "repetition_penalty": 1.1
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AIServiceError.invalidResponse
            }
            
            if httpResponse.statusCode == 429 {
                // Rate limited, rotate key and retry
                config.rotateKey()
                return try await callQwenAPI(system: system, user: user)
            }
            
            guard httpResponse.statusCode == 200 else {
                throw AIServiceError.httpError(statusCode: httpResponse.statusCode)
            }
            
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            guard let output = json?["output"] as? [String: Any],
                  let text = output["text"] as? String else {
                throw AIServiceError.parsingError
            }
            
            return text
            
        } catch {
            lastError = error
            throw error
        }
    }
    
    // MARK: - Response Parsing
    private func parseDialogueResponse(_ response: String) -> DialogueResponse {
        // Parse the response into structured dialogue
        let lines = response.components(separatedBy: "\n").filter { !$0.isEmpty }
        
        return DialogueResponse(
            lines: lines,
            emotionalTone: extractEmotionalTone(from: response),
            summary: lines.first ?? ""
        )
    }
    
    private func parseReflectionResponse(_ response: String) -> ReflectionInsight {
        let components = response.components(separatedBy: "->").map { $0.trimmingCharacters(in: .whitespaces) }
        
        return ReflectionInsight(
            pattern: components[safe: 0] ?? "",
            insight: components[safe: 1] ?? response,
            futureImplication: components[safe: 2] ?? ""
        )
    }
    
    private func parseActionResponse(_ response: String, agent: Agent) -> Action {
        // Parse ACTION: [action] REASON: [reason] DURATION: [minutes]
        var actionDesc = ""
        var reason = ""
        var duration = 30
        
        let lines = response.components(separatedBy: "\n")
        for line in lines {
            if line.starts(with: "ACTION:") {
                actionDesc = line.replacingOccurrences(of: "ACTION:", with: "").trimmingCharacters(in: .whitespaces)
            } else if line.starts(with: "REASON:") {
                reason = line.replacingOccurrences(of: "REASON:", with: "").trimmingCharacters(in: .whitespaces)
            } else if line.starts(with: "DURATION:") {
                let durationStr = line.replacingOccurrences(of: "DURATION:", with: "")
                    .replacingOccurrences(of: "minutes", with: "")
                    .trimmingCharacters(in: .whitespaces)
                duration = Int(durationStr) ?? 30
            }
        }
        
        // If parsing fails, use the whole response as action description
        if actionDesc.isEmpty {
            actionDesc = response
        }
        
        // Extract target object from action description
        var targetObject: String? = nil
        let objectKeywords = ["bench", "fountain", "book", "guitar", "piano", "tree", "trash", "table", "coffee", "newspaper"]
        for keyword in objectKeywords {
            if actionDesc.lowercased().contains(keyword) {
                targetObject = keyword
                break
            }
        }
        
        // Determine action type based on content
        let actionType: Action.ActionType = determineActionType(from: actionDesc)
        
        return Action(
            type: actionType,
            target: nil,
            targetAgent: nil,
            targetObject: targetObject,
            duration: duration,
            description: actionDesc,
            reason: reason
        )
    }
    
    private func determineActionType(from description: String) -> Action.ActionType {
        let lowercased = description.lowercased()
        
        if lowercased.contains("talk") || lowercased.contains("discuss") || lowercased.contains("chat") || lowercased.contains("approach") {
            return .socialize
        } else if lowercased.contains("work") || lowercased.contains("job") || lowercased.contains("task") {
            return .work
        } else if lowercased.contains("eat") || lowercased.contains("food") || lowercased.contains("breakfast") || lowercased.contains("lunch") || lowercased.contains("dinner") {
            return .eat
        } else if lowercased.contains("rest") || lowercased.contains("sleep") || lowercased.contains("tired") {
            return .rest
        } else if lowercased.contains("think") || lowercased.contains("reflect") || lowercased.contains("consider") {
            return .reflect
        } else if lowercased.contains("walk") || lowercased.contains("go to") || lowercased.contains("head") {
            return .move
        } else if lowercased.contains("create") || lowercased.contains("make") || lowercased.contains("build") {
            return .create
        } else if lowercased.contains("remember") || lowercased.contains("recall") {
            return .remember
        } else if lowercased.contains("watch") || lowercased.contains("look") || lowercased.contains("observe") {
            return .observe
        } else {
            return .observe // Default fallback
        }
    }
    
    private func parseCreativeSolutionResponse(_ response: String) -> CreativeSolution {
        let components = response.components(separatedBy: "->").map { $0.trimmingCharacters(in: .whitespaces) }
        
        return CreativeSolution(
            idea: components[safe: 0] ?? response,
            implementation: components[safe: 1] ?? "",
            reasoning: components[safe: 2] ?? ""
        )
    }
    
    private func parseDailyPlanResponse(_ response: String) -> DailyPlan {
        let lines = response.components(separatedBy: "\n")
        var activities: [QwenPlannedActivity] = []
        
        for line in lines {
            if let activity = parseActivityLine(line) {
                activities.append(activity)
            }
        }
        
        // Convert to DailyPlan format
        return DailyPlan(
            id: UUID(),
            agentId: UUID(), // Would need to be passed in
            date: 1,
            timeBlocks: [], // Would convert activities to time blocks
            goals: [],
            flexibility: 0.5
        )
    }
    
    private func parseActivityLine(_ line: String) -> QwenPlannedActivity? {
        // Parse lines like "8 AM: Having breakfast"
        let pattern = #"(\d{1,2})\s*(AM|PM):\s*(.+)"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: line, range: NSRange(location: 0, length: line.count)) else {
            return nil
        }
        
        let hourStr = (line as NSString).substring(with: match.range(at: 1))
        let periodStr = (line as NSString).substring(with: match.range(at: 2))
        let activity = (line as NSString).substring(with: match.range(at: 3))
        
        guard let hour = Int(hourStr) else { return nil }
        
        let adjustedHour = periodStr == "PM" && hour != 12 ? hour + 12 : hour
        
        return QwenPlannedActivity(
            hour: adjustedHour,
            description: activity,
            duration: 60 // Default 1 hour
        )
    }
    
    private func extractContent(from response: String) -> String {
        response.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func extractEmotionalTone(from text: String) -> Float {
        // Simple sentiment analysis
        let positiveWords = ["happy", "joy", "love", "excited", "grateful", "peaceful"]
        let negativeWords = ["sad", "angry", "frustrated", "worried", "anxious", "upset"]
        
        let lowercased = text.lowercased()
        var score: Float = 0
        
        for word in positiveWords {
            if lowercased.contains(word) {
                score += 0.2
            }
        }
        
        for word in negativeWords {
            if lowercased.contains(word) {
                score -= 0.2
            }
        }
        
        return max(-1, min(1, score))
    }
}

// MARK: - Response Types
struct DialogueResponse {
    let lines: [String]
    let emotionalTone: Float
    let summary: String
}

struct ReflectionInsight {
    let pattern: String
    let insight: String
    let futureImplication: String
}

struct CreativeSolution {
    let idea: String
    let implementation: String
    let reasoning: String
}

// MARK: - Errors
enum AIServiceError: Error {
    case invalidResponse
    case httpError(statusCode: Int)
    case parsingError
    case rateLimited
    case noAPIKey
}

// MARK: - LRU Cache for responses
class LRUCache<Key: Hashable, Value> {
    private let capacity: Int
    private var cache: [Key: Value] = [:]
    private var order: [Key] = []
    
    init(capacity: Int) {
        self.capacity = capacity
    }
    
    func get(_ key: Key) -> Value? {
        guard let value = cache[key] else { return nil }
        
        // Move to end (most recently used)
        order.removeAll { $0 == key }
        order.append(key)
        
        return value
    }
    
    func put(_ key: Key, _ value: Value) {
        if cache[key] != nil {
            // Update existing
            cache[key] = value
            order.removeAll { $0 == key }
            order.append(key)
        } else {
            // Add new
            if order.count >= capacity {
                // Remove least recently used
                let lru = order.removeFirst()
                cache.removeValue(forKey: lru)
            }
            
            cache[key] = value
            order.append(key)
        }
    }
}

// MARK: - Array Safe Subscript
extension Array {
    subscript(safe index: Int) -> Element? {
        return index >= 0 && index < count ? self[index] : nil
    }
}