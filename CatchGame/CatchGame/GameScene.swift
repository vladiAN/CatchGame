//
//  GameScene.swift
//  CatchGame
//
//  Created by Андрушок on 01.01.2023.
//

import SpriteKit
import GameplayKit

struct BitMasks {
    static let egg: UInt32 = 1
    static let basket: UInt32 = 2
}

class GameScene: SKScene {
    
    var scoreLabel = SKLabelNode()
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    let background = SKSpriteNode(imageNamed: "background")
    let basket = SKSpriteNode(imageNamed: "basket")
    let eggBreak = SKTexture(imageNamed: "eggBreak")
    let sizeBasket = CGSize(width: 100, height: 100)
    let sizeEgg = CGSize(width: 40, height: 40)
    let bottomBorder = SKShapeNode()
    
    let delay = SKAction.wait(forDuration: 0.5)
    let disappearance = SKAction.fadeOut(withDuration: 0.2)
    

    override func didMove(to view: SKView) {
        scene?.size = UIScreen.main.bounds.size
        
        background.size = CGSize(width: self.size.width, height: self.size.height)
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: \(score)"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: frame.maxX - 20, y: frame.maxY - 60)
        addChild(scoreLabel)
        
        basket.size = CGSize(width: sizeBasket.width, height: sizeBasket.height)
        basket.position.y = frame.minY + 100
        
        basket.physicsBody = SKPhysicsBody(texture: basket.texture!, size: basket.size)
        basket.physicsBody?.isDynamic = false
        basket.physicsBody?.categoryBitMask = BitMasks.basket
        basket.physicsBody?.collisionBitMask = 0
        basket.physicsBody?.contactTestBitMask = BitMasks.egg
        
        addChild(basket)
        
        physicsWorld.gravity = .init(dx: 0, dy: -1)
        physicsWorld.contactDelegate = self

        setupEgg()
        setupBottomBorder()
        
        
    }
    
    func setupBottomBorder() {
        bottomBorder.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: frame.width, height: 1))
        bottomBorder.physicsBody?.affectedByGravity = false
        bottomBorder.physicsBody?.isDynamic = false
        bottomBorder.physicsBody?.restitution = 0.0
        bottomBorder.position = .init(x: 0, y: frame.minY)
        addChild(bottomBorder)
    }
    
    func createEgg() -> SKSpriteNode {
        let imageEgg = SKTexture(imageNamed: "egg")
        let egg = SKSpriteNode(texture: imageEgg, size: CGSize(width: sizeEgg.width, height: sizeEgg.height))
        
        //egg.size = CGSize(width: sizeEgg.width, height: sizeEgg.height)
        egg.position.x = .random(in: frame.minX...frame.maxX)
        egg.position.y = frame.size.height + egg.size.height
        
        egg.physicsBody = SKPhysicsBody(texture: egg.texture!, size: egg.size)
        egg.physicsBody?.restitution = 0.0
        egg.physicsBody?.categoryBitMask = BitMasks.egg
        egg.physicsBody?.contactTestBitMask = BitMasks.basket
        egg.physicsBody?.collisionBitMask = 1
        
        return egg
    }
    
    func setupEgg() {
        let createEgg = SKAction.run {
            let egg = self.createEgg()
            self.addChild(egg)
        }
        let eggPerDecond: Double = 2
        let eggCreationDelay = SKAction.wait(forDuration: 1.5 / eggPerDecond, withRange: 0.1)
        let eggSequenceAction = SKAction.sequence([createEgg,eggCreationDelay])
        let eggRunAction = SKAction.repeatForever(eggSequenceAction)
        
        run(eggRunAction)
    }
    

    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.location(in: self)
            
            basket.position.x = touchLocation.x
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
    
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        
        if contact.bodyA.categoryBitMask == BitMasks.egg{
            if contact.bodyB.categoryBitMask == BitMasks.basket {
                print("basket")
                score += 1
                contact.bodyA.node?.removeFromParent()
                    
                
            } else {
                print("pol")
                if let egg = contact.bodyB.node as? SKSpriteNode {
                    egg.texture = eggBreak
                    egg.physicsBody?.density = 0.0
                    egg.physicsBody?.isDynamic = false
                    egg.run(SKAction.sequence([
                        SKAction.wait(forDuration: 0.5),
                        SKAction.fadeOut(withDuration: 0.2),
                        SKAction.run {
                            egg.removeFromParent()
                        }
                    ]))
                    
                }
                //contact.bodyA.node?.removeFromParent()
            }
        } else {
            if contact.bodyA.categoryBitMask == BitMasks.basket {
                print("basket")
                //score += 1
                contact.bodyB.node?.removeFromParent()
                
            } else {
                print("pol")
                if let egg = contact.bodyB.node as? SKSpriteNode {
                    egg.texture = eggBreak
                    egg.physicsBody?.density = 0.0
                    egg.physicsBody?.isDynamic = false
                    egg.run(SKAction.sequence([
                        SKAction.wait(forDuration: 0.5),
                        SKAction.fadeOut(withDuration: 0.2),
                        SKAction.run {
                            egg.removeFromParent()
                        }
                    ]))
                }
            }
        }
    
    }
}

