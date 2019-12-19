//
//  VocabRow.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 12/15/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import SwiftUI

struct VocabRow: View {
    let card: VocabCard
    var body: some View {
        VStack(alignment: .leading) {
            Text(card.word).font(.title)
            Text(card.translation).font(.subheadline).lineLimit(2)
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
