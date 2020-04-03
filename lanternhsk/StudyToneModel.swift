//
//  StudyToneModel.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 4/2/20.
//  Copyright © 2020 Alexey Smirnov. All rights reserved.
//

import SwiftUI
import Combine

class StudyToneModel: ObservableObject {
    var totalQuestions: Int
    var totalCorrect = 0
    var totalIncorrect = 0
    
    var deck: StudyDeck
 
    @Published var index: Int = 0
    @Published var toneIndex = 0
    let updateUI = PassthroughSubject<Void, Never>()

    var cards = [VocabCard]()
    var currentCard: VocabCard { cards[index] }

    var syllabi = [String]()
    var tones = [Tone]()
    var answers = [Bool]()
    
    var multiChoice = false
    
    init(deck: StudyDeck, totalQuestions: Int = 3) {
        self.deck = deck
        self.totalQuestions = totalQuestions
        
        self.cards = (0..<totalQuestions).map {_ in
            self.deck.cards[Int.random(in: 0..<deck.cards.count)]
        }
        
        print(self.cards)
    }
    
    func getCard(_ _index: Int = 0) {
        index = _index
        
        if index == totalQuestions {
            updateUI.send()
            return
        }
        
        multiChoice = cards[index].pinyin.contains("|")
        syllabi = cards[index].pinyin
            .components(separatedBy: CharacterSet(charactersIn: "| "))
            .filter { $0.count > 0 }
        
        tones = cards[index].getTones()
        
        toneIndex = 0
        answers = [Bool]()
        
        updateUI.send()
    }
    
    func toneAnswered(_ t: (Bool, Bool, Bool, Bool, Bool)) {
        var isCorrect = false
        let (isFirstTone, isSecondTone, isThirdTone, isFourthTone, isFifthTone) = t
        
        if multiChoice {
            isCorrect =  tones.contains(.first) && isFirstTone ||
                tones.contains(.second) && isSecondTone ||
                tones.contains(.third) && isThirdTone ||
                tones.contains(.fourth) && isFourthTone ||
                tones.contains(.none) && isFifthTone
            
        } else {
            switch tones[toneIndex] {
            case .first:
                isCorrect = isFirstTone
                
            case .second:
                isCorrect = isSecondTone
                
            case .third:
                isCorrect = isThirdTone
                
            case .fourth:
                isCorrect = isFourthTone
                
            case .none:
                isCorrect = isFifthTone
            }
        }
        
        answers.append(isCorrect)
        
        if multiChoice {
            toneIndex = syllabi.count
            
        } else {
            toneIndex += 1
        }
                
        if toneIndex == syllabi.count {
            if answers.contains(false) {
                totalIncorrect += 1
                
            } else {
                totalCorrect += 1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.getCard(self.index + 1)
            }
        }
        
        updateUI.send()
    }
}

