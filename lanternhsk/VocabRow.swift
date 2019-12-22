//
//  VocabRow.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 12/15/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import SwiftUI

struct ImageButton: View {
    let iconName: String
    let handler: () -> Void
    
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
        .frame(width: 40, height: 40)
    }
}

struct HeightPreferenceKey: PreferenceKey {
    typealias Value = CGFloat

    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct VocabRowItemGeometry: View {
    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(Color.clear)
                .preference(key: HeightPreferenceKey.self, value: geometry.size.height)
        }
    }
}

struct VocabRowSideOne: View {
    let card: VocabCard
    @State var starred: Bool = false
    
    var body: some View {
        ZStack() {
            HStack(spacing: 0) {
                Spacer()
                ImageButton(iconName: starred ? "star.fill": "star", handler: {
                    self.starred = !self.starred
                    print("action2") })
                ImageButton(iconName: "ellipsis", handler: { print("action1") })
                
            }.frame(maxHeight: .infinity, alignment: .top)
            
            VStack(alignment: .leading) {
                Text(card.word).font(.title)
                Text(card.pinyin).font(.subheadline)
            }
            .padding([.top, .bottom], 5.0)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(VocabRowItemGeometry())
            
        }
    }
}

struct VocabRowSideTwo: View {
    let card: VocabCard
    let maxHeight: CGFloat
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(card.translation)
                .multilineTextAlignment(.leading)
        }.frame(height: maxHeight)
    }
}

struct VocabRow: View {
    let card: VocabCard
    @State private var flipped: Bool = false
    @State var maxHeight : CGFloat
    
    init(card: VocabCard, height: CGFloat = 0.0) {
        self.card = card
        _maxHeight = State(initialValue: height)
    }
    
    var body: some View {
        ZStack {
            VocabRowSideOne(card: card)
                .rotation3DEffect(.degrees(self.flipped ? 180.0 : 0.0), axis: (x: 1.0, y: 0.0, z: 0.0))
                .zIndex(self.flipped ? 0 : 1)
                .opacity(self.flipped ? 0: 1)
            
            VocabRowSideTwo(card: card, maxHeight: maxHeight)
                .rotation3DEffect(.degrees(self.flipped ? 0.0 : 180.0), axis: (x: -1.0, y: 0.0, z: 0.0))
                .zIndex(self.flipped ? 1 : 0)
                .opacity(self.flipped ? 1: 0)
        }
        .contentShape(Rectangle())
        .onTapGesture { self.handleFlipViewTap() }
        .onPreferenceChange(HeightPreferenceKey.self) {
            if $0 > self.maxHeight {
                self.maxHeight = $0
            }
        }
    }
    
    func handleFlipViewTap() -> Void {
        withAnimation(.easeOut(duration:0.25)) {
            self.flipped.toggle()
        }
    }
}

struct VocabRow_Previews: PreviewProvider {
    static var previews: some View {
        let cards: [VocabCard] = lists[0].load()
        return Group {
            VocabRow(card: cards[0])
            VocabRow(card: cards[5])

        }
        .previewLayout(.fixed(width: 300, height: 70))

    }
}
