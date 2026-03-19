//
//  HiddenVolumeView.swift
//  Abracard
//
//  Created by claudio pelleriti on 19/09/25.
//
import SwiftUI
import MediaPlayer

struct HiddenVolumeView: UIViewRepresentable {
    func makeUIView(context: Context) -> MPVolumeView {
        let volumeView = MPVolumeView(frame: CGRect(x: -1000, y: -1000, width: 0, height: 0))
        volumeView.alpha = 0.0001 // invisibile ma attivo
        return volumeView
    }

    func updateUIView(_ uiView: MPVolumeView, context: Context) {}
}
