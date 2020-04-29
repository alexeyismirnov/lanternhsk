//
//  AddCard.swift
//  coredata2
//
//  Created by Alexey Smirnov on 3/18/20.
//  Copyright © 2020 Alexey Smirnov. All rights reserved.
//

import SwiftUI

final class KeyboardResponder: ObservableObject {
    private var notificationCenter: NotificationCenter
    @Published private(set) var currentHeight: CGFloat = 0

    init(center: NotificationCenter = .default) {
        notificationCenter = center
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    @objc func keyBoardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            currentHeight = keyboardSize.height
        }
    }

    @objc func keyBoardWillHide(notification: Notification) {
        currentHeight = 0
    }
}

struct AddCard: View {
    @State private var wordInput = ""
    @State private var pinyinInput = ""
    @State private var translationInput = ""
    @State private var firstResponder1 = false
    @State private var firstResponder2 = false
    @State private var firstResponder3 = false

    @State private var selectorIndex = 0
    @State private var csvInput = ""
    
    @ObservedObject private var keyboard = KeyboardResponder()

    @State private var validationError = false
    @Binding var sheetVisible: Bool

    var list: CloudListEntity
    var section: CloudSectionEntity
    
    func formatPinyin(_ str: String) -> String? {
        var pinyin = str
        
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
            
            return pinyin
            
        } else {
            print("Invalid pinyin \(pinyin)")
            return nil
        }
    }
    
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
                items.append(VocabCard(id: UUID(),
                                       word: values[0],
                                       pinyin: values[1],
                                       translation: values[2],
                                       entity: nil
                ))
            }
        }
        
        return items
    }
     
    var body: some View {
        VStack {
            List {
                Picker("", selection: $selectorIndex) {
                    Text("Single").tag(0)
                    Text("Multiple").tag(1)
                    
                }.pickerStyle(SegmentedPickerStyle())
                
                (selectorIndex == 0) ?
                    AnyView(VStack(alignment: .leading) {
                        LabelTextField(label: "Character(s)", text: $wordInput, isFirstResponder: $firstResponder1)
                        LabelTextField(label: "Pinyin", text: $pinyinInput, isFirstResponder: $firstResponder2)
                        LabelTextField(label: "Translation", text: $translationInput, isFirstResponder: $firstResponder3)
                    }
                    .padding()
                    .padding(.bottom, keyboard.currentHeight)
                    .edgesIgnoringSafeArea(.bottom)
                    .animation(.easeOut(duration: 0.16))
                    .listRowInsets(EdgeInsets()))
                    
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
            let context = CoreDataStack.shared.persistentContainer.viewContext
            
            if self.selectorIndex == 0 {
                self.firstResponder1 = false
                self.firstResponder2 = false
                self.firstResponder3 = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if self.wordInput.count == 0 ||
                        self.pinyinInput.count == 0 ||
                        self.translationInput.count == 0 {
                        self.validationError = true
                        return
                    }
                    
                    var tones = [String]()
                    
                    for pinyin in self.pinyinInput.components(separatedBy: " ") {
                        if let pinyin = self.formatPinyin(pinyin) {
                            tones.append(pinyin)
                            
                        } else {
                            self.validationError = true
                            return
                        }
                    }
                    
                    let card = CloudCardEntity(context: context)
                    card.id = UUID()
                    card.list = self.list
                    card.section = self.section
                    
                    card.word = self.wordInput
                    card.pinyin = tones.joined(separator: " ")
                    card.translation = self.translationInput.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    self.list.wordCount += 1
                    self.section.wordCount += 1
                    
                    try! context.save()
                    
                    self.sheetVisible = false
                }
                
            } else {
                let cards: [VocabCard] = self.loadCSV(self.csvInput)
                
                for c in cards {
                    var tones = [String]()
                    var valid = true
                    
                    if c.word.count == 0 ||
                        c.pinyin.count == 0 ||
                        c.translation.count == 0 {
                        // validation error
                        continue
                    }
                    
                    for pinyin in c.pinyin.components(separatedBy: " ") {
                        if let pinyin = self.formatPinyin(pinyin) {
                            tones.append(pinyin)
                            
                        } else {
                            valid = false
                            break
                        }
                    }
                    
                    if !valid {
                        // validation error
                        continue
                    }
                    
                    let card = CloudCardEntity(context: context)
                    card.id = UUID()
                    card.list = self.list
                    card.section = self.section
                    card.word = c.word
                    card.pinyin = tones.joined(separator: " ")
                    card.translation = c.translation
                    
                    self.list.wordCount += 1
                    self.section.wordCount += 1
                    
                    try! context.save()
                }
                
                self.sheetVisible = false
            }
            
        }) {
            Text("Add").bold()
        })
            .alert(isPresented: $validationError) {
                Alert(title: Text("Add card"), message: Text("Invalid input"), dismissButton: .default(Text("OK")))
        }
    }
}
