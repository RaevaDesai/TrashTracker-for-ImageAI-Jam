//
//  ResultView.swift
//  TrashTracker
//
//  Created by Raeva Desai on 8/1/24.
//

import SwiftUI

struct ResultView: View {
    var resultText: String
    var capturedImage: UIImage
    var onBack: () -> Void

    var body: some View {
        VStack {
            Image(uiImage: capturedImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300, height: 300)

            Text(resultText)
                .font(.title)
                .padding()
            
            Button(action: {
                onBack()
            }) {
                Text("Back to Home")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .navigationBarHidden(true)
    }
}
