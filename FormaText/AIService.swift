import Foundation
import GoogleGenerativeAI
import Combine

@MainActor
class AIService: ObservableObject {
    @Published var outputText = ""
    @Published var isLoading = false
    
    // Initializing the model with the 2026 stable identifier
    private let model = GenerativeModel(name: "gemini-3-flash-preview", apiKey: "AIzaSyDvoTi8Hrv8nHN_CiUNTHXon73P-rvUo8w")
    
    func polishEmail(input: String, tone: String) async {
        guard !input.isEmpty else { return }
        
        isLoading = true
        
        // Using [SPLIT] as a hidden marker to help the UI partition the results
        let prompt = """
        Rewrite the following message in a \(tone) tone. 
        Provide exactly 5 distinct versions: 
        1. **Professional & Standard**
        2. **Concise & Direct**
        3. **Detailed & Personalized**
        4. **Funny**
        5. **Friendly**

        CRITICAL: Place the string '[SPLIT]' on its own line between each of the 5 options.
        Use bold headers for each option.
        Original Message: \(input)
        """
        
        do {
            let response = try await model.generateContent(prompt)
            if let text = response.text {
                // Clean up markdown blockquotes and store the result
                self.outputText = text.replacingOccurrences(of: ">", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Persistence: Save locally
                UserDefaults.standard.set(self.outputText, forKey: "lastEmail")
            }
        } catch {
            self.outputText = "Error: Please check your internet connection or API settings."
        }
        isLoading = false
    }
}
