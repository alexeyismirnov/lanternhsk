//
//  QuestionModel.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 2/18/20.
//  Copyright © 2020 Alexey Smirnov. All rights reserved.
//

import SwiftUI
import Combine

enum AnswerType {
    case none, correct, incorrect, ignored
}

class QuestionModel: ObservableObject {
    var totalQuestions: Int
    var deck: StudyDeck
    
    var totalCorrect = 0
    var totalIncorrect = 0
    var totalIgnored = 0

    @Published var index: Int = 0
    var cards = [VocabCard]()

    init(deck: StudyDeck, totalQuestions: Int = 3) {
        self.deck = deck
        self.totalQuestions = totalQuestions
        
        self.cards = (0..<totalQuestions).map {_ in
            self.deck.cards[Int.random(in: 0..<deck.cards.count)]
        }
    }

    func getNextQuestion(answer: AnswerType) {
        if index == totalQuestions {
            return
        }
        
        switch answer {
        case .correct:
            totalCorrect += 1
        case .incorrect:
            totalIncorrect += 1
        case .ignored:
            totalIgnored += 1
        default:
            break
        }
        
        index += 1
    }
    
}
