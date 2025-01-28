import SpriteKit

let screenSize = UIScreen.main.bounds.size

private let playerActionKey = "playerActionKey"

private let playerSize = CGSize(width: 60, height: 60)

final class GameScene: SKScene {
    
    private let playerNode = SKSpriteNode()
    private let skCamera = SKCameraNode()
    private var floorsList: [SKSpriteNode] = []
    
    override init(size: CGSize) {
        super.init(size: size)
        
        setupScene()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        setupBack()
        setupPlayer()
        setupFloor(0)
        setupMoveAction()
        setupCamera()

    }
    
    override func didSimulatePhysics() {
        if playerNode.position.x > -100 {
            camera?.position.x = playerNode.position.x+100
        }
        
        if let last = floorsList.last {
            if playerNode.position.x+100 > last.frame.maxX {
                setupFloor(last.frame.maxX+last.frame.width/2 + 50)
                
                setupJump()
                
                if floorsList.count > 1 {
                    let floor = floorsList.removeFirst()
                    floor.removeFromParent()
                }
            }

        }
    }
    
}

private extension GameScene {
    
    func setupPlayer() {
        playerNode.position = CGPoint(x: -screenSize.width/2 + playerSize.width, y: 0)
        playerNode.zPosition = 1
        playerNode.size = playerSize
        playerNode.color = .red
        playerNode.physicsBody = SKPhysicsBody(rectangleOf: playerSize)
        playerNode.physicsBody?.mass = 1
        playerNode.physicsBody?.allowsRotation = false
        playerNode.physicsBody?.isDynamic = true
        playerNode.physicsBody?.affectedByGravity = true
        
        addChild(playerNode)
    }
    
    func setupCamera() {
        camera = skCamera
        camera?.position = CGPoint(x: 0, y: frame.midY)
        addChild(camera!)
    }
    
    func setupBack() {
        let backNode = SKSpriteNode()
        backNode.position = CGPoint(x: 0, y: 0)
        backNode.zPosition = 0
        backNode.size = screenSize
        backNode.color = .gray
        addChild(backNode)
    }
    
    func setupMoveAction() {
        let moveAction = SKAction.moveBy(x: 100, y: 0, duration: 1)
        moveAction.timingMode = .linear
        
        let repeatForeveAction = SKAction.repeatForever(moveAction)
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
            guard let self else { return }
            self.playerNode.run(repeatForeveAction, withKey: playerActionKey)
        }
        
    }
    
    func setupScene() {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scaleMode = .aspectFill
    }
    
    func setupJump() {
        Timer.scheduledTimer(withTimeInterval: 0, repeats: false) { [weak self] _ in
            guard let self else { return }
            let jumpImpuls = CGVector(dx: 100, dy: 900)
            self.playerNode.physicsBody?.applyImpulse(jumpImpuls)
        }
    }
    
    func setupFloor(_ x: CGFloat) {
        let floorSize = CGSize(width: screenSize.width*2, height: 60)
        
        let floorNode = SKSpriteNode()
        floorNode.position = CGPoint(x: x, y: -screenSize.height/2 + floorSize.height)
        floorNode.zPosition = 2
        floorNode.size = floorSize
        floorNode.color = .brown
        floorNode.physicsBody = SKPhysicsBody(rectangleOf: floorSize)
        floorNode.physicsBody?.allowsRotation = false
        floorNode.physicsBody?.isDynamic = false
        floorNode.physicsBody?.affectedByGravity = false
        
        addChild(floorNode)
        
        floorsList.append(floorNode)
    }
    
}
