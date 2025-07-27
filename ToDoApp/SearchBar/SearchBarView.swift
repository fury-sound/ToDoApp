//
//  SearchBarView.swift
//  ToDoApp
//
//  Created by Valery Zvonarev on 27.07.2025.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 8){
            Image(systemName: "magnifyingglass")
                .foregroundColor(.appWhite)
            TextField("Поиск", text: $text)
                .textFieldStyle(.plain)
                .foregroundColor(.appWhite)

            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.appWhite)
                }
            } else {
                Button(action: {}) {
                    Image(systemName: "mic.fill")
                        .foregroundColor(.appWhite)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.appGray)
        .cornerRadius(10)
    }
}

#Preview {
    @State var text: String = ""
    SearchBarView(text: $text)
}

#Preview {
    @State var text: String = "No voice search"
    SearchBarView(text: $text)
}
