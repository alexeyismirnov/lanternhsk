//
//  VocabRow.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 12/15/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import SwiftUI
import CoreData

struct ImageButton: View {
    let iconName: String
    let handler: () -> Void
    
    let frameSize: CGFloat
    
    init(iconName: String, handler: @escaping () -> Void, frameSize: CGFloat = 50.0) {
        self.iconName = iconName
        self.handler = handler
        self.frameSize = frameSize
    }
    
    var body: some View {
        VStack() {
            Image(systemName: iconName)
                .resizable()
                .scaledToFit()
                .foregroundColor(.yellow)
                .padding(10.0)
                
        }.onTapGesture {
            self.handler()
        }
        .frame(width: frameSize, height: frameSize)
    }
}

private struct CardModalItem: Identifiable {
    let id = UUID()
    let card: VocabCard
}

private struct CardRowSideOne: View {
    @EnvironmentObject var studyManager: StudyManager
    @State var cardDetails: CardModalItem?
    
    @Binding var card: VocabCard
    
    var isStarred: Bool {
        return studyManager.isStarred(card: card)
    }

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                Spacer()
                ImageButton(iconName: isStarred ? "star.fill": "star",
                            handler: {
                                if (self.isStarred) {
                                    self.studyManager.removeFromStudy(card: self.card)
                                    
                                } else {
                                    self.studyManager.addToStudy(card: self.card)
                                }
                })
                
                ImageButton(iconName: "info.circle", handler: {
                    self.cardDetails = CardModalItem(card: self.card)
                    
                }).sheet(item: $cardDetails, content: { CardDetails(card: $0.card) })
                
            }.frame(maxHeight: .infinity, alignment: .top)
            
            VStack(alignment: .leading) {
                Text(card.word).font(.title)
                Text(card.pinyin).font(.subheadline)
            }
            .padding([.top, .bottom], 5.0)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct CardRowSideTwo: View {
    let card: VocabCard
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(card.translation)
                .multilineTextAlignment(.leading)
        }
    }
}

struct CardRow: View {
    @State private var flipped: Bool = false
    
    @Binding var card: VocabCard
    
    init(card: Binding<VocabCard>) {
        self._card = card
    }
    
    var body: some View {
        ZStack {
            CardRowSideOne(card: $card)
                .rotation3DEffect(.degrees(self.flipped ? 180.0 : 0.0), axis: (x: 1.0, y: 0.0, z: 0.0))
                .zIndex(self.flipped ? 0 : 1)
                .opacity(self.flipped ? 0 : 1)
            
            CardRowSideTwo(card: card)
                .rotation3DEffect(.degrees(self.flipped ? 0.0 : 180.0), axis: (x: -1.0, y: 0.0, z: 0.0))
                .zIndex(self.flipped ? 1 : 0)
                .opacity(self.flipped ? 1 : 0)
        }
        .contentShape(Rectangle())
        .onTapGesture { self.handleFlipViewTap() }
    }
    
    func handleFlipViewTap() -> Void {
        withAnimation(.easeOut(duration:0.25)) {
            self.flipped.toggle()
        }
    }
}

struct VocabRow_Previews: PreviewProvider {
    static var previews: some View {
        Rectangle()
            .fill(Color.yellow)
            .frame(width: 50, height: 50)
    }
}
