import SpriteKit

private let playerActionKey = "playerActionKey"

private let enemyNodeName = "enemy"

private let playerNodeName = "player"

private let playerInitialSize = CGSize(width: 80, height: 80)
private let playerDownSize = CGSize(width: 50, height: 50)

struct BitMask {
    static let player: UInt32 = 0x1 << 0
    static let enemy: UInt32 = 0x1 << 1
}

final class GameScene: SKScene {
    
    private let playerNode = SKSpriteNode()
    private let skCamera = SKCameraNode()
    private var floorsList: [SKSpriteNode] = []
    private var enemyesList: [SKSpriteNode] = []
    
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
        moveCamera()

        
        if let last = floorsList.last {
            if playerNode.position.x+100 > last.frame.maxX {
                setupFloor(last.frame.maxX+last.frame.width/2 + 100)
                
                
                let last = floorsList.last!
                setupEnemy(x: last.frame.midX, y: last.frame.maxY)
                
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
               
               // TO DO: descrease life while contact with enemy
               print("-1 life")
           }
       }
        

    }
    
}

extension GameScene {
    
    func jumpDidTap() {
        let jumpImpuls = CGVector(dx: 20, dy: 300)
        playerNode.physicsBody?.applyImpulse(jumpImpuls)
    }
    
    func downDidTap() {
        playerNode.physicsBody = SKPhysicsBody(rectangleOf: playerDownSize)
        
        Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { [weak self] _ in
            guard let self else {return}
            self.playerNode.physicsBody = SKPhysicsBody(rectangleOf: playerInitialSize)
            self.playerNode.physicsBody?.categoryBitMask = BitMask.player
            self.playerNode.physicsBody?.contactTestBitMask = BitMask.enemy
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
        playerNode.physicsBody?.categoryBitMask = BitMask.player
        playerNode.physicsBody?.contactTestBitMask = BitMask.enemy
        
        addChild(playerNode)
    }
    
    func setupEnemy(x: CGFloat, y: CGFloat) {
        let enemySize = CGSize(width: 60, height: 60)
        
        let enemyNode = SKSpriteNode()
        enemyNode.position = CGPoint(x: x, y: y + enemySize.height/2 + playerInitialSize.height - 10)
        enemyNode.zPosition = 2
        enemyNode.size = enemySize
        enemyNode.color = .black
        enemyNode.name = enemyNodeName
        enemyNode.physicsBody = SKPhysicsBody(rectangleOf: enemySize)
        enemyNode.physicsBody?.allowsRotation = false
        enemyNode.physicsBody?.isDynamic = false
        enemyNode.physicsBody?.affectedByGravity = false
        enemyNode.physicsBody?.categoryBitMask = BitMask.enemy
        enemyNode.physicsBody?.contactTestBitMask = BitMask.player
        
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
        physicsWorld.contactDelegate = self
    }
    
    func setupFloor(_ x: CGFloat) {
        let floorSize = CGSize(width: screenSize.width*2, height: 60)
        
        let floorNode = SKSpriteNode()
        floorNode.position = CGPoint(x: x, y: -screenSize.height/2 + floorSize.height + 120)
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
    
    func moveCamera() {
        if playerNode.position.x > -100 {
            camera?.position.x = playerNode.position.x+100
        }
    }
    
}
