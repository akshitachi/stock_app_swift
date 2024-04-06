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

