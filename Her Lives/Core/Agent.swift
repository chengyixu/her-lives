//
//  Agent.swift
//  Her Lives
//
//  The core Agent class - a truly living digital being
//

import Foundation
import SwiftUI
import Combine

class Agent: ObservableObject, Identifiable {
    // MARK: - Core Properties
    let id: UUID
    @Published var name: String
    @Published var age: Int
    @Published var position: Position
    
    // Workplace and home positions
    var workplace: Position?
    var home: Position?
    var favoriteSpot: Position?
    
    // MARK: - Cognitive Systems
    @Published var consciousness: ConsciousnessState
    @Published var memoryStream: MemoryStream
    @Published var reflection: ReflectionSystem
    @Published var planning: PlanningSystem
    @Published var cognitiveOrchestra: CognitiveOrchestra
    
    // MARK: - Personality & Emotion
    @Published var personality: PersonalityVector
    @Published var emotion: EmotionState
    @Published var mood: MoodState
    @Published var values: ValueSystem
    
    // MARK: - Social
    @Published var relationships: [UUID: Relationship] = [:]
    @Published var recentInteractions: Set<UUID> = []
    @Published var socialRole: String?
    @Published var reputation: Float = 0.5
    
    // MARK: - Goals & Desires
    @Published var goals: [Goal] = []
    @Published var desires: [Desire] = []
    @Published var currentAction: Action?
    @Published var dailyPlan: DailyPlan?
    
    // MARK: - Cultural
    @Published var carriedMemes: [CulturalMeme] = []
    @Published var beliefs: [Belief] = []
    @Published var culturalIdentity: CulturalIdentity
    
    // MARK: - Physical
    @Published var energy: Float = 1.0
    @Published var health: Float = 1.0
    @Published var hunger: Float = 0.0
    @Published var fatigue: Float = 0.0
    
    // MARK: - Professional & Resources
    @Published var profession: String?
    @Published var skills: [String: Float] = [:]
    @Published var resources: [String: Int] = [:]
    @Published var money: Int = 100  // Starting money
    @Published var inventory: [String: Int] = [:]  // Items carried
    
    // MARK: - Internal State
    var innerVoice: String = ""
    var lastReflectionTime: GameTime?
    var lastInteractionTime: GameTime?
    var currentContext: Context?
    var attentionFocus: AttentionFocus?
    
    // Computed Properties
    var currentState: AgentState {
        AgentState(
            id: id,
            position: position,
            consciousness: consciousness,
            emotion: emotion,
            currentAction: currentAction,
            energy: energy
        )
    }
    
    var isAwake: Bool {
        consciousness.state != .sleeping && consciousness.state != .dreaming
    }
    
    var needsRest: Bool {
        fatigue > 0.8 || energy < 0.2
    }
    
    var description: String {
        "\(name), \(age) years old, \(profession ?? "exploring life")"
    }
    
    // MARK: - Initialization
    init(id: UUID, name: String, age: Int, position: Position) {
        self.id = id
        self.name = name
        self.age = age
        self.position = position
        
        // Initialize cognitive systems
        self.consciousness = ConsciousnessState()
        self.memoryStream = MemoryStream(agentId: id)
        self.reflection = ReflectionSystem()
        self.planning = PlanningSystem()
        self.cognitiveOrchestra = CognitiveOrchestra()
        
        // Initialize personality and emotion
        self.personality = PersonalityVector()
        self.emotion = EmotionState()
        self.mood = MoodState()
        self.values = ValueSystem()
        
        // Initialize cultural identity
        self.culturalIdentity = CulturalIdentity()
        
        // Setup initial inner voice
        self.innerVoice = "Who am I? What is my purpose here?"
    }
    
    // MARK: - Core Life Cycle
    func liveOneMoment(world: LivingWorld) async {
        // 1. Perceive the world
        let perceptions = perceive(world: world)
        
        // 2. Process perceptions through memory
        for perception in perceptions {
            memoryStream.encode(perception)
        }
        
        // 3. Concurrent cognitive processing (PIANO architecture)
        async let emotionalProcessing = emotion.process(perceptions)
        async let attentionSelection = selectAttention(from: perceptions)
        async let memoryRetrieval = memoryStream.retrieve(context: currentContext)
        
        // Wait for all concurrent processes
        _ = await (emotionalProcessing, attentionSelection, memoryRetrieval)
        
        // 4. Check if should reflect
        if shouldReflect(world.currentTime) {
            await performReflection()
        }
        
        // 5. Update plans based on new information
        planning.update(with: perceptions, memory: memoryStream)
        
        // 6. Decide next action
        let decision = await makeDecision(world: world)
        
        // 7. Execute action
        if let action = decision {
            await executeAction(action, in: world)
        }
        
        // 8. Update physical state
        updatePhysicalState(world.currentTime)
        
        // 9. Process any pending social interactions
        await processSocialQueue(world: world)
        
        // 10. Cultural participation
        participateInCulture(world: world)
        
        // 11. Inner monologue (consciousness stream)
        generateInnerMonologue()
        
        // 12. Dreams if sleeping
        if consciousness.state == .dreaming {
            await dream()
        }
    }
    
    // MARK: - Perception
    private func perceive(world: LivingWorld) -> [CorePerception] {
        var perceptions: [Perception] = []
        
        // Visual perception (other agents and environment)
        let visualRange: Float = 20.0
        let nearbyAgents = world.physicalSpace.getAgentsNear(self, radius: visualRange, from: world.agents)
        
        for agent in nearbyAgents {
            perceptions.append(Perception(
                type: .visual,
                content: "I see \(agent.name)",
                subject: agent,
                importance: calculateImportance(of: agent),
                emotionalValence: getEmotionalResponse(to: agent)
            ))
        }
        
        // Environmental perception
        let environment = world.physicalSpace.getEnvironmentAt(position)
        perceptions.append(Perception(
            type: .environmental,
            content: environment.description,
            importance: 0.3,
            emotionalValence: environment.mood
        ))
        
        // Internal perception (hunger, fatigue, etc.)
        if hunger > 0.7 {
            perceptions.append(Perception(
                type: .internalSense,
                content: "I'm feeling hungry",
                importance: 0.6,
                emotionalValence: -0.3
            ))
        }
        
        if fatigue > 0.8 {
            perceptions.append(Perception(
                type: .internalSense,
                content: "I'm very tired",
                importance: 0.7,
                emotionalValence: -0.4
            ))
        }
        
        // Social perception (ongoing conversations, social cues)
        if let interaction = world.getCurrentInteraction(involving: self) {
            perceptions.append(Perception(
                type: .social,
                content: "Engaged in conversation",
                subject: interaction,
                importance: 0.8,
                emotionalValence: 0.5 // Placeholder since socialResponse doesn't exist
            ))
        }
        
        return perceptions
    }
    
    // MARK: - Reflection
    private func shouldReflect(_ currentTime: GameTime) -> Bool {
        // Stanford-style importance threshold
        let recentImportance = memoryStream.getRecentImportanceSum()
        if recentImportance > 150 {
            return true
        }
        
        // Time-based reflection (every 3 hours)
        if let lastReflection = lastReflectionTime {
            if currentTime.hoursSince(lastReflection) >= 3 {
                return true
            }
        }
        
        // Emotional trigger
        if emotion.intensity > 0.9 {
            return true
        }
        
        // Bedtime reflection
        if consciousness.state == .drowsy {
            return true
        }
        
        return false
    }
    
    private func performReflection() async {
        let insights = await reflection.generateReflection(
            trigger: determineReflectionTrigger()
        )
        
        // Process insights
        for insight in insights {
            // Convert SystemReflection to MemoryReflection for memory stream
            let memoryReflection = MemoryReflection(
                id: UUID(),
                timestamp: Date(),
                question: "What patterns do I see?",
                insight: insight.insights.first?.content ?? insight.summary,
                evidence: insight.memories,
                confidence: insight.insights.first?.confidence ?? 0.5,
                abstractionLevel: insight.depth,
                emotionalTone: insight.emotionalTone
            )
            
            // Add to memory as reflection
            memoryStream.addReflection(memoryReflection)
            
            // Process individual insights within the reflection
            for individualInsight in insight.insights {
                // Update beliefs if applicable
                if individualInsight.type == .philosophical || individualInsight.type == .behavioral {
                    updateBeliefs(from: insight)
                }
                
                // Update self-concept for emotional insights
                if individualInsight.type == .emotional {
                    updateSelfConcept(from: insight)
                }
                
                // Adjust goals for causal or actionable insights
                if individualInsight.type == .causal && individualInsight.actionable {
                    adjustGoals(from: insight)
                }
            }
        }
        
        lastReflectionTime = GameTime.current
    }
    
    // MARK: - Decision Making
    private func makeDecision(world: LivingWorld) async -> Action? {
        // Check if current action should continue
        if let currentAction = currentAction {
            if shouldContinueAction(currentAction) {
                return nil // Continue current action
            }
        }
        
        // Use LLM to generate contextual action based on full cognitive state
        do {
            // Get recent memories for context
            let recentMemories = memoryStream.getRecentMemories(count: 5)
            
            // Get nearby agents
            let nearbyAgents = world.physicalSpace.getAgentsNear(
                self,
                radius: 20.0,
                from: world.agents
            )
            
            // Get current location description
            let currentLocation = world.getLocationAt(position) ?? "An open area"
            
            // Get nearby objects
            let nearbyObjects = world.environmentalObjects.getObjectsNear(
                position: position,
                radius: 10.0
            )
            
            // Generate action using Qwen LLM with full context
            let action = try await QwenAIService.shared.generateNextAction(
                agent: self,
                world: world,
                recentMemories: recentMemories,
                nearbyAgents: nearbyAgents,
                currentLocation: currentLocation,
                nearbyObjects: nearbyObjects
            )
            
            return action
            
        } catch {
            // Fallback to basic need-based action if LLM fails
            print("LLM action generation failed for \(name): \(error)")
            return generateFallbackAction()
        }
    }
    
    private func generateFallbackAction() -> Action {
        // Simple fallback based on most urgent need
        if physicalState.energy < 0.2 {
            return Action(
                type: .rest,
                target: nil,
                duration: 60,
                description: "Resting due to exhaustion",
                reason: "Extremely low energy"
            )
        } else if physicalState.hunger > 0.8 {
            return Action(
                type: .eat,
                target: nil,
                duration: 30,
                description: "Finding food",
                reason: "Very hungry"
            )
        } else if socialState.needForInteraction > 0.7 {
            return Action(
                type: .socialize,
                target: nil,
                duration: 45,
                description: "Seeking social interaction",
                reason: "Feeling lonely"
            )
        } else {
            return Action(
                type: .observe,
                target: nil,
                duration: 20,
                description: "Observing surroundings",
                reason: "Nothing urgent to do"
            )
        }
    }
    
    // MARK: - Action Execution
    private func executeAction(_ action: Action, in world: LivingWorld) async {
        currentAction = action
        
        // First check if action involves an object
        if let objectName = action.targetObject {
            if let object = world.environmentalObjects.findObjectByName(objectName) {
                // Determine object action based on description
                let objectAction = determineObjectAction(from: action.description)
                let result = object.interact(agent: self, action: objectAction)
                
                // Process interaction effects
                for effect in result.effects {
                    processInteractionEffect(effect)
                }
                
                // Record reputation impact if witnessed
                let witnesses = world.physicalSpace.getAgentsNear(self, radius: 15, from: world.agents).map { $0.id }
                if !witnesses.isEmpty {
                    let reputationType = determineReputationType(from: action)
                    world.reputationSystem.recordAction(
                        actor: self.id,
                        action: action.description,
                        actionType: reputationType,
                        witnesses: Set(witnesses)
                    )
                }
                
                // Add to memory
                let memory = Memory(
                    content: result.message,
                    importance: 0.5,
                    emotionalValence: 0.2
                )
                memoryStream.add(memory)
            }
        }
        
        // Execute base action types
        switch action.type {
        case .move:
            if let target = action.target {
                moveToward(target)
            }
            
        case .speak:
            if let target = action.targetAgent {
                await speak(to: target, content: action.content ?? action.description, world: world)
            }
            
        case .work:
            performWork(action.description)
            skills["work", default: 0] += 0.01
            
        case .rest:
            rest()
            
        case .eat:
            eat()
            
        case .socialize:
            if let target = action.targetAgent {
                await socialize(with: target, world: world)
            }
            
        case .reflect:
            await performReflection()
            
        case .create:
            await createSomething(action.description)
            skills["creativity", default: 0] += 0.02
            
        default:
            break
        }
        
        // Record action in memory with full context
        let enrichedMemory = Memory(
            content: "\(action.description). \(action.reason)",
            importance: action.importance ?? 0.3,
            emotionalValence: emotion.valence
        )
        memoryStream.add(enrichedMemory)
    }
    
    private func determineObjectAction(from description: String) -> ObjectAction {
        let desc = description.lowercased()
        if desc.contains("sit") { return .sit }
        if desc.contains("read") { return .read }
        if desc.contains("play") { return .play }
        if desc.contains("eat") { return .eat }
        if desc.contains("search") { return .search }
        if desc.contains("harvest") { return .harvest }
        if desc.contains("write") { return .write }
        if desc.contains("observe") { return .observe }
        return .interact
    }
    
    private func determineReputationType(from action: Action) -> ActionReputationType {
        let desc = action.description.lowercased()
        if desc.contains("help") { return .helpStranger }
        if desc.contains("share") { return .shareResource }
        if desc.contains("joke") { return .tellJoke }
        if desc.contains("solve") { return .solveProblems }
        if desc.contains("steal") { return .stealFrom }
        if desc.contains("insult") { return .insult }
        if desc.contains("create") || desc.contains("art") { return .createArt }
        if desc.contains("teach") { return .teachOthers }
        return .solveProblems // default
    }
    
    private func processInteractionEffect(_ effect: InteractionEffect) {
        switch effect {
        case .rest(let amount):
            physicalState.energy = min(physicalState.energy + amount, 1.0)
        case .hunger(let reduction):
            physicalState.hunger = max(physicalState.hunger - reduction, 0)
        case .health(let change):
            physicalState.health = min(max(physicalState.health + change, 0), 1)
        case .mood(let change):
            emotion.happiness = min(max(emotion.happiness + change, 0), 1)
        case .skill(let name, let gain):
            skills[name, default: 0] += gain
        case .knowledge(let topic):
            let memory = Memory(content: "Learned about \(topic)", importance: 0.6, emotionalValence: 0.3)
            memoryStream.add(memory)
        case .item(let name, let quantity):
            inventory[name, default: 0] += quantity
        case .reputation(let change):
            // Reputation is handled above with witnesses
            break
        case .relationship(let withId, let change):
            // Update relationship if it exists
            if let rel = relationships[withId] {
                rel.affection = min(max(rel.affection + change, -1), 1)
            }
        }
    }
    
    // MARK: - Social Interaction
    func processDialogue(_ dialogue: SocialDialogue) {
        // Update emotional state based on dialogue
        // Process the dialogue's emotional impact
        let emotionalImpact = EmotionImpact(
            happiness: dialogue.emotionalTone > 0 ? dialogue.emotionalTone * 0.3 : 0,
            sadness: dialogue.emotionalTone < 0 ? -dialogue.emotionalTone * 0.3 : 0,
            anger: 0, fear: 0, surprise: 0.1, disgust: 0,
            arousal: 0.5, valence: dialogue.emotionalTone
        )
        emotion.happiness += emotionalImpact.happiness
        emotion.sadness += emotionalImpact.sadness
        
        // Extract and process information
        let informationStrings = extractInformation(from: dialogue)
        for infoString in informationStrings {
            let info = Information(
                content: infoString,
                source: "dialogue",
                importance: 0.5,
                relevance: nil
            )
            memoryStream.addInformation(info)
        }
        
        // Update relationship based on interaction quality
        if let otherAgent = dialogue.otherParticipant(besides: self) {
            updateRelationship(with: otherAgent, quality: dialogue.interactionQuality)
        }
        
        // Check for meme transmission
        if let meme = dialogue.containedMeme {
            considerAdoptingMeme(meme)
        }
    }
    
    private func speak(to target: Agent, content: String, world: LivingWorld) async {
        // Generate contextual dialogue using Qwen
        let dialogueText: String
        do {
            dialogueText = try await world.qwenService.generateAgentDialogue(
                speaker: self,
                listener: target,
                context: content,
                emotion: emotion,
                relationship: relationships[target.id]
            )
        } catch {
            // Fallback to simple dialogue on error
            dialogueText = "Hello, \(target.name)!"
        }
        
        // Create dialogue object from text
        let dialogue = SocialDialogue(
            lines: [dialogueText],
            emotionalTone: emotion.valence,
            summary: dialogueText
        )
        
        // Deliver dialogue
        target.receiveDialogue(dialogue, from: self)
        
        // Update interaction records
        recentInteractions.insert(target.id)
        lastInteractionTime = world.currentTime
    }
    
    func receiveDialogue(_ dialogue: SocialDialogue, from sender: Agent) {
        // Process received dialogue
        processDialogue(dialogue)
        
        // Record the interaction in memory
        let memory = Memory(
            id: UUID(),
            timestamp: Date(),
            content: "Conversation with \(sender.name): \(dialogue.summary)",
            type: .social,
            importance: 0.6,
            recency: 1.0,
            relevance: 0.7,
            emotionalValence: dialogue.emotionalTone,
            emotionalIntensity: abs(dialogue.emotionalTone),
            participants: [sender.id]
        )
        addMemory(memory)
    }
    
    // MARK: - Physical State
    private func updatePhysicalState(_ currentTime: GameTime) {
        // Energy decreases over time
        energy -= 0.001
        
        // Hunger increases
        hunger += 0.002
        
        // Fatigue increases based on activity
        if currentAction?.type == .work {
            fatigue += 0.003
        } else if currentAction?.type == .rest {
            fatigue -= 0.005
        } else {
            fatigue += 0.001
        }
        
        // Clamp values
        energy = max(0, min(1, energy))
        hunger = max(0, min(1, hunger))
        fatigue = max(0, min(1, fatigue))
        
        // Update consciousness based on fatigue
        if fatigue > 0.9 {
            consciousness.state = .drowsy
        } else if consciousness.state == .sleeping && fatigue < 0.2 {
            consciousness.state = .awake
        }
    }
    
    // MARK: - Inner Monologue
    private func generateInnerMonologue() {
        // Generate rich, contextual inner thoughts using LLM
        Task {
            do {
                // Build context for inner thought generation
                let recentMemory = memoryStream.getRecentMemories(count: 1).first?.content ?? "nothing particular"
                let currentGoal = goals.first?.description ?? "no specific goal"
                
                let context = """
                Feeling: \(emotion.dominantFeeling.rawValue) (intensity: \(emotion.arousal))
                Physical: Energy \(physicalState.energy), Hunger \(physicalState.hunger)
                Recent memory: \(recentMemory)
                Current goal: \(currentGoal)
                Current action: \(currentAction?.description ?? "idle")
                Personality traits: Creative(\(personality.creativity)), Neurotic(\(personality.neuroticism))
                """
                
                innerVoice = try await QwenAIService.shared.generateInnerMonologue(
                    agent: self,
                    context: context
                )
            } catch {
                // Fallback to contextual thoughts if LLM fails
                generateFallbackInnerVoice()
            }
        }
    }
    
    private func generateFallbackInnerVoice() {
        let contextualThoughts: [String] = [
            // Physical state thoughts
            physicalState.hunger > 0.7 ? "I'm starving... need food soon" : nil,
            physicalState.energy < 0.3 ? "So exhausted... can barely keep going" : nil,
            physicalState.energy > 0.8 ? "Feeling energized and ready for anything!" : nil,
            
            // Emotional thoughts
            emotion.dominantFeeling == .happy ? "Everything feels right in the world" : nil,
            emotion.dominantFeeling == .sad ? "Why does everything feel so heavy?" : nil,
            emotion.dominantFeeling == .angry ? "This frustration is eating at me..." : nil,
            emotion.dominantFeeling == .fearful ? "Something doesn't feel safe here" : nil,
            
            // Social thoughts
            socialState.needForInteraction > 0.6 ? "I really need to talk to someone" : nil,
            relationships.count == 0 ? "Am I truly alone in this world?" : nil,
            relationships.count > 5 ? "Blessed with so many connections" : nil,
            
            // Goal thoughts
            goals.isEmpty ? "What am I even doing with my life?" : nil,
            goals.count > 3 ? "So much to do, where do I start?" : nil,
            
            // Creative thoughts (based on personality)
            personality.creativity > 0.7 ? "I see patterns everywhere... beauty in chaos" : nil,
            personality.neuroticism > 0.7 ? "What if everything goes wrong?" : nil,
            personality.openness > 0.7 ? "I wonder what's beyond the horizon..." : nil
        ].compactMap { $0 }
        
        innerVoice = contextualThoughts.randomElement() ?? "..."
    }
    
    // MARK: - Dreaming
    private func dream() async {
        let dream = Dream(
            dreamer: self,
            memories: memoryStream.getRandomMemories(count: 5),
            emotions: emotion.recentEmotions,
            desires: desires
        )
        
        let dreamContent = await dream.generate()
        
        // Dreams can influence waking life
        memoryStream.addDream(dreamContent)
        
        // Process dream for insights
        if dreamContent.isSignificant {
            reflection.processDream(dreamContent)
        }
        
        // Emotional regulation through dreams
        processDreamEmotions(dreamContent)
    }
    
    // MARK: - Memory Management
    func consolidateMemories() {
        memoryStream.consolidate()
        
        // Move important short-term memories to long-term
        let importantMemories = memoryStream.shortTerm.filter { $0.importance > 0.7 }
        for memory in importantMemories {
            memoryStream.moveToLongTerm(memory)
        }
        
        // Forget unimportant details
        memoryStream.forget(threshold: 0.2)
    }
    
    // Add intelligence property to personality
    var intelligence: Float {
        return personality.openness * 0.3 + personality.conscientiousness * 0.7
    }
    
    // MARK: - Helpers
    func isBirthday(_ currentTime: GameTime) -> Bool {
        // Simple birthday check (every 365 days from creation)
        return currentTime.daysSinceStart % 365 == age % 365
    }
    
    func addGoal(_ goal: Goal) {
        goals.append(goal)
    }
    
    func moveTo(_ location: Position, in world: LivingWorld) async {
        // Move agent to new location
        let oldPosition = position
        position = location
        world.physicalSpace.recordMovement(self, from: oldPosition, to: location, timestamp: Date())
    }
    
    func interactWith(_ target: Agent, in world: LivingWorld) async {
        let interaction = SocialInteraction(
            participants: [self, target],
            type: .casual,
            location: position,
            timestamp: world.currentTime
        )
        
        world.relationshipNetwork.updateRelationship(between: self, and: target, interaction: interaction)
        updateRelationship(with: target, quality: 0.6)
    }
    
    func performWork() {
        energy -= 0.1
        fatigue += 0.05
        
        if let work = profession {
            skills[work, default: 0] += 0.01
        }
    }
    
    // Duplicate performReflection removed
    
    func adoptMeme(_ meme: CulturalMeme) {
        if !carriedMemes.contains(where: { $0.id == meme.id }) {
            carriedMemes.append(meme)
            
            // Meme might influence beliefs
            if meme.resonatesWith(beliefs: beliefs) {
                let influence = meme.calculateInfluence(on: self)
                applyMemeInfluence(influence)
            }
        }
    }
    
    func joinMovement(_ movement: String) {
        socialRole = movement
        // Add movement goals
        goals.append(Goal(
            type: .social,
            description: "Participate in \(movement)",
            priority: 0.7
        ))
    }
    
    private func applyMemeInfluence(_ influence: MemeInfluence) {
        // Update values
        values.adjust(influence.valueChanges)
        
        // Update personality slightly
        personality.nudge(influence.personalityShift)
        
        // Add new beliefs
        if let newBelief = influence.newBelief {
            beliefs.append(newBelief)
        }
    }
}

// MARK: - Missing Agent Methods

extension Agent {
    func selectAttention(from perceptions: [CorePerception]) async -> AttentionFocus? {
        // Select most salient perception for attention
        guard let mostSalient = perceptions.max(by: { $0.importance < $1.importance }) else {
            return nil
        }
        
        return AttentionFocus(
            target: mostSalient.content,
            intensity: mostSalient.importance,
            duration: 60.0
        )
    }
    
    func calculateImportance(of other: Agent) -> Float {
        // Calculate importance of another agent based on relationship
        if let relationship = relationships[other.id] {
            return relationship.closeness * 0.5 + relationship.dimensions.familiarity * 0.3
        }
        return 0.2 // Base importance for strangers
    }
    
    func getEmotionalResponse(to other: Agent) -> Float {
        // Get emotional response to another agent
        if let relationship = relationships[other.id] {
            return relationship.dimensions.affection
        }
        return 0.0
    }
    
    func determineReflectionTrigger() -> String {
        if emotion.intensity > 0.8 {
            return "high emotional intensity"
        } else if memoryStream.getRecentImportanceSum() > 150 {
            return "accumulated experiences"
        } else {
            return "routine reflection"
        }
    }
    
    func updateBeliefs(from reflection: SystemReflection) {
        // Update beliefs based on reflection insights
        if reflection.depth > 2 {
            // Use the most significant insight
            if let bestInsight = reflection.insights.max(by: { $0.significance < $1.significance }) {
                let newBelief = Belief(
                    content: bestInsight.content,
                    strength: bestInsight.confidence,
                    category: .personal
                )
                beliefs.append(newBelief)
            }
        }
    }
    
    func updateSelfConcept(from reflection: SystemReflection) {
        // Update self-concept based on emotional insights
        if let emotionalInsight = reflection.insights.first(where: { $0.type == .emotional }) {
            // Could update personality slightly or add to self-description
            innerVoice = "I am learning that \(emotionalInsight.content)"
        }
    }
    
    func adjustGoals(from reflection: SystemReflection) {
        // Adjust goals based on causal insights
        for insight in reflection.insights where insight.type == .causal && insight.confidence > 0.7 {
            // Re-prioritize goals or add new ones
            for goal in goals {
                if insight.content.lowercased().contains(goal.description.lowercased()) {
                    var mutableGoal = goal
                    mutableGoal.priority = min(1.0, mutableGoal.priority + 0.1)
                    // Update the goal in the array
                    if let index = goals.firstIndex(where: { $0.id == goal.id }) {
                        goals[index] = mutableGoal
                    }
                }
            }
        }
    }
    
    func shouldContinueAction(_ action: Action) -> Bool {
        // Simple continuation logic
        return action.duration > 0 && energy > 0.2
    }
    
    func getUrgentNeed() -> String? {
        if fatigue > 0.9 { return "rest" }
        if hunger > 0.8 { return "food" }
        if energy < 0.1 { return "rest" }
        return nil
    }
    
    func handleUrgentNeed(_ need: String) -> Action {
        switch need {
        case "rest":
            return Action(type: .rest, description: "Taking a rest")
        case "food":
            return Action(type: .eat, description: "Getting food")
        default:
            return Action(type: .rest, description: "Addressing urgent need")
        }
    }
    
    func checkSocialOpportunities(_ world: LivingWorld) -> SocialOpportunity? {
        let nearbyAgents = world.physicalSpace.getAgentsNear(self, radius: 50, from: world.agents)
        
        for other in nearbyAgents {
            if let relationship = relationships[other.id],
               relationship.dimensions.affection > 0.5 {
                return SocialOpportunity(
                    targetAgent: other,
                    opportunity: "reconnect with friend",
                    importance: 0.7
                )
            }
        }
        
        return nil
    }
    
    func createSocialAction(for opportunity: SocialOpportunity) -> Action {
        return Action(
            type: .socialize,
            description: "Socializing with \(opportunity.targetAgent.name)",
            targetAgent: opportunity.targetAgent
        )
    }
    
    func moveToward(_ target: Position) {
        // Simple movement toward target
        let direction = Vector2D(from: position, to: target)
        let normalized = direction.normalized()
        let speed: Float = 5.0
        
        position.x += normalized.x * speed
        position.y += normalized.y * speed
    }
    
    func performWork(_ workType: String?) {
        // Perform work-related activities
        energy -= 0.1
        fatigue += 0.05
        
        // Could update skills, resources, etc.
        if let work = workType {
            skills[work, default: 0] += 0.01
        }
    }
    
    func rest() {
        fatigue = max(0, fatigue - 0.2)
        energy = min(1.0, energy + 0.1)
        consciousness.state = .sleeping
    }
    
    func eat() {
        hunger = max(0, hunger - 0.5)
        energy = min(1.0, energy + 0.1)
        
        // Consume food resources if available
        resources["food", default: 0] = max(0, resources["food", default: 0] - 1)
    }
    
    func socialize(with target: Agent, world: LivingWorld) async {
        // Engage in social interaction
        let interaction = SocialInteraction(
            participants: [self, target],
            type: .casual,
            location: position,
            timestamp: world.currentTime
        )
        
        // Update relationship
        updateRelationship(with: target, quality: 0.6)
        
        // Add to recent interactions
        recentInteractions.insert(target.id)
    }
    
    func createSomething(_ creationType: String?) async {
        // Creative activities
        energy -= 0.05
        
        if let creation = creationType {
            skills["creativity", default: 0] += 0.02
            
            // Could create cultural artifacts, memes, etc.
            let culturalMeme = CulturalMeme(content: "Creative expression through \(creation)")
            adoptMeme(culturalMeme)
        }
    }
    
    func processSocialQueue(world: LivingWorld) async {
        // Process any pending social interactions
        // Clean up old recent interactions
        if recentInteractions.count > 10 {
            recentInteractions = Set(Array(recentInteractions).suffix(5))
        }
    }
    
    func participateInCulture(world: LivingWorld) {
        // Participate in cultural transmission
        let nearbyAgents = world.physicalSpace.getAgentsNear(self, radius: 30, from: world.agents)
        
        for other in nearbyAgents {
            // Chance to transmit memes
            for meme in carriedMemes {
                if Float.random(in: 0...1) < 0.1 { // 10% chance per nearby agent per meme
                    _ = world.culturalSystem.transmitMeme(meme, from: self, to: other)
                }
            }
        }
    }
    
    func extractInformation(from dialogue: SocialDialogue) -> [String] {
        // Extract information from dialogue
        return dialogue.lines.filter { line in
            line.lowercased().contains("fact") || line.lowercased().contains("information")
        }
    }
    
    // Placeholder methods for compilation
    func updateBeliefs() {
        // Update agent beliefs based on recent experiences
    }
    
    func generateNewInsight() {
        // Generate new insights
        let insight = "Life is about continuous learning"
        innerVoice = insight
    }
    
    func updateSocialModels() {
        // Update mental models of other agents
    }
    
    func addCreativeIdea() {
        // Add creative ideas to agent's repertoire
        let idea = "What if we tried a new approach?"
        innerVoice = idea
    }
    
    var pendingDecision: CognitiveDecision? {
        get { nil }
        set { /* Store decision */ }
    }
    
    // MARK: - Missing Memory Methods
    
    func addMemory(_ memory: Memory) {
        memoryStream.addMemory(memory)
    }
    
    func processDreamEmotions(_ dreamContent: DreamContent) {
        // Process dream's emotional content to regulate emotions
        for emotionSnapshot in dreamContent.emotions {
            switch emotionSnapshot.emotion {
            case .happy:
                emotion.happiness += 0.1 * emotionSnapshot.intensity
            case .sad:
                emotion.sadness += 0.1 * emotionSnapshot.intensity
            case .angry:
                emotion.anger = max(0, emotion.anger - 0.1 * emotionSnapshot.intensity)
            case .fearful:
                emotion.fear = max(0, emotion.fear - 0.1 * emotionSnapshot.intensity)
            default:
                break
            }
        }
        
        // Clamp values
        emotion.happiness = max(0, min(1, emotion.happiness))
        emotion.sadness = max(0, min(1, emotion.sadness))
        emotion.anger = max(0, min(1, emotion.anger))
        emotion.fear = max(0, min(1, emotion.fear))
    }
    
    // Note: updateRelationship method is defined in RelationshipNetwork.swift extension
    
    // Note: considerAdoptingMeme method is defined in CulturalSystem.swift extension
    
    // Duplicate methods removed
}

struct SocialOpportunity {
    let targetAgent: Agent
    let opportunity: String
    let importance: Float
}