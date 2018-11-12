//
//  GameScene.swift
//  Swimmy Fish
//
//  Created by Markus Varner on 11/9/18.
//  Copyright © 2018 Markus Varner. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bird = SKSpriteNode()
    var background = SKSpriteNode()
    var gameOver = false
    var scoreLabel = SKLabelNode()
    var score = 0
    var gameOverLabel = SKLabelNode()
    var timer = Timer()
    
    enum ColliderType: UInt32 {
        case Bird = 1
        case Object = 2
        case Gap = 4
    }
    
    @objc func makePipes() {
        //MARK: - PIPES
        
        //pipe animation
        let movePipes = SKAction.move(by: CGVector(dx: -2 * self.frame.width, dy: 0), duration: TimeInterval(self.frame.width / 100))
        
        let gapHeight = bird.size.height * 4
        //this is the total amount the pipes can move up or down on the screen
        let movementAmount = arc4random() % UInt32(self.frame.height / 2)
        let pipeOffset = CGFloat(movementAmount) - self.frame.height / 4
        
        
        let pipeTexture = SKTexture(imageNamed: "pipe1.png")
        let pipe1 = SKSpriteNode(texture: pipeTexture)
        pipe1.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeTexture.size().height / 2 + gapHeight / 2 + pipeOffset)
        pipe1.run(movePipes)
        //set the physics body
        pipe1.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture.size())
        pipe1.physicsBody!.isDynamic = false
        //assign collider types
        pipe1.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        
        self.addChild(pipe1)
        
        
        let pipe2Texture = SKTexture(imageNamed: "pipe2.png")
        let pipe2 = SKSpriteNode(texture: pipe2Texture)
        pipe2.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY - pipe2Texture.size().height / 2 - gapHeight / 2 + pipeOffset)
        pipe2.run(movePipes)
        //set physics body
        pipe2.physicsBody = SKPhysicsBody(rectangleOf: pipe2Texture.size())
        pipe2.physicsBody!.isDynamic = false
        //assign collider types
        pipe2.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
      
        self.addChild(pipe2)
        
        //MARK: - SCORE GAP
        
        let gap = SKNode()
        gap.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeOffset)
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeTexture.size().width, height: gapHeight))
        //make sure it is not effected by gravity
        gap.physicsBody!.isDynamic = false
        gap.run(movePipes)
        //assign collider types
        gap.physicsBody!.contactTestBitMask = ColliderType.Bird.rawValue
        gap.physicsBody!.categoryBitMask = ColliderType.Gap.rawValue
        gap.physicsBody!.collisionBitMask = ColliderType.Gap.rawValue
        self.addChild(gap)
        
        
    }
    
    
    //MARK: - Setup Game Method
    
    func setupGame() {
        //MARK: - TIMED SPAWNS
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.makePipes), userInfo: nil, repeats: true)
        
        //MARK: - THE BIRD
        
        //create and set bird textures
        let birdTexture = SKTexture(imageNamed: "flappy1.png")
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        //create the birds animation
        let animation = SKAction.animate(with: [birdTexture, birdTexture2], timePerFrame: 0.4)
        //repeat the animation over and over
        let makeBirdFlap = SKAction.repeatForever(animation)
        bird = SKSpriteNode(texture: birdTexture)
        //define the position of the bird
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        //initiate the birds animation
        bird.run(makeBirdFlap)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height / 2)
        bird.physicsBody!.isDynamic = false
        //assign appropriate collider types
        bird.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        bird.physicsBody!.categoryBitMask = ColliderType.Bird.rawValue
        bird.physicsBody!.collisionBitMask = ColliderType.Bird.rawValue
        
        self.addChild(bird)
        
        
        //MARK: - THE BACKGROUND
        
        let backgroundTexture = SKTexture(imageNamed: "bg.png")
        //the CGVector is set to move the background 1 pixel to the left
        let moveBGAnimation = SKAction.move(by: CGVector(dx: -backgroundTexture.size().width, dy: 0), duration: 5)
        
        let shiftBGAnimation = SKAction.move(by: CGVector(dx: backgroundTexture.size().width, dy: 0), duration: 0)
        
        //repeat background animation
        let movingBackground = SKAction.repeatForever(SKAction.sequence([moveBGAnimation, shiftBGAnimation]))
        
        //create 3 background nodes
        var i: CGFloat = 0
        while i < 3 {
            //set background texture
            background = SKSpriteNode(texture: backgroundTexture)
            //set the position of the background, this aligns it with the edge of the background texture
            background.position = CGPoint(x:  backgroundTexture.size().width * i, y: self.frame.midY)
            //set the height of the background
            background.size.height = self.frame.height
            //initiate the backgrounds animation
            background.run(movingBackground)
            //set the Z position of the background to -1 this will make it always behind the brid
            background.zPosition = -1
            
            self.addChild(background)
            i += 1
        }
        
        //MARK: - THE GROUND
        
        //The ground is essentially an invisible object
        let ground = SKNode()
        //set the grounds position to be at the bottom of the screen
        ground.position = CGPoint(x: self.frame.midX, y: -self.frame.height / 2)
        //set a physics body for the ground
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        //take the gravity from the ground so it doesnt fall
        ground.physicsBody!.isDynamic = false
        //set appropriate collider types
        ground.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        self.addChild(ground)
        
        
        //MARK: - SCORE LABEL
        
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height / 2 - 100)
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
    }
    
    //This method helps detect collisions
    func didBegin(_ contact: SKPhysicsContact) {
        if gameOver == false {
            if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue {
                score += 1
                scoreLabel.text = String(score)
                
            } else {
                self.speed = 0
                gameOver = true
                timer.invalidate()
                gameOverLabel.fontName = "Helvetica"
                gameOverLabel.fontSize = 30
                gameOverLabel.text = "Game Over! Tap to play again."
                gameOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                gameOverLabel.zPosition = 1
                self.addChild(gameOverLabel)
                
                
            }
        }
    
    }
    
    //didMove essentially is the ViewDidLoad()
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        setupGame()
        
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameOver == false {
            bird.physicsBody!.isDynamic = true
            //note the velocity must always be set before the impulse
            bird.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 80))
        } else {
            gameOver = false
            score = 0
            self.speed = 1
            self.removeAllChildren()
            setupGame()
        }
        
    }
        
    
    
    override func update(_ currentTime: TimeInterval) {
        
        
    }
}
