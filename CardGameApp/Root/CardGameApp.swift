//
//  CardGameAppApp.swift
//  CardGameApp
//
//  Created by Tolga Ulutaş on 29.12.2025.
//

import SwiftUI
import GoogleMobileAds

@main
struct CardGameApp: App {
    init() {
        MobileAds.shared.start(completionHandler: nil)
        }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
