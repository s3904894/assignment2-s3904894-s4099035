//
//  QuotesView.swift
//  Habood
//
//  Created by Yunlong Chen on 30/8/2025
//

import SwiftUI

// Daily Quote screen using ZenQuotes API
struct QuotesView: View {
    @State private var quote: String = "Fetching quote..."
    @State private var author: String = ""

    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text("Daily Quote")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            // Display quote
            Text("\"\(quote)\"")
                .font(.title2)
                .italic()
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Display author if available
            if !author.isEmpty {
                Text("- \(author)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            // Refresh button to get a new quote
            Button(action: {
                fetchQuote()
            }) {
                Text("Refresh")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .onAppear {
            fetchQuote()
        }
    }

    // Fetch quote from ZenQuotes API
    func fetchQuote() {
        guard let url = URL(string: "https://zenquotes.io/api/today") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                if let result = try? JSONDecoder().decode([Quote].self, from: data) {
                    DispatchQueue.main.async {
                        self.quote = result.first?.q ?? "No quote available."
                        self.author = result.first?.a ?? ""
                    }
                } else {
                    DispatchQueue.main.async {
                        self.quote = "Failed to decode quote."
                        self.author = ""
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.quote = "Failed to fetch quote."
                    self.author = ""
                }
            }
        }.resume()
    }
}

// Quote model for decoding API response
struct Quote: Codable {
    let q: String  // quote text
    let a: String  // author
}

