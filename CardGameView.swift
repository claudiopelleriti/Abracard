//
//  ContentView.swift
//  envelopTest
//
//  Created by claudio pelleriti on 09/09/25.
//

import SwiftUI
import SpriteKit

struct CardGameView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showBanner = false
    
    var scene: SKScene {
        let scene = CardGameScene()
        scene.size = CGSize(width: 390, height: 844)
        scene.scaleMode = .aspectFit
        return scene
    }

    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .edgesIgnoringSafeArea(.all)
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)

            // 👇 Questo nasconde l'HUD del volume
            HiddenVolumeView()
            
            // Pulsante invisibile per tornare indietro
            Button(action: {
                dismiss()
            }) {
                //Color.red.opacity(0.7)
                Color.clear
            }
            .frame(width: 150, height: 100)
            .contentShape(Rectangle())
            .position(x: 60, y: 70)
            .zIndex(10)
            
            // Banner tutorial
            if showBanner {
                BackInstructionBanner()
                    .zIndex(20)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // Mostra banner solo se l'utente non ha scelto di nasconderlo
                let hideBackBanner = UserDefaults.standard.bool(forKey: "hideBackBanner")
                if !hideBackBanner {
                    showBanner = true
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CardGameView()
    }
}
