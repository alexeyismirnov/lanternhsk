//
//  StudyToneInterfaceController.swift
//  WatchLanternhsk Extension
//
//  Created by Alexey Smirnov on 2/25/20.
//  Copyright © 2020 Alexey Smirnov. All rights reserved.
//

import Foundation
import WatchKit

class StudyToneInterfaceController: WKInterfaceController {
    var previousPoint: CGPoint?

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        super.willActivate()
        
        setTitle("Draw tones")
    }
    
    @IBAction func panGesture(_ sender: Any) {
        guard let panGesture = sender as? WKPanGestureRecognizer else {
          return
        }
        
        switch panGesture.state {
        case .began:
          previousPoint = panGesture.locationInObject()

        case .changed:
          guard let previousPoint = previousPoint else {
            return
          }
          let currentPanPoint = panGesture.locationInObject()
          let deltaX = currentPanPoint.x - previousPoint.x
          let deltaY = currentPanPoint.y - previousPoint.y
          
          print("\(deltaX) \(deltaY)")

          self.previousPoint = currentPanPoint

        default:
          previousPoint = nil
          break
        }
    }
    
    @IBAction func tapGesture(_ sender: Any) {
        print("Tap gesture")
    }
}

 
