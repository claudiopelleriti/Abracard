//
//  TutorialView.swift
//  Abracard
//
//  Created by Alessandro Guzzardi on 19/09/25.
//

import SwiftUI

struct TutorialView: View {
    // Azione per tornare indietro
    @Environment(\.dismiss) var dismiss
    
    // Array di tuple con testo e immagini
    // Titolo, testo, nome_immagine
    let pages = [
        ("Introduction", "Want to impress your friends, relatives or anyone else? With this magic trick, you'll be able to predict the exact card they will think. Get ready to amaze them with your magic skills!", "tutorial_intro"),
        ("Volume Settings", "Before starting the game, you must set your device volume to half to ensure the proper functioning of the game.", "tutorial_volume"),
        ("Start", "Ask the spectator to think a card value (from Ace to King). Then, ask them to chose a card suit (hearts, diamonds, clubs, or spades). I sugguest you to set the value (next tutorial slides) between the choices of value and suit.", "dice_suits"),
        ("Set the number (1/2)", "Under the pretext of moving the phone to put it closer to the spectator, use the phone's volume buttons to secretly set the number the spectator told you as the following table (Ace = 1):", "set_value_table"),
        ("Set the number (2/2)", "To set cards with a number higher than 6, slightly tilt the phone when you set the value with the volume buttons, and after subtracting 6 to the value, follow the previous table (es. 8 -> 2, J -> 5,\nQ -> 6). To set the King just tap three times the volume down, tilting the phone or not makes no difference in this case", "tutorial_tilt"),
        ("Set the suit", "Invite the spectator to scroll on the screen to select the suit they told, folllowing the table below (specify you don't want to touch the phone but move your finger near the screen to indicate them the direction of the scroll they have to do):", "tutorial_suits"),
        ("The reveal", "Make the spectator tap the card twice... and the magic is done!\nAfter the spectator may also check with double tap the other cards to see they were all different", "tutorial_end"),
        ("Going back", "You can go back in any moment by tapping a zone on the the top left screen (the red zone in the following image)", "tutorial_back")
    ]
    
    var body: some View {
            VStack {
                Text("Tutorial")
                    .font(.system(size: 32))
                    .fontWeight(.bold)
                
                TabView {
                    ForEach(pages, id: \.0) { page in
                        TutorialFrameView(title: page.0, description: page.1, imageName: page.2)
                            .tabItem {
                                Text(page.0)
                            }
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(height: 570)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(LinearGradient.purpleGradient)
            .navigationBarBackButtonHidden(true)
        
            // Bottone Back personalizzato
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                                .foregroundStyle(.black)
                            Text("Back")
                                .foregroundStyle(.black)
                        }
                    }
                }
            }
        }
}

struct TutorialFrameView: View {
    let title: String
    let description: String
    let imageName: String?
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let imageName = imageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 220)
                    .cornerRadius(10)
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.85, height: 470)
        .padding()
        .background(Color.white.opacity(0.75))
        .cornerRadius(30)
        .shadow(radius: 5)
    }
}

#Preview {
    NavigationStack {
        TutorialView()
    }
}
