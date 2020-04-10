//
//  QuestionList.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 2/18/20.
//  Copyright © 2020 Alexey Smirnov. All rights reserved.
//

import SwiftUI

struct iWatchModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if os(watchOS)
        return GeometryReader { geometry in
            List { content }
                .environment(\.defaultMinListRowHeight, geometry.size.height)
        }
        #else
        return content
        #endif
    }
}

struct StudyVocab: View {        
    @State var answerStr : String = ""
    @State var review: Bool = false
    
    @ObservedObject var model: StudyVocabModel
        
    init(_ model: StudyVocabModel) {
        self.model = model
    }
    
    func nextQuestion() {
        if model.index == model.totalQuestions {
            return
        }
        
        answerStr = ""
        model.getNextQuestion()
    }
    
    func scheduleNextQuestion(after delay: Double) {
        if model.task == nil {
            model.task = DispatchWorkItem { self.nextQuestion() }
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: model.task!)
        }
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
        
        var content: AnyView
        
        if model.answerType == .ignored {
            content = AnyView(EmptyView().modifier(iWatchModifier()))
            scheduleNextQuestion(after: 0.5)
            
        } else if model.answerType == .correct || model.answerType == .incorrect {
            content = AnyView(QuestionAnswered(model, review: self.$review).modifier(iWatchModifier()))
            scheduleNextQuestion(after: 2.5)
            
        } else {
            content = AnyView(GetAnswer(model, answerStr: $answerStr).modifier(iWatchModifier()))
        }
        
        return AnyView(content
        .sheet(isPresented: $review,
               onDismiss: { self.nextQuestion() },
               content: { CardDetails(self.model.currentCard) })

        )
    }

}

struct QuestionList_Previews: PreviewProvider {
    static var previews: some View {
        Rectangle()
            .fill(Color.yellow)
            .frame(width: 50, height: 50)
    }
}
