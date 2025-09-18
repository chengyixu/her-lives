//
//  LivingWorld.swift
//  Her Lives
//
//  The main world system where agents live and interact
//

import Foundation
import SwiftUI
import Combine

class LivingWorld: ObservableObject {
    // MARK: - Published Properties
    @Published var agents: [Agent] = []
    @Published var currentTime: GameTime = GameTime()
    @Published var isRunning: Bool = false
    @Published var worldEvents: [WorldEvent] = []
    @Published var emergentPhenomena: [EmergentPhenomenon] = []
    
    // MARK: - World Systems
    let physicalSpace = PhysicalSpace()
    let relationshipNetwork = RelationshipNetwork()
    let culturalSystem = CulturalSystem()
    let economicSystem = EmergentEconomy()
    let governanceSystem = EmergentGovernance()
    let collectiveConsciousness = CollectiveConsciousness()
    let reputationSystem = ReputationSystem()
    let environmentalObjects = EnvironmentalObjectsManager()
    
    // MARK: - Core Properties
    private var worldTimer: Timer?
    private let timeStep: TimeInterval = 1.0 // 1 second = 1 game minute (real-time)
    var emergenceDetector = EmergenceDetector()
    let qwenService = QwenAIService.shared
    
    // Computed Properties
    var totalRelationships: Int {
        relationshipNetwork.getAllRelationships().count
    }
    
    var currentDay: Int {
        currentTime.daysSinceStart + 1
    }
    
    // World is ALWAYS running - no pause
    
    var averageHappiness: Float {
        guard !agents.isEmpty else { return 0.5 }
        return agents.reduce(0) { $0 + $1.emotion.happiness } / Float(agents.count)
    }
    
    var culturalDiversity: Float {
        culturalSystem.calculateDiversity()
    }
    
    // MARK: - Initialization
    func initialize() {
        createInitialAgents()
        setupInitialRelationships()
        initializeCulture()
        initializeEnvironment()
        startWorld()
    }
    
    private func initializeEnvironment() {
        // Spawn default environmental objects
        environmentalObjects.spawnDefaultObjects()
    }
    
    private func createInitialAgents() {
        // Create diverse initial population
        let names = [
            "Isabella Rodriguez", "Maria Lopez", "Klaus Mueller", "Sam Moore",
            "Tom Moreno", "Jenny Lin", "Alex Chen", "Sarah Johnson",
            "David Kim", "Emma Wilson", "Oliver Brown", "Sophia Davis",
            "Liam Martinez", "Ava Anderson", "Noah Thompson", "Mia Garcia"
        ]
        
        for (index, name) in names.enumerated() {
            let agent = Agent(
                id: UUID(),
                name: name,
                age: Int.random(in: 20...65),
                position: physicalSpace.randomPosition()
            )
            
            // Initialize with diverse personalities
            agent.personality.randomizeWithBias(index: index)
            
            // Give them initial goals
            agent.goals = GoalGenerator.generateInitialGoals(for: agent)
            
            // Add some initial memories
            agent.memoryStream.seedWithBackstory()
            
            agents.append(agent)
        }
    }
    
    private func setupInitialRelationships() {
        // Create some initial relationships
        for agent in agents {
            // Each agent knows 2-5 other agents initially
            let numRelationships = Int.random(in: 2...5)
            for _ in 0..<numRelationships {
                if let other = agents.randomElement(), other.id != agent.id {
                    let relationship = Relationship(from: agent, to: other)
                    relationship.dimensions.familiarity = Float.random(in: 0.1...0.5)
                    relationship.dimensions.affection = Float.random(in: -0.2...0.6)
                    relationshipNetwork.addRelationship(relationship)
                }
            }
        }
    }
    
    private func initializeCulture() {
        // Seed some initial cultural memes
        let initialMemes = [
            "Community is strength",
            "Creativity solves problems",
            "Love needs courage",
            "Every person matters",
            "Growth comes from challenge"
        ]
        
        for memeContent in initialMemes {
            let meme = CulturalMeme(content: memeContent)
            // Randomly distribute to some agents
            for agent in agents.prefix(Int.random(in: 3...6)) {
                agent.adoptMeme(meme)
            }
            culturalSystem.addMeme(meme)
        }
    }
    
    // MARK: - World Control
    func startWorld() {
        isRunning = true
        worldTimer = Timer.scheduledTimer(withTimeInterval: timeStep, repeats: true) { _ in
            Task {
                await self.worldTick()
            }
        }
    }
    
    // NO PAUSE/RESUME - World always runs
    
    func reset() {
        // Stop current timer
        worldTimer?.invalidate()
        
        // Clear everything
        agents.removeAll()
        worldEvents.removeAll()
        emergentPhenomena.removeAll()
        currentTime = GameTime()
        
        // Restart world
        initialize()
    }
    
    // MARK: - Main World Loop
    @MainActor
    private func worldTick() async {
        // Time advances automatically with system clock - no manual advance needed
        
        // Process all agents concurrently
        await withTaskGroup(of: Void.self) { group in
            for agent in agents {
                group.addTask {
                    await agent.liveOneMoment(world: self)
                }
            }
        }
        
        // Process interactions
        processInteractions()
        
        // Process emergence
        detectAndProcessEmergence()
        
        // Update collective consciousness
        collectiveConsciousness.update(agents: agents)
        
        // Cultural evolution
        culturalSystem.evolve(timeStep: timeStep)
        
        // Economic processes
        economicSystem.processTransactions()
        
        // Environmental updates
        physicalSpace.update(time: currentTime)
        
        // Check for special events
        checkForSpecialEvents()
        
        // Memory management
        if currentTime.isNewHour {
            performHourlyMaintenance()
        }
    }
    
    // MARK: - Interaction Processing
    private func processInteractions() {
        let interactionRadius: Float = 10.0
        
        for agent in agents {
            let nearby = physicalSpace.getAgentsNear(agent, radius: interactionRadius, from: agents)
            
            for other in nearby {
                if shouldInteract(agent, other) {
                    let interaction = createInteraction(between: agent, and: other)
                    processInteraction(interaction)
                }
            }
        }
    }
    
    private func shouldInteract(_ agent1: Agent, _ agent2: Agent) -> Bool {
        // Check if they haven't interacted recently
        guard !agent1.recentInteractions.contains(agent2.id) else { return false }
        
        // Probability based on personality and relationship
        let relationship = relationshipNetwork.getRelationship(from: agent1, to: agent2)
        let affinity = relationship?.dimensions.affection ?? 0
        
        let interactionProbability = 0.1 + affinity * 0.3 + 
                                     agent1.personality.extraversion * 0.2
        
        return Float.random(in: 0...1) < interactionProbability
    }
    
    private func createInteraction(between agent1: Agent, and agent2: Agent) -> SocialInteraction {
        SocialInteraction(
            participants: [agent1, agent2],
            type: determineInteractionType(agent1, agent2),
            location: agent1.position,
            timestamp: currentTime
        )
    }
    
    private func determineInteractionType(_ agent1: Agent, _ agent2: Agent) -> InteractionType {
        let relationship = relationshipNetwork.getRelationship(from: agent1, to: agent2)
        
        if let rel = relationship {
            if rel.dimensions.conflict > 0.5 {
                return .conflict
            } else if rel.dimensions.affection > 0.7 {
                return .intimate
            }
        }
        
        return .casual
    }
    
    private func processInteraction(_ interaction: SocialInteraction) {
        // Generate dialogue using Qwen
        Task {
            let dialogue = await generateDialogue(for: interaction)
            
            // Process dialogue effects
            for participant in interaction.participants {
                participant.processDialogue(dialogue)
            }
            
            // Update relationships
            updateRelationships(from: interaction, with: dialogue)
            
            // Update reputation based on interaction
            for participant in interaction.participants {
                let witnesses = agents.filter { agent in
                    agent.id != participant.id &&
                    physicalSpace.distance(from: agent.position, to: interaction.location) < 20
                }
                
                if !witnesses.isEmpty {
                    let witnessList = witnesses.map { $0.id }
                    
                    // Record social interaction reputation
                    if interaction.type == .intimate {
                        reputationSystem.recordAction(
                            actor: participant.id,
                            action: "showed kindness",
                            actionType: .shareResource,
                            witnesses: Set(witnessList)
                        )
                    } else if interaction.type == .conflict {
                        reputationSystem.recordAction(
                            actor: participant.id,
                            action: "showed aggression",
                            actionType: .bullyOthers,
                            witnesses: Set(witnessList)
                        )
                    }
                }
            }
            
            // Check for meme transmission
            checkMemeTransmission(in: interaction)
            
            // Record as world event
            let event = WorldEvent(
                type: .socialInteraction,
                participants: interaction.participants.map { $0.id },
                description: dialogue.summary,
                timestamp: currentTime
            )
            worldEvents.append(event)
        }
    }
    
    // MARK: - Emergence Detection
    private func detectAndProcessEmergence() {
        let observations = gatherWorldObservations()
        let emergentPhenomena = emergenceDetector.detect(observations)
        
        for phenomenon in emergentPhenomena {
            processPhenomenon(phenomenon)
            self.emergentPhenomena.append(phenomenon)
            
            // Notify player of interesting emergence
            if phenomenon.significance > 0.8 {
                NotificationManager.shared.notifyEmergence(phenomenon)
            }
        }
    }
    
    private func gatherWorldObservations() -> WorldObservations {
        WorldObservations(
            agentStates: agents.map { $0.currentState },
            relationships: relationshipNetwork.getAllRelationships(),
            economicActivity: [], // economicSystem.recentTransactions not available
            culturalMemes: culturalSystem.activeMemes,
            collectiveMood: collectiveConsciousness.currentMood
        )
    }
    
    private func processPhenomenon(_ phenomenon: EmergentPhenomenon) {
        switch phenomenon.type {
        case .newTradition:
            culturalSystem.establishTradition(phenomenon.data)
            
        case .economicSpecialization:
            if let agentId = phenomenon.affectedAgents.first {
                if let agent = agents.first(where: { $0.id == agentId }) {
                    agent.profession = phenomenon.data["profession"] as? String
                }
            }
            
        case .socialMovement:
            for agentId in phenomenon.affectedAgents {
                if let agent = agents.first(where: { $0.id == agentId }) {
                    agent.joinMovement(phenomenon.data["movement"] as? String ?? "")
                }
            }
            
        case .collectiveRitual:
            scheduleCollectiveEvent(phenomenon)
            
        default:
            break
        }
    }
    
    // MARK: - AI Dialogue Generation
    private func generateDialogue(for interaction: SocialInteraction) async -> SocialDialogue {
        let prompt = DialoguePromptBuilder.build(
            interaction: interaction,
            world: self
        )
        
        do {
            let response = try await qwenService.generateDialogue(prompt: prompt)
            return SocialDialogue(
                lines: response.lines,
                emotionalTone: response.emotionalTone,
                summary: response.summary
            )
        } catch {
            // Fallback to simple dialogue
            return SocialDialogue.createFallback(for: interaction)
        }
    }
    
    // MARK: - Special Events
    private func checkForSpecialEvents() {
        // Check for birthdays
        for agent in agents {
            if agent.isBirthday(currentTime) {
                celebrateBirthday(agent)
            }
        }
        
        // Check for scheduled events
        // getScheduledEvent and executeEvent methods will be implemented if needed
        
        // Random events
        if Float.random(in: 0...1) < 0.001 { // 0.1% chance per tick
            generateRandomEvent()
        }
    }
    
    private func celebrateBirthday(_ agent: Agent) {
        let event = WorldEvent(
            type: .birthday,
            participants: [agent.id],
            description: "\(agent.name)'s birthday!",
            timestamp: currentTime
        )
        worldEvents.append(event)
        
        // Friends remember and may interact
        let friends = relationshipNetwork.getFriends(of: agent)
        for friend in friends {
            friend.addGoal(Goal(
                type: .social,
                description: "Wish \(agent.name) happy birthday",
                priority: 0.8,
                target: agent.id
            ))
        }
    }
    
    // MARK: - Maintenance
    private func performHourlyMaintenance() {
        // Memory consolidation for sleeping agents
        for agent in agents where agent.consciousness.isSleeping {
            agent.memoryStream.consolidate()
        }
        
        // Relationship decay
        relationshipNetwork.applyDecay(timePassed: 1.0)
        
        // Clean up old events
        worldEvents = Array(worldEvents.suffix(1000)) // Keep last 1000 events
        
        // Garbage collection for emergent phenomena
        emergentPhenomena = emergentPhenomena.compactMap { phenomenon -> EmergentPhenomenon? in
            let timeSince = Date().timeIntervalSince(phenomenon.timestamp)
            let hoursSince = timeSince / 3600
            return hoursSince < 168 ? phenomenon : nil // Keep for a week
        }
    }
    
    // MARK: - Save/Load
    func saveState() -> WorldSaveState {
        WorldSaveState(
            agents: agents,
            time: currentTime,
            relationships: relationshipNetwork.getAllRelationships(),
            culturalMemes: culturalSystem.getAllMemes(),
            worldEvents: worldEvents,
            emergentPhenomena: emergentPhenomena
        )
    }
    
    func loadState(_ state: WorldSaveState) {
        agents = state.agents
        currentTime = state.time
        relationshipNetwork.loadRelationships(state.relationships)
        culturalSystem.loadMemes(state.culturalMemes)
        worldEvents = state.worldEvents
        emergentPhenomena = state.emergentPhenomena
    }
    
    // MARK: - Missing Methods
    
    func checkMemeTransmission(in interaction: SocialInteraction) {
        // Check if any memes are transmitted during interaction
        for participant in interaction.participants {
            for meme in participant.carriedMemes {
                let otherParticipants = interaction.participants.filter { $0.id != participant.id }
                for other in otherParticipants {
                    _ = culturalSystem.transmitMeme(meme, from: participant, to: other)
                }
            }
        }
    }
    
    func updateRelationships(from interaction: SocialInteraction, with dialogue: SocialDialogue) {
        // Update relationships based on interaction and dialogue
        for i in 0..<interaction.participants.count {
            for j in (i+1)..<interaction.participants.count {
                let agent1 = interaction.participants[i]
                let agent2 = interaction.participants[j]
                
                relationshipNetwork.updateRelationship(
                    between: agent1,
                    and: agent2,
                    interaction: interaction
                )
            }
        }
    }
    
    func getCurrentInteraction(involving agent: Agent) -> SocialInteraction? {
        // Find any current interaction involving this agent
        // This would typically be stored in a current interactions list
        return nil // Placeholder
    }
    
    func getAgent(_ id: UUID) -> Agent? {
        return agents.first { $0.id == id }
    }
    
    func getLocation(_ name: String) -> Position? {
        // Get location by name
        let location = physicalSpace.locations.first { $0.name == name }
        return location?.position
    }
    
    func getLocationAt(_ position: Position) -> String? {
        // Get location name at position
        let location = physicalSpace.getLocationAt(position)
        return location?.name
    }
    
    func getRandomLocation() -> Position {
        return physicalSpace.randomPosition()
    }
    
    private func scheduleCollectiveEvent(_ phenomenon: EmergentPhenomenon) {
        // Schedule a collective event based on emergent phenomenon
        let event = WorldEvent(
            type: .celebration,
            participants: Array(phenomenon.affectedAgents),
            description: "Collective event: \(phenomenon.name)",
            timestamp: currentTime
        )
        worldEvents.append(event)
    }
    
    // Duplicate celebrateBirthday method removed
    
    private func generateRandomEvent() {
        let eventTypes = ["Weather change", "Community gathering", "Unexpected visitor"]
        let event = WorldEvent(
            type: .socialInteraction,
            participants: [],
            description: eventTypes.randomElement() ?? "Something interesting happened",
            timestamp: currentTime
        )
        worldEvents.append(event)
    }
}
