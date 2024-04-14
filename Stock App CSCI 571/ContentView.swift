//
//  ContentView.swift
//  Stock App CSCI 571
//
//  Created by Akshil Shah on 4/1/24.
//

import SwiftUI
import Alamofire
import SwiftyJSON
import UIKit

extension Color {
    public static let ListBGColor = Color("ListBGColor")
}

struct ContentView: View {
    @State private var searchText = ""
    @State private var isSearchBarHidden = true
    @State private var searchResults: [SearchResult] = []
    @State private var debounceTimer: Timer?
    @State private var portfolioData: [PortfolioItem] = []
    @State private var money: JSON = JSON()
    @State private var totalStockValue: Double = 0.0
    var body: some View {
            NavigationView {
                VStack {
                    if !searchText.isEmpty {
                        List(searchResults) { result in
                            NavigationLink{StockData(displaySymbol: result.displaySymbol)}
                        label:
                            {
                                VStack(alignment: .leading) {
                                    Text(result.displaySymbol)
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(.primary)
                                    Text(result.description)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                    }
                    if searchText.isEmpty {
                        List {
                            Section {
                                Text(currentDateFormatted())
                                    .font(.title)
                                    .foregroundColor(.secondary)
                                    .bold()
                                    .padding(.vertical, 10)
                            }
                            Text("PORTFOLIO")
                                .font(.callout)
                                .listRowBackground(Color.ListBGColor)
                                .foregroundColor(.secondary)
                            HStack{
                                VStack(alignment:.leading){
                                    Text("Net Worth")
                                        .font(.title2)
                                    Text("$\(String(format: "%.2f", money.doubleValue+totalStockValue))")
                                        .font(.title2) 
                                        .bold()
                                }
                                Spacer()
                                VStack(alignment:.leading){
                                    Text("Cash Balance")
                                        .font(.title2)
                                    Text("$\(String(format: "%.2f", money.doubleValue))")
                                        .font(.title2)
                                        .bold()
                                }
                            }
                            ForEach(portfolioData, id: \.id) { item in
                                StockRow(portfolioItem: item).cornerRadius(10)
                            }
                            Section{
                                Button(action: {
                                    if let url = URL(string: "https://finnhub.io") {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    Text("Powered by finnhub.io")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                        .padding(.vertical, 10)
                                        .frame(maxWidth: .infinity, alignment: .center)
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
                .onChange(of: searchText) { newSearchText in
                    debounceTimer?.invalidate()
                    debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { _ in
                        fetchAutocompleteResults(searchText: newSearchText) { results in
                            searchResults = results
                        }
                    }
                }.onAppear {
                    fetchPortfolioData { portfolioItems in
                        portfolioData = portfolioItems
                        totalStockValue = portfolioItems.reduce(0.0) { $0 + $1.totalCost }
                    }
                    fetchMoney()
                        { json in
                            money = json
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


func fetchPortfolioData(completionHandler: @escaping ([PortfolioItem]) -> Void) {
    AF.request("http://localhost:8080/getPortfolio")
        .validate()
        .responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                guard let jsonArray = json.array else {
                    print("JSON is not an array")
                    completionHandler([])
                    return
                }
                let portfolioItems: [PortfolioItem] = jsonArray.compactMap { jsonObject in
                    guard let id = jsonObject["_id"].string,
                          let name = jsonObject["name"].string,
                          let ticker = jsonObject["ticker"].string,
                          let quantity = jsonObject["quantity"].int,
                          let avgCost = jsonObject["avgCost"].double,
                          let totalCost = jsonObject["totalCost"].double else {
                        print("Missing required values in JSON object")
                        return nil
                    }
                    return PortfolioItem(id: id, name: name, ticker: ticker, quantity: quantity, avgCost: avgCost, totalCost: totalCost)
                }
                completionHandler(portfolioItems)
            case .failure(let error):
                print("Error fetching data: \(error)")
                completionHandler([])
            }
        }
}



func parseJSON(_ json: JSON) -> [SearchResult] {
    var results: [SearchResult] = []
    
    guard let jsonArray = json.array else {
        print("JSON is not an array")
        return results
    }

    for jsonObject in jsonArray {

        guard let description = jsonObject["description"].string,
              let type = jsonObject["type"].string,
              let symbol = jsonObject["symbol"].string,
              let displaySymbol = jsonObject["displaySymbol"].string else {
            print("Missing required values in JSON object")
            continue
        }

        let primary: [String]? = jsonObject["primary"].array?.compactMap { $0.string }
        let result = SearchResult(description: description, type: type, symbol: symbol, displaySymbol: displaySymbol, primary: primary)
        results.append(result)
    }
    
    return results
}

func currentDateFormatted() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM d, yyyy"
    return dateFormatter.string(from: Date())
}

private func arrowImageName(for value: Double) -> String {
        if value > 0 {
            return "arrow.up.right"
        } else if value < 0 {
            return "arrow.down.right"
        } else {
            return "arrow.right"
        }
    }
    

private func changeColor(_ value: Double) -> Color {
        if value > 0 {
            return .green
        } else if value < 0 {
            return .red
        } else {
            return .gray
        }
    }
struct StockRow: View {
    let portfolioItem: PortfolioItem
    @State private var stockData: JSON = JSON()
    @State private var isLoading = true
    var body: some View {
        VStack{
        if isLoading {
            Text("")
            }
            else{
                if !stockData.isEmpty {
                    HStack {
                        VStack(alignment:.leading){
                            Text("\(portfolioItem.ticker)")
                                .font(.title3)
                                .bold()
                            Text("\(portfolioItem.quantity) shares")
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        VStack(alignment:.trailing){
                            Text("$\(String(format: "%.2f", portfolioItem.totalCost))")
                                .bold()
                            HStack{
                                let changeInValue = (stockData["quote"]["c"].doubleValue - portfolioItem.avgCost)*Double(portfolioItem.quantity)
                                let changePercentage = (changeInValue*100)/portfolioItem.totalCost
                                Image(systemName: arrowImageName(for: changeInValue))
                                    .foregroundColor(changeColor(changeInValue))
                                Text("$\(String(format: "%.2f",changeInValue))")
                                    .foregroundColor(changeColor(changeInValue))
                                Text("(\(String(format: "%.2f",changePercentage))%)")
                                    .foregroundColor(changeColor(changeInValue))
                            }
                        }
                    }
                } else {
                    Text("")
                }
            }
            }
            .onAppear{
                fetchStockData2(searchText: portfolioItem.ticker) { json in
                    stockData = json
                    isLoading = false
                }
        }
        }
    
}

func fetchStockData2(searchText: String, completionHandler: @escaping (JSON) -> Void) {
    AF.request("http://localhost:8080/search/\(searchText)")
        .validate()
        .responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completionHandler(json)
            case .failure(let error):
                print("Error fetching data: \(error)")
                completionHandler([])
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
