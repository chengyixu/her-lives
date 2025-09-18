//
//  PhysicalSpace.swift
//  Her Lives
//
//  Manages the game world's physical locations and spatial relationships
//

import Foundation
import SwiftUI
import Combine

class PhysicalSpace: ObservableObject {
    // MARK: - Published Properties
    @Published var locations: [Location] = []
    @Published var worldBounds: WorldBounds = WorldBounds(width: 1000, height: 1000)
    @Published var pathfindingGrid: PathfindingGrid = PathfindingGrid()
    @Published var spatialEvents: [SpatialEvent] = []
    @Published var weatherSystem: WeatherSystem = WeatherSystem()
    
    // MARK: - Internal State
    private var spatialIndex: SpatialIndex = SpatialIndex()
    private var movementHistory: [MovementRecord] = []
    private var timeOfDay: TimeOfDay = TimeOfDay()
    
    // Spatial constants
    private let gridResolution: Float = 10.0
    private let maxInteractionDistance: Float = 50.0
    private let locationSpacing: Float = 100.0
    
    // MARK: - Initialization
    
    init() {
        generateInitialLocations()
        initializePathfinding()
        spatialIndex.initialize(bounds: worldBounds)
    }
    
    private func generateInitialLocations() {
        let baseLocations = [
            ("Town Square", LocationType.social, Position(x: 500, y: 500), 100, "Heart of community"),
            ("Park", LocationType.recreational, Position(x: 300, y: 300), 80, "Peaceful green space"),
            ("Market", LocationType.commercial, Position(x: 700, y: 400), 60, "Trading hub"),
            ("Library", LocationType.educational, Position(x: 200, y: 600), 40, "Repository of knowledge"),
            ("Workshop", LocationType.creative, Position(x: 800, y: 200), 50, "Place for crafts"),
            ("Gardens", LocationType.natural, Position(x: 150, y: 150), 90, "Growing things"),
            ("Cafe", LocationType.social, Position(x: 600, y: 600), 30, "Cozy meeting place"),
            ("Theater", LocationType.cultural, Position(x: 400, y: 700), 70, "Performances and art")
        ]
        
        for (name, type, position, capacity, description) in baseLocations {
            let location = Location(
                id: UUID(),
                name: name,
                type: type,
                position: position,
                capacity: capacity,
                description: description
            )
            locations.append(location)
            spatialIndex.add(location)
        }
    }
    
    private func initializePathfinding() {
        pathfindingGrid = PathfindingGrid(
            width: Int(worldBounds.width / gridResolution),
            height: Int(worldBounds.height / gridResolution),
            cellSize: gridResolution
        )
        
        // Mark obstacles and walkable areas
        updatePathfindingObstacles()
    }
    
    // MARK: - Position and Movement
    
    func randomPosition() -> Position {
        Position(
            x: Float.random(in: 0...worldBounds.width),
            y: Float.random(in: 0...worldBounds.height)
        )
    }
    
    func getValidPosition(near target: Position, radius: Float = 50) -> Position {
        var attempts = 0
        let maxAttempts = 10
        
        while attempts < maxAttempts {
            let angle = Float.random(in: 0...(2 * .pi))
            let distance = Float.random(in: 10...radius)
            
            let newPosition = Position(
                x: target.x + cos(angle) * distance,
                y: target.y + sin(angle) * distance
            )
            
            if isValidPosition(newPosition) {
                return newPosition
            }
            
            attempts += 1
        }
        
        return clampToBounds(target)
    }
    
    func isValidPosition(_ position: Position) -> Bool {
        // Check world bounds
        guard position.x >= 0 && position.x <= worldBounds.width &&
              position.y >= 0 && position.y <= worldBounds.height else {
            return false
        }
        
        // Check for obstacles
        return !pathfindingGrid.isObstacle(at: position)
    }
    
    func clampToBounds(_ position: Position) -> Position {
        Position(
            x: max(0, min(worldBounds.width, position.x)),
            y: max(0, min(worldBounds.height, position.y))
        )
    }
    
    // MARK: - Spatial Queries
    
    func getAgentsNear(_ agent: Agent, radius: Float, from agents: [Agent]) -> [Agent] {
        return agents.filter { other in
            other.id != agent.id &&
            agent.position.distance(to: other.position) <= radius
        }
    }
    
    func getLocationAt(_ position: Position) -> Location? {
        return locations.first { location in
            position.distance(to: location.position) <= Float(location.radius)
        }
    }
    
    func getLocationsNear(_ position: Position, radius: Float = 100) -> [Location] {
        return locations.filter { location in
            position.distance(to: location.position) <= radius
        }
    }
    
    func getLocationsByType(_ type: LocationType) -> [Location] {
        return locations.filter { $0.type == type }
    }
    
    func getEnvironmentAt(_ position: Position) -> PhysicalEnvironment {
        let nearbyLocations = getLocationsNear(position, radius: 50)
        let dominantLocation = nearbyLocations.max { loc1, loc2 in
            position.distance(to: loc1.position) > position.distance(to: loc2.position)
        }
        
        return PhysicalEnvironment(
            location: dominantLocation,
            weather: weatherSystem.currentWeather,
            timeOfDay: timeOfDay.current,
            ambience: calculateAmbience(at: position),
            description: generateEnvironmentDescription(at: position, location: dominantLocation)
        )
    }
    
    private func calculateAmbience(at position: Position) -> Ambience {
        let nearbyLocations = getLocationsNear(position, radius: 100)
        var socialLevel: Float = 0
        var naturalLevel: Float = 0
        var culturalLevel: Float = 0
        var commercialLevel: Float = 0
        
        for location in nearbyLocations {
            let distance = position.distance(to: location.position)
            let influence = max(0, 1 - (distance / 100))
            
            switch location.type {
            case .social:
                socialLevel += influence * Float(location.currentOccupancy) / Float(location.capacity)
            case .natural:
                naturalLevel += influence
            case .cultural:
                culturalLevel += influence
            case .commercial:
                commercialLevel += influence
            default:
                break
            }
        }
        
        return Ambience(
            socialLevel: min(1.0, socialLevel),
            naturalLevel: min(1.0, naturalLevel),
            culturalLevel: min(1.0, culturalLevel),
            commercialLevel: min(1.0, commercialLevel),
            noiseLevel: calculateNoiseLevel(at: position)
        )
    }
    
    private func calculateNoiseLevel(at position: Position) -> Float {
        let nearbyAgents = spatialIndex.getEntitiesNear(position, radius: maxInteractionDistance)
        return min(1.0, Float(nearbyAgents.count) / 10.0)
    }
    
    private func generateEnvironmentDescription(at position: Position, location: Location?) -> String {
        if let location = location {
            let occupancy = location.currentOccupancy
            let capacity = location.capacity
            
            if occupancy == 0 {
                return "The \(location.name.lowercased()) is quiet and empty"
            } else if occupancy < capacity / 3 {
                return "The \(location.name.lowercased()) has a few people around"
            } else if occupancy < capacity * 2 / 3 {
                return "The \(location.name.lowercased()) is moderately busy"
            } else {
                return "The \(location.name.lowercased()) is bustling with activity"
            }
        } else {
            let weather = weatherSystem.currentWeather
            return "An open area under \(weather.description.lowercased()) skies"
        }
    }
    
    // MARK: - Pathfinding
    
    func findPath(from start: Position, to end: Position) -> [Position]? {
        return pathfindingGrid.findPath(from: start, to: end)
    }
    
    func getNextMoveToward(_ from: Position, _ to: Position, speed: Float = 5.0) -> Position {
        let direction = Vector2D(from: from, to: to).normalized()
        let movement = direction.scaled(by: speed)
        
        let newPosition = Position(
            x: from.x + movement.x,
            y: from.y + movement.y
        )
        
        return clampToBounds(newPosition)
    }
    
    private func updatePathfindingObstacles() {
        pathfindingGrid.clearObstacles()
        
        // Mark location boundaries as obstacles or walkable
        for location in locations {
            let gridPos = pathfindingGrid.worldToGrid(location.position)
            let radius = Int(Float(location.radius) / gridResolution)
            
            // Most locations are walkable, but some might have obstacles
            if location.type == .natural && location.name.lowercased().contains("water") {
                pathfindingGrid.markCircleAsObstacle(center: gridPos, radius: radius)
            }
        }
    }
    
    // MARK: - Location Management
    
    func addLocation(_ location: Location) {
        locations.append(location)
        spatialIndex.add(location)
        updatePathfindingObstacles()
    }
    
    func removeLocation(_ locationId: UUID) {
        locations.removeAll { $0.id == locationId }
        spatialIndex.remove(locationId)
        updatePathfindingObstacles()
    }
    
    func updateLocationOccupancy(_ locationId: UUID, change: Int) {
        if let index = locations.firstIndex(where: { $0.id == locationId }) {
            locations[index].currentOccupancy = max(0, min(
                locations[index].capacity,
                locations[index].currentOccupancy + change
            ))
        }
    }
    
    // MARK: - Distance Calculation
    
    func distance(from: Position, to: Position) -> Float {
        return from.distance(to: to)
    }
    
    func getPopularLocations(limit: Int = 5) -> [Location] {
        return locations
            .filter { $0.currentOccupancy > 0 }
            .sorted { loc1, loc2 in
                let occupancy1 = Float(loc1.currentOccupancy) / Float(loc1.capacity)
                let occupancy2 = Float(loc2.currentOccupancy) / Float(loc2.capacity)
                return occupancy1 > occupancy2
            }
            .prefix(limit)
            .map { $0 }
    }
    
    // MARK: - Spatial Events
    
    func recordMovement(_ agent: Agent, from: Position, to: Position, timestamp: Date) {
        let record = MovementRecord(
            agentId: agent.id,
            fromPosition: from,
            toPosition: to,
            timestamp: timestamp,
            distance: from.distance(to: to)
        )
        
        movementHistory.append(record)
        spatialIndex.updatePosition(agent.id, newPosition: to)
        
        // Check for spatial events
        checkForSpatialEvents(agent: agent, newPosition: to)
        
        // Clean up old movement history
        if movementHistory.count > 1000 {
            movementHistory.removeFirst()
        }
    }
    
    private func checkForSpatialEvents(agent: Agent, newPosition: Position) {
        // Check for location entries/exits
        let currentLocation = getLocationAt(newPosition)
        let previousLocation = getLocationAt(agent.position)
        
        if currentLocation != previousLocation {
            if let prev = previousLocation {
                // Exited location
                updateLocationOccupancy(prev.id, change: -1)
                recordSpatialEvent(.locationExit, agent: agent, location: prev)
            }
            
            if let current = currentLocation {
                // Entered location
                updateLocationOccupancy(current.id, change: 1)
                recordSpatialEvent(.locationEntry, agent: agent, location: current)
            }
        }
        
        // Check for agent encounters
        let nearbyAgents = getAgentsNear(agent, radius: maxInteractionDistance, from: [])
        for other in nearbyAgents {
            let wasNearby = agent.position.distance(to: other.position) <= maxInteractionDistance
            let isNearby = newPosition.distance(to: other.position) <= maxInteractionDistance
            
            if !wasNearby && isNearby {
                recordSpatialEvent(.agentEncounter, agent: agent, otherAgent: other)
            }
        }
    }
    
    private func recordSpatialEvent(_ type: SpatialEventType, agent: Agent, location: Location? = nil, otherAgent: Agent? = nil) {
        let event = SpatialEvent(
            type: type,
            agentId: agent.id,
            position: agent.position,
            locationId: location?.id,
            otherAgentId: otherAgent?.id,
            timestamp: Date(),
            description: generateSpatialEventDescription(type, agent: agent, location: location, otherAgent: otherAgent)
        )
        
        spatialEvents.append(event)
        
        // Keep only recent events
        if spatialEvents.count > 500 {
            spatialEvents.removeFirst()
        }
    }
    
    private func generateSpatialEventDescription(_ type: SpatialEventType, agent: Agent, location: Location?, otherAgent: Agent?) -> String {
        switch type {
        case .locationEntry:
            return "\(agent.name) entered \(location?.name ?? "unknown location")"
        case .locationExit:
            return "\(agent.name) left \(location?.name ?? "unknown location")"
        case .agentEncounter:
            return "\(agent.name) encountered \(otherAgent?.name ?? "someone")"
        case .pathBlocked:
            return "\(agent.name)'s path was blocked"
        case .territoryEstablished:
            return "\(agent.name) established territory at \(location?.name ?? "a location")"
        }
    }
    
    // MARK: - World Updates
    
    func update(time: GameTime) {
        // Update time of day
        timeOfDay.update(gameTime: time)
        
        // Update weather system
        weatherSystem.update(time: time)
        
        // Update spatial index (remove stale entries)
        spatialIndex.cleanup()
        
        // Process any scheduled spatial changes
        processScheduledChanges(time: time)
    }
    
    private func processScheduledChanges(time: GameTime) {
        // Handle any scheduled location changes, weather events, etc.
        // This could include seasonal changes, construction, etc.
    }
    
    // MARK: - Analysis
    
    func getMovementPatterns(for agentId: UUID) -> MovementPattern {
        let agentMovements = movementHistory.filter { $0.agentId == agentId }
        
        let totalDistance = agentMovements.reduce(0) { $0 + $1.distance }
        let averageSpeed = totalDistance / Float(max(1, agentMovements.count))
        
        // Find most visited locations
        var locationVisits: [UUID: Int] = [:]
        for movement in agentMovements {
            if let location = getLocationAt(movement.toPosition) {
                locationVisits[location.id, default: 0] += 1
            }
        }
        
        let favoriteLocation = locationVisits.max { $0.value < $1.value }?.key
        
        return MovementPattern(
            totalDistance: totalDistance,
            averageSpeed: averageSpeed,
            favoriteLocationId: favoriteLocation,
            movementCount: agentMovements.count
        )
    }
    
    func getSpatialStatistics() -> SpatialStatistics {
        let totalOccupancy = locations.reduce(0) { $0 + $1.currentOccupancy }
        let totalCapacity = locations.reduce(0) { $0 + $1.capacity }
        
        let utilizationRate = totalCapacity > 0 ? Float(totalOccupancy) / Float(totalCapacity) : 0
        
        let locationTypes = Set(locations.map { $0.type })
        let diversity = Float(locationTypes.count) / Float(LocationType.allCases.count)
        
        return SpatialStatistics(
            totalLocations: locations.count,
            totalOccupancy: totalOccupancy,
            utilizationRate: utilizationRate,
            locationDiversity: diversity,
            recentMovements: movementHistory.suffix(100).count
        )
    }
}

// MARK: - Supporting Types

struct Location: Identifiable, Equatable {
    let id: UUID
    let name: String
    let type: LocationType
    let position: Position
    let capacity: Int
    let radius: Float
    let description: String
    var currentOccupancy: Int = 0
    var amenities: [String] = []
    var mood: Float = 0.0 // Environmental mood influence
    
    init(id: UUID, name: String, type: LocationType, position: Position, capacity: Int, description: String) {
        self.id = id
        self.name = name
        self.type = type
        self.position = position
        self.capacity = capacity
        self.radius = Float(capacity) / 2.0 + 10.0 // Rough size calculation
        self.description = description
        self.mood = type.defaultMood
    }
    
    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }
    
    var occupancyRate: Float {
        capacity > 0 ? Float(currentOccupancy) / Float(capacity) : 0
    }
    
    var statusDescription: String {
        if currentOccupancy == 0 {
            return "Empty"
        } else if occupancyRate < 0.3 {
            return "Quiet"
        } else if occupancyRate < 0.7 {
            return "Moderate"
        } else if occupancyRate < 1.0 {
            return "Busy"
        } else {
            return "Full"
        }
    }
}

enum LocationType: String, CaseIterable {
    case social = "Social"
    case recreational = "Recreational"
    case commercial = "Commercial"
    case educational = "Educational"
    case creative = "Creative"
    case natural = "Natural"
    case cultural = "Cultural"
    case residential = "Residential"
    case professional = "Professional"
    
    var defaultMood: Float {
        switch self {
        case .social: return 0.3
        case .recreational: return 0.5
        case .commercial: return 0.1
        case .educational: return 0.2
        case .creative: return 0.4
        case .natural: return 0.6
        case .cultural: return 0.3
        case .residential: return 0.4
        case .professional: return 0.0
        }
    }
    
    var icon: String {
        switch self {
        case .social: return "person.3"
        case .recreational: return "leaf"
        case .commercial: return "cart"
        case .educational: return "book"
        case .creative: return "paintbrush"
        case .natural: return "tree"
        case .cultural: return "theatermasks"
        case .residential: return "house"
        case .professional: return "building"
        }
    }
}

struct PhysicalEnvironment {
    let location: Location?
    let weather: Weather
    let timeOfDay: TimeOfDayPhase
    let ambience: Ambience
    let description: String
    
    var mood: Float {
        var mood: Float = 0
        
        // Location influence
        if let location = location {
            mood += location.mood * 0.4
        }
        
        // Weather influence
        mood += weather.moodModifier * 0.3
        
        // Time influence
        mood += timeOfDay.moodModifier * 0.2
        
        // Ambience influence
        mood += ambience.overallMood * 0.1
        
        return max(-1, min(1, mood))
    }
}

struct Ambience {
    let socialLevel: Float
    let naturalLevel: Float
    let culturalLevel: Float
    let commercialLevel: Float
    let noiseLevel: Float
    
    var overallMood: Float {
        return (socialLevel * 0.2 + naturalLevel * 0.4 + culturalLevel * 0.3 + commercialLevel * 0.1 - noiseLevel * 0.2)
    }
    
    var description: String {
        if naturalLevel > 0.7 {
            return "Peaceful and natural"
        } else if socialLevel > 0.7 {
            return "Socially vibrant"
        } else if commercialLevel > 0.7 {
            return "Bustling commercial area"
        } else if culturalLevel > 0.7 {
            return "Rich cultural atmosphere"
        } else if noiseLevel > 0.7 {
            return "Noisy and chaotic"
        } else {
            return "Calm and ordinary"
        }
    }
}

struct WeatherSystem {
    var currentWeather: Weather = Weather.clear
    private var lastUpdate: Date = Date()
    
    mutating func update(time: GameTime) {
        // Simple weather changes
        if Date().timeIntervalSince(lastUpdate) > 3600 { // Change every hour
            let weatherTypes: [Weather] = [.clear, .cloudy, .rainy, .sunny, .windy]
            currentWeather = weatherTypes.randomElement() ?? .clear
            lastUpdate = Date()
        }
    }
}

enum Weather {
    case clear, cloudy, rainy, sunny, windy, stormy
    
    var description: String {
        switch self {
        case .clear: return "Clear"
        case .cloudy: return "Cloudy"
        case .rainy: return "Rainy"
        case .sunny: return "Sunny"
        case .windy: return "Windy"
        case .stormy: return "Stormy"
        }
    }
    
    var moodModifier: Float {
        switch self {
        case .sunny: return 0.4
        case .clear: return 0.2
        case .cloudy: return -0.1
        case .windy: return 0.0
        case .rainy: return -0.3
        case .stormy: return -0.5
        }
    }
}

struct TimeOfDay {
    var current: TimeOfDayPhase = .morning
    
    mutating func update(gameTime: GameTime) {
        switch gameTime.hour {
        case 6..<12: current = .morning
        case 12..<18: current = .afternoon
        case 18..<22: current = .evening
        default: current = .night
        }
    }
}

enum TimeOfDayPhase {
    case morning, afternoon, evening, night
    
    var moodModifier: Float {
        switch self {
        case .morning: return 0.2
        case .afternoon: return 0.1
        case .evening: return 0.3
        case .night: return -0.1
        }
    }
}

struct WorldBounds {
    let width: Float
    let height: Float
}

struct Vector2D {
    let x: Float
    let y: Float
    
    init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }
    
    init(from: Position, to: Position) {
        self.x = to.x - from.x
        self.y = to.y - from.y
    }
    
    var magnitude: Float {
        sqrt(x * x + y * y)
    }
    
    func normalized() -> Vector2D {
        let mag = magnitude
        return mag > 0 ? Vector2D(x: x / mag, y: y / mag) : Vector2D(x: 0, y: 0)
    }
    
    func scaled(by factor: Float) -> Vector2D {
        Vector2D(x: x * factor, y: y * factor)
    }
}

struct SpatialEvent: Identifiable {
    let id = UUID()
    let type: SpatialEventType
    let agentId: UUID
    let position: Position
    let locationId: UUID?
    let otherAgentId: UUID?
    let timestamp: Date
    let description: String
}

enum SpatialEventType {
    case locationEntry, locationExit, agentEncounter, pathBlocked, territoryEstablished
}

struct MovementRecord {
    let agentId: UUID
    let fromPosition: Position
    let toPosition: Position
    let timestamp: Date
    let distance: Float
}

struct MovementPattern {
    let totalDistance: Float
    let averageSpeed: Float
    let favoriteLocationId: UUID?
    let movementCount: Int
}

struct SpatialStatistics {
    let totalLocations: Int
    let totalOccupancy: Int
    let utilizationRate: Float
    let locationDiversity: Float
    let recentMovements: Int
}

// MARK: - Supporting Classes

class SpatialIndex {
    private var entities: [UUID: Position] = [:]
    private var bounds: WorldBounds = WorldBounds(width: 1000, height: 1000)
    
    func initialize(bounds: WorldBounds) {
        self.bounds = bounds
    }
    
    func add(_ location: Location) {
        entities[location.id] = location.position
    }
    
    func remove(_ entityId: UUID) {
        entities.removeValue(forKey: entityId)
    }
    
    func updatePosition(_ entityId: UUID, newPosition: Position) {
        entities[entityId] = newPosition
    }
    
    func getEntitiesNear(_ position: Position, radius: Float) -> [UUID] {
        return entities.compactMap { entityId, entityPosition in
            position.distance(to: entityPosition) <= radius ? entityId : nil
        }
    }
    
    func cleanup() {
        // Remove stale entries if needed
    }
}

class PathfindingGrid {
    private var grid: [[Bool]] = []
    private let width: Int
    private let height: Int
    private let cellSize: Float
    
    init(width: Int = 100, height: Int = 100, cellSize: Float = 10.0) {
        self.width = width
        self.height = height
        self.cellSize = cellSize
        
        // Initialize grid - true = walkable, false = obstacle
        grid = Array(repeating: Array(repeating: true, count: width), count: height)
    }
    
    func findPath(from start: Position, to end: Position) -> [Position]? {
        // Simple pathfinding - return direct path for now
        let steps = 10
        var path: [Position] = []
        
        for i in 0...steps {
            let t = Float(i) / Float(steps)
            let x = start.x + (end.x - start.x) * t
            let y = start.y + (end.y - start.y) * t
            path.append(Position(x: x, y: y))
        }
        
        return path
    }
    
    func isObstacle(at position: Position) -> Bool {
        let gridPos = worldToGrid(position)
        return !isValidGridPosition(gridPos) || !grid[gridPos.y][gridPos.x]
    }
    
    func worldToGrid(_ position: Position) -> GridPosition {
        GridPosition(
            x: Int(position.x / cellSize),
            y: Int(position.y / cellSize)
        )
    }
    
    private func isValidGridPosition(_ pos: GridPosition) -> Bool {
        pos.x >= 0 && pos.x < width && pos.y >= 0 && pos.y < height
    }
    
    func clearObstacles() {
        for y in 0..<height {
            for x in 0..<width {
                grid[y][x] = true
            }
        }
    }
    
    func markCircleAsObstacle(center: GridPosition, radius: Int) {
        for y in max(0, center.y - radius)...min(height - 1, center.y + radius) {
            for x in max(0, center.x - radius)...min(width - 1, center.x + radius) {
                let dx = x - center.x
                let dy = y - center.y
                if dx * dx + dy * dy <= radius * radius {
                    grid[y][x] = false
                }
            }
        }
    }
}

struct GridPosition {
    let x: Int
    let y: Int
}

// MARK: - Position Extensions

extension Position {
    func distance(to other: Position) -> Float {
        let dx = x - other.x
        let dy = y - other.y
        return sqrt(dx * dx + dy * dy)
    }
}