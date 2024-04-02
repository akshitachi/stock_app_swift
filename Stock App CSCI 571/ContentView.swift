//
//  ContentView.swift
//  Stock App CSCI 571
//
//  Created by Akshil Shah on 4/1/24.
//

import SwiftUI
import Alamofire
import SwiftyJSON

struct ContentView: View {
    @State private var searchText = ""
    @State private var isSearchBarHidden = true
    @State private var searchResults: [SearchResult] = []
    @State private var debounceTimer: Timer?
    
//    var filteredSearchResults: [SearchResult] {
//        return searchResults.filter{$0.}
//    }
    var body: some View {
        NavigationView {
            VStack {
            if !searchText.isEmpty {
                List(searchResults) { result in
                    VStack(alignment: .leading) {
                        Text(result.displaySymbol)
                            .font(.headline)
                        Text(result.description)
                            .font(.subheadline)
                    }
                    .onTapGesture {
                        print("Selected: \(result.symbol)")
                    }
                }
                .padding()
            }
                if searchText.isEmpty{
                    List {
                        Section(header: Text("Portfolio")) {
                            Text("Cash Balance: $25,000") // Initial cash balance
                            Text("Net Worth: $25,000") // Initial net worth
                            // List of stocks in the portfolio
                            // You can replace this with dynamic data based on the user's portfolio
                            ForEach(0..<3) { index in // Example data for demonstration
                                StockRow(symbol: "AAPL", marketValue: "$1500", changeInPrice: "$200", changeInPricePercentage: "10%", totalSharesOwned: 10)
                            }
                        }
                        
                        Section(header: Text("Favorites")) {
                            // List of favorite stocks
                            // You can replace this with dynamic data based on the user's favorites
                            ForEach(0..<3) { index in // Example data for demonstration
                                FavoriteStockRow(symbol: "GOOGL", currentPrice: "$2500", changeInPrice: "$100", changeInPricePercentage: "5%")
                            }
                        }
                    }
                }

        }
              
                .navigationTitle("Stocks")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                }
                .searchable(text: $searchText)
//                    onSubmit(of: .search) { 
//                                        fetchAutocompleteResults(searchText: searchText) { results in
//                                            searchResults = results
//                                        }
//                                    }
                .onChange(of: searchText) { newSearchText in
                                        debounceTimer?.invalidate()
                                        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { _ in
                                            fetchAutocompleteResults(searchText: newSearchText) { results in
                                                searchResults = results
                                            
                                        }
                                        }
                }
            }
        }
    
        
    }

func fetchAutocompleteResults(searchText: String, completionHandler: @escaping ([SearchResult]) -> Void) {
    AF.request("http://localhost:8080/autocomplete/\(searchText)")
        .validate()
        .responseJSON { response in
            switch response.result {
            case .success(_):
                if let data = response.data {
                    do {
                        let json = try JSON(data: data)
                        print(json)
                        let results = parseJSON(json)
                        print(results)
                        completionHandler(results)
                    } catch {
                        print("Error parsing JSON: \(error)")
                        completionHandler([])
                    }
                } else {
                    print("No data received")
                    completionHandler([])
                }
            case .failure(let error):
                print("Error fetching data: \(error)")
                completionHandler([])
            }
        }
}

func parseJSON(_ json: JSON) -> [SearchResult] {
    var results: [SearchResult] = []
    
    // Check if JSON is an array
    guard let jsonArray = json.array else {
        print("JSON is not an array")
        return results
    }
    
    // Iterate through each JSON object in the array
    for jsonObject in jsonArray {
        // Extract values from the JSON object
        guard let description = jsonObject["description"].string,
              let type = jsonObject["type"].string,
              let symbol = jsonObject["symbol"].string,
              let displaySymbol = jsonObject["displaySymbol"].string else {
            // If any required value is missing, skip this object
            print("Missing required values in JSON object")
            continue
        }
        
        // Extract primary array if available
        let primary: [String]? = jsonObject["primary"].array?.compactMap { $0.string }
        
        // Create a SearchResult object and add it to the results array
        let result = SearchResult(description: description, type: type, symbol: symbol, displaySymbol: displaySymbol, primary: primary)
        results.append(result)
    }
    
    return results
}




struct StockRow: View {
    let symbol: String
    let marketValue: String
    let changeInPrice: String
    let changeInPricePercentage: String
    let totalSharesOwned: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Symbol: \(symbol)")
            Text("Market Value: \(marketValue)")
            Text("Change In Price: \(changeInPrice)")
            Text("Change In Price Percentage: \(changeInPricePercentage)")
            Text("Total Shares Owned: \(totalSharesOwned)")
        }
    }
}

struct FavoriteStockRow: View {
    let symbol: String
    let currentPrice: String
    let changeInPrice: String
    let changeInPricePercentage: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Symbol: \(symbol)")
            Text("Current Price: \(currentPrice)")
            Text("Change In Price: \(changeInPrice)")
            Text("Change In Price Percentage: \(changeInPricePercentage)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


#Preview {
    ContentView()
}
