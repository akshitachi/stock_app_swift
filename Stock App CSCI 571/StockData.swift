//
//  StockData.swift
//  Stock App CSCI 571
//
//  Created by Akshil Shah on 4/2/24.
//

import SwiftUI
import Alamofire
import SwiftyJSON

import Foundation

struct StockData: View {
    let displaySymbol:String
    @State private var stockData: JSON = JSON()
    @State private var isLoading = true
    

    var body: some View {
        NavigationView {
            if isLoading {
                VStack {
                    ProgressView()
                    Text("Fetching Data...")
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading) {
                                    Text("\(stockData["profile"]["name"])")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                        
                                    HStack {
                                        Text("$\(String(format: "%.2f", stockData["quote"]["c"].doubleValue))")
                                            .foregroundColor(.primary)
                                            .font(.title)
                                            .bold()
                                        Text("Change: ")
                                            .foregroundColor(.primary)
//                                        Text("$\(stockData["changePrice"].doubleValue)")
//                                            .foregroundColor(changeColor(stockData["changePrice"].doubleValue))
                                        Text("(\(stockData["changePercentage"].doubleValue)%)")
                                            .foregroundColor(.primary)
                                    }
                                    Spacer()
                }
                .navigationTitle(displaySymbol)
            }
        }
        .onAppear {
            fetchStockData(searchText: displaySymbol) { json in
                stockData = json
                print(stockData["quote"])
                isLoading = false
            }
        }
    }

    }
func fetchStockData(searchText: String, completionHandler: @escaping (JSON) -> Void) {
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

#Preview {
    StockData(displaySymbol: "AAPL")
}
