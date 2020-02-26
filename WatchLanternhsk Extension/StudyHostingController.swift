//
//  StudyHostingController.swift
//  WatchLanternhsk Extension
//
//  Created by Alexey Smirnov on 12/19/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import WatchKit
import SwiftUI
import Combine

class StudyHostingController: WKHostingController<AnyView> {
    var studyManager: StudyManager!
    var cancellable: AnyCancellable?

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.studyManager = (WKExtension.shared().delegate as! ExtensionDelegate).studyManager
        
        self.cancellable = self.studyManager.questionAdded.sink(receiveValue: {   _ in
            self.presentController(withName: "StudyTone", context: nil)
        })
    }
    
    override var body: AnyView {
        return AnyView(StudyTab().environmentObject(studyManager))
    }
}

