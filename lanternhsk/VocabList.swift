//
//  ContentView.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 12/15/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import SwiftUI

struct VocabList: View {
    var body: some View {
        List(vocabData, rowContent: VocabRow.init)
    }
}

struct VocabList_Previews: PreviewProvider {
    static var previews: some View {
        VocabList()
    }
}
