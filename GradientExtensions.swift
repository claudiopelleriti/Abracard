//
//  GradientExtensions.swift
//  Abracard
//
import SwiftUI

extension Color {
    
    /// Definisco la palette di colori su cui verrà generato il gradiente
    struct purplePalette {
        static let darkBase = Color(hex: "1A0B2E")     // Base scura
        static let deepPurple = Color(hex: "4A1A4F")   // Purple profondo
        static let mediumPurple = Color(hex: "7B2D8E")  // Purple medio
        static let lightPurple = Color(hex: "B347D9")   // Purple chiaro
        static let veryLightPurple = Color(hex: "E8C5F0") // Purple molto chiaro
    }
    
    /// Inizializza un Color da una stringa esadecimale a 6 caratteri (formato RRGGBB)
    init(hex: String) {
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255

        self.init(.sRGB, red: r, green: g, blue: b)
    }
}

extension LinearGradient {

    /// Gradiente
    static var purpleGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                Gradient.Stop(color: Color.purplePalette.darkBase, location: 0.0),
                Gradient.Stop(color: Color.purplePalette.deepPurple, location: 0.35),
                Gradient.Stop(color: Color.purplePalette.mediumPurple, location: 0.65),
                Gradient.Stop(color: Color.purplePalette.lightPurple, location: 0.85),
                Gradient.Stop(color: Color.purplePalette.veryLightPurple, location: 1.0)
            ]),
            startPoint: .bottom,
            endPoint: .top
        )
    }
    


}

#Preview {
    Rectangle()
        .fill(LinearGradient.purpleGradient)
        .ignoresSafeArea()
}
