//
//  CognitiveOrchestra.swift
//  Her Lives
//
//  Orchestrates concurrent cognitive processes (PIANO architecture)
//

import Foundation

class CognitiveOrchestra: ObservableObject {
    // Cognitive modules
    @Published var activeThoughts: [String] = []
    @Published var currentLoad: Float = 0
    @Published var dominantProcess: CognitiveProcess = .idle
    @Published var parallelProcesses: [CognitiveProcess] = []
    
    // Resource allocation
    private var cognitiveResources: Float = 1.0
    private var resourceAllocation: [CognitiveProcess: Float] = [:]
    
    // Bottleneck for coherence
    private let bottleneckCapacity: Int = 3
    private var processingQueue: [CognitiveTask] = []
    
    // Process states
    private var perceptionBuffer: [CorePerception] = []
    private var workingMemory: [Any] = []
    private var attentionFocus: AttentionFocus?
    
    // MARK: - Orchestration
    
    func orchestrate(agent: Agent, world: LivingWorld) async {
        // Clear previous state
        parallelProcesses.removeAll()
        activeThoughts.removeAll()
        
        // Determine active processes based on context
        let activeProcesses = determineActiveProcesses(agent: agent, world: world)
        
        // Allocate resources
        allocateResources(to: activeProcesses)
        
        // Execute processes concurrently
        await withTaskGroup(of: CognitiveOutput?.self) { group in
            for process in activeProcesses {
                group.addTask {
                    await self.executeProcess(process, agent: agent, world: world)
                }
            }
            
            // Collect outputs
            var outputs: [CognitiveOutput] = []
            for await output in group {
                if let output = output {
                    outputs.append(output)
                }
            }
            
            // Integrate through bottleneck
            integrateOutputs(outputs, agent: agent)
        }
        
        // Update cognitive load
        updateCognitiveLoad()
    }
    
    // MARK: - Process Selection
    
    private func determineActiveProcesses(agent: Agent, world: LivingWorld) -> [CognitiveProcess] {
        var processes: [CognitiveProcess] = []
        
        // Always active: perception
        processes.append(.perception)
        
        // Conditional processes
        if needsReflection(agent) {
            processes.append(.reflection)
        }
        
        if needsPlanning(agent) {
            processes.append(.planning)
        }
        
        if agent.currentAction?.type == .socialize {
            processes.append(.socialCognition)
        }
        
        if agent.emotion.intensity > 0.7 {
            processes.append(.emotionalRegulation)
        }
        
        if agent.cognitiveOrchestra.perceptionBuffer.count > 5 {
            processes.append(.memoryConsolidation)
        }
        
        // Limit to cognitive capacity
        let capacity = Int(agent.intelligence * Float(bottleneckCapacity) + 2)
        if processes.count > capacity {
            processes = prioritizeProcesses(processes, agent: agent)
                .prefix(capacity)
                .map { $0 }
        }
        
        parallelProcesses = processes
        return processes
    }
    
    private func prioritizeProcesses(_ processes: [CognitiveProcess], agent: Agent) -> [CognitiveProcess] {
        return processes.sorted { process1, process2 in
            processPriority(process1, agent: agent) > processPriority(process2, agent: agent)
        }
    }
    
    private func processPriority(_ process: CognitiveProcess, agent: Agent) -> Float {
        switch process {
        case .perception:
            return 1.0 // Always highest
        case .emotionalRegulation:
            return 0.9 * agent.emotion.intensity
        case .socialCognition:
            return 0.8 * Float(agent.friendCount) / 10.0
        case .planning:
            return 0.7 * agent.personality.conscientiousness
        case .reflection:
            return 0.6 * agent.personality.openness
        case .memoryConsolidation:
            return 0.5
        case .creativity:
            return 0.4 * agent.personality.openness
        case .problemSolving:
            return 0.7
        case .idle:
            return 0.1
        }
    }
    
    // MARK: - Resource Allocation
    
    private func allocateResources(to processes: [CognitiveProcess]) {
        resourceAllocation.removeAll()
        
        let totalPriority = processes.reduce(Float(0)) { sum, process in
            sum + 1.0 // Simplified priority calculation
        }
        
        for process in processes {
            let priority: Float = 1.0 // Simplified priority
            resourceAllocation[process] = (priority / totalPriority) * cognitiveResources
        }
    }
    
    // MARK: - Process Execution
    
    private func executeProcess(_ process: CognitiveProcess, agent: Agent, world: LivingWorld) async -> CognitiveOutput? {
        let resources = resourceAllocation[process] ?? 0.1
        
        switch process {
        case .perception:
            return await executePerception(agent: agent, world: world, resources: resources)
            
        case .reflection:
            return await executeReflection(agent: agent, resources: resources)
            
        case .planning:
            return await executePlanning(agent: agent, world: world, resources: resources)
            
        case .socialCognition:
            return await executeSocialCognition(agent: agent, world: world, resources: resources)
            
        case .emotionalRegulation:
            return executeEmotionalRegulation(agent: agent, resources: resources)
            
        case .memoryConsolidation:
            return executeMemoryConsolidation(agent: agent, resources: resources)
            
        case .creativity:
            return await executeCreativity(agent: agent, resources: resources)
            
        case .problemSolving:
            return await executeProblemSolving(agent: agent, world: world, resources: resources)
            
        case .idle:
            return nil
        }
    }
    
    // MARK: - Specific Cognitive Processes
    
    private func executePerception(agent: Agent, world: LivingWorld, resources: Float) async -> CognitiveOutput {
        var perceptions: [CorePerception] = []
        
        // Visual perception
        let nearbyAgents = world.agents.filter { other in
            other.id != agent.id && other.position.distance(to: agent.position) < 50
        }
        
        for other in nearbyAgents {
            perceptions.append(CorePerception(
                type: .visual,
                content: "See \(other.name) nearby",
                subject: other,
                importance: 0.5,
                emotionalValence: 0,
                emotionalIntensity: nil,
                location: agent.position,
                participants: [other.id]
            ))
        }
        
        // Environmental perception
        if let location = world.getLocationAt(agent.position) {
            perceptions.append(CorePerception(
                type: .environmental,
                content: "At \(location)",
                subject: location,
                importance: 0.3,
                emotionalValence: 0,
                emotionalIntensity: nil,
                location: agent.position,
                participants: []
            ))
        }
        
        // Internal perception
        if agent.emotion.intensity > 0.5 {
            perceptions.append(CorePerception(
                type: .internalSense,
                content: "Feeling \(agent.emotion.dominantFeeling.rawValue)",
                subject: nil,
                importance: agent.emotion.intensity,
                emotionalValence: agent.emotion.valence,
                emotionalIntensity: agent.emotion.intensity,
                location: agent.position,
                participants: []
            ))
        }
        
        // Filter by attention and resources
        let filteredPerceptions = perceptions
            .sorted { $0.importance > $1.importance }
            .prefix(Int(resources * 5))
        
        perceptionBuffer.append(contentsOf: filteredPerceptions)
        
        return CognitiveOutput(
            process: .perception,
            thoughts: filteredPerceptions.map { $0.content },
            modifications: [],
            decisions: []
        )
    }
    
    private func executeReflection(agent: Agent, resources: Float) async -> CognitiveOutput {
        guard resources > 0.2 else { return CognitiveOutput(process: .reflection, thoughts: [], modifications: [], decisions: []) }
        
        let recentMemories = agent.memoryStream.getRecentMemories(count: Int(resources * 10))
        let reflection = agent.reflection.reflect(
            on: recentMemories,
            personality: agent.personality,
            relationships: agent.relationships
        )
        
        let thoughts = [
            reflection.summary,
            "Realized: \(reflection.insights.first?.content ?? "something important")"
        ]
        
        return CognitiveOutput(
            process: .reflection,
            thoughts: thoughts,
            modifications: [.updateBeliefs, .generateInsight],
            decisions: []
        )
    }
    
    private func executePlanning(agent: Agent, world: LivingWorld, resources: Float) async -> CognitiveOutput {
        let plan = await agent.planning.createDailyPlan(for: agent, world: world)
        
        let thoughts = [
            "Planning the day ahead",
            "Priority: \(plan.goals.first?.description ?? "explore")"
        ]
        
        let decisions = [CognitiveDecision(
            action: .followPlan,
            confidence: resources,
            rationale: "Following daily plan"
        )]
        
        return CognitiveOutput(
            process: .planning,
            thoughts: thoughts,
            modifications: [],
            decisions: decisions
        )
    }
    
    private func executeSocialCognition(agent: Agent, world: LivingWorld, resources: Float) async -> CognitiveOutput {
        var thoughts: [String] = []
        
        // Theory of mind
        let nearbyAgents = world.agents.filter { other in
            other.id != agent.id && other.position.distance(to: agent.position) < 30
        }
        
        for other in nearbyAgents {
            let relationship = agent.relationships[other.id]
            let mentalModel = modelOthersMind(other, relationship: relationship)
            thoughts.append("\(other.name) seems \(mentalModel)")
        }
        
        // Social planning
        if let target = nearbyAgents.first {
            let approach = planSocialApproach(to: target, agent: agent)
            thoughts.append(approach)
        }
        
        return CognitiveOutput(
            process: .socialCognition,
            thoughts: thoughts,
            modifications: [.updateSocialModels],
            decisions: []
        )
    }
    
    private func executeEmotionalRegulation(agent: Agent, resources: Float) -> CognitiveOutput {
        var thoughts: [String] = []
        var modifications: [CognitiveModification] = []
        
        if agent.emotion.intensity > 0.8 {
            thoughts.append("Need to calm down")
            modifications.append(.regulateEmotion)
            
            // Apply regulation strategy
            if agent.personality.neuroticism < 0.5 {
                thoughts.append("Taking deep breaths")
                // Note: Can't directly modify intensity as it's computed property
                // Instead, regulate through modifications
                modifications.append(.regulateEmotion)
            } else {
                thoughts.append("Feeling overwhelmed")
            }
        }
        
        if agent.emotion.valence < -0.5 {
            thoughts.append("Trying to think positively")
            modifications.append(.reframeNegative)
        }
        
        return CognitiveOutput(
            process: .emotionalRegulation,
            thoughts: thoughts,
            modifications: modifications,
            decisions: []
        )
    }
    
    private func executeMemoryConsolidation(agent: Agent, resources: Float) -> CognitiveOutput {
        let consolidated = agent.memoryStream.consolidateMemories()
        
        let thoughts = [
            "Processing recent experiences",
            "Strengthened \(consolidated) memories"
        ]
        
        perceptionBuffer.removeAll()
        
        return CognitiveOutput(
            process: .memoryConsolidation,
            thoughts: thoughts,
            modifications: [.consolidateMemory],
            decisions: []
        )
    }
    
    private func executeCreativity(agent: Agent, resources: Float) async -> CognitiveOutput {
        let thoughts = [
            "What if \(generateCreativeIdea(agent))?",
            "Imagining new possibilities"
        ]
        
        return CognitiveOutput(
            process: .creativity,
            thoughts: thoughts,
            modifications: [.generateIdea],
            decisions: []
        )
    }
    
    private func executeProblemSolving(agent: Agent, world: LivingWorld, resources: Float) async -> CognitiveOutput {
        // Identify current problem
        let problem = identifyCurrentProblem(agent, world: world)
        
        let thoughts = [
            "Problem: \(problem)",
            "Considering options..."
        ]
        
        let solution = generateSolution(for: problem, agent: agent, resources: resources)
        
        return CognitiveOutput(
            process: .problemSolving,
            thoughts: thoughts,
            modifications: [],
            decisions: [solution]
        )
    }
    
    // MARK: - Integration
    
    private func integrateOutputs(_ outputs: [CognitiveOutput], agent: Agent) {
        // Collect all thoughts
        let allThoughts = outputs.flatMap { $0.thoughts }
        
        // Apply bottleneck - only top thoughts make it to consciousness
        activeThoughts = Array(allThoughts
            .prefix(bottleneckCapacity))
        
        // Update inner voice
        if let primaryThought = activeThoughts.first {
            agent.innerVoice = primaryThought
        }
        
        // Apply modifications
        for output in outputs {
            for modification in output.modifications {
                applyModification(modification, to: agent)
            }
        }
        
        // Integrate decisions
        let decisions = outputs.flatMap { $0.decisions }
        if let bestDecision = decisions.max(by: { $0.confidence < $1.confidence }) {
            agent.pendingDecision = bestDecision
        }
    }
    
    private func applyModification(_ modification: CognitiveModification, to agent: Agent) {
        switch modification {
        case .updateBeliefs:
            agent.updateBeliefs()
        case .generateInsight:
            agent.generateNewInsight()
        case .regulateEmotion:
            // Regulate emotions by reducing individual emotion components
            agent.emotion.happiness *= 0.9
            agent.emotion.sadness *= 0.9
            agent.emotion.anger *= 0.9
            agent.emotion.fear *= 0.9
        case .reframeNegative:
            agent.emotion.valence = min(0, agent.emotion.valence + 0.1)
        case .consolidateMemory:
            agent.memoryStream.strengthenImportantMemories()
        case .updateSocialModels:
            agent.updateSocialModels()
        case .generateIdea:
            agent.addCreativeIdea()
        }
    }
    
    // MARK: - Cognitive Load
    
    private func updateCognitiveLoad() {
        let processCount = Float(parallelProcesses.count)
        let perceptionLoad = Float(perceptionBuffer.count) / 10.0
        let memoryLoad = Float(workingMemory.count) / 7.0
        
        currentLoad = min(1.0, (processCount / Float(bottleneckCapacity)) * 0.5 +
                              perceptionLoad * 0.3 +
                              memoryLoad * 0.2)
    }
    
    // MARK: - Helper Functions
    
    private func needsReflection(_ agent: Agent) -> Bool {
        let memoryCount = agent.memoryStream.stream.count
        let timeSinceReflection: TimeInterval
        if let lastReflection = agent.reflection.recentReflections.last {
            // Convert GameTime to approximate Date for comparison
            let approximateDate = Date().addingTimeInterval(TimeInterval(-lastReflection.timestamp.daysSinceStart * 24 * 3600))
            timeSinceReflection = Date().timeIntervalSince(approximateDate)
        } else {
            timeSinceReflection = 3601 // More than 1 hour to trigger reflection
        }
        
        return memoryCount > 10 && timeSinceReflection > 3600 // 1 hour
    }
    
    private func needsPlanning(_ agent: Agent) -> Bool {
        return agent.dailyPlan == nil ||
               agent.currentAction == nil ||
               agent.goals.isEmpty
    }
    
    private func modelOthersMind(_ other: Agent, relationship: Relationship?) -> String {
        if other.emotion.dominantFeeling == .happy {
            return "happy"
        } else if other.emotion.dominantFeeling == .sad {
            return "troubled"
        } else if relationship?.closeness ?? 0 > 0.7 {
            return "friendly"
        } else {
            return "neutral"
        }
    }
    
    private func planSocialApproach(to other: Agent, agent: Agent) -> String {
        let relationship = agent.relationships[other.id]
        
        if relationship?.closeness ?? 0 > 0.7 {
            return "Approaching \(other.name) warmly"
        } else if relationship == nil {
            return "Considering introducing myself to \(other.name)"
        } else {
            return "Greeting \(other.name) politely"
        }
    }
    
    private func generateCreativeIdea(_ agent: Agent) -> String {
        let ideas = [
            "we tried something completely different",
            "there was another way to see this",
            "we combined unexpected elements",
            "we broke the usual pattern"
        ]
        return ideas.randomElement() ?? "we explored"
    }
    
    private func identifyCurrentProblem(_ agent: Agent, world: LivingWorld) -> String {
        if agent.goals.filter({ $0.progress < 0.3 }).count > 2 {
            return "Multiple goals are stalled"
        } else if agent.emotion.valence < -0.5 {
            return "Emotional distress"
        } else if agent.relationships.isEmpty {
            return "Social isolation"
        } else {
            return "No urgent problems"
        }
    }
    
    private func generateSolution(for problem: String, agent: Agent, resources: Float) -> CognitiveDecision {
        switch problem {
        case "Multiple goals are stalled":
            return CognitiveDecision(
                action: .reprioritize,
                confidence: resources,
                rationale: "Need to focus on fewer goals"
            )
        case "Emotional distress":
            return CognitiveDecision(
                action: .seekSupport,
                confidence: resources,
                rationale: "Need emotional support"
            )
        case "Social isolation":
            return CognitiveDecision(
                action: .socialize,
                confidence: resources,
                rationale: "Need to connect with others"
            )
        default:
            return CognitiveDecision(
                action: .continueCurrentPlan,
                confidence: resources,
                rationale: "Stay the course"
            )
        }
    }
}

// MARK: - Supporting Types

enum CognitiveProcess {
    case perception
    case reflection
    case planning
    case socialCognition
    case emotionalRegulation
    case memoryConsolidation
    case creativity
    case problemSolving
    case idle
}

struct CognitiveOutput {
    let process: CognitiveProcess
    let thoughts: [String]
    let modifications: [CognitiveModification]
    let decisions: [CognitiveDecision]
}

enum CognitiveModification {
    case updateBeliefs
    case generateInsight
    case regulateEmotion
    case reframeNegative
    case consolidateMemory
    case updateSocialModels
    case generateIdea
}

struct CognitiveTask {
    let id: UUID
    let process: CognitiveProcess
    let priority: Float
    let requiredResources: Float
}

struct AttentionFocus {
    let target: String
    let intensity: Float
    let duration: TimeInterval
    
    init(target: String, intensity: Float, duration: TimeInterval) {
        self.target = target
        self.intensity = intensity
        self.duration = duration
    }
}

enum AttentionTarget {
    case agent(UUID)
    case location(Position)
    case memory(UUID)
    case goal(UUID)
    case internalFocus
}

// Use CorePerception instead of duplicating Perception type
typealias CognitivePerception = CorePerception

struct CognitiveDecision {
    enum ActionType {
        case followPlan
        case reprioritize
        case seekSupport
        case socialize
        case continueCurrentPlan
        case explore
        case rest
    }
    
    let action: ActionType
    let confidence: Float
    let rationale: String
}