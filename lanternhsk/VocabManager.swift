//
//  Data.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 12/15/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import SwiftUI

enum Tone: Int {
    case none = 0, first = 1, second = 2, third = 3, fourth = 4
}

extension Tone {
    init?(_ str: String) {
        let scalars = str.decomposedStringWithCanonicalMapping
            .unicodeScalars
            .map { $0.value }
            .filter { [0x300, 0x301, 0x304, 0x30C].contains($0) }
        
        if scalars.count == 0 {
            self = .none
            
        } else if scalars.count == 1 {            
            switch scalars[0] {
            case 0x304:
                self = .first
            case 0x301:
                self = .second
            case 0x30C:
                self = .third
            case 0x300:
                self = .fourth
            default:
                self = .none
            }
            
        } else {
            return nil
        }
    }
}

extension String {
    func tone(_ tone: Int) -> String {
        let diacritics = ["", "\u{0304}", "\u{0301}", "\u{030C}", "\u{0300}"]
        
        let suffix3 = self.suffix(3)
        let suffix2 = self.suffix(2)

        if suffix3 == "iao" || suffix3 == "uai" {
            return String(self.dropLast()) + diacritics[tone] + String(self.last!)
            
        } else if suffix2 == "ai" || suffix2 == "ei" ||  suffix2 == "ao" || suffix2 == "ou" {
            return String(self.dropLast()) + diacritics[tone] + String(self.last!)

        } else {
            let pattern = "(.*)([aoeiu])(.*)"
            let regex = try! NSRegularExpression(pattern: pattern)

            let text2 = NSMutableString(string: self)

            regex.replaceMatches(in: text2,
                                 options: .reportProgress,
                                 range: NSRange(location: 0,length: text2.length),
                                 withTemplate: "$1$2"  + diacritics[tone] + "$3")
            
            return String(text2)
        }
    }
}

struct VocabCard: Identifiable {
    var id: UUID
    var word: String
    var pinyin: String
    var translation: String
    var entity: AnyObject?
   
    func getTones() -> [Tone] {
        var tones = [Tone]()
        for str in pinyin
            .components(separatedBy: CharacterSet(charactersIn: "| ")) 
            .filter({ $0.count > 0 }) {
            if let tone = Tone(str) {
                tones.append(tone)
            }
        }
        
        return tones
    }
}

extension VocabCard {
    init(entity: CardEntity, charType: SettingsCharType) {
        self.init(id: entity.id!,
                  word: charType == .traditional ? entity.wordTrad! : entity.wordSimp!,
                  pinyin: entity.pinyin!,
                  translation: entity.translation!,
                  entity: entity)
    }
    
    init(entity: CloudCardEntity) {
        self.init(id: entity.id!,
                  word: entity.word!,
                  pinyin: entity.pinyin!,
                  translation: entity.translation!,
                  entity: entity)
    }
}
