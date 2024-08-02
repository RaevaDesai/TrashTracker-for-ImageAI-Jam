//
//  SplashScreenView.swift
//  TrashTracker
//
//  Created by Raeva Desai on 8/1/24.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var navigateToLogin = false
    @State private var scale: CGFloat = 0.5
    @State private var hideLogo = false
    let onLogin: () -> Void
    
    var body: some View {
        VStack {
            if !hideLogo {
                Image("logo") // Ensure you have this image in your asset catalog
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .frame(width: 300, height: 300)
                    .offset(y: -30)
                    .padding()
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.0)) {
                            scale = 1.0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                hideLogo = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    navigateToLogin = true
                                }
                            }
                        }
                    }
            }
            if navigateToLogin {
                LoginView(onLogin: onLogin)
            }
        }
    }
}
