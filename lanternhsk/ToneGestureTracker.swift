//
//  ToneGestureTracker.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 4/3/20.
//  Copyright © 2020 Alexey Smirnov. All rights reserved.
//

import UIKit

enum CheckmarkPhases {
    case initialPoint
    case downStroke
    case upStroke
    case error
}

class ToneGestureTracker {
    var strokePhase : CheckmarkPhases = .initialPoint
    
    var offsetX: CGFloat = 0.0
    var offsetY: CGFloat = 0.0
    var offset3rdTone: CGFloat = 0.0
    
    let minOffset: CGFloat
    let maxOffset: CGFloat
    
    var isFirstTone: Bool {
        abs(offsetY) < minOffset && abs(offset3rdTone) < minOffset && offsetX > maxOffset
    }
    
    var isSecondTone: Bool {
        strokePhase != .upStroke && offsetY < -maxOffset && offsetX > maxOffset
    }
    
    var isThirdTone: Bool {
        strokePhase == .upStroke && offset3rdTone < -maxOffset
    }
    
    var isFourthTone: Bool {
        strokePhase != .upStroke && offsetY > maxOffset && offsetX > maxOffset
    }
    
    init(minOffset: CGFloat, maxOffset: CGFloat) {
        self.minOffset = minOffset
        self.maxOffset = maxOffset
    }
    
    func initState() {
        self.strokePhase = .initialPoint
        
        offsetX = 0.0
        offsetY = 0.0
        offset3rdTone = 0.0
    }
    
    func changed(_ diffX: CGFloat, _ diffY: CGFloat) {
        offsetX += diffX
        offsetY += diffY
        offset3rdTone += diffY
        
        // print("\(offsetX) \(offsetY) \(offset3rdTone)")
        
        // 3rd tone tracking
        
        if strokePhase == .initialPoint {
            strokePhase = (diffX >= 0.0 && diffY >= 0) ? .downStroke : .error
            
        } else if strokePhase == .downStroke {
            if diffX >= 0.0 && diffY >= 0 {
                // downStroke
                
            } else if diffX >= 0.0 && diffY < 0.0 && offset3rdTone > maxOffset {
                strokePhase = .upStroke
                offset3rdTone = 0.0
                
            } else {
                strokePhase = .error
            }
            
        } else if strokePhase == .upStroke {
            strokePhase = diffX >= 0.0 && diffY <= 0  ? .upStroke : .error
        }
    }
    
}
