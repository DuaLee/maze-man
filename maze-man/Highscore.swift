//
//  HighScore.swift
//  maze-man
//
//  Created by Cony Lee on 4/16/22.
//

import Foundation

struct Highscore: Codable {
    var score: Int
    var date: String
    var toString: String {
        return String("\(date) | \(score)")
    }
    
    init(score: Int) {
        self.score = score
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        
        self.date = formatter.string(from: Date.now)
    }
}
