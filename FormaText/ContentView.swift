import SwiftUI

struct ContentView: View {
    @StateObject var aiService = AIService()
    @State private var userInput = ""
    @State private var selectedTone = "Student to Professor"
    @State private var customTone = ""
    
    let tones = ["Student to Professor", "Employee to Boss", "Formal Complaint", "Friendly Professional", "Other..."]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Draft Your Message")) {
                    TextEditor(text: $userInput)
                        .frame(height: 100)
                }
                
                Section(header: Text("Target Tone")) {
                    Picker("Select Tone", selection: $selectedTone) {
                        ForEach(tones, id: \.self) { tone in
                            Text(tone)
                        }
                    }
                    
                    if selectedTone == "Other..." {
                        TextField("e.g., To my Mom, To my Girlfriend", text: $customTone)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                
                Button(action: {
                    let finalTone = (selectedTone == "Other...") ? customTone : selectedTone
                    Task { await aiService.polishEmail(input: userInput, tone: finalTone) }
                }) {
                    if aiService.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Polish Your Message").bold()
                    }
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                .disabled(userInput.isEmpty || aiService.isLoading || (selectedTone == "Other..." && customTone.isEmpty))

                if !aiService.outputText.isEmpty {
                    Section(header: Text("Polished Results")) {
                        // Logic to split the text into separate cards
                        let options = aiService.outputText.components(separatedBy: "[SPLIT]")
                        
                        ForEach(options, id: \.self) { option in
                            if !option.trimmingCharacters(in: .whitespaces).isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(option.trimmingCharacters(in: .whitespacesAndNewlines))
                                        .font(.system(.body, design: .rounded))
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(.secondarySystemBackground))
                                        .cornerRadius(12)
                                        .textSelection(.enabled)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        
                        Button(action: {
                            UIPasteboard.general.string = aiService.outputText.replacingOccurrences(of: "[SPLIT]", with: "\n\n")
                        }) {
                            Label("Copy All to Clipboard", systemImage: "doc.on.doc")
                        }
                        .padding(.top, 10)
                    }
                }
            }
            .navigationTitle("FormaText")
        }
    }
}
