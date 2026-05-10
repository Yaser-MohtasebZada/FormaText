import Foundation
import GoogleGenerativeAI
import Combine

/// A ViewModel service that manages interactions with the Google Gemini API.
@MainActor
class AIService: ObservableObject {
    // Published properties to trigger UI updates in ContentView
    @Published var outputText = ""
    @Published var isLoading = false

    // Configurable constant to control the number of variations requested
    let numberOfOptions = 3

    // Initialize the Generative Model with the Gemini 3 Flash engine
    private let model = GenerativeModel(name: "gemini-3-flash-preview", apiKey: "AIzaSyC4eNNq_EGlH07eg7y7mtT_sLhqWOBnIkw")
    
    /// Sends a prompt to the AI model to rewrite text in a specific tone.
    /// - Parameters:
    ///   - input: The raw text from the user.
    ///   - tone: The desired professional or personal tone.
    func polishEmail(input: String, tone: String) async {
        guard !input.isEmpty else { return }
        isLoading = true
        
        // Structured prompt engineering to enforce specific output formatting
        let prompt = """
        Rewrite the following message/email in a \(tone) tone. 
        Provide exactly \(numberOfOptions) distinct versions ranging from concise to detailed.
        
        CRITICAL FORMATTING RULES:
        1. Use bold headers for each option (e.g., **Option 1: Professional**).
        2. Place the string '[SPLIT]' on its own line between every single option.
        3. Do not include any intro or outro text, only the options.
        
        Original Message: \(input)
        """
        
        do {
            // Await the response from the remote LLM
            let response = try await model.generateContent(prompt)
            if let text = response.text {
                // Post-process the response to remove markdown artifacts and trim whitespace
                self.outputText = text.replacingOccurrences(of: ">", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Persistence: Cache the result locally using UserDefaults
                UserDefaults.standard.set(self.outputText, forKey: "lastEmail")
            }
        } catch {
            // Error handling for network issues or API outages
            self.outputText = "Connection Error. Please check your internet."
            print("API Error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}
