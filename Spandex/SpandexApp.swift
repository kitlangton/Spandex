//
//  SpandexApp.swift
//  Spandex
//
//  Created by Kit Langton on 1/10/21.
//

import SwiftUI

@main
struct SpandexApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    getPermissions()
                }
        }
    }

    func getPermissions() {
        AXIsProcessTrustedWithOptions(
            [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
        )
    }
}
