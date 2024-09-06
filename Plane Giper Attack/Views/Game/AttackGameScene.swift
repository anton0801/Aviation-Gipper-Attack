import SwiftUI
import SpriteKit

extension UInt32 {
    static let myPlane: UInt32 = 1
    static let myBullet: UInt32 = 2
    static let myRocket: UInt32 = 3
    static let enemy: UInt32 = 4
    static let enemyBullet: UInt32 = 5
    static let enemyRocket: UInt32 = 6
}

class AttackGameScene: SKScene, SKPhysicsContactDelegate {
    
    var level: Int
    
    init(level: Int) {
        self.level = level
        super.init(size: CGSize(width: 3200, height: 1750))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var credits = UserDefaults.standard.integer(forKey: "credits") {
        didSet {
            UserDefaults.standard.set(credits, forKey: "credits")
            creditsLabel.text = "\(credits)"
        }
    }
    
    private var energy = UserDefaults.standard.integer(forKey: "energy") {
        didSet {
            UserDefaults.standard.set(energy, forKey: "energy")
            energyLabel.text = "\(energy)"
        }
    }
    
    private var creditsLabel: SKLabelNode!
    private var energyLabel: SKLabelNode!
    
    private var background: SKSpriteNode {
        get {
            let node = SKSpriteNode(imageNamed: "game_field_back")
            node.size = size
            node.position = CGPoint(x: size.width / 2, y: size.height / 2)
            return node
        }
    }
    
    private var menuBtn: SKSpriteNode {
        get {
            let node = SKSpriteNode(imageNamed: "menu_btn")
            node.position = CGPoint(x: 150, y: size.height - 130)
            node.size = CGSize(width: 150, height: 180)
            node.name = "menu_btn"
            return node
        }
    }
    
    private var plane: SKSpriteNode!
    private var planeHealt: SKSpriteNode!
    private var planeHealtBack: SKSpriteNode!
    private var planeHealtHeart: SKSpriteNode!
    private var planeHealtCount = 100.0 {
        didSet {
            planeHealt.size = CGSize(width: planeHealtCount * (400 / 100), height: 50)
            if planeHealtCount <= 0 {
                showLoseDialog()
            }
        }
    }
    
    private var jostik: SKSpriteNode {
        get {
            let node = SKSpriteNode()
            
            let jostikUp = SKSpriteNode(imageNamed: "arrow_up")
            jostikUp.size = CGSize(width: 140, height: 170)
            jostikUp.name = "arrow_up"
            jostikUp.position = CGPoint(x: 0, y: 150)
            node.addChild(jostikUp)
            
            let jostikBottom = SKSpriteNode(imageNamed: "arrow_down")
            jostikBottom.size = CGSize(width: 140, height: 170)
            jostikBottom.name = "arrow_down"
            jostikBottom.position = CGPoint(x: 0, y: -150)
            node.addChild(jostikBottom)
            
            let jostikLeft = SKSpriteNode(imageNamed: "arrow_back")
            jostikLeft.size = CGSize(width: 140, height: 170)
            jostikLeft.name = "arrow_left"
            jostikLeft.position = CGPoint(x: -100, y: 0)
            node.addChild(jostikLeft)
            
            let jostikRight = SKSpriteNode(imageNamed: "arrow_next")
            jostikRight.size = CGSize(width: 140, height: 170)
            jostikRight.name = "arrow_right"
            jostikRight.position = CGPoint(x: 100, y: 0)
            node.addChild(jostikRight)
            
            node.position = CGPoint(x: 300, y: 250)
            
            return node
        }
    }
    
    private var attackBtn: SKSpriteNode {
        get {
            let node = SKSpriteNode(imageNamed: "attack")
            node.position = CGPoint(x: size.width - 240, y: 200)
            node.size = CGSize(width: 320, height: 350)
            node.name = "arrow_attack"
            return node
        }
    }
    
    private var timeNode: SKSpriteNode!
    private var allTime = 50
    private var timeLeft = 50 {
        didSet {
            timeNode.size = CGSize(width: 380 * (Double(timeLeft) / Double(allTime)), height: 140)
            if timeLeft == 0 {
                isPaused = true
                showWinDialog()
            }
        }
    }
    private var gameTimer: Timer = Timer()
    private var enemySpawner: Timer = Timer()
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        addChild(background)
        addChild(menuBtn)
        
        plane = SKSpriteNode(imageNamed: "main_plane")
        plane.position = CGPoint(x: 600, y: size.height / 2)
        plane.size = CGSize(width: 350, height: 220)
        plane.physicsBody = SKPhysicsBody(rectangleOf: plane.size)
        plane.physicsBody?.isDynamic = true
        plane.physicsBody?.affectedByGravity = false
        plane.physicsBody?.categoryBitMask = .myPlane
        plane.physicsBody?.collisionBitMask = .enemyBullet | .enemyRocket
        plane.physicsBody?.contactTestBitMask = .enemyBullet | .enemyRocket
        plane.name = "main_plane"
        addChild(plane)
        
        createPlaneHealt()
        createBalances()
        createLevelAndTime()
        
        addChild(jostik)
        addChild(attackBtn)
        
        gameTimer = .scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
            if !self.isPaused {
                self.timeLeft -= 1
            }
        })
        
        
        enemySpawner = .scheduledTimer(withTimeInterval: 7.0, repeats: true, block: { _ in
            if !self.isPaused {
                self.spawnEnemy()
            }
        })
        
        spawnEnemy()
    }
    
    private func createLevelAndTime() {
        let levelBack = SKSpriteNode(imageNamed: "level_label")
        levelBack.position = CGPoint(x: size.width / 2 - 350, y: size.height - 200)
        levelBack.size = CGSize(width: 170, height: 190)
        levelBack.zPosition = 3
        addChild(levelBack)
        
        let levelLabel = SKLabelNode(text: "\(level)")
        levelLabel.position = CGPoint(x: size.width / 2 - 355, y: size.height - 230)
        levelLabel.fontName = "Philosopher-Bold"
        levelLabel.fontSize = 130
        levelLabel.fontColor = .white
        levelLabel.zPosition = 3
        addChild(levelLabel)
        
        let timeBack = SKSpriteNode(imageNamed: "level_tag")
        timeBack.position = CGPoint(x: size.width / 2 - 330, y: size.height - 200)
        timeBack.size = CGSize(width: 450, height: 180)
        timeBack.anchorPoint = CGPoint(x: 0, y: 0.5)
        timeBack.zPosition = 1
        addChild(timeBack)
        
        timeNode = SKSpriteNode(imageNamed: "time_line")
        timeNode.position = CGPoint(x: size.width / 2 - 280, y: size.height - 200)
        timeNode.size = CGSize(width: 380 * (Double(timeLeft) / Double(allTime)), height: 140)
        timeNode.anchorPoint = CGPoint(x: 0, y: 0.5)
        timeNode.zPosition = 1
        addChild(timeNode)
    }
    
    private func createPlaneHealt() {
        planeHealtHeart = SKSpriteNode(imageNamed: "heart")
        planeHealtHeart.position = CGPoint(x: plane.position.x - 120, y: plane.position.y + 200)
        planeHealtHeart.size = CGSize(width: 150, height: 150)
        planeHealtHeart.zPosition = 2
        addChild(planeHealtHeart)
        
        planeHealtBack = SKSpriteNode(imageNamed: "healt_line_back")
        planeHealtBack.position = CGPoint(x: plane.position.x - 70, y: plane.position.y + 175)
        planeHealtBack.size = CGSize(width: 400, height: 50)
        planeHealtBack.anchorPoint = CGPoint(x: 0, y: 0)
        addChild(planeHealtBack)
        
        planeHealt = SKSpriteNode(imageNamed: "healt_line")
        planeHealt.position = CGPoint(x: plane.position.x - 70, y: plane.position.y + 175)
        planeHealt.size = CGSize(width: planeHealtCount * (400 / 100), height: 50)
        planeHealt.anchorPoint = CGPoint(x: 0, y: 0)
        addChild(planeHealt)
    }
    
    private func createBalances() {
        let balanceBack = SKSpriteNode(imageNamed: "balance_bg")
        balanceBack.position = CGPoint(x: size.width - 400, y: size.height - 200)
        balanceBack.size = CGSize(width: 450, height: 170)
        addChild(balanceBack)
        
        creditsLabel = .init(text: "\(credits)")
        creditsLabel.position = CGPoint(x: size.width - 450, y: size.height - 220)
        creditsLabel.fontName = "Philosopher-Bold"
        creditsLabel.fontSize = 82
        creditsLabel.fontColor = .black
        addChild(creditsLabel)
        
        let energyBack = SKSpriteNode(imageNamed: "energy_background")
        energyBack.position = CGPoint(x: size.width - 900, y: size.height - 200)
        energyBack.size = CGSize(width: 450, height: 170)
        addChild(energyBack)
        
        energyLabel = .init(text: "\(energy)")
        energyLabel.position = CGPoint(x: size.width - 940, y: size.height - 220)
        energyLabel.fontName = "Philosopher-Bold"
        energyLabel.fontSize = 82
        energyLabel.fontColor = .black
        addChild(energyLabel)
    }
    
    private var enemyHealtNodes: [String: SKSpriteNode] = [:]
    private var enemyHealtBacksNodes: [String: SKSpriteNode] = [:]
    private var enemyHealtHeartsNodes: [String: SKSpriteNode] = [:]
    private var enemyHealt: [String: Int] = [:]
    private var enemyTimers: [String: Timer] = [:]
    
    private func spawnEnemy() {
        if !self.isPaused {
            let enemy = getRandomEnemy()
            let initialEnemyPosY = CGFloat.random(in: 550...size.height - 550)
            let nodeEnemy = SKSpriteNode(imageNamed: enemy)
            nodeEnemy.position = CGPoint(x: size.width + 300, y: initialEnemyPosY)
            nodeEnemy.size = CGSize(width: 400, height: 250)
            nodeEnemy.physicsBody = SKPhysicsBody(rectangleOf: nodeEnemy.size)
            nodeEnemy.physicsBody?.isDynamic = false
            nodeEnemy.physicsBody?.affectedByGravity = false
            nodeEnemy.physicsBody?.categoryBitMask = .enemy
            nodeEnemy.physicsBody?.collisionBitMask = .myBullet | .myRocket
            nodeEnemy.physicsBody?.contactTestBitMask = .myBullet | .myRocket
            nodeEnemy.name = "enemy_\(UUID().uuidString)"
            addChild(nodeEnemy)
            
            let enemyPlaneHealtHeart = SKSpriteNode(imageNamed: "heart")
            enemyPlaneHealtHeart.position = CGPoint(x: nodeEnemy.position.x - 120, y: nodeEnemy.position.y + 200)
            enemyPlaneHealtHeart.size = CGSize(width: 150, height: 150)
            enemyPlaneHealtHeart.zPosition = 2
            addChild(enemyPlaneHealtHeart)
            
            let enemyPlaneHealtBack = SKSpriteNode(imageNamed: "healt_line_back")
            enemyPlaneHealtBack.position = CGPoint(x: nodeEnemy.position.x - 70, y: nodeEnemy.position.y + 175)
            enemyPlaneHealtBack.size = CGSize(width: 400, height: 50)
            enemyPlaneHealtBack.anchorPoint = CGPoint(x: 0, y: 0)
            addChild(enemyPlaneHealtBack)
            
            let enemtPlaneHealt = SKSpriteNode(imageNamed: "healt_line")
            enemtPlaneHealt.position = CGPoint(x: nodeEnemy.position.x - 70, y: nodeEnemy.position.y + 175)
            enemtPlaneHealt.size = CGSize(width: 400, height: 50)
            enemtPlaneHealt.anchorPoint = CGPoint(x: 0, y: 0)
            addChild(enemtPlaneHealt)
            
            enemyHealtNodes[nodeEnemy.name!] = enemtPlaneHealt
            enemyHealt[nodeEnemy.name!] = 100
            enemyHealtBacksNodes[nodeEnemy.name!] = enemyPlaneHealtBack
            enemyHealtHeartsNodes[nodeEnemy.name!] = enemyPlaneHealtHeart
            
            let movedPlaneX = CGFloat.random(in: 500...800)
            let actionMoveLeft = SKAction.moveTo(x: size.width - movedPlaneX, duration: 2)
            let actionMoveLeft2 = SKAction.moveTo(x: size.width - (movedPlaneX + 90), duration: 2)
            nodeEnemy.run(actionMoveLeft)
            enemyPlaneHealtHeart.run(actionMoveLeft2)
            enemyPlaneHealtBack.run(actionMoveLeft2)
            enemtPlaneHealt.run(actionMoveLeft2)
            
            if enemy != "enemy_3" {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    let actionMoveUp = SKAction.moveTo(y: self.size.height - 550, duration: 3)
                    let actionMoveDown = SKAction.moveTo(y: 550, duration: 3)
                    let seq = SKAction.sequence([actionMoveUp, actionMoveDown])
                    let repeateForever = SKAction.repeatForever(seq)
                    nodeEnemy.run(repeateForever)
                    
                    
                    let actionMoveUp2 = SKAction.moveTo(y: self.size.height - 400, duration: 3)
                    let actionMoveDown2 = SKAction.moveTo(y: 700, duration: 3)
                    let seq2 = SKAction.sequence([actionMoveUp2, actionMoveDown2])
                    let repeateForever2 = SKAction.repeatForever(seq2)
                    enemyPlaneHealtHeart.run(repeateForever2)
                    enemyPlaneHealtBack.run(repeateForever2)
                    enemtPlaneHealt.run(repeateForever2)
                }
            }
            
            let _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                if let enemyHealtNodes = self.enemyHealtNodes[nodeEnemy.name ?? ""] {
                    self.attackEnemy(enemyPos: nodeEnemy.position)
                } else {
                    timer.invalidate()
                }
            }
        }
    }
    
    func getRandomEnemy() -> String {
        let randomValue = Double(arc4random_uniform(100)) / 100.0
        switch randomValue {
        case 0..<0.50:
            return "enemy_1"
        case 0.50..<0.90:
            return "enemy_2"
        default:
            return "enemy_3"
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let object = atPoint(touch.location(in: self))
            
            if object.name == "menu_btn" {
                showExitDialog()
            }

            if object.name?.contains("arrow") == true {
                object.run(SKAction.group([SKAction.scaleX(to: 0.8, duration: 0.2), SKAction.scaleY(to: 0.8, duration: 0.2)]))
            }
            
            if object.name == "arrow_up" {
                let actionUp = SKAction.move(to: CGPoint(x: plane.position.x, y: plane.position.y + 20), duration: 0.1)
                let actionUp2 = SKAction.move(to: CGPoint(x: planeHealt.position.x, y: planeHealt.position.y + 20), duration: 0.1)
                let actionUp3 = SKAction.move(to: CGPoint(x: planeHealtBack.position.x, y: planeHealtBack.position.y + 20), duration: 0.1)
                let actionUp4 = SKAction.move(to: CGPoint(x: planeHealtHeart.position.x, y: planeHealtHeart.position.y + 20), duration: 0.1)
                plane.run(actionUp)
                planeHealt.run(actionUp2)
                planeHealtBack.run(actionUp3)
                planeHealtHeart.run(actionUp4)
            }
            
            if object.name == "arrow_down" {
                let actionUp = SKAction.move(to: CGPoint(x: plane.position.x, y: plane.position.y - 20), duration: 0.1)
                let actionUp2 = SKAction.move(to: CGPoint(x: planeHealt.position.x, y: planeHealt.position.y - 20), duration: 0.1)
                let actionUp3 = SKAction.move(to: CGPoint(x: planeHealtBack.position.x, y: planeHealtBack.position.y - 20), duration: 0.1)
                let actionUp4 = SKAction.move(to: CGPoint(x: planeHealtHeart.position.x, y: planeHealtHeart.position.y - 20), duration: 0.1)
                plane.run(actionUp)
                planeHealt.run(actionUp2)
                planeHealtBack.run(actionUp3)
                planeHealtHeart.run(actionUp4)
            }
            
            if object.name == "arrow_left" {
                if plane.position.x - 20 > 100 {
                    let actionLeft = SKAction.move(to: CGPoint(x: plane.position.x - 20, y: plane.position.y), duration: 0.1)
                    let actionLeft2 = SKAction.move(to: CGPoint(x: planeHealt.position.x - 20, y: planeHealt.position.y), duration: 0.1)
                    let actionLeft3 = SKAction.move(to: CGPoint(x: planeHealtBack.position.x - 20, y: planeHealtBack.position.y), duration: 0.1)
                    let actionLeft4 = SKAction.move(to: CGPoint(x: planeHealtHeart.position.x - 20, y: planeHealtHeart.position.y), duration: 0.1)
                    plane.run(actionLeft)
                    planeHealt.run(actionLeft2)
                    planeHealtBack.run(actionLeft3)
                    planeHealtHeart.run(actionLeft4)
                }
            }
            
            if object.name == "arrow_right" {
                if plane.position.x + 20 < size.width / 2 - 200 {
                    let actionRight = SKAction.move(to: CGPoint(x: plane.position.x + 20, y: plane.position.y), duration: 0.1)
                    let actionRight2 = SKAction.move(to: CGPoint(x: planeHealt.position.x + 20, y: planeHealt.position.y), duration: 0.1)
                    let actionRight3 = SKAction.move(to: CGPoint(x: planeHealtBack.position.x + 20, y: planeHealtBack.position.y), duration: 0.1)
                    let actionRight4 = SKAction.move(to: CGPoint(x: planeHealtHeart.position.x + 20, y: planeHealtHeart.position.y), duration: 0.1)
                    plane.run(actionRight)
                    planeHealt.run(actionRight2)
                    planeHealtBack.run(actionRight3)
                    planeHealtHeart.run(actionRight4)
                }
            }
            
            if object.name == "arrow_attack" {
                attack()
            }
            
            if object.name == "exit_game_yes" {
                NotificationCenter.default.post(name: Notification.Name("exit_game"), object: nil)
            }
            
            if object.name == "exit_game_no" {
                isPaused = false
                dialogClose.removeFromParent()
            }
            
            if object.name == "exit_game" {
                NotificationCenter.default.post(name: Notification.Name("exit_game"), object: nil)
            }
            
            if object.name == "retry_game" {
                NotificationCenter.default.post(name: Notification.Name("retry_game"), object: nil)
            }
        }
    }
    
    func retryGame() -> AttackGameScene {
        let newScene = AttackGameScene(level: level)
        view?.presentScene(newScene)
        return newScene
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let object = atPoint(touch.location(in: self))
            
            if object.name?.contains("arrow") == true {
                object.run(SKAction.group([SKAction.scaleX(to: 1, duration: 0.2), SKAction.scaleY(to: 1, duration: 0.2)]))
            }
        }
    }
    
    private var dialogClose: SKSpriteNode = SKSpriteNode()
    
    private func showExitDialog() {
        isPaused = true
        let gameBackground = SKSpriteNode(color: .black.withAlphaComponent(0.4), size: size)
        gameBackground.position = CGPoint(x: size.width / 2, y: size.height / 2)
        gameBackground.zPosition = 10
        dialogClose.addChild(gameBackground)
        
        let exitDialog = SKSpriteNode(imageNamed: "exit_game_dialog")
        exitDialog.position = CGPoint(x: size.width / 2, y: size.height / 2)
        exitDialog.size = CGSize(width: 800, height: 900)
        exitDialog.zPosition = 10
        dialogClose.addChild(exitDialog)
        
        let yesBtn = SKSpriteNode(color: .clear, size: CGSize(width: 400, height: 200))
        yesBtn.position = CGPoint(x: size.width / 2 + 230, y: size.height / 2 - 350)
        yesBtn.zPosition = 10
        yesBtn.name = "exit_game_yes"
        dialogClose.addChild(yesBtn)
        
        let noBtn = SKSpriteNode(color: .clear, size: CGSize(width: 400, height: 200))
        noBtn.position = CGPoint(x: size.width / 2 - 230, y: size.height / 2 - 350)
        noBtn.zPosition = 10
        noBtn.name = "exit_game_no"
        dialogClose.addChild(noBtn)
        
        addChild(dialogClose)
    }
    
    private func attack() {
        if !self.isPaused {
            let bulletNode = SKSpriteNode(imageNamed: "bullet")
            bulletNode.position.x = plane.position.x + 250
            bulletNode.position.y = plane.position.y - 25
            bulletNode.size = CGSize(width: 100, height: 20)
            bulletNode.physicsBody = SKPhysicsBody(rectangleOf: bulletNode.size)
            bulletNode.physicsBody?.isDynamic = true
            bulletNode.physicsBody?.affectedByGravity = false
            bulletNode.physicsBody?.categoryBitMask = .myBullet
            bulletNode.physicsBody?.collisionBitMask = .enemy
            bulletNode.physicsBody?.contactTestBitMask = .enemy
            bulletNode.name = "my_bullet"
            addChild(bulletNode)
            
            let moveAction = SKAction.move(to: CGPoint(x: size.width + 100, y: bulletNode.position.y), duration: 1)
            let seq = SKAction.sequence([moveAction, SKAction.removeFromParent()])
            bulletNode.run(seq)
        }
    }
    
    private func attackEnemy(enemyPos: CGPoint) {
        if !self.isPaused {
            let bulletNode = SKSpriteNode(imageNamed: "bullet")
            bulletNode.position.x = enemyPos.x - 250
            bulletNode.position.y = enemyPos.y - 25
            bulletNode.size = CGSize(width: 100, height: 20)
            bulletNode.physicsBody = SKPhysicsBody(rectangleOf: bulletNode.size)
            bulletNode.physicsBody?.isDynamic = true
            bulletNode.physicsBody?.affectedByGravity = false
            bulletNode.physicsBody?.categoryBitMask = .enemyBullet
            bulletNode.physicsBody?.collisionBitMask = .myPlane
            bulletNode.physicsBody?.contactTestBitMask = .myPlane
            bulletNode.name = "enemy_bullet"
            addChild(bulletNode)
            
            let moveAction = SKAction.move(to: CGPoint(x: -100, y: bulletNode.position.y), duration: 1)
            let seq = SKAction.sequence([moveAction, SKAction.removeFromParent()])
            bulletNode.run(seq)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactA = contact.bodyA
        let contactB = contact.bodyB
        
        if contactA.categoryBitMask == .enemyBullet && contactB.categoryBitMask == .myPlane ||
            contactA.categoryBitMask == .myPlane && contactB.categoryBitMask == .enemyBullet {
            let enemyByllet: SKPhysicsBody
            
            if contactA.categoryBitMask == .enemyBullet {
                enemyByllet = contactA
            } else {
                enemyByllet = contactB
            }
            
            if let bulletNode = enemyByllet.node {
                planeHealtCount -= 5
                bulletNode.removeFromParent()
            }
        }
        
        if contactA.categoryBitMask == .myBullet && contactB.categoryBitMask == .enemy ||
            contactA.categoryBitMask == .enemy && contactB.categoryBitMask == .myBullet {
            let myBullet: SKPhysicsBody
            let enemy: SKPhysicsBody
            
            if contactA.categoryBitMask == .myBullet {
                myBullet = contactA
                enemy = contactB
            } else {
                myBullet = contactB
                enemy = contactA
            }
            
            if let enemyNode = enemy.node, let enemyNodeName = enemyNode.name,
               let myBulletNode = myBullet.node {
                let healtOfEnemy = enemyHealt[enemyNodeName]
                let healtNode = enemyHealtNodes[enemyNodeName]
                if let healtOfEnemy = healtOfEnemy,
                    let healtNode = healtNode {
                    enemyHealt[enemyNodeName] = healtOfEnemy - (10 - level)
                    healtNode.size = CGSize(width: (healtOfEnemy - 10) * (400 / 100), height: 50)
                    if healtOfEnemy - (10 - level) <= 0 {
                        let explosion = SKSpriteNode(imageNamed: "explosion")
                        explosion.position = enemyNode.position
                        addChild(explosion)
                        
                        let actionScale = SKAction.scaleX(to: 15, duration: 0.3)
                        let actionScale2 = SKAction.scaleY(to: 15, duration: 0.3)
                        let group = SKAction.group([actionScale, actionScale2])
                        let wait = SKAction.wait(forDuration: 1)
                        let remove = SKAction.removeFromParent()
                        let seq = SKAction.sequence([group, wait, remove])
                        explosion.run(seq)
                        
                        enemyNode.removeFromParent()
                        healtNode.removeFromParent()
                        enemyHealtBacksNodes[enemyNodeName]?.removeFromParent()
                        enemyHealtHeartsNodes[enemyNodeName]?.removeFromParent()
                        
                        enemyHealt[enemyNodeName] = nil
                        enemyHealtHeartsNodes[enemyNodeName] = nil
                        enemyHealtBacksNodes[enemyNodeName] = nil
                        enemyHealtNodes[enemyNodeName] = nil
                    }
                }
                myBulletNode.removeFromParent()
            }
        }
    }
    
    private var winDialog: SKSpriteNode = SKSpriteNode()
    private var loseDialog: SKSpriteNode = SKSpriteNode()
    
    private func showWinDialog() {
        isPaused = true
        credits += 20
        energy += 15
        let gameBackground = SKSpriteNode(color: .black.withAlphaComponent(0.6), size: size)
        gameBackground.position = CGPoint(x: size.width / 2, y: size.height / 2)
        gameBackground.zPosition = 10
        winDialog.addChild(gameBackground)
        
        let pers = SKSpriteNode(imageNamed: "pers_3")
        pers.position = CGPoint(x: 600, y: 700)
        pers.size = CGSize(width: 1300, height: 1500)
        pers.zPosition = 10
        winDialog.addChild(pers)
        
        let image = SKSpriteNode(imageNamed: "win_dialog")
        image.position = CGPoint(x: size.width / 2, y: size.height / 2)
        image.size = CGSize(width: 1200, height: 1300)
        image.zPosition = 10
        winDialog.addChild(image)

        let exitBtn = SKSpriteNode(color: .clear, size: CGSize(width: 400, height: 200))
        exitBtn.position = CGPoint(x: size.width / 2, y: size.height / 2 - 520)
        exitBtn.zPosition = 10
        exitBtn.name = "exit_game"
        winDialog.addChild(exitBtn)
        
        var energyWinLabel = SKLabelNode(text: "+15")
        energyWinLabel.fontName = "Philosopher-Bold"
        energyWinLabel.fontSize = 82
        energyWinLabel.fontColor = .white
        energyWinLabel.zPosition = 10
        energyWinLabel.position = CGPoint(x: size.width / 2 - 130, y: size.height / 2 - 230)
        winDialog.addChild(energyWinLabel)
        
        var creditsWinLabel = SKLabelNode(text: "+20")
        creditsWinLabel.fontName = "Philosopher-Bold"
        creditsWinLabel.fontSize = 82
        creditsWinLabel.fontColor = .white
        creditsWinLabel.zPosition = 10
        creditsWinLabel.position = CGPoint(x: size.width / 2 + 280, y: size.height / 2 - 230)
        winDialog.addChild(creditsWinLabel)
        
        addChild(winDialog)
    }
    
    private func showLoseDialog() { 
        isPaused = true
        let gameBackground = SKSpriteNode(color: .black.withAlphaComponent(0.6), size: size)
        gameBackground.position = CGPoint(x: size.width / 2, y: size.height / 2)
        gameBackground.zPosition = 10
        loseDialog.addChild(gameBackground)
        
        let pers = SKSpriteNode(imageNamed: "pers_2")
        pers.position = CGPoint(x: size.width - 800, y: 700)
        pers.size = CGSize(width: 1300, height: 1500)
        pers.zPosition = 10
        loseDialog.addChild(pers)
        
        let image = SKSpriteNode(imageNamed: "lose_dialog")
        image.position = CGPoint(x: size.width / 2, y: size.height / 2)
        image.size = CGSize(width: 1200, height: 1300)
        image.zPosition = 10
        loseDialog.addChild(image)
        
        let retry = SKSpriteNode(color: .clear, size: CGSize(width: 400, height: 200))
        retry.position = CGPoint(x: size.width / 2 + 300, y: size.height / 2 - 520)
        retry.zPosition = 10
        retry.name = "retry_game"
        loseDialog.addChild(retry)

        let exitBtn = SKSpriteNode(color: .clear, size: CGSize(width: 400, height: 200))
        exitBtn.position = CGPoint(x: size.width / 2 - 270, y: size.height / 2 - 520)
        exitBtn.zPosition = 10
        exitBtn.name = "exit_game"
        loseDialog.addChild(exitBtn)
        
        addChild(loseDialog)
    }
    
}

#Preview {
    VStack {
        SpriteView(scene: AttackGameScene(level: 1))
            .ignoresSafeArea()
    }
}
