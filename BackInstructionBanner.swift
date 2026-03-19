//
//  BackInstructionBanner.swift
//  Abracard
//
//  Created by GitHub Copilot on 23/09/25.
//

import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct BackInstructionBanner: View {
    @State private var isVisible = false
    @State private var bannerDismissed = false
    @AppStorage("hideBackBanner") private var hideBackBanner = false
    @State private var dontShowAgain = false  // Stato locale per questa sessione
    
    var body: some View {
        if !bannerDismissed {
            // Background overlay stile Apple
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .overlay(
                    // Banner card centrato stile Apple
                    VStack(spacing: 24) {
                        // Titolo
                        Text("How to Go Back")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        // Immagine tutorial
                        Image("tutorial_back")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 140)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                            )
                        
                        // Testo descrittivo
                        Text("Tap the highlighted area in the top-left corner to return to the previous screen.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // Controlli
                        VStack(spacing: 16) {
                            // Checkbox stile
                            HStack {
                                Button(action: {
                                    dontShowAgain.toggle()
                                    // Salva la preferenza solo quando viene spuntata
                                    if dontShowAgain {
                                        hideBackBanner = true
                                    } else {
                                        hideBackBanner = false
                                    }
                                }) {
                                    HStack(spacing: 10) {
                                        Image(systemName: dontShowAgain ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(dontShowAgain ? .accentColor : .secondary)
                                            .font(.title3)
                                        
                                        Text("Don't show again")
                                            .font(.callout)
                                            .foregroundColor(.primary)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Spacer()
                            }
                            
                            // Pulsante principale stile 
                            Button(action: {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    bannerDismissed = true
                                }
                            }) {
                                Text("Continue")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.accentColor)
                                    .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: 320)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.regularMaterial)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                )
                .scaleEffect(isVisible ? 1 : 0.8)
                .opacity(isVisible ? 1 : 0)
                .onAppear {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                        isVisible = true
                    }
                    
                    // Auto-dismiss dopo 10 secondi
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                        if !bannerDismissed {
                            withAnimation(.easeOut(duration: 0.4)) {
                                bannerDismissed = true
                            }
                        }
                    }
                }
        }
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        BackInstructionBanner()
    }
}
