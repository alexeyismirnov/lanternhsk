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

class ListsHostingController: WKHostingController<AnyView> {
    var studyManager: StudyManager!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.studyManager = (WKExtension.shared().delegate as! ExtensionDelegate).studyManager
    }
    
    override var body: AnyView {
        return AnyView(ListView().environmentObject(studyManager))
    }
}
