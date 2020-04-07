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

class StudyVocabModel: ObservableObject {
    var totalQuestions: Int
    
    var totalCorrect = 0
    var totalIncorrect = 0
    var totalIgnored = 0

    @Published var index: Int = 0
    @Published var answerType: AnswerType = .none

    var cards = [VocabCard]()
    var currentCard: VocabCard { cards[index] }
    
    var task: DispatchWorkItem?

    init(deck: StudyDeck, totalQuestions: Int = 3) {
        self.totalQuestions = totalQuestions
        self.cards = deck.shuffle(totalQuestions: totalQuestions)
    }

    func getNextQuestion() {
        if index == totalQuestions {
            return
        }
        
        task = nil
        answerType = .none
        index += 1
    }
    
    func answered(_ answer: String?) {
        if let answer = answer {
            if currentCard.translation.lowercased()
                .contains(answer
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .lowercased()) {
                answerType = .correct
                totalCorrect += 1

            } else {
                answerType = .incorrect
                totalIncorrect += 1
            }
            
        } else {
            answerType = .ignored
            totalIgnored += 1
        }

    }
}
