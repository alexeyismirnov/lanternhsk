//
//  QuestionList.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 2/18/20.
//  Copyright © 2020 Alexey Smirnov. All rights reserved.
//

import SwiftUI

struct QuestionList: View {    
    @State var answerType = AnswerType.none
    @State var answerStr : String = ""
    @State var review: Bool = false
    
    @ObservedObject var model: QuestionModel
        
    init(model: QuestionModel) {
        self.model = model
    }
    
    func nextQuestion() {
        if model.index == model.totalQuestions {
            return
        }
        
        model.getNextQuestion(answer: answerType)
        answerType = .none
        answerStr = ""
    }
    
    var body: some View {
        if model.index == model.totalQuestions {
            return AnyView(
                VStack(alignment: .leading) {
                    Text("Correct: \(model.totalCorrect)")
                        .foregroundColor(.green)
                    
                    Text("Wrong: \(model.totalIncorrect)")
                        .foregroundColor(.red)
                    
                    Text("Skipped: \(model.totalIgnored)")
                        .foregroundColor(.yellow)
                }.font(.headline)
            )
        }
        
        if answerType != .none {
            let delay = answerType == .ignored ? 0.5 : 2.5
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if !self.review && self.answerType != .none  {
                    self.nextQuestion()
                }
            }
        }
        
        var content: some View {
            #if os(watchOS)
            return GeometryReader { geometry in
                List {
                    StudyVocab(card: self.model.cards[self.model.index],
                             answerType: self.$answerType,
                             answerStr: self.$answerStr,
                             review: self.$review)
                    
                }.environment(\.defaultMinListRowHeight, geometry.size.height)
            }
            
            #else
            return StudyVocab(card: self.model.cards[self.model.index],
                            answerType: $answerType,
                            answerStr: $answerStr,
                            review: self.$review)
            #endif
        }
        
        return AnyView(content
        .sheet(isPresented: $review,
               onDismiss: { self.nextQuestion() },
               content: { VocabDetails(card: self.model.cards[self.model.index]) })

        )
    }

}

struct QuestionList_Previews: PreviewProvider {
    static var previews: some View {
        let cards: [VocabCard] = lists[0].load()
               let deck = StudyDeck(id: 0, name:"", cards: cards)
        return QuestionList(model: QuestionModel(deck: deck))
    }
}
