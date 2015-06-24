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

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }


    override init(size: CGSize)
    {
        super.init(size: size)

        


    }


    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent)
    {

        let transition = SKTransition.fadeWithDuration(1)
        let gameScene = GameScene(size: size)

        view?.presentScene(gameScene, transition: transition)
    }

}