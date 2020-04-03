//
//  ToneGestureRecognizer.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 4/3/20.
//  Copyright © 2020 Alexey Smirnov. All rights reserved.
//

import UIKit
import SwiftUI

class CheckmarkGestureRecognizer : UIGestureRecognizer {
    var trackedTouch : UITouch? = nil
    static let tracker = ToneGestureTracker(minOffset: 40.0, maxOffset: 120.0)
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        
        if touches.count != 1 {
            self.state = .failed
        }
        
        // Capture the first touch and store some information about it.
        if self.trackedTouch == nil {
            CheckmarkGestureRecognizer.tracker.initState()
            self.trackedTouch = touches.first
            
        } else {
            // Ignore all but the first touch.
            for touch in touches {
                if touch != self.trackedTouch {
                    self.ignore(touch, for: event)
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        let newTouch = touches.first
        
        guard newTouch == self.trackedTouch else {
            self.state = .failed
            return
        }
        
        let newPoint = (newTouch?.location(in: self.view))!
        let previousPoint = (newTouch?.previousLocation(in: self.view))!
        
        let diffX = (newPoint.x - previousPoint.x)
        let diffY = (newPoint.y - previousPoint.y)
        
        if abs(diffX) < 5.0 && abs(diffY) < 5.0 {
            return
        }
        
        CheckmarkGestureRecognizer.tracker.changed(diffX, diffY)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        let newTouch = touches.first
        
        guard newTouch == self.trackedTouch else {
            self.state = .failed
            return
        }
        
        if self.state == .possible  {
            self.state = .recognized
            
        } else {
            self.state = .failed
        }
        
        self.trackedTouch = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        
        self.state = .cancelled
        self.trackedTouch = nil

    }
    
    override func reset() {
        super.reset()
        self.trackedTouch = nil
    }
    
}

typealias ToneCallback = ((Bool, Bool, Bool, Bool, Bool)) -> Void

struct ToneOverlayView: UIViewRepresentable {
    var callback: ToneCallback
    
    typealias UIViewType = UIView
    
    func makeCoordinator() -> ToneOverlayView.Coordinator {
        Coordinator(callback: self.callback)
    }
    
    func makeUIView(context: UIViewRepresentableContext<ToneOverlayView>) -> UIView {
        let view = UIView()
        
        let tap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(sender:)))
        
        let checkmark = CheckmarkGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTone(sender:)))
        
        checkmark.require(toFail: tap)
        
        view.addGestureRecognizer(tap)
        view.addGestureRecognizer(checkmark)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<ToneOverlayView>) {
    }
    
    class Coordinator {
        var callback: ToneCallback
        
        init(callback: @escaping ToneCallback) {
            self.callback = callback
        }
        
        @objc func handleTap(sender: UITapGestureRecognizer) {
            self.callback((false, false, false, false, true))
        }
        
        @objc func handleTone(sender: UIGestureRecognizer) {
            let t = CheckmarkGestureRecognizer.tracker
            self.callback((t.isFirstTone, t.isSecondTone, t.isThirdTone, t.isFourthTone, false))
        }
    }
    
    
}

