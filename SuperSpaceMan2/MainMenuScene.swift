//
//  MainMenuScene.swift
//  SuperSpaceMan2
//
//  Created by Adam Johnson on 6/24/15.
//  Copyright (c) 2015 Adam. All rights reserved.
//

import Foundation
import SpriteKit
import CoreMotion


class MainMenuScene: SKScene, SKPhysicsContactDelegate
{

    var titleLabel = SKLabelNode(fontNamed: "Copperplate")
    var tapScreenLabel = SKLabelNode(fontNamed: "Copperplate")


    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }


    override init(size: CGSize)
    {
        super.init(size: size)

        backgroundColor = SKColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)

        addMainMenuSceneLabels()
    }


    func addMainMenuSceneLabels()
    {
        titleLabel.text = "Title Screen"
        titleLabel.fontSize = 40
        titleLabel.fontColor = SKColor.whiteColor()
        titleLabel.position = CGPointMake(size.width / 2, size.height / 2)
        addChild(titleLabel)

        tapScreenLabel.text = "Tap Screen To Begin"
        tapScreenLabel.fontSize = 25
        tapScreenLabel.fontColor = SKColor.whiteColor()
        tapScreenLabel.position = CGPointMake(size.width / 2, size.height / 2 - 80)
        addChild(tapScreenLabel)
    }


    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent)
    {

        let transition = SKTransition.fadeWithDuration(1)
        let gameScene = GameScene(size: size)

        view?.presentScene(gameScene, transition: transition)
    }

}