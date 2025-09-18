//
//  SaveGameManager.swift
//  Her Lives
//
//  Save/Load game state management
//

import Foundation
import SwiftUI
import Combine

class SaveGameManager: ObservableObject {
    @Published var hasAutoSave = false
    @Published var lastSaveDate: Date?
    @Published var availableSaves: [SaveGame] = []
    
    private let saveDirectory: URL
    private let autoSaveInterval: TimeInterval = 300 // 5 minutes
    private var autoSaveTimer: Timer?
    
    struct SaveGame: Codable, Identifiable {
        let id = UUID()
        let name: String
        let date: Date
        let worldData: Data
        let thumbnailData: Data?
        
        var formattedDate: String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
    }
    
    init() {
        // Setup save directory in Documents
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            saveDirectory = documentsPath.appendingPathComponent("Saves")
            
            // Create saves directory if it doesn't exist
            try? FileManager.default.createDirectory(at: saveDirectory, withIntermediateDirectories: true)
        } else {
            saveDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
        }
        
        loadAvailableSaves()
    }
    
    // MARK: - Save Operations
    
    func save(_ world: LivingWorld, name: String? = nil) {
        let saveName = name ?? "Save \(Date().timeIntervalSince1970)"
        
        // Encode world data
        if let worldData = encodeWorld(world) {
            let save = SaveGame(
                name: saveName,
                date: Date(),
                worldData: worldData,
                thumbnailData: nil
            )
            
            // Save to file
            let saveFile = saveDirectory.appendingPathComponent("\(save.id.uuidString).save")
            
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(save)
                try data.write(to: saveFile)
                
                lastSaveDate = Date()
                loadAvailableSaves()
                
            } catch {
                print("Failed to save game: \(error)")
            }
        }
    }
    
    func autoSave(_ world: LivingWorld) {
        save(world, name: "Autosave")
        hasAutoSave = true
    }
    
    func quickSave(_ world: LivingWorld) {
        save(world, name: "Quicksave")
    }
    
    // MARK: - Load Operations
    
    func load(_ saveGame: SaveGame) -> LivingWorld? {
        return decodeWorld(from: saveGame.worldData)
    }
    
    func loadLatest() -> LivingWorld? {
        guard let latest = availableSaves.first else { return nil }
        return load(latest)
    }
    
    func loadAutoSave() -> LivingWorld? {
        guard let autoSave = availableSaves.first(where: { $0.name == "Autosave" }) else { return nil }
        return load(autoSave)
    }
    
    // MARK: - Management
    
    func delete(_ saveGame: SaveGame) {
        let saveFile = saveDirectory.appendingPathComponent("\(saveGame.id.uuidString).save")
        try? FileManager.default.removeItem(at: saveFile)
        loadAvailableSaves()
    }
    
    func deleteAll() {
        let saves = try? FileManager.default.contentsOfDirectory(at: saveDirectory, includingPropertiesForKeys: nil)
        saves?.forEach { url in
            try? FileManager.default.removeItem(at: url)
        }
        availableSaves = []
    }
    
    // MARK: - Private Methods
    
    private func loadAvailableSaves() {
        guard let saves = try? FileManager.default.contentsOfDirectory(at: saveDirectory, includingPropertiesForKeys: nil) else {
            availableSaves = []
            return
        }
        
        availableSaves = saves.compactMap { url -> SaveGame? in
            guard url.pathExtension == "save" else { return nil }
            
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                return try decoder.decode(SaveGame.self, from: data)
            } catch {
                print("Failed to load save: \(error)")
                return nil
            }
        }.sorted { $0.date > $1.date }
    }
    
    private func encodeWorld(_ world: LivingWorld) -> Data? {
        // Create a simplified save structure
        let saveData = WorldSaveData(
            agents: world.agents.map { AgentSaveData(from: $0) },
            time: Date(), // Convert GameTime to Date for save
            day: world.currentDay
            // World is always running - no pause state
        )
        
        do {
            let encoder = JSONEncoder()
            return try encoder.encode(saveData)
        } catch {
            print("Failed to encode world: \(error)")
            return nil
        }
    }
    
    private func decodeWorld(from data: Data) -> LivingWorld? {
        do {
            let decoder = JSONDecoder()
            let saveData = try decoder.decode(WorldSaveData.self, from: data)
            
            let world = LivingWorld()
            // Reconstruct world from save data
            world.agents = saveData.agents.map { $0.toAgent() }
            // Note: Cannot directly set GameTime from Date - would need conversion logic
            // Note: currentDay and isPaused are computed properties, cannot be set directly
            
            return world
        } catch {
            print("Failed to decode world: \(error)")
            return nil
        }
    }
    
    // MARK: - Auto Save Timer
    
    func startAutoSaveTimer(for world: LivingWorld) {
        autoSaveTimer?.invalidate()
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: autoSaveInterval, repeats: true) { _ in
            self.autoSave(world)
        }
    }
    
    func stopAutoSaveTimer() {
        autoSaveTimer?.invalidate()
        autoSaveTimer = nil
    }
}

// MARK: - Save Data Structures

struct WorldSaveData: Codable {
    let agents: [AgentSaveData]
    let time: Date
    let day: Int
    // World is always running - no pause state
}

struct AgentSaveData: Codable {
    let id: UUID
    let name: String
    let age: Int
    let position: Position
    let personality: PersonalityVector
    let memories: [Memory]
    let relationships: [RelationshipSaveData]
    let goals: [Goal]
    let profession: String?
    
    init(from agent: Agent) {
        self.id = agent.id
        self.name = agent.name
        self.age = agent.age
        self.position = agent.position
        self.personality = agent.personality
        self.memories = Array(agent.memoryStream.stream.suffix(100)) // Save last 100 memories
        self.relationships = agent.relationships.values.map { RelationshipSaveData(from: $0) }
        self.goals = agent.goals
        self.profession = agent.profession
    }
    
    func toAgent() -> Agent {
        let agent = Agent(id: UUID(), name: name, age: age, position: position)
        agent.personality = personality
        agent.goals = goals
        agent.profession = profession
        
        // Restore memories
        memories.forEach { memory in
            agent.memoryStream.addMemory(memory)
        }
        
        // Restore relationships
        relationships.forEach { rel in
            agent.relationships[rel.otherAgentId] = rel.toRelationship()
        }
        
        return agent
    }
}

struct RelationshipSaveData: Codable {
    let otherAgentId: UUID
    let closeness: Float
    let stage: String
    let dimensions: RelationshipDimensions
    let history: [InteractionMemory]
    
    init(from relationship: Relationship) {
        self.otherAgentId = relationship.otherAgentId
        self.closeness = relationship.closeness
        self.stage = relationship.stage
        self.dimensions = relationship.dimensions
        self.history = [] // Relationship history not available in current model
    }
    
    func toRelationship() -> Relationship {
        // Create a temporary agent for relationship creation
        let tempAgent1 = Agent(id: UUID(), name: "temp1", age: 25, position: Position(x: 0, y: 0))
        let tempAgent2 = Agent(id: otherAgentId, name: "temp2", age: 25, position: Position(x: 0, y: 0))
        let rel = Relationship(from: tempAgent1, to: tempAgent2)
        // Note: closeness is computed from dimensions, cannot be set directly
        rel.stage = stage
        rel.dimensions = dimensions
        // Note: history property not available in current Relationship model
        return rel
    }
}