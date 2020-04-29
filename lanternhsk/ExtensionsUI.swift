//
//  ExtensionsUI.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 3/25/20.
//  Copyright © 2020 Alexey Smirnov. All rights reserved.
//

import UIKit
import SwiftUI

struct TextField_UI : UIViewRepresentable {
    typealias UIViewType = UITextView
    
    @Binding var text: String
    var onEditingChanged: ((String) -> Void)?
    var onCommit: (() -> Void)?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = nil
        textView.text = text
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.textContainerInset = .zero
        
        textView.delegate = context.coordinator
        
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        textView.text = text
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var field: TextField_UI
        
        init(_ field: TextField_UI) {
            self.field = field
        }
        
        func textViewDidChange(_ textView: UITextView) {
            field.text = textView.text
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.field.text = textView.text
            }
        }
    }
}

struct TextFieldWithFocus: UIViewRepresentable {
    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        @Binding var isFirstResponder: Bool
  
        var onCommit: () -> Void
  
        init(text: Binding<String>, isFirstResponder: Binding<Bool>, onCommit: @escaping () -> Void) {
            _text = text
            _isFirstResponder = isFirstResponder
            self.onCommit = onCommit
        }
  
        func textFieldDidBeginEditing(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.isFirstResponder = true
            }
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            text = textField.text ?? ""
            isFirstResponder = false
            onCommit()
            return true
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.text = textField.text ?? ""
            }
        }
        
        func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
            DispatchQueue.main.async {
                self.text = textField.text ?? ""
            }

            return true
        }
    }
  
    var placeholder: String = ""
    @Binding var text: String
    @Binding var isFirstResponder: Bool

    var textColor: UIColor?
    var textAlignment: NSTextAlignment = .left
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var returnKeyType: UIReturnKeyType = .default
    var textContentType: UITextContentType?
    var textFieldBorderStyle: UITextField.BorderStyle = .none
    var enablesReturnKeyAutomatically: Bool = false
  
    var onCommit: (() -> Void)?
  
    func makeUIView(context: UIViewRepresentableContext<TextFieldWithFocus>) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.delegate = context.coordinator
        textField.placeholder = NSLocalizedString(placeholder, comment: "")
        textField.textAlignment = textAlignment
        textField.isSecureTextEntry = isSecure
        textField.keyboardType = keyboardType
        textField.returnKeyType = returnKeyType
        textField.textContentType = textContentType
        textField.borderStyle = textFieldBorderStyle
        textField.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
        textField.backgroundColor = .clear
        textField.font = UIFont.systemFont(ofSize: 17)
        
        if let textColor = textColor {
            textField.textColor = textColor
        }
        
        return textField
    }
  
    func makeCoordinator() -> TextFieldWithFocus.Coordinator {
        return Coordinator(text: $text, isFirstResponder: $isFirstResponder, onCommit: {
            self.onCommit?()
        })
    }
  
    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<TextFieldWithFocus>) {
        if isFirstResponder {
            uiView.becomeFirstResponder()

        } else {
            uiView.resignFirstResponder()
        }
    }
}

struct LabelTextField : View {
    var label: String
    
    @Binding var text: String
    @Binding var isFirstResponder: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text(label).font(.headline)
            
            TextFieldWithFocus(
                text: self.$text,
                isFirstResponder: self.$isFirstResponder,
                onCommit: {})
                .padding(.all)
                .border(Color.gray, width: 2)
                // .background(Color.white.opacity(0.5))
                .cornerRadius(5.0)
            }
            .padding(10)
        
    }
}

struct TextFieldAlert<Presenting>: View where Presenting: View {
    @Binding var isShowing: Bool
    @Binding var text: String

    let presenting: Presenting
    let title: String
    var action: (() -> Void)?

    var body: some View {
        ZStack {
            self.presenting.disabled(self.isShowing)
            VStack {
                Text(self.title).foregroundColor(.black)
                
                TextFieldWithFocus(text: self.$text,
                                   isFirstResponder: self.$isShowing,
                                   textColor: .black,
                                   onCommit: {
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    self.isShowing = false                                    
                                    self.action?()
                })
                    .id(self.isShowing)
                    .foregroundColor(.black)
                
                Divider()
                HStack {
                    Button(action: {
                        withAnimation {
                            self.isShowing.toggle()
                        }
                    }) {
                        Text("Cancel").frame(minWidth: 0, maxWidth: .infinity)
                    }
                    
                }
            }
            .padding()
            .background(Color.white)
            .frame(width: 250, height: 100)
            .shadow(radius: CGFloat(1))
            .opacity(self.isShowing ? 1.0 : 0.0)
        }
    }

}

extension View {
    func textFieldAlert(isShowing: Binding<Bool>,
                        text: Binding<String>,
                        title: String,
                        action: @escaping () -> Void
                        ) -> some View {
        TextFieldAlert(isShowing: isShowing,
                       text: text,
                       presenting: self,
                       title: title,
                       action: action)
    }

}
