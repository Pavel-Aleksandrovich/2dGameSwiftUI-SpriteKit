import SpriteKit

private let playerActionKey = "playerActionKey"

private let enemyNodeName = "enemy"

private let playerNodeName = "player"

private let playerInitialSize = CGSize(width: 60, height: 60)
private let playerDownSize = CGSize(width: 50, height: 50)
private let trapSize = CGSize(width: 100, height: 60)
private let enemySize = CGSize(width: 60, height: 60)

final class GameScene: SKScene {
    
    var loseHandler: ()->() = {}
    
    private let playerNode = SKSpriteNode()
    private let skCamera = SKCameraNode()
    private var floorsList: [SKSpriteNode] = []
    private var enemyesList: [SKSpriteNode] = []
    
    private var isCanJump = true
    
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
        setupFloor(x: 0, width: FloorType.large.width, y: 0)
        setupCamera()
    }
    
    override func didSimulatePhysics() {
        moveCamera()
        
        guard !floorsList.isEmpty,
              playerNode.position.x+200 > floorsList.last!.frame.maxX
        else { return }
        
        let last = floorsList.last!
        let randomFloorType = FloorType.allCases.randomElement() ?? .small
        let floorY: CGFloat = randomFloorType == .small ? 60 : 0
        setupFloor(x: last.frame.maxX+randomFloorType.width/2 + trapSize.width + 20, width: randomFloorType.width, y: floorY)
        
        if randomFloorType == .large {
            let enemyY = floorsList.last!.frame.maxY + enemySize.height/2 + playerInitialSize.height - 10
            setupEnemy(x: floorsList.last!.frame.midX, y: enemyY, size: enemySize)
        }
        
        if floorsList.count > 2 {
            let floor = floorsList.removeFirst()
            floor.removeFromParent()
        }
        
        if enemyesList.count > 5 {
            let enemyNode = enemyesList.removeFirst()
            enemyNode.removeFromParent()
        }
        
    }
    
}

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {

       if let _ = contact.bodyA.node?.name,
          let nameB = contact.bodyB.node?.name {
           
           if nameB == enemyNodeName {
               removeFromParent(contact.bodyB.node)
           } else {
               removeFromParent(contact.bodyA.node)
           }

           func removeFromParent(_ node: SKNode?) {
               if let node = node {
                   node.removeFromParent()
               }
         
//               loseHandler()
               
           }
       }
        

    }
    
}

extension GameScene {
    
    func startGame() {
        setupPlayerMoveAction()
    }
    
    func jumpDidTap() {
//        let jumpImpuls = CGVector(dx: 0, dy: 250)
//        playerNode.physicsBody?.applyImpulse(jumpImpuls)
        
        guard isCanJump else { return }
        
        isCanJump = false
        
        let jumpAction = SKAction.moveBy(x: 15, y: playerNode.position.y + 350, duration: 0.2)
        jumpAction.timingMode = .easeOut
        
        let moveAction = SKAction.moveBy(x: 35, y: 0, duration: 0.1)

        
        let jumpEndHandler = SKAction.run { [weak self] in
            guard let self else { return }
            self.isCanJump = true
        }
        
        let jumpSequence = SKAction.sequence([jumpAction,moveAction, jumpEndHandler])
        playerNode.run(jumpSequence)
    }
    
    func downDidTap() {
        playerNode.physicsBody = SKPhysicsBody(rectangleOf: playerDownSize)
        
        Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { [weak self] _ in
            guard let self else {return}
            self.playerNode.physicsBody = SKPhysicsBody(rectangleOf: playerInitialSize)
            self.playerNode.physicsBody?.categoryBitMask = BitMaskGame.player
            self.playerNode.physicsBody?.contactTestBitMask = BitMaskGame.enemy
            self.playerNode.physicsBody?.allowsRotation = false
        }
    }
    
}

private extension GameScene {
    
    func setupPlayer() {
        playerNode.position = CGPoint(x: -screenSize.width/2 + playerInitialSize.width, y: 0)
        playerNode.zPosition = 1
        playerNode.size = playerInitialSize
        playerNode.color = .red
        playerNode.name = playerNodeName
        playerNode.physicsBody = SKPhysicsBody(rectangleOf: playerInitialSize)
        playerNode.physicsBody?.categoryBitMask = BitMaskGame.player
        playerNode.physicsBody?.contactTestBitMask = BitMaskGame.enemy
        playerNode.physicsBody?.allowsRotation = false
        
        addChild(playerNode)
    }
    
    func setupEnemy(x: CGFloat, y: CGFloat, size: CGSize) {
        let enemyNode = SKSpriteNode()
        enemyNode.position = CGPoint(x: x, y: y)
        enemyNode.zPosition = 3
        enemyNode.size = size
        enemyNode.color = .black
        enemyNode.name = enemyNodeName
        enemyNode.physicsBody = SKPhysicsBody(rectangleOf: size)
        enemyNode.physicsBody?.allowsRotation = false
        enemyNode.physicsBody?.isDynamic = false
        enemyNode.physicsBody?.affectedByGravity = false
        enemyNode.physicsBody?.categoryBitMask = BitMaskGame.enemy
        enemyNode.physicsBody?.contactTestBitMask = BitMaskGame.player
        
        addChild(enemyNode)
        
        enemyesList.append(enemyNode)
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
    
    func setupPlayerMoveAction() {
        let moveAction = SKAction.moveBy(x: 400, y: 0, duration: 1)
        moveAction.timingMode = .linear
        
        let repeatForeveAction = SKAction.repeatForever(moveAction)
        
        playerNode.run(repeatForeveAction, withKey: playerActionKey)
    }
    
    func setupScene() {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scaleMode = .aspectFill
        physicsWorld.contactDelegate = self
    }
    
    func setupFloor(x: CGFloat, width: CGFloat, y: CGFloat) {
        let floorSize = CGSize(width: width, height: 60)
        
        let floorNode = SKSpriteNode()
        floorNode.position = CGPoint(x: x, y: -screenSize.height/2 + floorSize.height + 120 + y)
        floorNode.zPosition = 2
        floorNode.size = floorSize
        floorNode.color = .brown
        floorNode.physicsBody = SKPhysicsBody(rectangleOf: floorSize)
        floorNode.physicsBody?.allowsRotation = false
        floorNode.physicsBody?.isDynamic = false
        floorNode.physicsBody?.affectedByGravity = false
        
        addChild(floorNode)
        
        floorsList.append(floorNode)
        
        setupEnemy(x: floorNode.frame.maxX + trapSize.width/2 + 10, y: floorNode.frame.midY+20, size: trapSize)
    }
    
    func moveCamera() {
        if playerNode.position.x > -100 {
            camera?.position.x = playerNode.position.x+100
        }
    }
    
}
