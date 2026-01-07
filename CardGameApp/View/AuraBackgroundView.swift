//
//  AuraBackgroundView.swift
//  CardGameApp
//
//  Created by Tolga Ulutaş on 3.01.2026.
//

import SwiftUI
import Combine

struct AuraBackgroundView: View {
    @State private var rotation: Double = 0
    var body: some View {
        RoundedRectangle(cornerRadius: 50, style: .continuous)
            .stroke(
                AngularGradient(
                    gradient: Gradient(colors: [.blue, .purple, .pink, .orange, .blue, .purple]),
                    center: .center
                ),
                lineWidth: 200
            )
            .blur(radius: 88)
            .padding(2)
            .onAppear {
                withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
            .rotationEffect(.degrees(rotation))
            .mask(
                RoundedRectangle(cornerRadius: 55, style: .continuous)
                    .stroke(lineWidth: 16)
            )
            .opacity(0.7)
            .ignoresSafeArea()
    }
}

#Preview {
    AuraBackgroundView()
}
