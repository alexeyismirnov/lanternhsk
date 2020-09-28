//
//  StudyRow.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 12/31/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import SwiftUI

fileprivate extension Image {
    func height50(color: Color) -> some View {
        self
            .resizable()
            .scaledToFit()
            .foregroundColor(color)
            .frame(height: 50)
    }
}

struct SmallButton: View {
    enum ButtonType: Int { case skip, review }
    let type: ButtonType
    let callback: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: type == .skip
                ? "arrow.right.circle"
                : "info.circle")
            Text(type == .skip ? "Skip": "Review").font(.headline)
        }
        .padding()
        .frame(width: 150, alignment: .center)
        .onTapGesture {
            self.callback()
        }
    }
}

struct QuestionAnswered: View {
    @Binding var review: Bool
    @ObservedObject var model: StudyVocabModel

    let answerType: AnswerType
    let color: Color
    
    init(_ model: StudyVocabModel, review: Binding<Bool>) {
        self._review = review
        self.model = model
        self.answerType = model.answerType
        self.color = self.answerType == .correct ? .green : .red
    }
    
    var body: some View {
        VStack {
            Spacer()

            Image(systemName: answerType == .correct
                ? "checkmark.circle"
                : "multiply.circle")
                .height50(color: color)
            
            Text(answerType == .correct
                ? "Correct"
                : "Incorrect")
                .font(.title)
                .foregroundColor(color)
            
            Spacer()

            SmallButton(type: .review) {
                self.model.task?.cancel()
                self.review = true
            }
        }
        .transition(AnyTransition.opacity
        .animation(.easeInOut(duration: 0.5)))
    }
}

struct GetAnswer: View {
    @ObservedObject var model: StudyVocabModel
    @Binding var answerStr: String

    init(_ model: StudyVocabModel, answerStr: Binding<String>) {
        self.model = model
        self._answerStr = answerStr
    }
        
    var body: some View {
        let placeholder = model.type == .translation
            ? "Translate"
            : "Pinyin"
        
        return VStack {
            Spacer().layoutPriority(10)
            VStack {
                Text(model.currentCard.word).font(.title)
                
                #if os(iOS)
                TextField(placeholder,
                          text: $answerStr,
                          onCommit: {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                            to: nil,
                                                            from: nil,
                                                            for: nil)
                            self.model.answered(self.answerStr)
                            
                          }).ignoresSafeArea(.keyboard, edges: .bottom)
                    .multilineTextAlignment(.center)
                
                #else
                TextField(placeholder, text: $answerStr, onCommit: {
                    self.model.answered(self.answerStr)
                }).multilineTextAlignment(.center)
                
                #endif
            }
            
            Spacer().layoutPriority(10)
            
            SmallButton(type: .skip) { self.model.answered(nil) }
        }
        .transition(AnyTransition.opacity
        .animation(.easeInOut(duration: 0.5)))
    }
}

struct StudyRow_Previews: PreviewProvider {
    static var previews: some View {
        Rectangle()
            .fill(Color.yellow)
            .frame(width: 50, height: 50)
    }
}
