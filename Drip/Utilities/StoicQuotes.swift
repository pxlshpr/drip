//
//  StoicQuotes.swift
//  Drip
//
//  Rotating Stoic quotes about money
//

import Foundation

struct StoicQuote {
    let text: String
    let author: String
    let emoji: String
}

class StoicQuotes {
    static let quotes: [StoicQuote] = [
        // Epictetus
        StoicQuote(
            text: "Wealth consists not in having great possessions, but in having few wants.",
            author: "Epictetus",
            emoji: "🏛️"
        ),
        StoicQuote(
            text: "He is a wise man who does not grieve for the things which he has not, but rejoices for those which he has.",
            author: "Epictetus",
            emoji: "🌿"
        ),

        // Seneca
        StoicQuote(
            text: "It is not the man who has too little, but the man who craves more, that is poor.",
            author: "Seneca",
            emoji: "💭"
        ),
        StoicQuote(
            text: "True happiness is to enjoy the present, without anxious dependence upon the future.",
            author: "Seneca",
            emoji: "☀️"
        ),

        // Marcus Aurelius
        StoicQuote(
            text: "Very little is needed to make a happy life; it is all within yourself, in your way of thinking.",
            author: "Marcus Aurelius",
            emoji: "🧘"
        ),
        StoicQuote(
            text: "The happiness of your life depends upon the quality of your thoughts.",
            author: "Marcus Aurelius",
            emoji: "🪷"
        ),
    ]

    static func quoteForDay(date: Date = Date()) -> StoicQuote {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        let index = dayOfYear % quotes.count
        return quotes[index]
    }
}
