//
//  AchievementsScene.swift
//  maze-man
//
//  Created by Cony Lee on 4/16/22.
//

import SpriteKit
import GameplayKit

class AchievementsScene: SKScene {
    var achievedArray: [String] = []
    var hintArray: [String] = []
    
    override func didMove(to view: SKView) {
        
        let numberLabel = self.childNode(withName: "numberLabel") as! SKLabelNode
        numberLabel.text = "\(achievedArray.count)/\(achievementDictionary.count)"
        numberLabel.alpha = 0
        
        let titleLabel = self.childNode(withName: "titleLabel") as! SKLabelNode
        titleLabel.text = "Achievements Unlocked"
        titleLabel.alpha = 0
        
        let contentLabel = self.childNode(withName: "contentLabel") as! SKLabelNode
        contentLabel.text = formatContentLabel()
        contentLabel.alpha = 0
        
        let restartLabel = self.childNode(withName: "restartLabel") as! SKLabelNode
        restartLabel.text = "Swipe up to restart..."
        restartLabel.alpha = 0
        
        //let waitAction = SKAction.wait(forDuration: 3)
        
        let labels = [numberLabel, titleLabel, contentLabel, restartLabel]
        let duration = 1.0
        let fadeAction = SKAction.fadeAlpha(to: 1, duration: 1)
                
        for (nodeIndex, node) in labels.enumerated() {
            node.run(SKAction.sequence([SKAction.wait(forDuration: duration * Double(nodeIndex)), fadeAction]), completion: { [self] in
                if nodeIndex == labels.endIndex - 1 {
                    restartLabel.run(SKAction.repeatForever(SKAction.sequence([SKAction.fadeAlpha(to: 0.4, duration: 1.5), SKAction.fadeAlpha(to: 1, duration: 1.5)])))
                    
                    let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(recognizer:)))
                    swipeGestureRecognizer.direction = .up
                    self.view?.addGestureRecognizer(swipeGestureRecognizer)
                }
            })
        }
    }
    
    @objc func handleSwipe(recognizer: UISwipeGestureRecognizer) {
        self.view?.removeGestureRecognizer(recognizer)
        restart()
    }
    
    func restart() {
        let transition = SKTransition.fade(with: .black, duration: 3)
        
        if let restartScene = GameScene(fileNamed: "GameScene") {
            restartScene.size = self.size
            restartScene.scaleMode = .aspectFill
            
            self.view?.presentScene(restartScene, transition: transition)
        }
    }
    
    func formatContentLabel() -> String {
        var labelString = ""
        
        for achieved in achievedArray {
            labelString.append("⭐️ \(achieved)\n")
        }
        
        for achievement in achievementDictionary {
            if !achievedArray.contains(achievement.value) {
                let index = achievement.value.index(achievement.value.firstIndex(of: "|")!, offsetBy: -2)
                let line = String(achievement.value.prefix(through: index))
                
                labelString.append("❔ \(line)\n")
            }
        }
        
        return labelString
    }
}

extension String {
    
    func numberOfLines() -> Int {
        return self.numberOfOccurrencesOf(string: "\n") + 1
    }

    func numberOfOccurrencesOf(string: String) -> Int {
        return self.components(separatedBy:string).count - 1
    }
}
