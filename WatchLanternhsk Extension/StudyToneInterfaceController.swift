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
    
    @IBOutlet weak var label1: WKInterfaceLabel!
    @IBOutlet weak var label2: WKInterfaceLabel!
    
    var previousPoint: CGPoint?
    
    var deck: StudyDeck?
    let totalQuestions = 3
    var cards = [VocabCard]()
    var index = 0

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        setTitle("Draw tones")

        deck = context as? StudyDeck
        
        if let deck = deck {
            cards = (0..<totalQuestions).map {_ in
                deck.cards[Int.random(in: 0..<deck.cards.count)]
            }
        }
        
        updateUI()
    }
    
    override func willActivate() {
        super.willActivate()
        
    }
    
    func updateUI() {
        label1.setText(cards[index].word)
        label2.setText(cards[index].pinyin)
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

 
