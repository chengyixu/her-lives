//
//  WorldView.swift
//  Her Lives
//
//  The main world view where agents live and interact
//

import SwiftUI
import SpriteKit

struct WorldView: View {
    @EnvironmentObject var gameWorld: LivingWorld
    @State private var selectedAgent: Agent?
    @State private var cameraPosition = CGPoint(x: 0, y: 0)
    @State private var zoomLevel: CGFloat = 1.0
    @State private var showAgentDetails = false
    @State private var followingAgent: Agent?
    @State private var showEmergentEvent = false
    @State private var currentEmergentEvent: EmergentPhenomenon?
    
    var body: some View {
        ZStack {
            // Main world scene
            WorldSceneView(
                selectedAgent: $selectedAgent,
                cameraPosition: $cameraPosition,
                zoomLevel: $zoomLevel,
                followingAgent: $followingAgent
            )
            .ignoresSafeArea()
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        zoomLevel = min(max(value, 0.5), 3.0)
                    }
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if followingAgent == nil {
                            cameraPosition.x -= value.translation.width / zoomLevel
                            cameraPosition.y -= value.translation.height / zoomLevel
                        }
                    }
            )
            
            // UI Overlay
            VStack {
                Spacer()
                
                // Agent list on the left
                HStack {
                    AgentSidebarView(selectedAgent: $selectedAgent, followingAgent: $followingAgent)
                    
                    Spacer()
                }
                
                // Bottom: Selected agent details
                if let agent = selectedAgent {
                    AgentDetailCard(agent: agent, isExpanded: $showAgentDetails)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            
            // Emergent event notification
            if showEmergentEvent, let event = currentEmergentEvent {
                EmergentEventNotification(event: event)
                    .transition(.scale.combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            withAnimation {
                                showEmergentEvent = false
                            }
                        }
                    }
            }
        }
        .onReceive(gameWorld.$emergentPhenomena) { phenomena in
            if let newEvent = phenomena.last,
               newEvent.significance > 0.8 {
                withAnimation(.spring()) {
                    currentEmergentEvent = newEvent
                    showEmergentEvent = true
                }
                // Haptic feedback for success
            }
        }
    }
}

// MARK: - World Scene (SpriteKit)
struct WorldSceneView: UIViewRepresentable {
    typealias UIViewType = SKView
    
    @EnvironmentObject var gameWorld: LivingWorld
    @Binding var selectedAgent: Agent?
    @Binding var cameraPosition: CGPoint
    @Binding var zoomLevel: CGFloat
    @Binding var followingAgent: Agent?
    
    func makeUIView(context: UIViewRepresentableContext<WorldSceneView>) -> SKView {
        let skView = SKView()
        skView.preferredFramesPerSecond = 60
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.allowsTransparency = true
        
        let scene = WorldScene(size: skView.bounds.size)
        scene.gameWorld = gameWorld
        scene.scaleMode = .aspectFill
        scene.backgroundColor = .clear
        scene.agentSelectedHandler = { agent in
            selectedAgent = agent
            // Haptic feedback for camera change
        }
        
        skView.presentScene(scene)
        return skView
    }
    
    func updateUIView(_ uiView: SKView, context: UIViewRepresentableContext<WorldSceneView>) {
        guard let scene = uiView.scene as? WorldScene else { return }
        
        scene.cameraPosition = cameraPosition
        scene.zoomLevel = zoomLevel
        
        if let following = followingAgent {
            scene.followAgent(following)
        } else {
            scene.stopFollowing()
        }
    }
}

// MARK: - SpriteKit World Scene
class WorldScene: SKScene {
    weak var gameWorld: LivingWorld?
    var agentSelectedHandler: ((Agent) -> Void)?
    
    private var agentNodes: [UUID: AgentNode] = [:]
    private var locationNodes: [LocationNode] = []
    private var interactionVisualizers: [InteractionVisualizer] = []
    private var cameraNode: SKCameraNode!
    
    var cameraPosition: CGPoint = .zero {
        didSet {
            cameraNode?.position = cameraPosition
        }
    }
    
    var zoomLevel: CGFloat = 1.0 {
        didSet {
            cameraNode?.setScale(1.0 / zoomLevel)
        }
    }
    
    private var followedAgent: Agent?
    
    override func didMove(to view: SKView) {
        setupWorld()
        setupCamera()
        startUpdateLoop()
    }
    
    private func setupWorld() {
        // Create background
        let background = SKSpriteNode(imageNamed: "world_map")
        background.size = CGSize(width: 2000, height: 2000)
        background.position = .zero
        background.zPosition = -100
        addChild(background)
        
        // Add location markers
        createLocations()
        
        // Create agent nodes
        createAgentNodes()
        
        // Ambient particle effects
        addAmbientEffects()
    }
    
    private func setupCamera() {
        cameraNode = SKCameraNode()
        self.camera = cameraNode
        addChild(cameraNode)
    }
    
    private func createLocations() {
        let locations = [
            ("Hobbs Cafe", CGPoint(x: -200, y: 100)),
            ("Town Square", CGPoint(x: 0, y: 0)),
            ("Library", CGPoint(x: 200, y: 150)),
            ("Park", CGPoint(x: -150, y: -200)),
            ("Market", CGPoint(x: 300, y: -100))
        ]
        
        for (name, position) in locations {
            let node = LocationNode(name: name)
            node.position = position
            addChild(node)
            locationNodes.append(node)
        }
    }
    
    private func createAgentNodes() {
        guard let world = gameWorld else { return }
        
        for agent in world.agents {
            let agentNode = AgentNode(agent: agent)
            agentNode.position = CGPoint(x: CGFloat(agent.position.x), y: CGFloat(agent.position.y))
            addChild(agentNode)
            agentNodes[agent.id] = agentNode
        }
    }
    
    private func addAmbientEffects() {
        // Day/night cycle overlay
        let dayNightOverlay = SKShapeNode(rect: CGRect(x: -1000, y: -1000, width: 2000, height: 2000))
        dayNightOverlay.fillColor = .clear
        dayNightOverlay.zPosition = 50
        dayNightOverlay.name = "dayNightOverlay"
        addChild(dayNightOverlay)
        
        // Weather effects
        if Bool.random() {
            addWeatherEffect()
        }
    }
    
    private func addWeatherEffect() {
        // Simple particle rain
        if let rainEmitter = SKEmitterNode(fileNamed: "Rain") {
            rainEmitter.position = CGPoint(x: 0, y: 500)
            rainEmitter.zPosition = 60
            cameraNode.addChild(rainEmitter)
        }
    }
    
    private func startUpdateLoop() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.updateAgentPositions()
            self.updateInteractions()
            self.updateDayNightCycle()
        }
    }
    
    private func updateAgentPositions() {
        guard let world = gameWorld else { return }
        
        for agent in world.agents {
            if let node = agentNodes[agent.id] {
                // Smooth movement
                let targetPosition = CGPoint(x: CGFloat(agent.position.x), y: CGFloat(agent.position.y))
                let moveAction = SKAction.move(to: targetPosition, duration: 0.5)
                moveAction.timingMode = SKActionTimingMode.easeInEaseOut
                node.run(moveAction)
                
                // Update agent state visualization
                node.updateState(agent)
            }
        }
        
        // Follow agent if set
        if let followed = followedAgent {
            let agentPosition = CGPoint(x: CGFloat(followed.position.x), y: CGFloat(followed.position.y))
            let moveCamera = SKAction.move(to: agentPosition, duration: 0.3)
            cameraNode.run(moveCamera)
        }
    }
    
    private func updateInteractions() {
        guard let world = gameWorld else { return }
        
        // Clear old visualizers
        interactionVisualizers.forEach { $0.removeFromParent() }
        interactionVisualizers.removeAll()
        
        // Create new interaction visualizations
        for event in world.worldEvents.suffix(10) {
            if event.type == .socialInteraction,
               let firstId = event.participants.first,
               let secondId = event.participants.dropFirst().first,
               let node1 = agentNodes[firstId],
               let node2 = agentNodes[secondId] {
                
                let visualizer = InteractionVisualizer(from: node1.position, to: node2.position)
                addChild(visualizer)
                interactionVisualizers.append(visualizer)
                
                visualizer.animate()
            }
        }
    }
    
    private func updateDayNightCycle() {
        guard let world = gameWorld,
              let overlay = childNode(withName: "dayNightOverlay") as? SKShapeNode else { return }
        
        let hour = world.currentTime.hour
        var alpha: CGFloat = 0
        
        switch hour {
        case 0...5, 20...23:
            alpha = 0.6 // Night
        case 6...7, 18...19:
            alpha = 0.3 // Dawn/Dusk
        default:
            alpha = 0.0 // Day
        }
        
        overlay.fillColor = UIColor.black.withAlphaComponent(alpha)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)
        
        for node in nodes {
            if let agentNode = node as? AgentNode {
                agentSelectedHandler?(agentNode.agent)
                
                // Visual feedback
                let pulse = SKAction.sequence([
                    SKAction.scale(to: 1.3, duration: 0.1),
                    SKAction.scale(to: 1.0, duration: 0.1)
                ])
                agentNode.run(pulse)
                
                break
            }
        }
    }
    
    func followAgent(_ agent: Agent) {
        followedAgent = agent
    }
    
    func stopFollowing() {
        followedAgent = nil
    }
}

// MARK: - Agent Node
class AgentNode: SKNode {
    let agent: Agent
    private let sprite: SKShapeNode
    private let nameLabel: SKLabelNode
    private let emotionIndicator: SKShapeNode
    private let thoughtBubble: SKNode
    
    init(agent: Agent) {
        self.agent = agent
        
        // Create agent sprite (circle for now)
        sprite = SKShapeNode(circleOfRadius: 10)
        sprite.fillColor = UIColor.systemBlue
        sprite.strokeColor = UIColor.white
        sprite.lineWidth = 2
        
        // Name label
        nameLabel = SKLabelNode(text: agent.name.components(separatedBy: " ").first)
        nameLabel.fontSize = 10
        nameLabel.position = CGPoint(x: 0, y: -20)
        
        // Emotion indicator
        emotionIndicator = SKShapeNode(circleOfRadius: 3)
        emotionIndicator.position = CGPoint(x: 12, y: 12)
        
        // Thought bubble (hidden by default)
        thoughtBubble = SKNode()
        thoughtBubble.alpha = 0
        
        super.init()
        
        addChild(sprite)
        addChild(nameLabel)
        addChild(emotionIndicator)
        addChild(thoughtBubble)
        
        updateState(agent)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateState(_ agent: Agent) {
        // Update color based on state
        if agent.consciousness.state == .sleeping {
            sprite.fillColor = UIColor.systemGray
        } else if agent.emotion.dominantFeeling == .happy {
            sprite.fillColor = UIColor.systemGreen
        } else if agent.emotion.dominantFeeling == .sad {
            sprite.fillColor = UIColor.systemBlue
        } else if agent.emotion.dominantFeeling == .angry {
            sprite.fillColor = UIColor.systemRed
        } else {
            sprite.fillColor = UIColor.systemTeal
        }
        
        // Update emotion indicator
        emotionIndicator.fillColor = UIColor(agent.emotion.color)
        
        // Show thought bubble if reflecting
        if agent.reflection.isReflecting {
            showThoughtBubble(with: "💭")
        } else if agent.currentAction?.type == .socialize {
            showThoughtBubble(with: "💬")
        } else if agent.currentAction?.type == .work {
            showThoughtBubble(with: "⚙️")
        }
    }
    
    private func showThoughtBubble(with text: String) {
        thoughtBubble.removeAllChildren()
        
        let bubble = SKLabelNode(text: text)
        bubble.position = CGPoint(x: 0, y: 20)
        thoughtBubble.addChild(bubble)
        
        thoughtBubble.alpha = 1
        
        // Fade out after 2 seconds
        thoughtBubble.run(SKAction.sequence([
            SKAction.wait(forDuration: 2),
            SKAction.fadeOut(withDuration: 0.5)
        ]))
    }
}

// MARK: - Location Node
class LocationNode: SKNode {
    init(name: String) {
        super.init()
        
        // Building icon
        let building = SKShapeNode(rectOf: CGSize(width: 40, height: 40))
        building.fillColor = UIColor.systemBrown.withAlphaComponent(0.7)
        building.strokeColor = UIColor.systemBrown
        addChild(building)
        
        // Label
        let label = SKLabelNode(text: name)
        label.fontSize = 12
        label.position = CGPoint(x: 0, y: -30)
        addChild(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Interaction Visualizer
class InteractionVisualizer: SKNode {
    init(from: CGPoint, to: CGPoint) {
        super.init()
        
        let path = CGMutablePath()
        path.move(to: from)
        path.addLine(to: to)
        
        let line = SKShapeNode(path: path)
        line.strokeColor = UIColor.systemYellow.withAlphaComponent(0.5)
        line.lineWidth = 2
        line.glowWidth = 4
        
        addChild(line)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animate() {
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let wait = SKAction.wait(forDuration: 2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()
        
        run(SKAction.sequence([fadeIn, wait, fadeOut, remove]))
    }
}