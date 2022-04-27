//
//  GameScene.swift
//  maze-man
//
//  Created by Cony Lee on 4/10/22.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // GAME SETUP PARAMETERS START //
    
    // World Setup
    let numWater: Int = 2
    let numCobblestone: Int = 15
    let cobblestoneAddTime: Int = 1 // Amount of time before new cobblestone tile is added
    
    // Player Setup
    let numStartingHealth: Int = 3
    let numStartingEnergy: Int = 100
    let maxEnergy: Int = 100 // Maximum possible energy storage
    let numStartingRocks: Int = 10
    let maxRocks: Int = 20 // Maximum possible rock storage
    
    // Difficulty Adjust
    let healthDecayRate: Int = 1
    let energyDecayRate: Int = 1
    let invincibilityTime: Int = 5 // Amount of time before taking damage again
    
    // Resources Adjust
    let starReward: Int = 1 // Amount of score given to player from stars
    let foodRespawnTime: Int = 10 // Amount of time before new food spawns after being eaten by enemies
    let foodReward: Int = 50 // Amount of energy given to player from food
    let rockRespawnTime: Int = 30 // Amount of time before new rocks are given to the player
    let rockReward: Int = 1 // Amount of rocks given to player per cycle
    
    // Enemy Adjust
    let frogDamage: Int = 60
    let spiderDamage: Int = 80
    let snakeDamage: Int = 100
    let fireDamage: Int = 100
    
    // GAME SETUP PARAMETERS END //
    
    
    var waterTiles = [CGPoint]()
    var emptyTiles = [CGPoint]()
    var emptyPlayerTiles = [CGPoint]()
    var emptyItemTiles = [CGPoint]()
    
    var player: SKSpriteNode = SKSpriteNode()
    var lightSource: SKLightNode = SKLightNode()
    
    var welcomeLabel: SKLabelNode?
    var statusLabel = SKLabelNode()
    var rockLabel = SKLabelNode()
    var scoreLabel = SKLabelNode()
    //var rock = SKSpriteNode()
    
    var score: Int = 0
    var rocks: Int = 0 {
        didSet {
            if rocks > self.maxRocks {
                rocks = self.maxRocks
            } else if rocks < 0 {
                rocks = 0
            }
        }
    }
    
    var healthBar = SKSpriteNode()
    var energyBar = SKSpriteNode()
    var health: Int = 0
    var energy: Int = 0
    
    var started: Bool = false
    
    override func didMove(to view: SKView) {
        self.welcomeLabel = self.childNode(withName: "//welcomeLabel") as? SKLabelNode
        if let welcomeLabel = self.welcomeLabel {
            welcomeLabel.alpha = 0.0
            welcomeLabel.run(SKAction.fadeIn(withDuration: 2.0))
            
            let zoomIn = SKAction.scale(to: 1.02, duration: 2)
            let zoomOut = SKAction.scale(to: 0.98, duration: 2)
            let zoomSequence = SKAction.sequence([zoomIn, zoomOut])
            
            welcomeLabel.run(SKAction.repeatForever(zoomSequence))
        }
        
        self.statusLabel = self.childNode(withName: "//statusLabel") as! SKLabelNode
        statusLabel.alpha = 1.0
        statusLabel.text = ""
        
        self.rockLabel = self.childNode(withName: "//rockLabel") as! SKLabelNode
        rockLabel.alpha = 1.0
        rockLabel.text = "0"
        
        self.scoreLabel = self.childNode(withName: "//scoreLabel") as! SKLabelNode
        scoreLabel.alpha = 1.0
        scoreLabel.text = "0"
        
        self.player = self.childNode(withName: "//player") as! SKSpriteNode
        player.zPosition = 10
        
        self.lightSource = player.childNode(withName: "lightSource") as! SKLightNode
        lightSource.falloff = 15
        
        self.healthBar = self.childNode(withName: "//healthBar") as! SKSpriteNode
        healthBar.xScale = 0
        
        self.energyBar = self.childNode(withName: "//energyBar") as! SKSpriteNode
        energyBar.xScale = 0
        
        if let map: SKTileMapNode = self.childNode(withName: "tileMap") as? SKTileMapNode {
            initMap(map: map)
        }
        
        spawnMob(id: 0)
        spawnMob(id: 1)
        spawnMob(id: 2)
        spawnMob(id: 3)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipeRight(sender:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipeUp(sender:)))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipeLeft(sender:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipeDown(sender:)))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    func touchUp(atPoint pos: CGPoint) {
        //print(pos)
        if started && rocks > 0 {
            rocks -= 1
            
            let rock = SKSpriteNode(imageNamed: "Rock")
            rock.size = CGSize(width: 32, height: 32)
            rock.position = player.position
            rock.name = "rock"
            
            self.addChild(rock)
            
            var dx = CGFloat(pos.x - player.position.x)
            var dy = CGFloat(pos.y - player.position.y)
            
            let magnitude = sqrt(dx * dx + dy * dy)
            
            dx /= magnitude
            dy /= magnitude
            
            
            let rockMove = SKAction.move(by: CGVector(dx: 1024 * dx, dy: 1024 * dy), duration: 1)
            rock.run(rockMove, completion: {
                rock.removeFromParent()
            })
        }
    }
    
    @objc func swipeRight(sender: UISwipeGestureRecognizer) {
        playerMove(direction: 0)
        //direction = 0
    }
    
    @objc func swipeUp(sender: UISwipeGestureRecognizer) {
        playerMove(direction: 1)
        //direction = 1
    }

    @objc func swipeLeft(sender: UISwipeGestureRecognizer) {
        playerMove(direction: 2)
        //direction = 2
    }
    
    @objc func swipeDown(sender: UISwipeGestureRecognizer) {
        playerMove(direction: 3)
        //direction = 3
    }

    var newDirection = 0
    var currentDirection = 0
    var finished = true
    
    func playerMove(direction: Int) {
        if let welcomeLabel = self.welcomeLabel {
            fadeAndRemove(node: welcomeLabel)
        }
        
        if started == false {
            statusLabel.text = "Beware!"
            
            rocks = numStartingRocks
            rockLabel.text = "\(rocks)"
            score = 0
            scoreLabel.text = "\(score)"
            
            health = numStartingHealth
            energy = numStartingEnergy
            
            lightSource.falloff = 5
            
            if let fireParticle = SKEmitterNode(fileNamed: "FireParticle") {
                fireParticle.position.x = 20
                self.childNode(withName: "tileMap")?.childNode(withName: "player")?.addChild(fireParticle)
            }
            
            started = true
            
            spawnItems()
            
            startMovement(id: 0)
            startMovement(id: 1)
            startMovement(id: 2)
            startMovement(id: 3)
            
            
            let cobblestoneWait = SKAction.wait(forDuration: TimeInterval(cobblestoneAddTime))
            let addTile = SKAction.run {
                self.addTile()
            }
            let tileSequence = SKAction.sequence([cobblestoneWait, addTile])
            
            self.run(SKAction.repeat(tileSequence, count: numCobblestone))
            
            
            let rockWait = SKAction.wait(forDuration: TimeInterval(rockRespawnTime))
            let addRock = SKAction.run {
                self.rocks += 1
            }
            let rockSequence = SKAction.sequence([rockWait, addRock])
            
            self.run(SKAction.repeatForever(rockSequence))
            
            
            startEnergyDecay()
        }
        
        let x = player.position.x
        let y = player.position.y
        let curPos = CGPoint(x: x, y: y)
        
        //print(curPos)

//        var curPos = CGPoint(x: x.roundedAwayFromZero(toMultipleOf: 64), y: y.roundedAwayFromZero(toMultipleOf: 64))
//
//        if curPos.x.sign == .minus {
//            curPos.x += 32
//        } else {
//            curPos.x -= 32
//        }
//        if curPos.y.sign == .minus {
//            curPos.y += 32
//        } else {
//            curPos.y -= 32
//        }
        
        newDirection = direction
        
        if finished == true && !player.hasActions() {
            finished = false
            currentDirection = direction
            
            let iterations = generatePlayerPosition(curPos: curPos, tileSize: CGSize(width: 64, height: 64), direction: direction)
            
            let playerAnimation = SKAction(named: "PlayerMove")!
            
            player.zRotation = CGFloat(currentDirection * 90) * .pi / 180
            player.run(SKAction.repeat(playerAnimation, count: iterations.count))
            
            for (index, iteration) in iterations.enumerated() {
                if finished {
                    emptyTiles.append(contentsOf: iterations)
                    findRemoveElement(element: player.position)
                    
                    break
                }
                
                let moveAction = SKAction.move(to: iteration, duration: 0.5)

                player.run(SKAction.sequence([SKAction.wait(forDuration: 0.5 * Double(index)), moveAction]), completion: { [self] in
                    if currentDirection != newDirection {
                        finished = true
                        player.removeAllActions()
                        
                        emptyTiles.append(contentsOf: iterations)
                        findRemoveElement(element: player.position)
                        
                        playerMove(direction: newDirection)
                    }
                    
                    if index == iterations.endIndex - 1 {
                        finished = true
                    }
                })
            }
        }
    }
    
    func generatePlayerPosition(curPos: CGPoint, tileSize: CGSize, direction: Int) -> [CGPoint] {
        var iterations: [CGPoint] = [curPos]
        //print(emptyTiles)
        
        switch direction {
        case 0:
            while true {
                let newRightPoint = CGPoint(x: curPos.x + (tileSize.width * CGFloat(iterations.count)), y: curPos.y)
                //print(newRightPoint)
                if emptyPlayerTiles.contains(newRightPoint) {
                    iterations.append(newRightPoint)
                } else {
                    break
                }
            }
        case 1:
            while true {
                let newUpPoint = CGPoint(x: curPos.x, y: curPos.y + (tileSize.height * CGFloat(iterations.count)))
                //print(newUpPoint)
                if emptyPlayerTiles.contains(newUpPoint) {
                    iterations.append(newUpPoint)
                } else {
                    break
                }
            }
        case 2:
            while true {
                let newLeftPoint = CGPoint(x: curPos.x - (tileSize.width * CGFloat(iterations.count)), y: curPos.y)
                //print(newLeftPoint)
                if emptyPlayerTiles.contains(newLeftPoint) {
                    iterations.append(newLeftPoint)
                } else {
                    break
                }
            }
        case 3:
            while true {
                let newDownPoint = CGPoint(x: curPos.x, y: curPos.y - (tileSize.height * CGFloat(iterations.count)))
                //print(newDownPoint)
                if emptyPlayerTiles.contains(newDownPoint) {
                    iterations.append(newDownPoint)
                } else {
                    break
                }
            }
        default:
            break
        }
        
        for iteration in iterations {
            findRemoveElement(element: iteration)
        }
        
        return iterations
    }
    
    func initMap(map: SKTileMapNode) {
        let tileSize = map.tileSize
        let tileMapCenterX = CGFloat(map.numberOfColumns) / 2.0 * tileSize.width
        let tileMapCenterY = CGFloat(map.numberOfRows) / 2.0 * tileSize.height
        
        for col in 0..<map.numberOfColumns { //find empty tiles
            for row in 0..<map.numberOfRows {
                if let _ = map.tileDefinition(atColumn: col, row: row) {
//                    let tileNode = SKNode()
//                    let x = CGFloat(col) * tileSize.width - tileMapCenterX + (tileSize.width / 2)
//                    let y = CGFloat(row) * tileSize.height - tileMapCenterY + (tileSize.height / 2)
                    
//                    tileNode.position = CGPoint(x: x, y: y)
//                    tileNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 64, height: 64))
//                    tileNode.physicsBody?.affectedByGravity = false
//                    tileNode.physicsBody?.pinned = true
//                    tileNode.physicsBody?.allowsRotation = false
//                    tileNode.physicsBody?.usesPreciseCollisionDetection = true
                    
//                    map.addChild(tileNode)
                } else {
                    let x = CGFloat(col) * tileSize.width - tileMapCenterX + (tileSize.width / 2)
                    let y = CGFloat(row) * tileSize.height - tileMapCenterY + (tileSize.height / 2)
                    
                    let newPoint: CGPoint = self.convert(CGPoint(x: x, y: y), from: map)
                    
                    emptyTiles.append(snapCGPoint(p: newPoint))
                    emptyPlayerTiles.append(snapCGPoint(p: newPoint))
                    emptyItemTiles.append(snapCGPoint(p: newPoint))
                }
            }
        }
        
        let uniqueRandomNumbers = Int.getUniqueRandomNumbers(min: 1, max: map.numberOfColumns - 1, count: 2)
        
        for index in 0..<numWater { //generate water
            let lastRow = 0
            let randomCol = uniqueRandomNumbers[index]
            
            let x = CGFloat(randomCol) * tileSize.width - tileMapCenterX + (tileSize.width / 2)
            let y = CGFloat(lastRow) * tileSize.height - tileMapCenterY + (tileSize.height / 2)
            
            let newPoint: CGPoint = self.convert(CGPoint(x: x, y: y), from: map)
            
            let newTile = SKSpriteNode(imageNamed: "Water")
            newTile.position = snapCGPoint(p: newPoint)
            newTile.size.width = 64
            newTile.size.height = 64
            newTile.lightingBitMask = 1
            newTile.name = "water\(index)"
            
            //map.setTileGroup(SKTileGroup(), forColumn: randomCol, row: lastRow)
            
            map.addChild(newTile)
            
            emptyPlayerTiles.append(snapCGPoint(p: newPoint))
            waterTiles.append(snapCGPoint(p: newPoint))
        }
    }
    
    func addTile() {
        var randomPoint = emptyTiles.randomElement()!
        
        while randomPoint == food.position || randomPoint == star.position {
            randomPoint = emptyTiles.randomElement()!
        }
        
        let newPoint = findRemoveElement(element: randomPoint)
        
        if let index = emptyPlayerTiles.firstIndex(of: newPoint) {
            emptyPlayerTiles.remove(at: index)
        }
        
        if let index = emptyItemTiles.firstIndex(of: newPoint) {
            emptyItemTiles.remove(at: index)
        }
        
        let newTile = SKSpriteNode(imageNamed: "Cobblestone")
        newTile.position = newPoint
        newTile.size.width = 80
        newTile.size.height = 80
        newTile.lightingBitMask = 1
        newTile.alpha = 0
        
//        newTile.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 64, height: 64))
//        newTile.physicsBody?.affectedByGravity = false
//        newTile.physicsBody?.pinned = true
//        newTile.physicsBody?.allowsRotation = false
//        newTile.physicsBody?.usesPreciseCollisionDetection = true
        
        self.childNode(withName: "tileMap")?.addChild(newTile)
        
        newTile.run(SKAction.fadeAlpha(to: 1, duration: 0.2))
        newTile.run(SKAction.scale(to: CGSize(width: 64, height: 64), duration: 0.5))
    }
    
    func snapCGPoint(p: CGPoint) -> CGPoint {
        return CGPoint(x: round(p.x), y: round(p.y))
    }
    
    @discardableResult
    func findRemoveElement(element: CGPoint) -> CGPoint {
        if let index = emptyTiles.firstIndex(of: snapCGPoint(p: element)) {
            return emptyTiles.remove(at: index)
        }
        
        return CGPoint()
    }
    
    //    func touchDown(atPoint pos : CGPoint) {
    //        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
    //            n.position = pos
    //            n.strokeColor = SKColor.green
    //            self.addChild(n)
    //        }
    //    }
    //
    //    func touchMoved(toPoint pos : CGPoint) {
    //        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
    //            n.position = pos
    //            n.strokeColor = SKColor.blue
    //            self.addChild(n)
    //        }
    //    }
    //

    
    func fadeAndRemove(node: SKNode) {
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let remove        = SKAction.run({ node.removeFromParent }())
        let sequence      = SKAction.sequence([fadeOutAction, remove])
        
        node.run(sequence)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    func startEnergyDecay() {
        let delay = SKAction.wait(forDuration: 1)
        let energyDecay = SKAction.run { [self] in
            changeEnergy(by: -energyDecayRate)
        }
        let energySequence = SKAction.sequence([delay, energyDecay])
        
        self.run(SKAction.repeatForever(energySequence))
    }
    
    var food = SKSpriteNode(imageNamed: "Food")
    let star = SKSpriteNode(imageNamed: "Star")
    
    func spawnItems() {
        let foodPosition = emptyItemTiles.remove(at: Int.random(in: 0..<emptyItemTiles.count))
        let starPosition = emptyItemTiles.remove(at: Int.random(in: 0..<emptyItemTiles.count))
        
        food.position = foodPosition
        food.size = CGSize(width: 40, height: 40)
        food.lightingBitMask = 1
        
        star.position = starPosition
        star.size = CGSize(width: 40, height: 40)
        star.lightingBitMask = 1
        
        self.addChild(food)
        self.addChild(star)
    }
    

    var frog = SKSpriteNode(imageNamed: "Frog")
    var spider = SKSpriteNode(imageNamed: "Spider")
    var snake = SKSpriteNode(imageNamed: "Snake")
    var ghost = SKSpriteNode(imageNamed: "Ghost")
    var fire = SKEmitterNode()
    
    var enemies: [SKSpriteNode] = []
    var enemyAliases: [String] = []
    
    func spawnMob(id: Int) {
        let map = self.childNode(withName: "tileMap") as! SKTileMapNode
        
        let tileSize = map.tileSize
        let tileMapCenterX = CGFloat(map.numberOfColumns) / 2.0 * tileSize.width
        let tileMapCenterY = CGFloat(map.numberOfRows) / 2.0 * tileSize.height
        
        switch id {
        case 0:
            frog = SKSpriteNode(imageNamed: "Frog")
            
            let randomWaterIndex = Int.random(in: 0..<numWater)
            let waterNode = self.childNode(withName: "tileMap")?.childNode(withName: "water\(randomWaterIndex)")
            
            frog.position = waterNode!.position
            frog.size.width = 60
            frog.size.height = 60
            frog.lightingBitMask = 1
            frog.zPosition = 5
            frog.name = "0"
            
            self.childNode(withName: "tileMap")!.addChild(frog)
            
        case 1:
            spider = SKSpriteNode(imageNamed: "Spider")
            
            let randomRow = Int.random(in: 1..<map.numberOfRows - 2)
            
            let x = CGFloat(map.numberOfColumns - 1) * tileSize.width - tileMapCenterX + (tileSize.width / 2)
            let y = CGFloat(randomRow) * tileSize.height - tileMapCenterY + (tileSize.height / 2)
            
            let newPoint: CGPoint = self.convert(CGPoint(x: x, y: y), from: map)
            
            spider.position = snapCGPoint(p: newPoint)
            spider.size.width = 60
            spider.size.height = 60
            spider.lightingBitMask = 1
            spider.zPosition = 5
            spider.name = "1"
            
            self.childNode(withName: "tileMap")!.addChild(spider)
            
        case 2:
            snake = SKSpriteNode(imageNamed: "Snake")
            
            let x = CGFloat(0) * tileSize.width - tileMapCenterX + (tileSize.width / 2)
            let y = CGFloat(map.numberOfRows - 3) * tileSize.height - tileMapCenterY + (tileSize.height / 2)
            
            let newPoint = self.convert(CGPoint(x: x, y: y), from: map)
            
            snake.position = snapCGPoint(p: newPoint)
            snake.size.width = 60
            snake.size.height = 60
            snake.lightingBitMask = 1
            snake.zPosition = 5
            snake.name = "2"
            
            self.childNode(withName: "tileMap")!.addChild(snake)
            
        case 3:
            ghost = SKSpriteNode(imageNamed: "Ghost")
            
            let x = CGFloat(0) * tileSize.width - tileMapCenterX + (tileSize.width / 2)
            let y = CGFloat(map.numberOfRows - 2) * tileSize.height - tileMapCenterY + (tileSize.height / 2)
            
            let newPoint = self.convert(CGPoint(x: x, y: y), from: map)
            
            ghost.position = snapCGPoint(p: newPoint)
            ghost.size.width = 60
            ghost.size.height = 60
            ghost.lightingBitMask = 1
            ghost.zPosition = 5
            ghost.name = "3"
            
            self.childNode(withName: "tileMap")!.addChild(ghost)
        default:
            break
        }
        
        enemies = [frog, spider, snake]
        enemyAliases = ["Frog", "Spider", "Snake", "Ghost Orb"]
    }
    
    func startMovement(id: Int) {
        let map = self.childNode(withName: "tileMap") as! SKTileMapNode
        let tileSize = map.tileSize
        
        let enemyWait = SKAction.wait(forDuration: 2, withRange: 2)
        
        switch id {
        case 0:
            let moveUp = SKAction.moveBy(x: 0, y: tileSize.height * 9, duration: 3)
            let flipUp = SKAction.scaleY(to: 1, duration: 0)
            let moveDown = SKAction.moveBy(x: 0, y: -tileSize.height * 9, duration: 3)
            let flipDown = SKAction.scaleY(to: -1, duration: 0)
            let upDownSequence = SKAction.sequence([flipUp, moveUp, flipDown, moveDown, enemyWait])
            
            frog.run(SKAction.repeatForever(upDownSequence))
            
        case 1:
            let flipLeft = SKAction.scaleX(to: -1, duration: 0)
            let moveLeft = SKAction.moveBy(x: -tileSize.width * 15, y: 0, duration: 5)
            let flipRight = SKAction.scaleX(to: 1, duration: 0)
            let moveRight = SKAction.moveBy(x: tileSize.width * 15, y: 0, duration: 5)
            let leftRightSequence = SKAction.sequence([flipLeft, moveLeft, flipRight, moveRight, enemyWait])
            
            spider.run(SKAction.repeatForever(leftRightSequence))
            
        case 2:
            var randomDirection = 0
            var newPoint = NewPoint()
            var locked = false
            
//            snake.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 64, height: 64))
//            snake.physicsBody?.affectedByGravity = false
//            snake.physicsBody?.allowsRotation = false
//            snake.physicsBody?.usesPreciseCollisionDetection = true
            
            let determinePosition = SKAction.run { [self] in
                if !locked {
                    //print("Initial: \(snake.position)")
                    let x = snake.position.x
                    let y = snake.position.y
                    
                    let curPos = CGPoint(x: x.rounded(.towardZero).roundedUp(toMultipleOf: 32), y: y.rounded(.towardZero).roundedUp(toMultipleOf: 32))
                    //print("Rounded: \(curPos)")
                    randomDirection = generateNewDirection(curPos: curPos, tileSize: tileSize).randomElement() ?? 0
                    newPoint = generateNewPoint(curPos: curPos, tileSize: tileSize, direction: randomDirection)
                    
                    snake.zRotation = CGFloat(randomDirection * 90) * .pi / 180
                    
                    locked = true
                    snake.run(SKAction.move(to: newPoint.point, duration: newPoint.duration / 2), completion: ({ [self] in
                        for iteration in newPoint.iterations.dropLast() {
                            emptyTiles.append(iteration)
                        }
                        
                        locked = false
                    }))
                }
            }
            
            let snakeWait = SKAction.wait(forDuration: 1)
            let moveToSequence = SKAction.sequence([determinePosition, snakeWait])
            
            snake.run(SKAction.repeatForever(moveToSequence))
            
        case 3:
            let flipRight = SKAction.scaleX(to: 1, duration: 0)
            let moveRight = SKAction.moveBy(x: tileSize.width * 15, y: 0, duration: 10)
            let flipLeft = SKAction.scaleX(to: -1, duration: 0)
            let moveLeft = SKAction.moveBy(x: -tileSize.width * 15, y: 0, duration: 10)
            let leftRightSequence = SKAction.sequence([flipRight, moveRight, flipLeft, moveLeft])
            
            ghost.run(SKAction.repeatForever(leftRightSequence), withKey: "ghostMove")
            
            let ghostLight = SKLightNode()
            ghostLight.lightColor = .white
            ghostLight.falloff = 5
            ghostLight.categoryBitMask = 1
            
            ghost.addChild(ghostLight)
            
            let ghostWait = SKAction.wait(forDuration: Double.random(in: 5..<10))
            let attack = SKAction.run { [self] in
                let fireLight = SKLightNode()
                fireLight.lightColor = .blue
                fireLight.falloff = 2
                fireLight.categoryBitMask = 1
                
                fire = SKEmitterNode(fileNamed: "GhostAttack")!
                fire.position.x = ghost.position.x
                fire.position.y = ghost.position.y - 10
                fire.xScale = 0.3
                fire.yScale = 0.3
                fire.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 32, height: 32))
                fire.physicsBody?.affectedByGravity = true
                
                fire.addChild(fireLight)
                self.addChild(fire)
                
                
            }
            let ghostAttackSequence = SKAction.sequence([ghostWait, attack])
            ghost.run(SKAction.repeatForever(ghostAttackSequence))
            
        default:
            break
        }
    }
    
    func generateNewDirection(curPos: CGPoint, tileSize: CGSize) -> [Int] {
        var possibleDirections: [Int] = []
        
        let newRightPoint = CGPoint(x: curPos.x + tileSize.width, y: curPos.y)
        if emptyPlayerTiles.contains(newRightPoint) {
            possibleDirections.append(0)
        }
        
        let newUpPoint = CGPoint(x: curPos.x, y: curPos.y + tileSize.height)
        if emptyPlayerTiles.contains(newUpPoint) {
            possibleDirections.append(1)
        }
        
        let newLeftPoint = CGPoint(x: curPos.x - tileSize.width, y: curPos.y)
        if emptyPlayerTiles.contains(newLeftPoint) {
            possibleDirections.append(2)
        }
        
        let newDownPoint = CGPoint(x: curPos.x, y: curPos.y - tileSize.height)
        if emptyPlayerTiles.contains(newDownPoint) {
            possibleDirections.append(3)
        }
        
        //print("Possible directions: \(possibleDirections)")
        return possibleDirections
    }
    
    func generateNewPoint(curPos: CGPoint, tileSize: CGSize, direction: Int) -> NewPoint {
        var iterations: [CGPoint] = [curPos]
        //print(emptyTiles)
        
        switch direction {
        case 0:
            while true {
                let newRightPoint = CGPoint(x: curPos.x + (tileSize.width * CGFloat(iterations.count)), y: curPos.y)
                //print(newRightPoint)
                if emptyPlayerTiles.contains(newRightPoint) {
                    iterations.append(newRightPoint)
                } else {
                    break
                }
            }
        case 1:
            while true {
                let newUpPoint = CGPoint(x: curPos.x, y: curPos.y + (tileSize.height * CGFloat(iterations.count)))
                //print(newUpPoint)
                if emptyPlayerTiles.contains(newUpPoint) {
                    iterations.append(newUpPoint)
                } else {
                    break
                }
            }
        case 2:
            while true {
                let newLeftPoint = CGPoint(x: curPos.x - (tileSize.width * CGFloat(iterations.count)), y: curPos.y)
                //print(newLeftPoint)
                if emptyPlayerTiles.contains(newLeftPoint) {
                    iterations.append(newLeftPoint)
                } else {
                    break
                }
            }
        case 3:
            while true {
                let newDownPoint = CGPoint(x: curPos.x, y: curPos.y - (tileSize.height * CGFloat(iterations.count)))
                //print(newDownPoint)
                if emptyPlayerTiles.contains(newDownPoint) {
                    iterations.append(newDownPoint)
                } else {
                    break
                }
            }
        default:
            break
        }
        
        for iteration in iterations {
            findRemoveElement(element: iteration)
        }
        //print("All iterations: \(iterations)")
        
        return NewPoint(point: iterations.last ?? curPos, iterations: iterations, duration: iterations.count)
    }
    
    var criticalAnimRunning = false
    var drownLock = false
    var foodLock = false
    var mobLock = [false, false, false, false]
    
    var deathCode = 0
    var numConsumed = 0
    var numKilled = 0
    var numCollected = 0
    var timesHit = 0
    
    override func update(_ currentTime: TimeInterval) {
        if (started && !drownLock) {
            if health < 0 {
                //print("GAME OVER")
                if numConsumed >= 10 {
                    deathCode = 100
                } else if numKilled >= 10 {
                    deathCode = 101
                } else if numCollected >= 10 {
                    deathCode = 102
                } else if numKilled == 0 && timesHit == 0 {
                    deathCode = 103
                } else if numConsumed == 7 && numCollected == 7 && rocks == 7 {
                    deathCode = 104
                }
                
                endGame(deathCode: deathCode)
            }
            
            if lightSource.falloff > 1 {
                lightSource.falloff -= 0.1
            } else {
                lightSource.falloff += CGFloat(Float.random(in: 0.0..<0.1))
            }
            
            if waterTiles.contains(player.position) && !drownLock {
                drownLock = true
                
                for recognizer in self.view?.gestureRecognizers ?? [] {
                    self.view?.removeGestureRecognizer(recognizer)
                }
                self.isUserInteractionEnabled = false
                
                let rotate = SKAction.rotate(byAngle: 5, duration: 0.5)
                let drown = SKAction.scale(to: 0, duration: 0.5)
                let alpha = SKAction.fadeAlpha(to: 0.1, duration: 0.5)
                
                player.run(SKAction.repeat(rotate, count: 1), completion: {
                    self.health = 0
                    self.energy = 0
                    
                    self.endGame(deathCode: 1)
                })
                
                player.run(SKAction.repeat(drown, count: 1))
                player.run(SKAction.repeat(alpha, count: 1))
            }
            
            if energy <= numStartingEnergy / 4 && !criticalAnimRunning {
                self.criticalAnimRunning = true
                
                let fadeOut = SKAction.fadeAlpha(to: 0.5, duration: 0.2)
                let fadeIn = SKAction.fadeAlpha(to: 1, duration: 0.2)
                let fadeInOut = SKAction.sequence([fadeOut, fadeIn])
                
                energyBar.run(fadeInOut, completion: { self.criticalAnimRunning = false })
            }
            
            for child in self.childNode(withName: "tileMap")!.children {
                if food.intersects(child) && !foodLock {
                    if child == player {
                        changeEnergy(by: foodReward)
                        statusLabel.text = "You feel energized."
                        numConsumed += 1
                        
                        food.position = emptyItemTiles.remove(at: Int.random(in: 0..<emptyItemTiles.count))
                    } else if enemies.contains(child as! SKSpriteNode) {
                        foodLock = true
                        statusLabel.text = "Enemy \(enemyAliases[Int(child.name!)!]) found food to eat."
                        
                        let newFood = food.copy() as! SKSpriteNode
                        
                        food.removeFromParent()
                        emptyItemTiles.append(newFood.position)
                        
                        newFood.position = emptyItemTiles.remove(at: Int.random(in: 0..<emptyItemTiles.count))
                        
                        let wait = SKAction.wait(forDuration: TimeInterval(foodRespawnTime))
                        let addFood = SKAction.run {
                            self.food = newFood
                            self.addChild(self.food)
                        }
                                            
                        self.run(SKAction.sequence([wait, addFood]), completion: {
                            self.foodLock = false
                        })
                    } else if food.position == child.position {
                        food.position = emptyItemTiles.remove(at: Int.random(in: 0..<emptyItemTiles.count))
                    }
                }
                
                if star.intersects(child) {
                    if child == player {
                        score += starReward
                        statusLabel.text = "Your pockets feel a bit heavier."
                        numCollected += 1
                        
                        let starPos = star.position
                        
                        star.position = emptyItemTiles.remove(at: Int.random(in: 0..<emptyItemTiles.count))
                        
                        emptyItemTiles.append(starPos)
                    }
                }
            }
            
            if !isInvincible {
                if player.intersects(frog) {
                    changeEnergy(by: -frogDamage)
                    timesHit += 1
                    
                    if energy <= 0 && health <= 0 {
                        deathCode = 2
                    }
                    
                    statusLabel.text = "Frog -> You | \(frogDamage) damage."
                    toggleInvincibility()
                } else if player.intersects(spider) {
                    changeEnergy(by: -spiderDamage)
                    timesHit += 1
                    
                    if energy <= 0 && health <= 0 {
                        deathCode = 3
                    }
                    
                    statusLabel.text = "Spider -> You | \(spiderDamage) damage."
                    toggleInvincibility()
                } else if player.intersects(snake) {
                    changeEnergy(by: -snakeDamage)
                    timesHit += 1
                    
                    if energy <= 0 && health <= 0 {
                        deathCode = 4
                    }
                    
                    statusLabel.text = "Snake -> You | \(snakeDamage) damage."
                    toggleInvincibility()
                } else if player.intersects(fire) {
                    changeEnergy(by: -fireDamage)
                    timesHit += 1
                    
                    if energy <= 0 && health <= 0 {
                        deathCode = 5
                    }
                    
                    statusLabel.text = "Ghost -> You | \(fireDamage) damage."
                    toggleInvincibility()
                }
            }
            
            for (index, enemy) in enemies.enumerated() {
                if let rock = self.childNode(withName: "rock") as? SKSpriteNode {
                    if enemy.intersects(rock) && !mobLock[index] {
                        mobLock[index] = true
                        statusLabel.text = "Enemy \(enemyAliases[index]) was killed."
                        numKilled += 1
                        
                        rock.removeFromParent()
                        enemy.removeFromParent()
                        
                        let wait = SKAction.wait(forDuration: Double.random(in: 1..<5))
                        let addEnemy = SKAction.run { [self] in
                            spawnMob(id: index)
                            startMovement(id: index)
                        }
                                            
                        self.run(SKAction.sequence([wait, addEnemy]), completion: {
                            self.mobLock[index] = false
                        })
                    }
                }
            }
            
            if let rock = self.childNode(withName: "rock") as? SKSpriteNode {
                if fire.intersects(rock) && !mobLock[3] {
                    mobLock[3] = true
                    statusLabel.text = "Enemy \(enemyAliases[3]) was extinguished."
                    numKilled += 1
                    
                    rock.removeFromParent()
                    fire.removeFromParent()
                    
                    mobLock[3] = false
                }
            }
            
            healthBar.run(SKAction.scaleX(to: CGFloat(health) / CGFloat(numStartingHealth), duration: 0.5))
            energyBar.run(SKAction.scaleX(to: CGFloat(energy) / CGFloat(maxEnergy), duration: 0.5))
            scoreLabel.text = "\(score)"
            rockLabel.text = "\(rocks)"
        }
    }
    
    var isInvincible = false
    
    func toggleInvincibility() {
        isInvincible = true
        
        if let damageIndicator = self.childNode(withName: "damageIndicator") as? SKSpriteNode {
            damageIndicator.color = .systemRed
            damageIndicator.alpha = 0.2
            
            damageIndicator.run(SKAction.wait(forDuration: 0.1), completion: {
                if self.invincibilityTime > 1 {
                    damageIndicator.alpha = 0
                    
                    damageIndicator.color = .white
                    let fadeIn = SKAction.fadeAlpha(to: 0.1, duration: 0.5)
                    let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.5)
                    let sequence = SKAction.sequence([fadeIn, fadeOut])
                    
                    damageIndicator.run(SKAction.repeat(sequence, count: self.invincibilityTime - 1))
                }
            })
        }
        
        let wait = SKAction.wait(forDuration: TimeInterval(invincibilityTime))
        
        self.run(wait, completion: {
            self.isInvincible = false
        })
    }
    
    func changeEnergy(by amount: Int) {
       if amount.signum() == 1 {
           energy += amount
           
           if energy > maxEnergy {
               energy = maxEnergy
           }
       } else {
           let difference = energy + amount
           
           if difference.signum() <= 0 {
               health -= 1
               energy = maxEnergy + difference
           } else {
               energy = difference
           }
       }
    }
    
    func endGame(deathCode: Int) {
        let transition = SKTransition.fade(with: .black, duration: 3)
        if let gameOverScene = GameOverScene(fileNamed: "GameOverScene") {
            gameOverScene.score = score
            gameOverScene.deathCode = deathCode
            gameOverScene.size = self.size
            gameOverScene.scaleMode = .aspectFill
            
            self.view?.presentScene(gameOverScene, transition: transition)
        }
    }
}

extension Int {
    
    static func getUniqueRandomNumbers(min: Int, max: Int, count: Int) -> [Int] {
        var set = Set<Int>()
        while set.count < count {
            set.insert(Int.random(in: min...max))
        }
        return Array(set)
    }
}

extension CGFloat {
  func roundedTowardZero(toMultipleOf m: Self) -> Self {
      return self - (self.truncatingRemainder(dividingBy: m))
  }
  
  func roundedAwayFromZero(toMultipleOf m: Self) -> Self {
    let x = self.roundedTowardZero(toMultipleOf: m)
    if x == self { return x }
    return (m.sign == self.sign) ? (x + m) : (x - m)
  }
  
  func roundedDown(toMultipleOf m: Self) -> Self {
    return (self < 0) ? self.roundedAwayFromZero(toMultipleOf: m)
                      : self.roundedTowardZero(toMultipleOf: m)
  }
  
  func roundedUp(toMultipleOf m: Self) -> Self {
    return (self > 0) ? self.roundedAwayFromZero(toMultipleOf: m)
                      : self.roundedTowardZero(toMultipleOf: m)
  }
}
