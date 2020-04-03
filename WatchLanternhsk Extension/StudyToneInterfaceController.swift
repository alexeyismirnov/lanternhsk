//
//  StudyToneInterfaceController.swift
//  WatchLanternhsk Extension
//
//  Created by Alexey Smirnov on 2/25/20.
//  Copyright © 2020 Alexey Smirnov. All rights reserved.
//

import SwiftUI
import Combine
import WatchKit

class StudyToneInterfaceController: WKInterfaceController {
    @IBOutlet weak var label1: WKInterfaceLabel!
    @IBOutlet weak var label2: WKInterfaceLabel!
        
    var model: StudyToneModel!
    var subscription1: AnyCancellable?

    var previousPoint: CGPoint?
    let tracker = ToneGestureTracker(minOffset: 20.0, maxOffset: 40.0)

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        setTitle("Cancel")

        let deck = context as? StudyDeck
        self.model = StudyToneModel(deck: deck!)
        
        self.subscription1 = self.model.updateUI.sink(receiveValue: { _ in
            self.updateUI()
        })
        
        model.getCard()
    }
    
    deinit {
        subscription1?.cancel()
    }
    
    func updateUI() {
        if (model.index == model.totalQuestions) {
            label1.setText("Correct: \(model.totalCorrect)")
            label2.setText("Wrong: \(model.totalIncorrect)")
            return
        }
        
        var word = NSAttributedString()
        let card = model.currentCard
        
        for i in 0..<model.answers.count {
            word = word + String(card.word[i]).colored(with: model.answers[i] ? .green : .red)
        }
        
        for i in model.answers.count..<model.syllabi.count {
            word = word + String(card.word[i])

        }
        
        label1.setAttributedText(word)
        
        var pinyin = [String]()
        
        for i in 0..<model.toneIndex {
            pinyin.append(model.syllabi[i])
        }
        
        for i in model.toneIndex..<model.syllabi.count {
            pinyin.append(model.syllabi[i].folding(options: .diacriticInsensitive, locale: .current))
        }
        
        label2.setText(pinyin.joined(separator: " "))
    }
    
    @IBAction func panGesture(_ sender: Any) {
        guard let panGesture = sender as? WKPanGestureRecognizer else {
          return
        }
        
        if model.index == model.totalQuestions || model.toneIndex == model.tones.count {
            return
        }
        
        switch panGesture.state {
        case .began:
            previousPoint = panGesture.locationInObject()
            tracker.initState()
            
        case .changed:
            guard let previousPoint = previousPoint else {
                return
            }
            
            let currentPoint = panGesture.locationInObject()
            
            let diffX = (currentPoint.x - previousPoint.x)
            let diffY = (currentPoint.y - previousPoint.y)
            
            tracker.changed(diffX, diffY)
            
            self.previousPoint = currentPoint

        case .ended:
            model.toneAnswered((tracker.isFirstTone,
                                tracker.isSecondTone,
                                tracker.isThirdTone,
                                tracker.isFourthTone,
                                false))
            
        default:
            previousPoint = nil
            break
        }
    }
    
    @IBAction func tapGesture(_ sender: Any) {
        if model.index == model.totalQuestions || model.toneIndex == model.tones.count {
            return
        }
        
        model.toneAnswered((false, false, false, false, true))
    }
}

 
