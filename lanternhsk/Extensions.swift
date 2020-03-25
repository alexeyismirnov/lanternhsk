//
//  Extensions.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 2/28/20.
//  Copyright © 2020 Alexey Smirnov. All rights reserved.
//

import UIKit
import SwiftUI

struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}


public extension String {
    func colored(with color: UIColor) -> NSAttributedString {
        return NSAttributedString(string: self).colored(with: color)
    }
    
    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}

public extension NSAttributedString {
    
    var centered: NSAttributedString {
        let centerStyle = NSMutableParagraphStyle()
        centerStyle.alignment = .center
        
        return applying(attributes: [.paragraphStyle: centerStyle])
    }
    
    func colored(with color: UIColor) -> NSAttributedString {
        return applying(attributes: [.foregroundColor: color])
    }
    
    func font(font: UIFont) -> NSAttributedString {
        return applying(attributes: [.font: font])
    }
    
    func systemFont(ofSize: CGFloat) -> NSAttributedString {
        return applying(attributes: [.font: UIFont.systemFont(ofSize: CGFloat(ofSize))])
    }
    
    func boldFont(ofSize: CGFloat) -> NSAttributedString {
        return applying(attributes: [.font: UIFont.boldSystemFont(ofSize: CGFloat(ofSize))])
    }
    
    fileprivate func applying(attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        let copy = NSMutableAttributedString(attributedString: self)
        let range = (string as NSString).range(of: string)
        copy.addAttributes(attributes, range: range)
        
        return copy
    }
    
    static func += (lhs: inout NSAttributedString, rhs: NSAttributedString) {
        let string = NSMutableAttributedString(attributedString: lhs)
        string.append(rhs)
        lhs = string
    }
    
    static func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
        let string = NSMutableAttributedString(attributedString: lhs)
        string.append(rhs)
        return NSAttributedString(attributedString: string)
    }
    
    static func += (lhs: inout NSAttributedString, rhs: String) {
        lhs += NSAttributedString(string: rhs)
    }
    
    static func + (lhs: NSAttributedString, rhs: String) -> NSAttributedString {
        return lhs + NSAttributedString(string: rhs)
    }
    
}
