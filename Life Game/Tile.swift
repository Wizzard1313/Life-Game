//
//  Tile.swift
//  Life Game
//
//  Created by Bruce Milyko on 9/18/14.
//  Copyright (c) 2014 Bruce Milyko. All rights reserved.
//

import UIKit
import SpriteKit

class Tile: SKSpriteNode {
    var isAlive:Bool = false {
        didSet {
            self.hidden = !isAlive
        }
    }
    var numLivingNeighbors = 0
    
   
}
