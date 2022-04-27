//
//  NewPoint.swift
//  maze-man
//
//  Created by Cony Lee on 4/13/22.
//

import Foundation
import SpriteKit
import GameplayKit

class NewPoint {
    var point: CGPoint
    var iterations: [CGPoint]
    var duration: TimeInterval
    
    init(point: CGPoint, iterations: [CGPoint], duration: Int) {
        self.point = point
        self.iterations = iterations
        self.duration = TimeInterval(duration)
    }
    
    init() {
        self.point = CGPoint(x: 0, y: 0)
        self.iterations = [point]
        self.duration = 0
    }
}
