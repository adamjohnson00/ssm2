//
//  GameScene.swift
//  SuperSpaceMan2
//
//  Created by Adam Johnson on 6/15/15.
//  Copyright (c) 2015 Adam. All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate
{
    var backgroundNode : SKSpriteNode?
    var backgroundStarsNode : SKSpriteNode?
    var backgroundPlanetNode : SKSpriteNode?
    var playerNode : SKSpriteNode?
    var impulseCount = 40
    var coreMotionManager = CMMotionManager()
    var xAxisAcceleration : CGFloat = 0
    var foregroundNode : SKSpriteNode?

    let CollisionCategoryPlayer : UInt32 = 0x1 << 1
    let CollisionCategoryPowerUpOrbs : UInt32 = 0x1 << 2
    let CollisionCategoryBlackHoles : UInt32 = 0x1 << 3
    let CollisionCategoryBlueLaser : UInt32 = 0x1 << 4

    var engineExhaust : SKEmitterNode?

    var exhaustTime : NSTimer?

    var score = 0
    let scoreTextNode = SKLabelNode(fontNamed: "Copperplate")

    var impulseTextNode = SKLabelNode(fontNamed: "Copperplate")

    var orbPopAction = SKAction.playSoundFileNamed("orb_pop.wav", waitForCompletion: false)

    var shootNoiseSoundAction = SKAction.playSoundFileNamed("lowblast.wav", waitForCompletion: false)

    let startGameTextNode = SKLabelNode(fontNamed: "Copperplate")

    var shootButton : SKSpriteNode?

    var shooting = false
    var lastShootingTime : CFTimeInterval = 0
    var delayBetweenShots : CFTimeInterval = 0.5

    var blueLaser : SKSpriteNode?


    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }


    override init(size: CGSize)
    {
        super.init(size: size)

        // Sets the delegate.
        physicsWorld.contactDelegate = self

        // Sets the strength of gravity.
//        physicsWorld.gravity = CGVectorMake(0.0, -5.0)
        physicsWorld.gravity = CGVectorMake(0.0, 0.0)


        // Turns on user interaction.
        userInteractionEnabled = true

        // The background node must come before the foreground node.
        addBackground()

        addStarsBackground()

        //addPlanetBackground()

        addForeground()

        addPlayerToForeground()

        addOrbsToForeground()

        addBlackHolesToForeground()

        addScoreLabel()

        addImpulseLabel()

        addEngineExhaust()

        addStartGameLabel()

        addShootButton()

        // Prints size of screen.
        println("The size is (\(size.width), \(size.height)).")
    }





    func addStartGameLabel()
    {
        startGameTextNode.text = "TAP ANYWHERE TO START!"
        startGameTextNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        startGameTextNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        startGameTextNode.fontSize = 20
        startGameTextNode.fontColor = SKColor.whiteColor()
        startGameTextNode.position = CGPointMake(scene!.size.width / 2, scene!.size.height / 2)

        addChild(startGameTextNode)
    }


    func addEngineExhaust()
    {
        let engineExhaustPath = NSBundle.mainBundle().pathForResource("EngineExhaust", ofType: "sks")
        engineExhaust = NSKeyedUnarchiver.unarchiveObjectWithFile(engineExhaustPath!) as? SKEmitterNode
        engineExhaust!.position = CGPointMake(0.0, -(playerNode!.size.height / 2))

        playerNode!.addChild(engineExhaust!)
        engineExhaust!.hidden = true;
    }


    func addScoreLabel()
    {
        scoreTextNode.text = "SCORE : \(score)"
        scoreTextNode.fontSize = 20
        scoreTextNode.fontColor = SKColor.whiteColor()
        scoreTextNode.position = CGPointMake(size.width - 10, size.height - 20)
        scoreTextNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right

        addChild(scoreTextNode)
    }


    func addImpulseLabel()
    {
        impulseTextNode.text = "IMPULSES : \(impulseCount)"
        impulseTextNode.fontSize = 20
        impulseTextNode.fontColor = SKColor.whiteColor()
        impulseTextNode.position = CGPointMake(10.0, size.height - 20)
        impulseTextNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left

        addChild(impulseTextNode)
    }


    func addBackground()
    {
        // Sets background color behind image to black.
        backgroundColor = SKColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)

        // Adds the background picture.
        backgroundNode = SKSpriteNode(imageNamed: "Background")

        // Sets the background's anchor point.
        backgroundNode!.anchorPoint = CGPoint(x: 0.5, y: 0.0)

        // Sets the background's position.
        backgroundNode!.position = CGPoint(x: size.width / 2.0, y: 0.0)

        // Adds the background node.
        addChild(backgroundNode!)
    }


    func addStarsBackground()
    {
        backgroundStarsNode = SKSpriteNode(imageNamed: "Stars")
        backgroundStarsNode!.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        backgroundStarsNode!.position = CGPoint(x: 160.0, y: 100.0)

        addChild(backgroundStarsNode!)
    }


    func addPlanetBackground()
    {
        backgroundPlanetNode = SKSpriteNode(imageNamed: "PlanetStart")
        backgroundPlanetNode!.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        backgroundPlanetNode!.position = CGPoint(x: 160.0, y: 0.0)

        addChild(backgroundPlanetNode!)
    }


    func addForeground()
    {
        foregroundNode = SKSpriteNode()

        addChild(foregroundNode!)
    }


    func addPlayerToForeground()
    {
        // Add the player.
        playerNode = SKSpriteNode(imageNamed: "Ship")

        // Add physics body to playerNode.
        playerNode!.physicsBody = SKPhysicsBody(circleOfRadius: playerNode!.size.width / 2)
        playerNode!.physicsBody!.dynamic = false

        // Set player position.
        playerNode!.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        playerNode!.position = CGPoint(x: self.size.width / 2.0, y: 220.0)

        // Add simulated air friction.
        playerNode!.physicsBody!.linearDamping = 1.0

        // Turns off rotation when collided with.
        playerNode!.physicsBody!.allowsRotation = false

        // Setting up the bit masks for playerNode.
        playerNode!.physicsBody!.categoryBitMask = CollisionCategoryPlayer
        playerNode!.physicsBody!.contactTestBitMask = CollisionCategoryPowerUpOrbs | CollisionCategoryBlackHoles
        playerNode!.physicsBody!.collisionBitMask = 0

        foregroundNode!.addChild(playerNode!)
    }


    func addOrbsToForeground()
    {
        var orbNodePosition = CGPoint(x: playerNode!.position.x, y: playerNode!.position.y + 100)
        var orbXShift : CGFloat = -1.0

        for _ in 1...50
        {
            var orbNode = SKSpriteNode(imageNamed: "PowerUp")

            if orbNodePosition.x - (orbNode.size.width * 2) <= 0
            {
                orbXShift = 1.0
            }

            if orbNodePosition.x + orbNode.size.width >= self.size.width
            {
                orbXShift = -1.0
            }

            orbNodePosition.x += 40.0 * orbXShift
            orbNodePosition.y += 120
            orbNode.position = orbNodePosition
            orbNode.physicsBody = SKPhysicsBody(circleOfRadius: orbNode.size.width / 2)
            orbNode.physicsBody!.dynamic = false

            orbNode.physicsBody!.categoryBitMask = CollisionCategoryPowerUpOrbs
            orbNode.physicsBody!.collisionBitMask = 0

            orbNode.name = "POWER_UP_ORB"

            foregroundNode!.addChild(orbNode)
        }
    }


    func addBlackHolesToForeground()
    {
        // Creates a texture atlas.
        let textureAtlas = SKTextureAtlas(named: "sprites.atlas")

        // Assigns texture atlas images to variables.
        let frame0 = textureAtlas.textureNamed("BlackHole0")
        let frame1 = textureAtlas.textureNamed("BlackHole1")
        let frame2 = textureAtlas.textureNamed("BlackHole2")
        let frame3 = textureAtlas.textureNamed("BlackHole3")
        let frame4 = textureAtlas.textureNamed("BlackHole4")

        // Stores texture atlas images in an array.
        let blackHoleTextures = [frame0, frame1, frame2, frame3, frame4]

        let animateAction = SKAction.animateWithTextures(blackHoleTextures, timePerFrame: 0.2)
        let rotateAction = SKAction.repeatActionForever(animateAction)

        let moveLeftAction = SKAction.moveToX(size.width, duration: 2.0)
        let moveRightAction = SKAction.moveToX(0.0, duration: 2.0)
        let actionSequence = SKAction.sequence([moveLeftAction, moveRightAction])
        let moveAction = SKAction.repeatActionForever(actionSequence)

        for i in 1...10
        {
            var blackHoleNode = SKSpriteNode(imageNamed: "BlackHole0")

            blackHoleNode.position = CGPointMake(self.size.width - 80.0, 600.0 * CGFloat(i))
            //blackHoleNode.anchorPoint = CGPoint(x: 1, y: 0)
            blackHoleNode.physicsBody = SKPhysicsBody(circleOfRadius: blackHoleNode.size.width / 2)
            blackHoleNode.physicsBody!.dynamic = false

            blackHoleNode.physicsBody!.categoryBitMask = CollisionCategoryBlackHoles
            blackHoleNode.physicsBody!.collisionBitMask = 0
            blackHoleNode.name = "BLACK_HOLE"

            blackHoleNode.runAction(moveAction)
            blackHoleNode.runAction(rotateAction)

            foregroundNode!.addChild(blackHoleNode)
        }
    }


    func addShootButton()
    {
        shootButton = SKSpriteNode(imageNamed: "shootbutton")

        shootButton!.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        shootButton!.position = CGPoint(x: self.size.width - 50, y: 50)

        shootButton!.name = "shootbutton"

        addChild(shootButton!)
    }


    func shootLaser()
    {



    }



    func addBlueLaser()
    {
        blueLaser = SKSpriteNode(imageNamed: "bluelaserwhiteborder")

        blueLaser!.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        blueLaser!.position = CGPoint(x: playerNode!.position.x, y: playerNode!.position.y)


        blueLaser!.physicsBody = SKPhysicsBody(circleOfRadius: blueLaser!.size.height / 2)

        blueLaser!.physicsBody!.dynamic = false

        // Move the blue laser up the screen (shoot the laser).
        let moveUpAction = SKAction.moveToY(playerNode!.position.y + 3000, duration: 3.0)

        blueLaser!.runAction(moveUpAction)

        blueLaser!.name = "blue_laser"

        blueLaser!.physicsBody!.categoryBitMask = CollisionCategoryBlueLaser
        blueLaser!.physicsBody!.contactTestBitMask = CollisionCategoryBlackHoles
        blueLaser!.physicsBody!.collisionBitMask = 0

        addChild(blueLaser!)


    }

    
    // This method executes when the user touches the screen.
    override func touchesBegan(touches: Set <NSObject>, withEvent event: UIEvent)
    {
        // Add blaster shot.

        addBlueLaser()


        if playerNode != nil
        {
            if !playerNode!.physicsBody!.dynamic
            {
                // Removes the "Tap Anywhere to Start" label once the screen has been tapped.
                startGameTextNode.removeFromParent()


                // Play blaster noise.
                runAction(shootNoiseSoundAction)

                playerNode!.physicsBody!.dynamic = true

                self.coreMotionManager.accelerometerUpdateInterval = 0.3

                self.coreMotionManager.startAccelerometerUpdatesToQueue(NSOperationQueue(), withHandler:
                {
                        (data: CMAccelerometerData!, error: NSError!) in

                        if let constVar = error
                        {
                            println("An error was encountered.")
                        }
                        else
                        {
                            self.xAxisAcceleration = CGFloat(data!.acceleration.x)
                        }
                })
            }

            if impulseCount > 0
            {
                playerNode!.physicsBody!.applyImpulse(CGVectorMake(0.0, 40.0))
                impulseCount--

                impulseTextNode.text = "IMPULSES : \(impulseCount)"

                // Shows fire coming from engine.
                self.engineExhaust!.hidden = false
                
                NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "hideEngineExhaust:", userInfo: nil, repeats: false)
            }
        }
    }









    // This method executes when the player node (the spaceship) touches either orbs or black holes.
    func didBeginContact(contact: SKPhysicsContact)
    {
        var nodeB = contact.bodyB!.node!

        if nodeB.name == "POWER_UP_ORB"
        {
            // Plays orb pop sound.
            runAction(orbPopAction)

            // Adds an impulse to total impulses.
            impulseCount++

            // Updates the impulse label.
            impulseTextNode.text = "IMPULSES : \(impulseCount)"

            // Adds one point to the score.
            score++

            // Updates the score label.
            scoreTextNode.text = "SCORE : \(score)"

            // Removes orb from screen.
            nodeB.removeFromParent()

        }

        else if nodeB.name == "BLACK_HOLE"
        {
            // Disables players ability to collide with objects.
            playerNode!.physicsBody!.contactTestBitMask = 0

            // Removes all impulses.
            impulseCount = 0

            // Turns the player red when he touches a black hole.
            var colorizeAction = SKAction.colorizeWithColor(UIColor.redColor(), colorBlendFactor: 1.0, duration: 0.8)

            // Runs the action.
            playerNode!.runAction(colorizeAction)

            // Removes black hole from screen.
            nodeB.removeFromParent()
        }


        if blueLaser != nil
        {
            if blueLaser!.position.y > size.height
            {

                blueLaser!.physicsBody!.contactTestBitMask = 0

            }
        }

    }









    override func update(currentTime: NSTimeInterval)
    {
        if playerNode != nil
        {
            if playerNode!.position.y >= 180.0 && playerNode!.position.y < 6400.0
            {
                backgroundNode!.position = CGPointMake(self.backgroundNode!.position.x, -((self.playerNode!.position.y - 180.0) / 8))

                backgroundStarsNode!.position = CGPointMake(backgroundStarsNode!.position.x, -((playerNode!.position.y - 180.0) / 6))

                //backgroundPlanetNode!.position = CGPointMake(backgroundPlanetNode!.position.x, -((playerNode!.position.y - 180.0) / 8))

                foregroundNode!.position = CGPointMake(foregroundNode!.position.x, -(playerNode!.position.y - 180.0))
            }
            else if playerNode!.position.y > 7000
            {
                gameOverWithResult(true)
            }
            else if playerNode!.position.y < 0.0
            {
                gameOverWithResult(false)
            }


        }
    }


    override func didSimulatePhysics()
    {
        if playerNode != nil
        {
            self.playerNode!.physicsBody!.velocity = CGVectorMake(self.xAxisAcceleration * 380.0, self.playerNode!.physicsBody!.velocity.dy)

            if playerNode!.position.x < -(playerNode!.size.width / 2)
            {
                playerNode!.position = CGPointMake(size.width - playerNode!.size.width / 2, playerNode!.position.y)
            }
            else if self.playerNode!.position.x > self.size.width
            {
                playerNode!.position = CGPointMake(playerNode!.size.width / 2, playerNode!.position.y)
            }
        }
    }


    deinit
    {
        self.coreMotionManager.stopAccelerometerUpdates()
    }


    func hideEngineExhaust(timer:NSTimer!)
    {
        if !engineExhaust!.hidden
        {
            engineExhaust!.hidden = true
        }
    }


    func gameOverWithResult(gameResult: Bool)
    {
        playerNode!.removeFromParent()
        playerNode = nil

        let transition = SKTransition.fadeWithDuration(3)
        let menuScene = MenuScene(size: size, gameResult: gameResult, score: score)

        view?.presentScene(menuScene, transition: transition)
    }
}






















