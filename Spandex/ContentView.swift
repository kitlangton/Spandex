//
//  ContentView.swift
//  Spandex
//
//  Created by Kit Langton on 1/10/21.
//

import SwiftUI
import Sauce

struct Snippet {
    let trigger: String
    let content: String

    /**
        xname
     ## Matches
     - xname
     -  xname
     - the xname
     ## Not Matches
     - xnot
     - xnam

     */
    func matches(_ string: String) -> Bool {
        let hasSuffix = string.hasSuffix(trigger)
        let isBoundary = (string.dropLast(trigger.count).last ?? " ").isWhitespace
        return hasSuffix && isBoundary
    }
}

extension Snippet {
    static var examples: [Snippet] = [
        Snippet(trigger: "xname", content: "Kit Langton"),
        Snippet(trigger: "xsite", content: "www.zombo.com"),
        Snippet(trigger: "xsnippet", content: "Snippet(trigger: \"<#trigger#>\", content: \"<#content#>\"),"),
        Snippet(trigger: "xcelebrate", content: "CELEBRATION!!!"),
//        CELEBRATION!!!
    ]
}

extension NSEvent {
    var isDelete: Bool {
        keyCode == 51
    }
}

/**
 1. Text Tracking √
 2. Snippet Matching √
 3. Insert the content of the snippet
   - delete the trigger
   - insert the content
 */

class SpandexModel: ObservableObject {
    @Published var text = ""
    @Published var snippets = Snippet.examples

    init() {
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown]) { _ in
            self.text = ""
        }

        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            guard let characters = event.characters else { return }
            print(characters, event.keyCode)
            if event.isDelete, !self.text.isEmpty {
                self.text.removeLast()
            } else if event.keyCode > 100 {
                self.text = ""
            } else {
                self.text += characters
            }

            self.matchSnippet()
        }
    }

    func matchSnippet() {
        if let match = snippets.first(where: { $0.matches(self.text) }) {
            insertSnippet(match)
        }
    }

    func delete() {
        let eventSource = CGEventSource(stateID: .combinedSessionState)

        let keyDownEvent = CGEvent(
            keyboardEventSource: eventSource,
            virtualKey: CGKeyCode(51),
            keyDown: true)

        let keyUpEvent = CGEvent(
            keyboardEventSource: eventSource,
            virtualKey: CGKeyCode(51),
            keyDown: false)

        keyDownEvent?.post(tap: .cghidEventTap)
        keyUpEvent?.post(tap: .cghidEventTap)
    }
    
    func paste() {
        let keyCode = Sauce.shared.keyCode(by: .v)
        let eventSource = CGEventSource(stateID: .combinedSessionState)

        let keyDownEvent = CGEvent(
            keyboardEventSource: eventSource,
            virtualKey: keyCode,
            keyDown: true)
        
        keyDownEvent?.flags.insert(.maskCommand)

        let keyUpEvent = CGEvent(
            keyboardEventSource: eventSource,
            virtualKey: keyCode,
            keyDown: false)

        keyDownEvent?.post(tap: .cghidEventTap)
        keyUpEvent?.post(tap: .cghidEventTap)
    }
    // https://github.com/Clipy/Sauce
    // https://github.com/Clipy/Sauce
    // Kit Langton

    func insertSnippet(_ snippet: Snippet) {
        print("inserting \(snippet)")

        // 1. Delete the trigger
        // - keyDown
        // - keyUp
        for _ in snippet.trigger {
            delete()
        }

        // 2. Insert the content
//        NSPasteboard
        // 1. save the old clipboard
        let oldClipboard = NSPasteboard.general.string(forType: .string)
        // 2. update the clipboard the contents of snippet
        NSPasteboard.general.declareTypes([.string], owner: nil)
        NSPasteboard.general.setString(snippet.content, forType: .string)
        // 3. hit command-v
        paste()
        // 4. returning the clipboard to its old state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            if let oldClipboard = oldClipboard {
                NSPasteboard.general.setString(oldClipboard, forType: .string)
            }
        }
    }
}

struct ContentView: View {
    @StateObject var model = SpandexModel()

    var body: some View {
        VStack {
            Text("\(model.text)")
            List(model.snippets, id: \.trigger) { snippet in
                HStack {
                    Text(snippet.trigger)
                    Text(snippet.content).lineLimit(1)
                }.foregroundColor(snippet.matches(model.text) ? Color.red : Color.primary)
            }
        }
        .padding()
        .frame(width: 300, height: 300)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
