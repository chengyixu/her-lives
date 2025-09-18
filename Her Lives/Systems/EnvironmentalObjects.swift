//
//  EnvironmentalObjects.swift
//  Her Lives
//
//  Interactive objects in the world that agents can use, inspired by:
//  - Breath of the Wild's physics interactions
//  - Minecraft's crafting and building
//  - Skyrim's object manipulation
//

import Foundation
import SwiftUI

// MARK: - Object Categories
enum ObjectCategory: String, Codable {
    case furniture      // Benches, chairs, tables
    case nature        // Trees, rocks, flowers
    case tools         // Hammers, shovels, paintbrushes
    case food          // Apples, bread, water
    case books         // Readable items
    case art           // Paintings, sculptures
    case containers    // Boxes, barrels, trash bins
    case decoration    // Fountains, statues
    case technology    // Computers, phones
    case musical       // Guitars, pianos
    case sports        // Balls, equipment
    case crafting      // Materials for creating
}

// MARK: - Object State
enum ObjectState: String, Codable {
    case pristine
    case used
    case damaged
    case broken
    case wet
    case burning
    case frozen
    case growing
    case decaying
}

// MARK: - Environmental Object
class EnvironmentalObject: Identifiable, ObservableObject {
    let id = UUID()
    @Published var name: String
    @Published var description: String
    @Published var category: ObjectCategory
    @Published var position: Position
    @Published var state: ObjectState = .pristine
    @Published var isPortable: Bool
    @Published var weight: Float // kg
    @Published var durability: Float = 1.0 // 0 = broken, 1 = perfect
    @Published var temperature: Float = 20.0 // Celsius
    @Published var ownership: UUID? // Who owns it
    @Published var lastUsedBy: UUID?
    @Published var lastUsedTime: Date?
    
    // Interaction properties
    var possibleActions: [ObjectAction] = []
    var requiredSkills: [String: Float] = [:] // Skill name: minimum level
    var providedResources: [String: Int] = [:] // Resource: quantity
    
    // Special properties
    var isContainer: Bool = false
    var containedItems: [String] = []
    var maxCapacity: Int = 0
    
    var isReadable: Bool = false
    var textContent: String?
    var author: String?
    
    var isEdible: Bool = false
    var nutritionValue: Float = 0
    var spoilRate: Float = 0
    
    var isCraftingStation: Bool = false
    var enabledRecipes: [CraftingRecipe] = []
    
    init(
        name: String,
        description: String,
        category: ObjectCategory,
        position: Position,
        isPortable: Bool = false,
        weight: Float = 1.0
    ) {
        self.name = name
        self.description = description
        self.category = category
        self.position = position
        self.isPortable = isPortable
        self.weight = weight
        
        setupPossibleActions()
    }
    
    private func setupPossibleActions() {
        switch category {
        case .furniture:
            possibleActions = [.sit, .move, .repair, .destroy]
        case .nature:
            possibleActions = [.observe, .harvest, .climb]
        case .tools:
            possibleActions = [.use, .repair, .carry]
        case .food:
            possibleActions = [.eat, .carry, .share, .cook]
            isEdible = true
        case .books:
            possibleActions = [.read, .carry, .write]
            isReadable = true
        case .art:
            possibleActions = [.observe, .create, .admire, .destroy]
        case .containers:
            possibleActions = [.open, .search, .store, .lock]
            isContainer = true
        case .decoration:
            possibleActions = [.observe, .interact, .maintain]
        case .technology:
            possibleActions = [.use, .repair, .hack]
        case .musical:
            possibleActions = [.play, .tune, .carry]
        case .sports:
            possibleActions = [.play, .throw, .kick, .carry]
        case .crafting:
            possibleActions = [.collect, .combine, .carry]
        }
    }
    
    func interact(agent: Agent, action: ObjectAction) -> InteractionResult {
        lastUsedBy = agent.id
        lastUsedTime = Date()
        
        // Check if agent has required skills
        for (skill, minLevel) in requiredSkills {
            if (agent.skills[skill] ?? 0) < minLevel {
                return InteractionResult(
                    success: false,
                    message: "\(agent.name) lacks the skill to \(action.rawValue) the \(name)",
                    effects: []
                )
            }
        }
        
        // Process action based on type
        switch action {
        case .sit:
            return InteractionResult(
                success: true,
                message: "\(agent.name) sits on the \(name)",
                effects: [.rest(amount: 0.1), .mood(change: 0.05)]
            )
            
        case .eat:
            if isEdible && durability > 0 {
                durability = 0 // Consumed
                return InteractionResult(
                    success: true,
                    message: "\(agent.name) eats the \(name)",
                    effects: [.hunger(reduction: nutritionValue), .health(change: 0.05)]
                )
            }
            
        case .read:
            if isReadable, let content = textContent {
                return InteractionResult(
                    success: true,
                    message: "\(agent.name) reads '\(content.prefix(50))...'",
                    effects: [.knowledge(topic: name), .mood(change: 0.1)]
                )
            }
            
        case .play:
            if category == .musical {
                return InteractionResult(
                    success: true,
                    message: "\(agent.name) plays the \(name)",
                    effects: [.skill(name: "music", gain: 0.01), .mood(change: 0.15)]
                )
            }
            
        case .search:
            if isContainer && !containedItems.isEmpty {
                let found = containedItems.randomElement() ?? "nothing"
                return InteractionResult(
                    success: true,
                    message: "\(agent.name) searches the \(name) and finds \(found)",
                    effects: [.item(name: found, quantity: 1)]
                )
            }
            
        case .harvest:
            if category == .nature {
                let harvested = providedResources.randomElement()
                return InteractionResult(
                    success: true,
                    message: "\(agent.name) harvests \(harvested?.key ?? "something") from the \(name)",
                    effects: [.item(name: harvested?.key ?? "material", quantity: harvested?.value ?? 1)]
                )
            }
            
        case .repair:
            if durability < 1.0 {
                durability = min(durability + 0.3, 1.0)
                return InteractionResult(
                    success: true,
                    message: "\(agent.name) repairs the \(name)",
                    effects: [.skill(name: "crafting", gain: 0.02)]
                )
            }
            
        case .destroy:
            state = .broken
            durability = 0
            return InteractionResult(
                success: true,
                message: "\(agent.name) destroys the \(name)!",
                effects: [.reputation(change: -0.1)]
            )
            
        default:
            return InteractionResult(
                success: true,
                message: "\(agent.name) interacts with the \(name)",
                effects: []
            )
        }
        
        return InteractionResult(
            success: false,
            message: "Cannot \(action.rawValue) the \(name)",
            effects: []
        )
    }
}

// MARK: - Object Actions
enum ObjectAction: String, Codable {
    case sit
    case lie
    case climb
    case read
    case write
    case eat
    case drink
    case carry
    case toss
    case kick
    case play
    case use
    case repair
    case destroy
    case open
    case close
    case lock
    case unlock
    case search
    case store
    case harvest
    case plant
    case water
    case burn
    case freeze
    case observe
    case admire
    case create
    case combine
    case share
    case steal
    case hide
    case reveal
    case move
    case interact
    case maintain
    case tune
    case hack
    case cook
    case collect
}

// MARK: - Interaction Result
struct InteractionResult {
    let success: Bool
    let message: String
    let effects: [InteractionEffect]
    var durabilityChange: Float = 0
    var stateChange: ObjectState?
}

enum InteractionEffect {
    case rest(amount: Float)
    case hunger(reduction: Float)
    case health(change: Float)
    case mood(change: Float)
    case skill(name: String, gain: Float)
    case knowledge(topic: String)
    case item(name: String, quantity: Int)
    case reputation(change: Float)
    case relationship(with: UUID, change: Float)
}

// MARK: - Crafting Recipe
struct CraftingRecipe {
    let name: String
    let requiredItems: [String: Int]
    let requiredSkill: Float
    let produces: String
    let quantity: Int
    let time: Int // minutes
}

// MARK: - Environmental Objects Manager
class EnvironmentalObjectsManager: ObservableObject {
    @Published var objects: [EnvironmentalObject] = []
    
    func spawnDefaultObjects() {
        // Town Square Objects
        objects.append(EnvironmentalObject(
            name: "Oak Tree Bench",
            description: "A weathered wooden bench under the old oak tree",
            category: .furniture,
            position: Position(x: 0, y: 10, z: 0),
            isPortable: false,
            weight: 50
        ))
        
        objects.append(EnvironmentalObject(
            name: "Town Fountain",
            description: "An ornate fountain with clear water",
            category: .decoration,
            position: Position(x: 0, y: 0, z: 0),
            isPortable: false,
            weight: 500
        ))
        
        // Park Objects
        objects.append(EnvironmentalObject(
            name: "Picnic Table",
            description: "A sturdy wooden picnic table",
            category: .furniture,
            position: Position(x: -150, y: -200, z: 0),
            isPortable: false,
            weight: 80
        ))
        
        let appleTree = EnvironmentalObject(
            name: "Apple Tree",
            description: "A mature apple tree bearing fruit",
            category: .nature,
            position: Position(x: -140, y: -190, z: 0),
            isPortable: false,
            weight: 300
        )
        appleTree.providedResources = ["apple": 5]
        objects.append(appleTree)
        
        // Library Objects
        var philosophyBook = EnvironmentalObject(
            name: "Philosophy of Mind",
            description: "A thick tome on consciousness",
            category: .books,
            position: Position(x: 200, y: 150, z: 0),
            isPortable: true,
            weight: 0.5
        )
        philosophyBook.textContent = "The nature of consciousness remains one of the deepest mysteries..."
        philosophyBook.author = "Dr. Elena Rodriguez"
        objects.append(philosophyBook)
        
        // Market Objects
        let fruitStand = EnvironmentalObject(
            name: "Fruit Stand",
            description: "A colorful display of fresh fruits",
            category: .containers,
            position: Position(x: 300, y: -100, z: 0),
            isPortable: false,
            weight: 100
        )
        fruitStand.containedItems = ["apple", "orange", "banana", "grapes"]
        fruitStand.maxCapacity = 20
        objects.append(fruitStand)
        
        // Cafe Objects
        objects.append(EnvironmentalObject(
            name: "Espresso Machine",
            description: "A professional espresso machine",
            category: .technology,
            position: Position(x: -200, y: 100, z: 0),
            isPortable: false,
            weight: 30
        ))
        
        // Musical Instruments
        let guitar = EnvironmentalObject(
            name: "Acoustic Guitar",
            description: "A well-worn six-string guitar",
            category: .musical,
            position: Position(x: 10, y: 5, z: 0),
            isPortable: true,
            weight: 2
        )
        guitar.requiredSkills = ["music": 0.1]
        objects.append(guitar)
        
        // Trash bins (for desperate scavenging)
        let trashBin = EnvironmentalObject(
            name: "Trash Bin",
            description: "A public waste container",
            category: .containers,
            position: Position(x: 50, y: 50, z: 0),
            isPortable: false,
            weight: 20
        )
        trashBin.containedItems = ["old newspaper", "empty bottle", "half-eaten sandwich"]
        objects.append(trashBin)
    }
    
    func getObjectsNear(position: Position, radius: Float) -> [EnvironmentalObject] {
        objects.filter { object in
            let dx = object.position.x - position.x
            let dy = object.position.y - position.y
            let distance = sqrt(dx * dx + dy * dy)
            return distance <= radius
        }
    }
    
    func findObjectByName(_ name: String) -> EnvironmentalObject? {
        objects.first { $0.name.lowercased().contains(name.lowercased()) }
    }
    
    func updateObjectStates() {
        for object in objects {
            // Decay food items
            if object.isEdible && object.spoilRate > 0 {
                object.durability -= object.spoilRate * 0.001
                if object.durability <= 0 {
                    object.state = .decaying
                }
            }
            
            // Weather effects
            if object.position.z == 0 { // Outdoor objects
                // Could apply weather effects here
            }
            
            // Repair over time for some objects
            if object.state == .damaged && object.durability < 1.0 {
                object.durability += 0.0001 // Very slow auto-repair
            }
        }
    }
}