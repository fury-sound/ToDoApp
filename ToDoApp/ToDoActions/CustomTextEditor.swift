//
//  CustomTextEditor.swift
//  ToDoApp
//
//  Created by Valery Zvonarev on 28.07.2025.
//

import SwiftUI

struct CustomTextEditor: UIViewRepresentable {
    @Binding var text: String
    var fontSize: CGFloat
    var isBold: Bool = false

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = true
        textView.isUserInteractionEnabled = true
        textView.backgroundColor = UIColor(Color.appBlack)
        textView.textColor = UIColor(Color.appWhite)
        textView.font = isBold ? UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize, weight: .regular)
        textView.delegate = context.coordinator
        textView.textContainer.maximumNumberOfLines = 3
        textView.textContainerInset = .zero
        textView.contentInset = .zero
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextEditor

        init(_ parent: CustomTextEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }

}

//#Preview {
//    CustomTextEditor()
//}
