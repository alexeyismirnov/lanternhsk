//
//  StudyTone.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 2/25/20.
//  Copyright © 2020 Alexey Smirnov. All rights reserved.
//

import SwiftUI

struct StudyTone: View {
    @ObservedObject var model: StudyToneModel
    
    init(_ model: StudyToneModel) {
        self.model = model
        self.model.getCard()
    }

    var body: some View {
        if model.index == model.totalQuestions {
            return AnyView(
                VStack(alignment: .leading) {
                    Text("Correct: \(model.totalCorrect)")
                        .foregroundColor(.green)
                    
                    Text("Wrong: \(model.totalIncorrect)")
                        .foregroundColor(.red)
                }.font(.headline)
            )
        }
        
        var word = Text("")
        
        for i in 0..<model.answers.count {
            word = word + Text(model.currentCard.word[i])
                .foregroundColor(model.answers[i] ? .green : .red)
        }
        
        for i in model.answers.count..<model.syllabi.count {
            word = word + Text(model.currentCard.word[i])
        }

        var pinyin = Text("")
        
        for i in 0..<model.toneIndex {
            pinyin = pinyin + Text(model.syllabi[i]) + Text(" ")
        }
        
        for i in model.toneIndex..<model.syllabi.count {
            pinyin = pinyin + Text(model.syllabi[i].folding(options: .diacriticInsensitive, locale: .current)) + Text(" ")
        }
        
        let content = VStack {
            word.font(.title)
            pinyin.font(.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarTitle("Draw tone", displayMode: .inline)
        .overlay(
            ToneOverlayView { self.model.toneAnswered($0) })
            
        return AnyView(content)
    }
}
