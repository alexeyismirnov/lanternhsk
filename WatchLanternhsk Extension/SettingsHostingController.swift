//
//  SettingsHostingController.swift
//  WatchLanternhsk Extension
//
//  Created by Alexey Smirnov on 4/9/20.
//  Copyright © 2020 Alexey Smirnov. All rights reserved.
//

import WatchKit
import SwiftUI

class SettingsHostingController: WKHostingController<AnyView> {
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // self.studyManager = (WKExtension.shared().delegate as! ExtensionDelegate).studyManager
    }
    
    override var body: AnyView {
        return AnyView(SettingsView())
    }
}

