//
//  LoginView.swift
//  TrashTracker
//
//  Created by Raeva Desai on 8/1/24.
//

import SwiftUI

struct LoginView: View {
    let onLogin: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Take a Photo")
                .font(.custom("Copperplate", size: 40))
                .padding(.bottom, 20)
            
            Button(action: onLogin) {
                Text("Go to Photo Capture")
                    .font(.custom("Copperplate", size: 20))
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
    }
}
