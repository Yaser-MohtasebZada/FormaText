import SwiftUI

/// The main user interface for FormaText, handling user input and displaying AI results.
struct ContentView: View {
    // Observed object that handles the business logic and API communication
    @StateObject var aiService = AIService()
    
    // Local state for managing user inputs and UI selection
    @State private var userInput = ""
    @State private var selectedTone = "Student to Professor"
    @State private var customTone = ""
    
    // Pre-defined tone options for the user
    let tones = ["Student to Professor", "Employee to Boss", "Formal Complaint", "Friendly Professional", "Other..."]
    
    var body: some View {
        NavigationStack {
            Form {
                // Section 1: Input area for the original message
                Section(header: Text("Draft Your Message")) {
                    TextEditor(text: $userInput)
                        .frame(height: 100)
                }
                
                // Section 2: Configuration for the desired output tone
                Section(header: Text("Target Tone")) {
                    Picker("Select Tone", selection: $selectedTone) {
                        ForEach(tones, id: \.self) { tone in
                            Text(tone)
                        }
                    }
                    
                    // Conditionally show text field if "Other..." is selected
                    if selectedTone == "Other..." {
                        TextField("e.g., To my Mom, To my Girlfriend", text: $customTone)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                
                // Action Button: Triggers the AI generation process
                Button(action: {
                    let finalTone = (selectedTone == "Other...") ? customTone : selectedTone
                    // Async task to call the AI service without blocking the UI thread
                    Task { await aiService.polishEmail(input: userInput, tone: finalTone) }
                }) {
                    if aiService.isLoading {
                        ProgressView().tint(.white) // Show loading spinner during API call
                    } else {
                        Text("Polish Your Message").bold()
                    }
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                // Prevent submission if input is empty or a request is in progress
                .disabled(userInput.isEmpty || aiService.isLoading || (selectedTone == "Other..." && customTone.isEmpty))

                // Results Section: Only appears when the API returns data
                if !aiService.outputText.isEmpty {
                    Section(header: Text("Polished Results")) {
                        // Logic to split the monolithic AI response into an array based on the custom delimiter
                        let options = aiService.outputText.components(separatedBy: "[SPLIT]")
                        
                        ForEach(options, id: \.self) { option in
                            if !option.trimmingCharacters(in: .whitespaces).isEmpty {
                                // MODERN CARD LAYOUT: Displays each variation in a stylized container
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Rectangle()
                                            .fill(Color.blue)
                                            .frame(width: 4) // Visual accent bar
                                        Text(option.trimmingCharacters(in: .whitespacesAndNewlines))
                                            .font(.system(.body, design: .rounded))
                                            .padding(.vertical, 8)
                                    }
                                }
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                .textSelection(.enabled) // Allows users to copy individual text blocks
                                .padding(.vertical, 5)
                            }
                        }
                        
                        // Utility buttons for bulk actions
                        HStack(spacing: 20) {
                            Button(action: {
                                // Replaces delimiters with newlines for a clean clipboard copy
                                UIPasteboard.general.string = aiService.outputText.replacingOccurrences(of: "[SPLIT]", with: "\n\n")
                            }) {
                                Label("Copy All", systemImage: "doc.on.doc")
                            }
                            .buttonStyle(.bordered)

                            // Native iOS Share Sheet integration
                            ShareLink(item: aiService.outputText.replacingOccurrences(of: "[SPLIT]", with: "\n\n")) {
                                Label("Send To...", systemImage: "square.and.arrow.up")
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.top, 15)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("FormaText")
        }
    }
}
