//
//  HostingController.swift
//  WatchLanternhsk Extension
//
//  Created by Alexey Smirnov on 12/15/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import WatchKit
import Foundation
import SwiftUI

class ListsHostingController: WKHostingController<ListsTab<VocabListWatch>> {
    override var body: ListsTab<VocabListWatch> {
        return ListsTab(producer: { VocabListWatch(deck: $0) })
    }
}
