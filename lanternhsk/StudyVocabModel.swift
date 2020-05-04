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

enum StudyModelType {
    case translation, pinyin
}

class StudyVocabModel: ObservableObject {
    let totalQuestions: Int
    let type: StudyModelType
    
    var totalCorrect = 0
    var totalIncorrect = 0
    var totalIgnored = 0

    @Published var index: Int = 0
    @Published var answerType: AnswerType = .none

    var cards = [VocabCard]()
    var currentCard: VocabCard { cards[index] }
    
    var task: DispatchWorkItem?

    init(_ type: StudyModelType, deck: StudyDeck) {
        self.type = type
        self.totalQuestions = Int(SettingsModel.shared.numQuestions)
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
    
    func checkTranslation(_ answer: String) {
        let trans = currentCard.translation.lowercased()
            .components(separatedBy: CharacterSet(charactersIn: " ;,!?()|"))
            .filter { $0.count > 2 }
        
        let ans = answer.lowercased()
            .components(separatedBy: CharacterSet(charactersIn: " ;,!?()|"))
            .filter { $0.count > 2 }
        
        if ans.count == 0 || ans.filter({ !trans.contains($0) }).count > 0 {
            answerType = .incorrect
            totalIncorrect += 1
            
        } else {
            answerType = .correct
            totalCorrect += 1
        }
    }
    
    func checkPinyin(_ answer: String) {
        let pinyin = currentCard.pinyin.lowercased()
            .folding(options: .diacriticInsensitive, locale: nil)
                
        let comp = pinyin.lowercased()
            .components(separatedBy: CharacterSet(charactersIn: "|, "))
            .filter({ $0.count > 0 })
        
        if pinyin.contains("|") || pinyin.contains(",") {
            if comp.contains(answer) {
                answerType = .correct
                totalCorrect += 1
            } else {
                answerType = .incorrect
                totalIncorrect += 1
            }
            
        } else {
            let str = answer.components(separatedBy:
                CharacterSet
                    .decimalDigits
                    .union(CharacterSet.whitespaces))
                .joined()
            
            if comp.joined() == str {
                answerType = .correct
                totalCorrect += 1
            } else {
                answerType = .incorrect
                totalIncorrect += 1
            }
            
        }
    }
    
    func checkChinese(_ answer: String) {
        if currentCard.word.components(separatedBy: CharacterSet.whitespaces).joined() ==
            answer.components(separatedBy: CharacterSet.whitespaces).joined() {
            answerType = .correct
            totalCorrect += 1
        } else {
            answerType = .incorrect
            totalIncorrect += 1
        }
    }
    
    func answered(_ answer: String?) {
        if var answer = answer {
            answer = answer
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            if type == .translation {
                checkTranslation(answer)
                
            } else {
                if answer.range(of: "\\p{Han}", options: .regularExpression) != nil {
                    checkChinese(answer)
                } else {
                    checkPinyin(answer.folding(options: .diacriticInsensitive, locale: nil))
                }
            }
            
        } else {
            answerType = .ignored
            totalIgnored += 1
        }
    }
}
