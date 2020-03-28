//
//  AddCard.swift
//  coredata2
//
//  Created by Alexey Smirnov on 3/18/20.
//  Copyright © 2020 Alexey Smirnov. All rights reserved.
//

import SwiftUI

struct LabelTextField : View {
    var label: String
    
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(label).font(.headline)
            
            TextField("", text: self.$text)
                .padding(.all)
                .background(Color.white.opacity(0.5))
                .cornerRadius(5.0)
            }
            .padding(10)
        
    }
}

struct AddCard: View {
    @State private var wordInput = ""
    @State private var pinyinInput = ""
    @State private var translationInput = ""
    @State private var selectorIndex = 0
    @State private var csvInput = ""
    
    @Binding var sheetVisible: Bool

    var list: CloudListEntity
    var section: CloudSectionEntity
    
    func loadCSV(_ dataString: String) -> [VocabCard] {
        var items = [VocabCard]()
        let lines: [String] = dataString.components(separatedBy: NSCharacterSet.newlines) as [String]

        for line in lines {
            var values: [String] = []
            if line != "" {
                if line.range(of: "\"") != nil {
                    var textToScan:String = line
                    var value:String?
                    var textScanner:Scanner = Scanner(string: textToScan)
                    while textScanner.string != "" {
                        if (textScanner.string as NSString).substring(to: 1) == "\"" {
                            textScanner.currentIndex = textScanner.string.index(after: textScanner.currentIndex)
                            value = textScanner.scanUpToString("\"")
                            textScanner.currentIndex = textScanner.string.index(after: textScanner.currentIndex)
                        } else {
                            value = textScanner.scanUpToString(",")
                        }

                         values.append(value ?? "")

                         if textScanner.currentIndex < textScanner.string.endIndex {
                            textScanner.currentIndex = textScanner.string.index(after: textScanner.currentIndex)
                            textToScan = String(textScanner.string[textScanner.currentIndex...])
                         } else {
                             textToScan = ""
                         }
                         textScanner = Scanner(string: textToScan)
                    }

                    // For a line without double quotes, we can simply separate the string
                    // by using the delimiter (e.g. comma)
                } else  {
                    values = line.components(separatedBy: ",")
                }
            }
            
            if values.count > 0 {
                var tones = [String]()
                
                for var pinyin in values[1].components(separatedBy: " ") {
                    if let tone = Tone(pinyin) {
                        if tone == .none {
                            let s1 = pinyin.components(separatedBy: CharacterSet.decimalDigits).joined()
                            let s2 = pinyin.components(separatedBy: CharacterSet.decimalDigits.inverted).filter { $0.count > 0 }.first
                            
                            let tone = Int(s2 ?? "0")!
                            
                            if tone >= 1 && tone <= 4 {
                                pinyin = s1.tone(tone)
                            } else {
                                pinyin = s1 // tone can be "5"
                            }
                        }
                        
                        tones.append(pinyin)
                        
                    } else {
                        print("Invalid pinyin \(pinyin)")
                    }
                }
                
                items.append(VocabCard(id: UUID(),
                                       word: values[0],
                                       pinyin: tones.joined(separator: " "),
                                       translation: values[2],
                                       entity: nil
                ))
            }
        }
        
        return items
    }
     
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Picker("", selection: $selectorIndex) {
                        Text("Single").tag(0)
                        Text("Multiple").tag(1)
                        
                    }.pickerStyle(SegmentedPickerStyle())
                    
                    (selectorIndex == 0) ?
                    AnyView(VStack(alignment: .leading) {
                        LabelTextField(label: "Word", text: $wordInput)
                        LabelTextField(label: "Pinyin", text: $pinyinInput)
                        LabelTextField(label: "Translation", text: $translationInput)
                    }.listRowInsets(EdgeInsets()))
                    
                        : AnyView(VStack {
                            Text("Enter list of words in CSV format, e.g.:\n\"一\", \"yi1\", \"one\"\n\"二\", \"er4\", \"two\"\n...")
                            Spacer()
                            TextField_UI(text: $csvInput).border(Color.gray, width: 1)
                                .frame(height: 300.0)
                            
                        })
                }
                
            }
            .onAppear { UITableView.appearance().separatorStyle = .none }
            .onDisappear { UITableView.appearance().separatorStyle = .singleLine }
            .navigationBarTitle(Text("New Card"), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                self.sheetVisible = false
                
                let context = CoreDataStack.shared.persistentContainer.viewContext

                if self.selectorIndex == 0 {
                    let card = CloudCardEntity(context: context)
                    card.id = UUID()
                    card.list = self.list
                    card.section = self.section
                    
                    card.word = self.wordInput
                    card.pinyin = self.pinyinInput
                    card.translation = self.translationInput
                    
                    self.list.wordCount += 1
                    self.section.wordCount += 1
                    
                    try! context.save()
                    
                } else {
                    let cards: [VocabCard] = self.loadCSV(self.csvInput)
                    
                    for c in cards {
                        let card = CloudCardEntity(context: context)
                        card.id = UUID()
                        card.list = self.list
                        card.section = self.section
                        card.word = c.word
                        card.pinyin = c.pinyin
                        card.translation = c.translation
                        
                        self.list.wordCount += 1
                        self.section.wordCount += 1
                        
                        try! context.save()
                    }
                }
               
            }) {
                Text("Add").bold()
            })
        }
    }
}
