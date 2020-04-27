//
//  HostingController.swift
//  WatchLanternhsk Extension
//
//  Created by Alexey Smirnov on 12/15/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import WatchKit
import SwiftUI
import Combine

class SearchResultsHostingController: WKHostingController<AnyView> {
    var studyManager: StudyManager!
    var query: String!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.studyManager = (WKExtension.shared().delegate as! ExtensionDelegate).studyManager
        self.query = context as! String
    }
    
    override var body: AnyView {
        return AnyView(SearchView(query: self.query).environmentObject(studyManager))
    }
}

class ListsHostingController: WKHostingController<AnyView> {
    var studyManager: StudyManager!
    var cancellable: AnyCancellable?
    var searchCancellable: AnyCancellable?

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.studyManager = (WKExtension.shared().delegate as! ExtensionDelegate).studyManager
        
        self.cancellable = self.studyManager.searchStarted.sink(receiveValue: {   _ in
            self.presentController(withName: "SearchQuery", context: nil)
        })
        
        self.searchCancellable = self.studyManager.$searchQuery.sink(receiveValue: { query in
            self.dismiss()
            self.presentController(withName: "SearchResults", context: query)

        })
                   
    }
    
    override var body: AnyView {
        return AnyView(ListView().environmentObject(studyManager))
    }
}
