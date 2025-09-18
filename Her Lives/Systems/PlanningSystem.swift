//
//  PlanningSystem.swift
//  Her Lives
//
//  Hierarchical planning and goal management system
//

import Foundation

class PlanningSystem: ObservableObject {
    @Published var currentPlan: Plan?
    @Published var dailyPlan: DailyPlan?
    @Published var activeGoals: [Goal] = []
    @Published var completedGoals: [Goal] = []
    
    private let maxActiveGoals = 5
    private let planHorizon = 24 // hours
    
    // MARK: - Planning Process
    
    func createDailyPlan(for agent: Agent, world: LivingWorld) async -> DailyPlan {
        _ = assessNeeds(agent)
        _ = identifyOpportunities(world, agent: agent)
        _ = getObligations(agent)
        
        // Generate time blocks
        var timeBlocks: [TimeBlock] = []
        
        // Morning routine (6-9 AM)
        timeBlocks.append(TimeBlock(
            startTime: GameTime(),
            duration: 180,
            activity: .routine("morning"),
            priority: 0.8,
            flexibility: 0.3
        ))
        
        // Work/Main activity (9 AM - 5 PM)
        if agent.profession != nil {
            timeBlocks.append(TimeBlock(
                startTime: GameTime(),
                duration: 480,
                activity: .work,
                priority: 0.9,
                flexibility: 0.2
            ))
        } else {
            timeBlocks.append(TimeBlock(
                startTime: GameTime(),
                duration: 480,
                activity: .explore,
                priority: 0.5,
                flexibility: 0.8
            ))
        }
        
        // Social time (5-8 PM)
        if !agent.relationships.isEmpty {
            timeBlocks.append(TimeBlock(
                startTime: GameTime(),
                duration: 180,
                activity: .socialize,
                priority: 0.6,
                flexibility: 0.6
            ))
        }
        
        // Personal time (8-10 PM)
        timeBlocks.append(TimeBlock(
            startTime: GameTime(),
            duration: 120,
            activity: .personal,
            priority: 0.7,
            flexibility: 0.7
        ))
        
        // Evening routine (10-11 PM)
        timeBlocks.append(TimeBlock(
            startTime: GameTime(),
            duration: 60,
            activity: .routine("evening"),
            priority: 0.8,
            flexibility: 0.3
        ))
        
        // Create plan
        let plan = DailyPlan(
            id: UUID(),
            agentId: agent.id,
            date: world.currentTime.day,
            timeBlocks: timeBlocks,
            goals: Array(activeGoals.prefix(3)),
            flexibility: agent.personality.openness
        )
        
        dailyPlan = plan
        return plan
    }
    
    // MARK: - Goal Management
    
    func generateGoals(for agent: Agent, basedOn insights: [Insight]) -> [Goal] {
        var goals: [Goal] = []
        
        // Generate goals from insights
        for insight in insights where insight.actionable {
            if let goal = createGoalFromInsight(insight, agent: agent) {
                goals.append(goal)
            }
        }
        
        // Add basic need-based goals
        goals.append(contentsOf: generateNeedGoals(agent))
        
        // Add relationship goals
        goals.append(contentsOf: generateRelationshipGoals(agent))
        
        // Add aspiration goals
        goals.append(contentsOf: generateAspirationGoals(agent))
        
        // Prioritize and limit
        goals.sort { $0.priority > $1.priority }
        return Array(goals.prefix(maxActiveGoals))
    }
    
    private func createGoalFromInsight(_ insight: Insight, agent: Agent) -> Goal? {
        switch insight.type {
        case .behavioral:
            return Goal(
                type: .personal,
                description: "Improve daily routine based on: \(insight.content)",
                priority: insight.impact
            )
            
        case .social:
            return Goal(
                type: .social,
                description: "Strengthen social connections: \(insight.content)",
                priority: insight.impact
            )
            
        case .emotional:
            return Goal(
                type: .personal,
                description: "Emotional wellbeing: \(insight.content)",
                priority: insight.impact * 1.2 // Emotional goals get priority boost
            )
            
        default:
            return nil
        }
    }
    
    // MARK: - Action Selection
    
    func selectNextAction(agent: Agent, world: LivingWorld) -> PlannedAction? {
        // Check current plan
        if let plan = dailyPlan,
           let currentBlock = getCurrentTimeBlock(plan, time: world.currentTime) {
            return createActionFromTimeBlock(currentBlock, agent: agent, world: world)
        }
        
        // Fallback to reactive planning
        return reactiveActionSelection(agent: agent, world: world)
    }
    
    private func createActionFromTimeBlock(_ block: TimeBlock, agent: Agent, world: LivingWorld) -> PlannedAction {
        switch block.activity {
        case .work:
            var action = PlannedAction(
                type: .work,
                target: agent.workplace ?? world.getLocation("Town Square"),
                duration: block.duration * 60,
                description: "Working on professional tasks"
            )
            action.importance = block.priority
            return action
            
        case .socialize:
            let friends = world.agents.filter { other in
                agent.relationships[other.id]?.closeness ?? 0 > 0.5
            }
            let target = friends.randomElement()
            
            var action = PlannedAction(
                type: .socialize,
                target: world.getLocation("Hobbs Cafe") ?? agent.position,
                targetAgent: target,
                duration: block.duration * 60,
                description: "Spending time with \(target?.name ?? "friends")"
            )
            action.importance = block.priority
            return action
            
        case .routine(let routineType):
            var action = PlannedAction(
                type: .rest,
                target: agent.home ?? agent.position,
                duration: block.duration * 60,
                description: "\(routineType) routine"
            )
            action.importance = block.priority
            return action
            
        case .personal:
            var action = PlannedAction(
                type: .reflect,
                target: agent.favoriteSpot ?? agent.home ?? agent.position,
                duration: block.duration * 60,
                description: "Personal time for reflection and hobbies"
            )
            action.importance = block.priority
            return action
            
        case .explore:
            var action = PlannedAction(
                type: .move,
                target: world.getRandomLocation(),
                duration: block.duration * 60,
                description: "Exploring the world"
            )
            action.importance = block.priority
            return action
        }
    }
    
    private func reactiveActionSelection(agent: Agent, world: LivingWorld) -> PlannedAction {
        // Assess immediate needs
        let needs = assessNeeds(agent)
        
        // Find highest priority need
        if let urgentNeed = needs.max(by: { $0.urgency < $1.urgency }) {
            return createActionForNeed(urgentNeed, agent: agent, world: world)
        }
        
        // Default: wander or rest
        var action = PlannedAction(
            type: .move,
            target: agent.position,
            duration: 30,
            description: "Wandering without specific purpose"
        )
        action.importance = 0.1
        return action
    }
    
    // MARK: - Plan Execution
    
    func executePlan(agent: Agent, world: LivingWorld) async {
        guard let action = selectNextAction(agent: agent, world: world) else { return }
        
        // Update agent state
        agent.currentAction = action
        
        // Move to location if needed
        if let targetLocation = action.target {
            if targetLocation.distance(to: agent.position) > 10 {
                await agent.moveTo(targetLocation, in: world)
            }
        }
        
        // Execute action
        switch action.type {
        case .socialize:
            if let target = action.targetAgent {
                await agent.interactWith(target, in: world)
            }
            
        case .work:
            agent.performWork()
            
        case .reflect:
            // Reflection is handled internally by the agent
            break
            
        default:
            break
        }
        
        // Update goal progress
        updateGoalProgress(action: action, agent: agent)
    }
    
    // MARK: - Goal Progress
    
    private func updateGoalProgress(action: PlannedAction, agent: Agent) {
        for i in 0..<activeGoals.count {
            var goal = activeGoals[i]
            
            // Check if action contributes to goal
            if actionContributesToGoal(action, goal: goal) {
                goal.progress = min(1.0, goal.progress + 0.1)
                
                // Check completion
                if goal.progress >= 1.0 {
                    completeGoal(goal, agent: agent)
                } else {
                    activeGoals[i] = goal
                }
            }
        }
    }
    
    private func actionContributesToGoal(_ action: PlannedAction, goal: Goal) -> Bool {
        switch (action.type, goal.type) {
        case (.socialize, .social):
            return true
        case (.work, .professional):
            return true
        case (.reflect, .personal):
            return true
        case (.rest, .survival):
            return true
        default:
            return false
        }
    }
    
    private func completeGoal(_ goal: Goal, agent: Agent) {
        completedGoals.append(goal)
        if let index = activeGoals.firstIndex(where: { $0.id == goal.id }) {
            activeGoals.remove(at: index)
        }
        
        // Generate new goal to replace it
        if let newGoal = generateReplacementGoal(for: goal, agent: agent) {
            activeGoals.append(newGoal)
        }
    }
    
    // MARK: - Helper Functions
    
    private func assessNeeds(_ agent: Agent) -> [Need] {
        var needs: [Need] = []
        
        // Social need
        if agent.lastInteractionTime == nil {
            needs.append(Need(
                type: .social,
                urgency: 0.7,
                description: "Need social interaction"
            ))
        } else {
            // Simplified social need check
            needs.append(Need(
                type: .social,
                urgency: 0.5,
                description: "Could use some social interaction"
            ))
        }
        
        // Rest need
        if agent.consciousness.state == .drowsy {
            needs.append(Need(
                type: .rest,
                urgency: 0.9,
                description: "Need rest"
            ))
        }
        
        // Activity need
        if agent.currentAction == nil {
            needs.append(Need(
                type: .activity,
                urgency: 0.5,
                description: "Need something to do"
            ))
        }
        
        return needs
    }
    
    private func identifyOpportunities(_ world: LivingWorld, agent: Agent) -> [Opportunity] {
        var opportunities: [Opportunity] = []
        
        // Social opportunities
        for other in world.agents where other.id != agent.id {
            if other.position.distance(to: agent.position) < 50 {
                opportunities.append(Opportunity(
                    type: .social,
                    description: "Can interact with \(other.name)",
                    value: agent.relationships[other.id]?.closeness ?? 0.5,
                    timeWindow: 60
                ))
            }
        }
        
        // Location opportunities
        if let cafe = world.getLocation("Hobbs Cafe"),
           cafe.distance(to: agent.position) < 100 {
            opportunities.append(Opportunity(
                type: .location,
                description: "Visit Hobbs Cafe",
                value: 0.6,
                timeWindow: 120
            ))
        }
        
        return opportunities
    }
    
    private func getObligations(_ agent: Agent) -> [Obligation] {
        var obligations: [Obligation] = []
        
        // Work obligation
        if agent.profession != nil {
            obligations.append(Obligation(
                description: "Work responsibilities",
                timeSlot: (9, 17),
                importance: 0.9
            ))
        }
        
        // Social obligations
        for relationship in agent.relationships.values {
            // Simplified check since lastInteraction might not exist
            let needsInteraction = true // Placeholder logic
            if needsInteraction {
                obligations.append(Obligation(
                    description: "Maintain relationship",
                    timeSlot: (0, 24),
                    importance: relationship.closeness
                ))
            }
        }
        
        return obligations
    }
    
    private func getCurrentTimeBlock(_ plan: DailyPlan, time: GameTime) -> TimeBlock? {
        return plan.timeBlocks.first { block in
            let blockEnd = block.startTime.totalMinutes + block.duration
            return time.totalMinutes >= block.startTime.totalMinutes &&
                   time.totalMinutes < blockEnd
        }
    }
    
    private func createActionForNeed(_ need: Need, agent: Agent, world: LivingWorld) -> PlannedAction {
        switch need.type {
        case .social:
            var action = PlannedAction(
                type: .socialize,
                target: world.getLocation("Town Square") ?? agent.position,
                duration: 60,
                description: "Seeking social interaction"
            )
            action.importance = need.urgency
            return action
            
        case .rest:
            var action = PlannedAction(
                type: .rest,
                target: agent.home ?? agent.position,
                duration: 120,
                description: "Resting"
            )
            action.importance = need.urgency
            return action
            
        case .activity:
            var action = PlannedAction(
                type: .move,
                target: agent.position,
                duration: 30,
                description: "Looking for something to do"
            )
            action.importance = need.urgency
            return action
            
        default:
            var action = PlannedAction(
                type: .rest,
                target: agent.position,
                duration: 15,
                description: "Waiting"
            )
            action.importance = 0.1
            return action
        }
    }
    
    private func generateNeedGoals(_ agent: Agent) -> [Goal] {
        return [
            Goal(
                type: .survival,
                description: "Maintain physical and mental wellbeing",
                priority: 0.8
            )
        ]
    }
    
    private func generateRelationshipGoals(_ agent: Agent) -> [Goal] {
        var goals: [Goal] = []
        
        if agent.relationships.isEmpty {
            goals.append(Goal(
                type: .social,
                description: "Make new friends",
                priority: 0.7
            ))
        } else {
            goals.append(Goal(
                type: .social,
                description: "Deepen existing friendships",
                priority: 0.6
            ))
        }
        
        return goals
    }
    
    private func generateAspirationGoals(_ agent: Agent) -> [Goal] {
        var goals: [Goal] = []
        
        // Based on personality
        if agent.personality.openness > 0.7 {
            goals.append(Goal(
                type: .personal,
                description: "Explore and discover new experiences",
                priority: 0.5
            ))
        }
        
        if agent.personality.conscientiousness > 0.7 {
            goals.append(Goal(
                type: .professional,
                description: "Achieve professional excellence",
                priority: 0.8
            ))
        }
        
        return goals
    }
    
    private func generateReplacementGoal(for completed: Goal, agent: Agent) -> Goal? {
        // Generate a new goal of similar type but evolved
        switch completed.type {
        case .social:
            return Goal(
                type: .social,
                description: "Build even stronger connections",
                priority: completed.priority * 0.9
            )
            
        case .professional:
            return Goal(
                type: .professional,
                description: "Reach new heights",
                priority: completed.priority * 1.1
            )
            
        default:
            return nil
        }
    }
    
    func update(with perceptions: [CorePerception], memory: MemoryStream) {
        // Update planning based on new perceptions
        // This could adjust goals, priorities, or plans
    }
}

// MARK: - Supporting Types

struct Plan {
    let id: UUID
    let goal: Goal
    let steps: [PlannedAction]
    let estimatedDuration: Int // minutes
    let flexibility: Float
}

struct DailyPlan {
    let id: UUID
    let agentId: UUID
    let date: Int
    let timeBlocks: [TimeBlock]
    let goals: [Goal]
    let flexibility: Float
    
    func getCurrentAction() -> Action? {
        // Find current time block and convert to action
        let currentHour = Calendar.current.component(.hour, from: Date())
        
        for block in timeBlocks {
            let blockHour = block.startTime.hour
            let blockEndHour = blockHour + block.duration / 60
            
            if currentHour >= blockHour && currentHour < blockEndHour {
                return Action(
                    type: mapActivityToActionType(block.activity),
                    description: "Scheduled: \(block.activity)"
                )
            }
        }
        
        return nil
    }
    
    func getNextAction() -> Action? {
        // Return the next scheduled action
        return getCurrentAction()
    }
    
    private func mapActivityToActionType(_ activity: TimeBlock.Activity) -> Action.ActionType {
        switch activity {
        case .work: return .work
        case .socialize: return .socialize
        case .routine: return .rest
        case .personal: return .reflect
        case .explore: return .move
        }
    }
}

struct TimeBlock {
    enum Activity {
        case work
        case socialize
        case routine(String)
        case personal
        case explore
    }
    
    let startTime: GameTime
    let duration: Int // minutes
    let activity: Activity
    let priority: Float
    let flexibility: Float
}

struct Need {
    enum NeedType {
        case social, rest, activity, food, safety
    }
    
    let type: NeedType
    let urgency: Float
    let description: String
}

struct Opportunity {
    enum OpportunityType {
        case social, location, activity
    }
    
    let type: OpportunityType
    let description: String
    let value: Float
    let timeWindow: Int // minutes
}

struct Obligation {
    let description: String
    let timeSlot: (start: Int, end: Int) // hours
    let importance: Float
}

struct GoalConditions {
    var requiredResources: [String] = []
    var requiredRelationships: [UUID] = []
    var requiredLocation: Position? = nil
}