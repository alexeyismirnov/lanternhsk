//
//  StudyTab.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 12/19/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import SwiftUI

struct StudyTab: View {
    var body: some View {
        Text("You did not select any words for study").navigationBarTitle("Study").multilineTextAlignment(.center)
    }
}

struct StudyTab_Previews: PreviewProvider {
    static var previews: some View {
        StudyTab()
    }
}
