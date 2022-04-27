//
//  GameOverScene.swift
//  maze-man
//
//  Created by Cony Lee on 4/14/22.
//

import SpriteKit
import GameplayKit

let achievementDictionary = [0: "Are you afraid? | You were swallowed by the darkness.", // default
                             1: "Drown | Try not to fall in the water next time, 'kay?", // death by falling in the water
                             2: "Die to a frog | Who would've thought you'd actually die to a frog?", // death by frog
                             3: "Die to a spider | Spiders give me the heebie-jeebies.", // death by spider
                             4: "Die to a snake | ssssss...", // death by snake
                             5: "Die to a ghost orb | Watch out for physics defying ghost orbs!", // death by ghost
                             100: "Glutton | Would you like another serving?", // 10 or more food consumed
                             101: "Berserker | Are you a KDA player?", // 10 or more enemies slain
                             102: "Merchantman | Mansa Musa is rolling in his grave...", // 10 or more coins picked up
                             103: "Pacifist | A great offence is having a great defence.", // run out your energy without attacking or getting attacked once
                             104: "Jackpot! | Perfect 7s."] // eat 7 food, collect 7 coins, and have 7 rocks by the end

class GameOverScene: SKScene {

    let defaults = UserDefaults.standard
    var highscores: [Highscore] = []
    var achievements: [String] = []
    
    var score: Int = 0
    var deathCode: Int = 0
    
    var message: String = ""
    
    override func didMove(to view: SKView) {
        if let message = achievementDictionary[deathCode] {
            let index = message.index(message.firstIndex(of: "|")!, offsetBy: 2)
            self.message = String(message.suffix(from: index))
        }
        
        fetchDefaults()
        updateHighScores()
        updateAchievements()
        saveDefaults()
        
        let gameOverLabel = self.childNode(withName: "gameOverLabel") as! SKLabelNode
        gameOverLabel.text = "Game Over"
        gameOverLabel.alpha = 0
        
        let scoreLabel = self.childNode(withName: "scoreLabel") as! SKLabelNode
        scoreLabel.text = "You scored \(score) points this run."
        scoreLabel.alpha = 0
        
        let messageLabel = self.childNode(withName: "messageLabel") as! SKLabelNode
        messageLabel.text = "\"\(message)\""
        messageLabel.alpha = 0
        
        let highscoreLabel = self.childNode(withName: "highscoreLabel") as! SKLabelNode
        highscoreLabel.text = formatHighscoreLabel()
        highscoreLabel.alpha = 0
        
        let achievementsButton = self.childNode(withName: "achievementsButton") as! SKSpriteNode
        achievementsButton.alpha = 0
        achievementsButton.run(SKAction.repeatForever(SKAction.rotate(byAngle: 1, duration: 10)))
        
        let tapLabel = self.childNode(withName: "tapLabel") as! SKLabelNode
        tapLabel.alpha = 0
        
        let restartLabel = self.childNode(withName: "restartLabel") as! SKLabelNode
        restartLabel.text = "Swipe up to restart..."
        restartLabel.alpha = 0
        
        let labels = [gameOverLabel, scoreLabel, messageLabel, highscoreLabel, achievementsButton, restartLabel, tapLabel]
        let duration = 1.0
        let fadeAction = SKAction.fadeAlpha(to: 1, duration: 1)
                
        for (nodeIndex, node) in labels.enumerated() {
            node.run(SKAction.sequence([SKAction.wait(forDuration: duration * Double(nodeIndex)), fadeAction]), completion: { [self] in
                if nodeIndex == labels.endIndex - 1 {
                    restartLabel.run(SKAction.repeatForever(SKAction.sequence([SKAction.fadeAlpha(to: 0.4, duration: 1.5), SKAction.fadeAlpha(to: 1, duration: 1.5)])))
                    
                    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
                    self.view?.addGestureRecognizer(tapGestureRecognizer)
                    
                    let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(recognizer:)))
                    swipeGestureRecognizer.direction = .up
                    self.view?.addGestureRecognizer(swipeGestureRecognizer)
                }
            })
        }
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        self.view?.removeGestureRecognizer(recognizer)
        achievementsScene()
    }
    
    @objc func handleSwipe(recognizer: UISwipeGestureRecognizer) {
        self.view?.removeGestureRecognizer(recognizer)
        restart()
    }
    
    func achievementsScene() {
        let transition = SKTransition.fade(with: .systemBackground, duration: 3)
        
        if let achievementsScene = AchievementsScene(fileNamed: "AchievementsScene") {
            achievementsScene.achievedArray = achievements
            achievementsScene.size = self.size
            achievementsScene.scaleMode = .aspectFill
            
            self.view?.presentScene(achievementsScene, transition: transition)
        }
    }
    
    func restart() {
        let transition = SKTransition.fade(with: .black, duration: 3)
        
        if let restartScene = GameScene(fileNamed: "GameScene") {
            restartScene.size = self.size
            restartScene.scaleMode = .aspectFill
            
            self.view?.presentScene(restartScene, transition: transition)
        }
    }
    
    func fetchDefaults() {
        if let data = UserDefaults.standard.data(forKey: "highscores") {
            do {
                let decoder = JSONDecoder()
                highscores = try decoder.decode([Highscore].self, from: data)
            } catch {
                print("Error while fetching highscores.")
            }
        } else {
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(highscores)
                
                UserDefaults.standard.set(data, forKey: "highscores")
            } catch {
                print("Error while init highscores.")
            }
        }
        
        if let achievements = defaults.stringArray(forKey: "achievements") {
            self.achievements = achievements
        } else {
            defaults.set(achievements, forKey: "achievements")
        }
    }
    
    func saveDefaults() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(highscores)
            
            UserDefaults.standard.set(data, forKey: "highscores")
        } catch {
            print("Error while saving highscores.")
        }
        
        defaults.set(achievements, forKey: "achievements")
    }
    
    func updateHighScores() {
        highscores.append(Highscore(score: score))
        
        highscores.sort(by: { $0.score > $1.score })
        
        if highscores.count > 3 {
            highscores.removeLast()
        }
    }
    
    func updateAchievements() {
        if !achievements.contains(achievementDictionary[deathCode]!) {
            achievements.append(achievementDictionary[deathCode]!)
        }
    }
    
    func formatHighscoreLabel() -> String {
        var labelString = ""
        
        for highscore in highscores {
            labelString.append("\(highscore.toString)\n")
        }
        
        return labelString
    }
    
    func resetAllData() {
        highscores.removeAll()
        achievements.removeAll()
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(highscores)
            
            UserDefaults.standard.set(data, forKey: "highscores")
        } catch {
            print("Error while init highscores.")
        }
        
        defaults.set(achievements, forKey: "achievements")
    }
}
