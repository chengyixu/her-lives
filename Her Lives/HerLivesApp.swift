//
//  HerLivesApp.swift
//  Her Lives - A Living AI World
//
//  Created on 2024
//  An iOS game where AI agents truly live, love, and evolve
//

import SwiftUI
import SpriteKit
import Combine
import UserNotifications

@main
struct HerLivesApp: App {
    @StateObject private var gameWorld = LivingWorld()
    @StateObject private var qwenService = QwenAIService()
    @StateObject private var saveManager = SaveGameManager()
    
    init() {
        // Configure Qwen API
        QwenConfiguration.shared.configure(
            apiKeys: [
                "sk-316420c29c624dbeb7fbbcb63077a46f",
                "sk-1a28c3fcc7e044cbacd6faf47dc89755"
            ]
        )
        
        // Initialize audio engine
        AudioEngine.shared.initialize()
        
        // Setup notification handlers
        setupNotifications()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameWorld)
                .environmentObject(qwenService)
                .environmentObject(saveManager)
                .preferredColorScheme(.dark)
                .onAppear {
                    gameWorld.initialize()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    // World continues running - no pause
                    saveManager.autoSave(gameWorld)
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    // World already running - no resume needed
                }
        }
    }
    
    private func setupNotifications() {
        // Request notification permissions for agent events
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notifications enabled for agent events")
            }
        }
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @EnvironmentObject var gameWorld: LivingWorld
    @State private var selectedView: GameView = .world
    @State private var selectedAgent: Agent?
    @State private var showSettings = false
    
    enum GameView {
        case world, agents, memories, relationships, culture, timeline
    }
    
    var body: some View {
        NavigationView {
            // Main game view
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color("DeepSpace"), Color("Twilight")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Main content
                VStack(spacing: 0) {
                    // Top bar - FIXED position
                    GameTopBar(selectedView: $selectedView)
                        .frame(height: UIScreen.main.bounds.height * 0.08)
                        .zIndex(100) // Always on top
                    
                    // Content area with proper clipping
                    Group {
                        switch selectedView {
                        case .world:
                            WorldView()
                        case .agents:
                            AgentListView()
                        case .memories:
                            MemoryStreamView()
                        case .relationships:
                            RelationshipNetworkView()
                        case .culture:
                            CultureEvolutionView()
                        case .timeline:
                            TimelineView()
                        }
                    }
                    .clipped() // Prevent content from going outside bounds
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - Game Top Bar
struct GameTopBar: View {
    @Binding var selectedView: ContentView.GameView
    @EnvironmentObject var gameWorld: LivingWorld
    @AppStorage("appLanguage") private var language: String = "en"
    @State private var showDetailedStats = false
    
    var body: some View {
        VStack(spacing: 15) {
            // Top row - Stats in the center
            HStack {
                // Language toggle on the left
                Button(action: {
                    language = language == "en" ? "zh" : "en"
                }) {
                    Text(language == "en" ? "EN" : "中文")
                        .font(.system(size: UIScreen.main.bounds.width * 0.035, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, UIScreen.main.bounds.width * 0.03)
                        .padding(.vertical, UIScreen.main.bounds.height * 0.008)
                        .background(Color.blue)
                        .cornerRadius(UIScreen.main.bounds.width * 0.02)
                }
                
                Spacer()
                
                // Stats in the center
                HStack(spacing: 20) {
                    // Happiness
                    StatIconView(
                        icon: "heart.fill",
                        value: String(format: "%.1f", gameWorld.averageHappiness),
                        color: gameWorld.averageHappiness > 0.5 ? .green : gameWorld.averageHappiness < 0 ? .red : .yellow
                    )
                    
                    // Relationships
                    StatIconView(
                        icon: "link",
                        value: "\(gameWorld.totalRelationships)",
                        color: .purple
                    )
                    
                    // Cultural Diversity
                    StatIconView(
                        icon: "globe",
                        value: gameWorld.culturalDiversity.isNaN ? "0.0" : String(format: "%.1f", gameWorld.culturalDiversity),
                        color: .orange
                    )
                    
                    // Stats detail button
                    Button(action: { showDetailedStats.toggle() }) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: UIScreen.main.bounds.width * 0.035))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                // Agent count on the right
                Text("\(gameWorld.agents.count) agents")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            
            // Bottom row - View selector
            HStack(spacing: 25) {
                ViewButton(icon: "globe", view: .world, selected: $selectedView)
                ViewButton(icon: "person.3.fill", view: .agents, selected: $selectedView)
                ViewButton(icon: "brain", view: .memories, selected: $selectedView)
                ViewButton(icon: "heart.circle", view: .relationships, selected: $selectedView)
                ViewButton(icon: "sparkles", view: .culture, selected: $selectedView)
                ViewButton(icon: "clock", view: .timeline, selected: $selectedView)
            }
        }
        .padding(.vertical, UIScreen.main.bounds.height * 0.015)
        .padding(.horizontal, UIScreen.main.bounds.width * 0.025)
        .background(
            VisualEffectView(effect: UIBlurEffect(style: .dark))
                .opacity(0.95)
        )
        .sheet(isPresented: $showDetailedStats) {
            DetailedStatsView()
                .environmentObject(gameWorld)
        }
    }
}

struct StatIconView: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: UIScreen.main.bounds.width * 0.035))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: UIScreen.main.bounds.width * 0.035, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

struct ViewButton: View {
    let icon: String
    let view: ContentView.GameView
    @Binding var selected: ContentView.GameView
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                selected = view
            }
        }) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(selected == view ? .white : .gray)
                .scaleEffect(selected == view ? 1.2 : 1.0)
        }
    }
}

// MARK: - Visual Effect View for Blur
struct VisualEffectView: UIViewRepresentable {
    typealias UIViewType = UIVisualEffectView
    
    let effect: UIVisualEffect
    
    func makeUIView(context: UIViewRepresentableContext<VisualEffectView>) -> UIVisualEffectView {
        return UIVisualEffectView(effect: effect)
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<VisualEffectView>) {
        uiView.effect = effect
    }
}