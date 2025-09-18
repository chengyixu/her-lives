//
//  EconomicSystem.swift
//  Her Lives
//
//  Handles economic transactions, resources, and agent professions
//

import Foundation
import SwiftUI
import Combine

class EconomicSystem: ObservableObject {
    // MARK: - Published Properties
    @Published var recentTransactions: [Transaction] = []
    @Published var marketPrices: [String: Float] = [:]
    @Published var professions: [Profession] = []
    @Published var economicMetrics: EconomicMetrics = EconomicMetrics()
    @Published var marketTrends: [MarketTrend] = []
    @Published var totalWealth: Float = 0.0
    
    // MARK: - Internal State
    private var transactionHistory: [Transaction] = []
    private var resourceSupply: [String: Float] = [:]
    private var resourceDemand: [String: Float] = [:]
    private let baseResources = ["food", "materials", "knowledge", "art", "services"]
    
    // Economic constants
    private let inflationRate: Float = 0.001
    private let priceVolatility: Float = 0.05
    private let supplyDemandSensitivity: Float = 0.1
    
    // Computed Properties
    var economicActivity: Float {
        let recentActivity = Float(recentTransactions.count)
        return min(1.0, recentActivity / 10.0)
    }
    
    var wealthDistribution: WealthDistribution {
        calculateWealthDistribution()
    }
    
    var averageWealth: Float {
        totalWealth / Float(max(1, getAllAgents().count))
    }
    
    // MARK: - Initialization
    
    init() {
        initializeMarket()
        createBaseProfessions()
    }
    
    private func initializeMarket() {
        // Initialize base resource prices
        for resource in baseResources {
            marketPrices[resource] = Float.random(in: 0.8...1.2)
            resourceSupply[resource] = Float.random(in: 50...100)
            resourceDemand[resource] = Float.random(in: 40...80)
        }
    }
    
    private func createBaseProfessions() {
        let baseProfessions = [
            Profession(name: "Farmer", specialty: "food", baseIncome: 1.0, skillRequirements: ["farming": 0.3]),
            Profession(name: "Artisan", specialty: "art", baseIncome: 1.2, skillRequirements: ["creativity": 0.5]),
            Profession(name: "Teacher", specialty: "knowledge", baseIncome: 1.1, skillRequirements: ["teaching": 0.4]),
            Profession(name: "Builder", specialty: "materials", baseIncome: 1.3, skillRequirements: ["construction": 0.4]),
            Profession(name: "Healer", specialty: "services", baseIncome: 1.4, skillRequirements: ["medicine": 0.5]),
            Profession(name: "Merchant", specialty: "services", baseIncome: 1.5, skillRequirements: ["trading": 0.4])
        ]
        
        professions = baseProfessions
    }
    
    // MARK: - Transaction Processing
    
    func processTransactions() {
        // Process pending transactions
        processPendingTransactions()
        
        // Update market prices
        updateMarketPrices()
        
        // Generate profession income
        generateProfessionIncome()
        
        // Update economic metrics
        updateEconomicMetrics()
        
        // Detect economic trends
        detectMarketTrends()
        
        // Clean up old transactions
        cleanupOldTransactions()
    }
    
    private func processPendingTransactions() {
        // This would be called with actual pending transactions from agents
        // For now, we simulate some basic economic activity
        simulateBasicEconomicActivity()
    }
    
    private func simulateBasicEconomicActivity() {
        // Generate some random transactions for economic activity
        if Float.random(in: 0...1) < 0.3 {
            let resource = baseResources.randomElement() ?? "food"
            let amount = Float.random(in: 1...10)
            let price = marketPrices[resource] ?? 1.0
            
            let transaction = Transaction(
                id: UUID(),
                buyerId: UUID(), // Would be actual agent IDs
                sellerId: UUID(),
                resource: resource,
                amount: amount,
                price: price,
                timestamp: Date()
            )
            
            executeTransaction(transaction)
        }
    }
    
    func executeTransaction(_ transaction: Transaction) -> Bool {
        // Validate transaction
        guard transaction.amount > 0 && transaction.price > 0 else { return false }
        
        // Execute transaction
        recentTransactions.append(transaction)
        transactionHistory.append(transaction)
        
        // Update supply and demand
        updateSupplyDemand(for: transaction)
        
        // Record economic activity
        recordEconomicActivity(transaction)
        
        return true
    }
    
    private func updateSupplyDemand(for transaction: Transaction) {
        // Decrease supply when sold
        resourceSupply[transaction.resource, default: 50] -= transaction.amount * 0.1
        
        // Increase demand pressure
        resourceDemand[transaction.resource, default: 50] += transaction.amount * 0.05
        
        // Clamp values
        resourceSupply[transaction.resource] = max(0, resourceSupply[transaction.resource] ?? 0)
        resourceDemand[transaction.resource] = max(0, resourceDemand[transaction.resource] ?? 0)
    }
    
    // MARK: - Market Price Updates
    
    private func updateMarketPrices() {
        for resource in baseResources {
            let supply = resourceSupply[resource] ?? 50
            let demand = resourceDemand[resource] ?? 50
            let currentPrice = marketPrices[resource] ?? 1.0
            
            // Supply and demand price adjustment
            let supplyDemandRatio = demand / max(supply, 1)
            let priceAdjustment = (supplyDemandRatio - 1) * supplyDemandSensitivity
            
            // Add some volatility
            let volatility = Float.random(in: -priceVolatility...priceVolatility)
            
            // Apply inflation
            let newPrice = currentPrice * (1 + priceAdjustment + volatility + inflationRate)
            
            marketPrices[resource] = max(0.1, min(10.0, newPrice))
            
            // Gradually restore supply
            resourceSupply[resource] = (supply + Float.random(in: 1...5)) * 0.99
            
            // Reduce demand over time
            resourceDemand[resource] = (demand * 0.95) + Float.random(in: 0...2)
        }
    }
    
    // MARK: - Profession System
    
    func assignProfession(to agent: Agent) -> Profession? {
        // Find best profession match based on skills and personality
        var bestMatch: Profession?
        var bestScore: Float = 0
        
        for profession in professions {
            let score = calculateProfessionFit(agent: agent, profession: profession)
            if score > bestScore {
                bestScore = score
                bestMatch = profession
            }
        }
        
        if let profession = bestMatch, bestScore > 0.3 {
            agent.profession = profession.name
            return profession
        }
        
        return nil
    }
    
    private func calculateProfessionFit(agent: Agent, profession: Profession) -> Float {
        var fit: Float = 0.5 // Base fit
        
        // Check skill requirements
        for (skill, requirement) in profession.skillRequirements {
            let agentSkill = agent.skills[skill] ?? 0.0
            if agentSkill >= requirement {
                fit += 0.3
            } else {
                fit += agentSkill / requirement * 0.3
            }
        }
        
        // Personality match
        switch profession.name {
        case "Artisan":
            fit += agent.personality.creativity * 0.3
        case "Teacher":
            fit += agent.personality.agreeableness * 0.2 + agent.personality.openness * 0.1
        case "Merchant":
            fit += agent.personality.extraversion * 0.2 + agent.personality.conscientiousness * 0.1
        case "Healer":
            fit += agent.personality.empathy * 0.3
        default:
            break
        }
        
        return min(1.0, fit)
    }
    
    private func generateProfessionIncome() {
        // This would typically update agent resources based on their professions
        // For now, we update economic metrics
        
        let activeWorkers = getAllAgents().filter { $0.profession != nil }
        var totalIncome: Float = 0
        
        for agent in activeWorkers {
            if let professionName = agent.profession,
               let profession = professions.first(where: { $0.name == professionName }) {
                
                let skillBonus = calculateSkillBonus(agent: agent, profession: profession)
                let marketModifier = getMarketModifier(for: profession.specialty)
                let income = profession.baseIncome * skillBonus * marketModifier
                
                // Add to agent resources (this would be done in a real implementation)
                totalIncome += income
            }
        }
        
        totalWealth += totalIncome
    }
    
    private func calculateSkillBonus(agent: Agent, profession: Profession) -> Float {
        var bonus: Float = 1.0
        
        for (skill, requirement) in profession.skillRequirements {
            let agentSkill = agent.skills[skill] ?? 0.0
            if agentSkill > requirement {
                bonus += (agentSkill - requirement) * 0.5
            }
        }
        
        return bonus
    }
    
    private func getMarketModifier(for resource: String) -> Float {
        let currentPrice = marketPrices[resource] ?? 1.0
        return 0.5 + (currentPrice * 0.5) // Market price affects income
    }
    
    // MARK: - Economic Analysis
    
    private func updateEconomicMetrics() {
        let recentTransactionCount = recentTransactions.count
        let totalTransactionValue = recentTransactions.reduce(0) { $0 + ($1.amount * $1.price) }
        
        economicMetrics = EconomicMetrics(
            transactionVolume: Float(recentTransactionCount),
            totalValue: totalTransactionValue,
            priceStability: calculatePriceStability(),
            marketEfficiency: calculateMarketEfficiency(),
            wealthConcentration: calculateWealthConcentration(),
            inflation: calculateInflation()
        )
    }
    
    private func calculatePriceStability() -> Float {
        var totalVariation: Float = 0
        var count = 0
        
        for resource in baseResources {
            let currentPrice = marketPrices[resource] ?? 1.0
            let variation = abs(currentPrice - 1.0) // Variation from base price
            totalVariation += variation
            count += 1
        }
        
        let averageVariation = count > 0 ? totalVariation / Float(count) : 0
        return max(0, 1 - averageVariation) // Higher is more stable
    }
    
    private func calculateMarketEfficiency() -> Float {
        // Simple efficiency based on supply/demand balance
        var totalEfficiency: Float = 0
        
        for resource in baseResources {
            let supply = resourceSupply[resource] ?? 50
            let demand = resourceDemand[resource] ?? 50
            let balance = min(supply, demand) / max(supply, demand)
            totalEfficiency += balance
        }
        
        return totalEfficiency / Float(baseResources.count)
    }
    
    private func calculateWealthConcentration() -> Float {
        // Simplified wealth concentration metric
        let agents = getAllAgents()
        guard !agents.isEmpty else { return 0 }
        
        let wealthValues = agents.map { getAgentWealth($0) }
        let sortedWealth = wealthValues.sorted(by: >)
        
        if sortedWealth.count < 2 { return 0 }
        
        let top20Percent = Int(max(1, sortedWealth.count / 5))
        let top20Wealth = sortedWealth.prefix(top20Percent).reduce(0, +)
        let totalWealth = sortedWealth.reduce(0, +)
        
        return totalWealth > 0 ? top20Wealth / totalWealth : 0
    }
    
    private func calculateInflation() -> Float {
        // Calculate average price change
        var priceChangeSum: Float = 0
        var count = 0
        
        for (resource, currentPrice) in marketPrices {
            // Compare to base price of 1.0
            let priceChange = (currentPrice - 1.0) / 1.0
            priceChangeSum += priceChange
            count += 1
        }
        
        return count > 0 ? priceChangeSum / Float(count) : 0
    }
    
    private func calculateWealthDistribution() -> WealthDistribution {
        let agents = getAllAgents()
        let wealthValues = agents.map { getAgentWealth($0) }.sorted()
        
        guard !wealthValues.isEmpty else {
            return WealthDistribution(giniCoefficient: 0, median: 0, mean: 0, standardDeviation: 0)
        }
        
        let mean = wealthValues.reduce(0, +) / Float(wealthValues.count)
        let median = wealthValues[wealthValues.count / 2]
        
        let variance = wealthValues.reduce(0) { acc, value in
            acc + pow(value - mean, 2)
        } / Float(wealthValues.count)
        
        let standardDeviation = sqrt(variance)
        
        let gini = calculateGiniCoefficient(wealthValues)
        
        return WealthDistribution(
            giniCoefficient: gini,
            median: median,
            mean: mean,
            standardDeviation: standardDeviation
        )
    }
    
    private func calculateGiniCoefficient(_ sortedWealth: [Float]) -> Float {
        let n = Float(sortedWealth.count)
        guard n > 1 else { return 0 }
        
        var numerator: Float = 0
        var denominator: Float = 0
        
        for (i, wealth) in sortedWealth.enumerated() {
            numerator += Float(2 * i + 1) * wealth
            denominator += wealth
        }
        
        return denominator > 0 ? (numerator / (n * denominator)) - (n + 1) / n : 0
    }
    
    // MARK: - Market Trends
    
    private func detectMarketTrends() {
        marketTrends.removeAll()
        
        for resource in baseResources {
            let currentPrice = marketPrices[resource] ?? 1.0
            let recentTransactions = transactionHistory.suffix(50).filter { $0.resource == resource }
            
            let trend = analyzeTrend(for: resource, currentPrice: currentPrice, transactions: Array(recentTransactions))
            marketTrends.append(trend)
        }
        
        // Sort by strength
        marketTrends.sort { $0.strength > $1.strength }
    }
    
    private func analyzeTrend(for resource: String, currentPrice: Float, transactions: [Transaction]) -> MarketTrend {
        let direction: TrendDirection
        let strength: Float
        
        if transactions.isEmpty {
            direction = .stable
            strength = 0.0
        } else {
            let averagePrice = transactions.reduce(0) { $0 + $1.price } / Float(transactions.count)
            let priceChange = (currentPrice - averagePrice) / averagePrice
            
            if priceChange > 0.1 {
                direction = .rising
                strength = min(1.0, abs(priceChange))
            } else if priceChange < -0.1 {
                direction = .declining
                strength = min(1.0, abs(priceChange))
            } else {
                direction = .stable
                strength = 0.5
            }
        }
        
        return MarketTrend(
            resource: resource,
            direction: direction,
            strength: strength,
            currentPrice: currentPrice
        )
    }
    
    // MARK: - Helper Functions
    
    private func getAllAgents() -> [Agent] {
        // This would get agents from the world context
        // For now, return empty array for compilation
        return []
    }
    
    func getAgentWealth(_ agent: Agent) -> Float {
        // Calculate total wealth from resources
        var wealth: Float = 0
        
        for (resource, amount) in agent.resources {
            let price = marketPrices[resource] ?? 1.0
            wealth += Float(amount) * price
        }
        
        return wealth
    }
    
    private func recordEconomicActivity(_ transaction: Transaction) {
        // Record transaction for analysis
        // This could trigger economic events or notifications
    }
    
    private func cleanupOldTransactions() {
        // Keep only recent transactions for performance
        recentTransactions = Array(recentTransactions.suffix(100))
        
        if transactionHistory.count > 1000 {
            transactionHistory = Array(transactionHistory.suffix(1000))
        }
    }
}

// MARK: - Supporting Types

struct Transaction: Identifiable {
    let id: UUID
    let buyerId: UUID
    let sellerId: UUID
    let resource: String
    let amount: Float
    let price: Float
    let timestamp: Date
    
    var totalValue: Float {
        amount * price
    }
    
    var description: String {
        "\(amount) \(resource) for \(price) each"
    }
}

struct Profession: Identifiable {
    let id = UUID()
    let name: String
    let specialty: String
    let baseIncome: Float
    let skillRequirements: [String: Float]
    var demand: Float = 0.5
    
    var description: String {
        "Produces \(specialty) with base income \(baseIncome)"
    }
}

struct EconomicMetrics {
    var transactionVolume: Float = 0
    var totalValue: Float = 0
    var priceStability: Float = 1.0
    var marketEfficiency: Float = 0.5
    var wealthConcentration: Float = 0.2
    var inflation: Float = 0.0
    
    var healthScore: Float {
        let stability = priceStability * 0.3
        let efficiency = marketEfficiency * 0.3
        let concentration = (1.0 - wealthConcentration) * 0.2
        let inflationPenalty = max(0, 1.0 - abs(inflation) * 10) * 0.2
        
        return stability + efficiency + concentration + inflationPenalty
    }
    
    var description: String {
        let health = healthScore > 0.7 ? "Healthy" : 
                    healthScore > 0.4 ? "Moderate" : "Struggling"
        return "\(health) economy (Score: \(Int(healthScore * 100))%)"
    }
}

struct MarketTrend: Identifiable {
    let id = UUID()
    let resource: String
    let direction: TrendDirection
    let strength: Float
    let currentPrice: Float
    
    var emoji: String {
        switch direction {
        case .rising: return "📈"
        case .declining: return "📉"
        case .stable: return "➡️"
        }
    }
    
    var description: String {
        "\(emoji) \(resource): \(String(format: "%.2f", currentPrice)) (\(Int(strength * 100))%)"
    }
}

struct WealthDistribution {
    let giniCoefficient: Float
    let median: Float
    let mean: Float
    let standardDeviation: Float
    
    var inequalityLevel: String {
        if giniCoefficient < 0.3 {
            return "Low inequality"
        } else if giniCoefficient < 0.5 {
            return "Moderate inequality"
        } else {
            return "High inequality"
        }
    }
}

// MARK: - Agent Extensions

extension Agent {
    func buyResource(_ resource: String, amount: Int, from seller: Agent, economicSystem: EconomicSystem) -> Bool {
        guard let price = economicSystem.marketPrices[resource] else { return false }
        
        let totalCost = price * Float(amount)
        let currentWealth = economicSystem.getAgentWealth(self)
        
        guard currentWealth >= totalCost else { return false }
        
        // Create and execute transaction
        let transaction = Transaction(
            id: UUID(),
            buyerId: id,
            sellerId: seller.id,
            resource: resource,
            amount: Float(amount),
            price: price,
            timestamp: Date()
        )
        
        if economicSystem.executeTransaction(transaction) {
            // Update resources
            resources[resource, default: 0] += amount
            seller.resources[resource, default: 0] -= amount
            
            return true
        }
        
        return false
    }
    
    func sellResource(_ resource: String, amount: Int, economicSystem: EconomicSystem) -> Bool {
        guard resources[resource, default: 0] >= amount else { return false }
        guard let price = economicSystem.marketPrices[resource] else { return false }
        
        // Create transaction (would need buyer in real implementation)
        let transaction = Transaction(
            id: UUID(),
            buyerId: UUID(), // Would be actual buyer
            sellerId: id,
            resource: resource,
            amount: Float(amount),
            price: price,
            timestamp: Date()
        )
        
        if economicSystem.executeTransaction(transaction) {
            resources[resource, default: 0] -= amount
            return true
        }
        
        return false
    }
}