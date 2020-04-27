//
//  SearchInterfaceController.swift
//  WatchLanternhsk Extension
//
//  Created by Alexey Smirnov on 4/27/20.
//  Copyright © 2020 Alexey Smirnov. All rights reserved.
//

import SwiftUI
import WatchKit

class SearchQueryInterfaceController: WKInterfaceController {
    var studyManager: StudyManager!


    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.studyManager = (WKExtension.shared().delegate as! ExtensionDelegate).studyManager

        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.presentTextInputController(withSuggestions: [""],
                                            allowedInputMode: .plain,
                                            completion: { (result) -> Void in
                                                
                                                if let choice = result?[0] as? String {
                                                    self.studyManager.searchQuery = choice
                                                }
            })
        }
        
       
    }
    
}

