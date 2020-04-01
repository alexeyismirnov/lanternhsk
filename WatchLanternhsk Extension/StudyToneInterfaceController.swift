//
//  StudyToneInterfaceController.swift
//  WatchLanternhsk Extension
//
//  Created by Alexey Smirnov on 2/25/20.
//  Copyright © 2020 Alexey Smirnov. All rights reserved.
//

import Foundation
import WatchKit

enum CheckmarkPhases {
    case initialPoint
    case downStroke
    case upStroke
    case error
}

class StudyToneInterfaceController: WKInterfaceController {
    @IBOutlet weak var label1: WKInterfaceLabel!
    @IBOutlet weak var label2: WKInterfaceLabel!
    
    var previousPoint: CGPoint?
    var offsetX: CGFloat = 0.0
    var offsetY: CGFloat = 0.0

    var deck: StudyDeck?
    let totalQuestions = 3
    var totalCorrect = 0
    var totalWrong = 0
    
    var cards = [VocabCard]()
    
    var index = 0
    var toneIndex = 0
    var tonePhase : CheckmarkPhases = .initialPoint
    
    var syllabi = [String]()
    var tones = [Tone]()
    var answers = [Bool]()
    
    var multiChoice = false
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        setTitle("Cancel")

        deck = context as? StudyDeck
        
        if let deck = deck {
            cards = (0..<totalQuestions).map {_ in
                deck.cards[Int.random(in: 0..<deck.cards.count)]
            }
        }
        
        getCard()
    }
    
    func getCard(_ _index: Int = 0) {
        index = _index
        
        if index == totalQuestions {
            updateUI()
            return
        }
        
        multiChoice = cards[index].pinyin.contains("|")
        syllabi = cards[index].pinyin
            .components(separatedBy: CharacterSet(charactersIn: "| "))
            .filter { $0.count > 0 }
        
        tones = cards[index].getTones()

        toneIndex = 0
        answers = [Bool]()
        
        updateUI()
    }
    
    func updateUI() {
        if (index == totalQuestions) {
            label1.setText("Correct: \(totalCorrect)")
            label2.setText("Wrong: \(totalWrong)")
            return
        }
        
        var word = NSAttributedString()
        
        for i in 0..<answers.count {
            word = word + String(cards[index].word[i]).colored(with: answers[i] ? .green : .red)
        }
        
        for i in answers.count..<syllabi.count {
            word = word + String(cards[index].word[i])

        }
        
        label1.setAttributedText(word)
        
        var str = [String]()
        
        for i in 0..<toneIndex {
            str.append(syllabi[i])
        }
        
        for i in toneIndex..<syllabi.count {
            str.append(syllabi[i].folding(options: .diacriticInsensitive, locale: .current))
        }
        
        label2.setText(str.joined(separator: " "))
    }
    
    func toneAnswered(isCorrect: Bool) {
        answers.append(isCorrect)
        
        if multiChoice {
            toneIndex = syllabi.count
            
        } else {
            toneIndex += 1
        }
        
        updateUI()
        
        if toneIndex == syllabi.count {
            if answers.contains(false) {
                totalWrong += 1
            } else {
                totalCorrect += 1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.getCard(self.index + 1)
            }
        }
        
    }
    
    @IBAction func panGesture(_ sender: Any) {
        var isFirstTone: Bool { abs(offsetY) < 20.0 && offsetX > 40.0 }
        var isSecondTone: Bool { offsetY < -40.0 && offsetX > 40.0 }
        var isThirdTone: Bool { tonePhase == .upStroke && offsetY < -40.0 }
        var isFourthTone: Bool { offsetY > 40.0 && offsetX > 40.0 }
        
        guard let panGesture = sender as? WKPanGestureRecognizer else {
          return
        }
        
        if index == totalQuestions || toneIndex == tones.count {
            return
        }
        
        switch panGesture.state {
        case .began:
            previousPoint = panGesture.locationInObject()
            offsetX = 0.0
            offsetY = 0.0
            tonePhase = .initialPoint

        case .changed:
            guard let previousPoint = previousPoint else {
                return
            }
            
            let currentPoint = panGesture.locationInObject()
            
            let diffX = (currentPoint.x - previousPoint.x)
            let diffY = (currentPoint.y - previousPoint.y)
            
            offsetX += diffX
            offsetY += diffY
            
            self.previousPoint = currentPoint
            
            if multiChoice || tones[toneIndex] == .third {
                switch tonePhase {
                case .initialPoint:
                    tonePhase =  (diffX >= 0.0 && diffY >= 0) ? .downStroke : .error
                   
                case .downStroke:
                    if diffX >= 0.0 && diffY >= 0 {
                        // downStroke
                        
                    } else if diffX >= 0.0 && diffY < 0.0 && offsetY > 40.0 {
                        tonePhase = .upStroke
                        offsetY = 0.0
                        
                    } else {
                        tonePhase = .error
                    }
                    
                case .upStroke:
                    tonePhase = diffX >= 0.0 && diffY <= 0  ? .upStroke : .error

                default:
                    break
                }
            }
            
        case .ended:
            if multiChoice {
                toneAnswered(isCorrect: tones.contains(.first) && isFirstTone ||
                        tones.contains(.second) && isSecondTone ||
                        tones.contains(.third) && isThirdTone ||
                        tones.contains(.fourth) && isFourthTone)
                
            } else {
                switch tones[toneIndex] {
                case .first:
                    toneAnswered(isCorrect: isFirstTone)
                   
                case .second:
                    toneAnswered(isCorrect: isSecondTone)
                    
                case .third:
                    toneAnswered(isCorrect: isThirdTone)
                    
                case .fourth:
                    toneAnswered(isCorrect: isFourthTone)
                   
                default:
                    toneAnswered(isCorrect: false)
                }
            }
            
        default:
            previousPoint = nil
            break
        }
    }
    
    @IBAction func tapGesture(_ sender: Any) {
        if index == totalQuestions || toneIndex == tones.count {
            return
        }
        
        let isCorrect = multiChoice
            ? tones.contains(.none)
            : tones[toneIndex] == .none
        
        toneAnswered(isCorrect: isCorrect)
    }
}

 
