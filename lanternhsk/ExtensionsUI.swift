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
        
        /*
        func textViewDidChange(_ textView: UITextView) {
            field.text = textView.text
        }
*/
        func textViewDidEndEditing(_ textView: UITextView) {
            field.text = textView.text
        }
        
    }
}

struct TextFieldWithFocus: UIViewRepresentable {
    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        @Binding var isFirstResponder: Bool
        var didBecomeFirstResponder = false
  
        var onCommit: () -> Void
  
        init(text: Binding<String>, isFirstResponder: Binding<Bool>, onCommit: @escaping () -> Void) {
            _text = text
            _isFirstResponder = isFirstResponder
            self.onCommit = onCommit
        }
  
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            text = textField.text ?? ""
            isFirstResponder = false
            didBecomeFirstResponder = false
                        
            onCommit()
            return true
        }
    }
  
    @Binding var text: String
    var placeholder: String
    @Binding var isFirstResponder: Bool
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
        textField.backgroundColor = nil
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.textColor = .black
        
        return textField
    }
  
    func makeCoordinator() -> TextFieldWithFocus.Coordinator {
        return Coordinator(text: $text, isFirstResponder: $isFirstResponder, onCommit: {
            self.onCommit?()
        })
    }
  
    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<TextFieldWithFocus>) {
        uiView.text = text
        if isFirstResponder && !context.coordinator.didBecomeFirstResponder {
            uiView.becomeFirstResponder()
            context.coordinator.didBecomeFirstResponder = true
        }
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
                                   placeholder: "",
                                   isFirstResponder: self.$isShowing,
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
