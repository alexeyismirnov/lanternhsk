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
        Group {
            VocabRow(card: vocabData[0])
            VocabRow(card: vocabData[5])

        }
        .previewLayout(.fixed(width: 300, height: 70))

    }
}
