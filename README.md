# FormaText

An iOS app that rewrites rough drafts into polished messages using AI. Paste a message, pick who it's for, and get three versions back, from short and direct to detailed, ready to copy or send.

Built with SwiftUI and Google's Gemini API as a final project at Cal State Fullerton.

## Features

- **Tone presets:** Student to Professor, Employee to Boss, Formal Complaint, Friendly Professional
- **Custom tone:** write your own (e.g. "to my landlord")
- **Three variations per request,** shown as separate cards
- **Copy or share:** copy all results, select text from one card, or send through the iOS share sheet
- **Remembers your last result** between launches

## Tech stack

- Swift and SwiftUI (`NavigationStack`, `Form`, `ShareLink`)
- Swift concurrency (`async`/`await`, `@MainActor`)
- MVVM: `AIService` is an `ObservableObject` view model
- [Google Generative AI Swift SDK](https://github.com/google/generative-ai-swift) with Gemini Flash
- `UserDefaults` for local persistence

## How it works

1. `ContentView` collects the draft and the chosen tone.
2. `AIService` builds a structured prompt that asks for exactly three options separated by a `[SPLIT]` marker.
3. The response is cleaned up and split on the marker, and each option is shown in its own card.

## Run it locally

Requires Xcode 26 or later.

1. Clone the repo and open `FormaText.xcodeproj`.
2. Get a free Gemini API key from [Google AI Studio](https://aistudio.google.com/app/apikey).
3. Copy `Config.example.swift` to `FormaText/Config.swift` and paste in your key. That file is git-ignored, so the key stays on your machine.
4. Build and run on a simulator or device.

## What I'd add next

- Proxy requests through a small backend so the API key isn't shipped in the app
- History of past rewrites
- Keyboard extension to polish text inside any app
