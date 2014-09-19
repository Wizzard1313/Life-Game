//
//  GameScene.swift
//  Life Game
//
//  Created by Bruce Milyko on 9/17/14.
//  Copyright (c) 2014 Bruce Milyko. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    let gridWidth = 800
    let gridHeight = 560
    let numRows = 13
    let numCols = 20
    let gridLowerLeftCorner:CGPoint = CGPoint(x: 215, y: 100)
    
    let populationLabel:SKLabelNode = SKLabelNode(text: "Population")
    let generationLabel:SKLabelNode = SKLabelNode(text: "Generation")
    var populationValueLabel:SKLabelNode = SKLabelNode(text: "0")
    var generationValueLabel:SKLabelNode = SKLabelNode(text: "0")
    var playButton:SKSpriteNode = SKSpriteNode(imageNamed:"play.png")
    var pauseButton:SKSpriteNode = SKSpriteNode(imageNamed:"pause.png")
    
    var tiles:[[Tile]] = []
    var margin = 4
    
    var isPlaying = false
    
    var prevTime:CFTimeInterval = 0
    var timeCounter:CFTimeInterval = 0
    
    var population:Int = 0 {
        didSet {
            populationValueLabel.text = "\(population)"
        }
    }
    var generation:Int = 0 {
        didSet {
            generationValueLabel.text = "\(generation)"
        }
    }
    
    override func didMoveToView(view: SKView) {
        let background = SKSpriteNode(imageNamed: "background.png")
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.size = self.size
        background.zPosition = -2
        self.addChild(background)
        
        
        let gridBackground = SKSpriteNode(imageNamed: "grid.png")
        gridBackground.size = CGSize(width: gridWidth, height: gridHeight)
        gridBackground.zPosition = -1
        gridBackground.anchorPoint = CGPoint(x:0, y:0)
        gridBackground.position = gridLowerLeftCorner
        self.addChild(gridBackground)
        playButton.position = CGPoint(x: 90, y: 590)
        playButton.setScale(1.0)
        self.addChild(playButton)
        pauseButton.position = CGPoint(x: 90, y: 500)
        pauseButton.setScale(1.0)
        self.addChild(pauseButton)
        // add a balloon background for the stats
        let balloon = SKSpriteNode(imageNamed: "balloon.png")
        balloon.position = CGPoint(x: 90, y: 360)
        balloon.setScale(0.8)
        self.addChild(balloon)
        // add a microscope image as a decoration
        let microscope = SKSpriteNode(imageNamed: "microscope.png")
        microscope.position = CGPoint(x: 90, y: 190)
        microscope.setScale(0.7)
        self.addChild(microscope)
        // dark green labels to keep track of number of living tiles
        // and number of steps the simulation has gone through
        populationLabel.position = CGPoint(x: 90, y: 390)
        populationLabel.fontName = "Courier"
        populationLabel.fontSize = 16
        populationLabel.fontColor = UIColor(red: 0, green: 0.2, blue: 0, alpha: 1)
        self.addChild(populationLabel)
        generationLabel.position = CGPoint(x: 90, y: 350)
        generationLabel.fontName = "Courier"
        generationLabel.fontSize = 16
        generationLabel.fontColor = UIColor(red: 0, green: 0.2, blue: 0, alpha: 1)
        self.addChild(generationLabel)
        populationValueLabel.position = CGPoint(x: 90, y: 375)
        populationValueLabel.fontName = "Courier"
        populationValueLabel.fontSize = 16
        populationValueLabel.fontColor = UIColor(red: 0, green: 0.2, blue: 0, alpha: 1)
        self.addChild(populationValueLabel)
        generationValueLabel.position = CGPoint(x: 90, y: 335)
        generationValueLabel.fontName = "Courier"
        generationValueLabel.fontSize = 16
        generationValueLabel.fontColor = UIColor(red: 0, green: 0.2, blue: 0, alpha: 1)
        self.addChild(generationValueLabel)
        
        // initialize the 2d array of tiles
        let tileSize = calculateTileSize()
        for r in 0..<numRows {
            var tileRow:[Tile] = []
            for c in 0..<numCols {
                let tile = Tile(imageNamed: "bubble.png")
                tile.isAlive = false
                tile.size = CGSize(width: tileSize.width, height: tileSize.height)
                tile.anchorPoint = CGPoint(x: 0, y: 0)
                tile.position = getTilePosition(row: r, column: c)
                self.addChild(tile)
                tileRow.append(tile)
            }
            tiles.append(tileRow)
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        for touch: AnyObject in touches {
            var selectedTile:Tile? = getTileAtPosition(xPos: Int(touch.locationInNode(self).x), yPos: Int(touch.locationInNode(self).y))
            if let tile = selectedTile {
                tile.isAlive = !tile.isAlive
                population++
            } else {
                population--
            }
            if CGRectContainsPoint(playButton.frame, touch.locationInNode(self)) {
                playButtonPressed()
            }
            if CGRectContainsPoint(pauseButton.frame, touch.locationInNode(self)) {
                pauseButtonPressed()
            }
        }
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if prevTime == 0 {
            prevTime = currentTime
        }
        if isPlaying{
            timeCounter += currentTime - prevTime
            if timeCounter > 0.5 {
                timeCounter = 0
                timeStep()
            }
        }
        prevTime = currentTime
    }
    
    func calculateTileSize() -> CGSize{
        let tileWidth = gridWidth / numCols - margin
        let tileHeight = gridHeight / numRows - margin
        return CGSize(width: tileWidth, height: tileHeight)
    }
    
    func getTilePosition(row r:Int, column c:Int) -> CGPoint{
        let tileSize = calculateTileSize()
        let x = Int(gridLowerLeftCorner.x) + margin + (c * (Int(tileSize.width) + margin))
        let y = Int(gridLowerLeftCorner.y) + margin + (r * (Int(tileSize.height) + margin))
        return CGPoint(x: x, y: y)
    }
    
    func isValidTile(row r: Int, column c:Int) -> Bool {
        return r >= 0 && r < numRows && c >= 0 && c < numCols
    }
    
    func getTileAtPosition(xPos x: Int, yPos y: Int) -> Tile? {
    let r:Int = Int( CGFloat(y - (Int(gridLowerLeftCorner.y) + margin)) / CGFloat(gridHeight) * CGFloat(numRows))
    let c:Int = Int( CGFloat(x - (Int(gridLowerLeftCorner.x) + margin)) / CGFloat(gridWidth) * CGFloat(numCols))
    if isValidTile(row: r, column: c) {
        return tiles[r][c]
        } else {
        return nil
        }
    }
    
    func playButtonPressed() {
        isPlaying = true
    }
    
    func pauseButtonPressed() {
        isPlaying = false
    }
    
    func timeStep() {
        countLivingNeighbors()
        updateCreatures()
        generation++
    }
    
    func countLivingNeighbors() {
        for r in 0..<numRows {
            for c in 0..<numCols {
                var numLivingNeighbors:Int = 0
                for i in (r-1)...(r+1) {
                    for j in (c-1)...(c+1) {
                        if ( !((r == i) && (c == j)) && isValidTile(row: i, column: j)) {
                            if tiles[i][j].isAlive {
                                numLivingNeighbors++
                            }
                        }
                    }
                }
                tiles[r][c].numLivingNeighbors = numLivingNeighbors
            }
        }
    }
    
    func updateCreatures() {
        var numAlive = 0
        for r in 0..<numRows {
            for c in 0..<numCols {
                var tile:Tile = tiles[r][c]
                if tile.numLivingNeighbors == 3 {
                    tile.isAlive = true
                } else if tile.numLivingNeighbors < 2 || tile.numLivingNeighbors > 3 {
                    tile.isAlive = false
                }
                if tile.isAlive {
                    numAlive++
                }
            }
        }
        population = numAlive
    }
}
