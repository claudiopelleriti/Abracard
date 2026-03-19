import SwiftUI

struct Main: View {
    @State private var logoMoved = false
    @State private var showButtons = false
    @State private var startGame = false
    @State private var startTutorial = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    // Gruppo animato: logo + bottoni
                    VStack(spacing: 16) {
                        // Logo
                        VStack(spacing: -30) {
                            Image("solo_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 320, height: 320)
                            Text("Abracard")
                                .font(.system(size: 32, weight: .bold, design: .default))
                                .foregroundColor(.white)
                                .padding(.bottom, 30)
                        }
                        // Bottoni: sempre presenti, compaiono con fade
                        VStack(spacing: 24) {
                            Button(action: {
                                startGame = true
                            }) {
                                MenuButton(title: "Play", isPrimary: true)
                            }
                            .opacity(showButtons ? 1 : 0)
                            .allowsHitTesting(showButtons)
                            Button(action: {
                                startTutorial = true
                            }) {
                                MenuButton(title: "Tutorial", isPrimary: false)
                            }
                            .opacity(showButtons ? 1 : 0)
                            .allowsHitTesting(showButtons)
                        }
                    }
                    .offset(y: logoMoved ? 0 : geometry.size.height * 0.15)
                    .animation(.interpolatingSpring(stiffness: 150, damping: 40), value: logoMoved)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(LinearGradient.purpleGradient)
                .overlay(
                    // Pulsante debug nascosto per resettare banner
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                // Reset banner preference
                                UserDefaults.standard.set(false, forKey: "hideBackBanner")
                                
                                // Feedback visivo
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                            }) {
                                Image(systemName: "arrow.clockwise.circle")
                                    .font(.title2)
                                    .foregroundColor(.white.opacity(0))
                            }
                            .padding()
                        }
                        Spacer()
                    }
                )
                .onAppear {
                    startAnimationSequence()
                }
                .navigationDestination(isPresented: $startGame) {
                    CardGameView()
                }
                .navigationDestination(isPresented: $startTutorial) {
                    TutorialView()
                }
            }
        }
    }
    private func startAnimationSequence() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.interpolatingSpring(stiffness: 300, damping: 30)) {
                logoMoved = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showButtons = true
            }
        }
    }
}

struct MenuButton: View {
    let title: String
    let isPrimary: Bool
    private let buttonHeight: CGFloat = 60
    private let cornerRadius: CGFloat = 25
    
    var body: some View {
        Text(title)
            .font(.system(size: isPrimary ? 24 : 20, weight: isPrimary ? .semibold : .medium))
            .foregroundColor(.white)
            .frame(width: 200, height: buttonHeight)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        isPrimary
                        ? Color.purplePalette.lightPurple.opacity(0.8)
                        : Color.clear
                    )
                    .stroke(
                        isPrimary
                        ? Color.clear
                        : Color.white.opacity(0.6),
                        lineWidth: isPrimary ? 0 : 2
                    )
            )
    }
}

#Preview {
    Main()
}
