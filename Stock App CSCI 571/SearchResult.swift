//
//  SearchResult.swift
//  Stock App CSCI 571
//
//  Created by Akshil Shah on 4/2/24.
//

import Foundation
struct SearchResult:Identifiable {
        var id = UUID()
        var description: String
        var type: String
        var symbol: String
        var displaySymbol: String
        var primary: [String]?
}

struct StockStats:Identifiable {
    var id = UUID()
    var highPrice: String
    var openPrice: String
    var lowPrice: String
    var previousClose: String
}

struct NewsItem {
    let related: String
    let category: String
    let headline: String
    let url: String
    let datetime: Int
    let id: Int
    let source: String
    let summary: String
    let image: String
}

struct PortfolioItem {
    let id: String
    let name: String
    let ticker: String
    let quantity: Int
    let avgCost: Double
    let totalCost: Double
}

