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

    var body: some View {
        NavigationView{
//            if let stockData = stockData {
                Text("Display Symbol: \(displaySymbol)")
                    .navigationTitle(displaySymbol)
                    .task {
                        fetchStockData(searchText: displaySymbol) { json in
                            stockData = json
                            print(stockData["peers"])
                        }
                    }
//            } else {
//                // Placeholder view while data is loading
//                ProgressView()
//            }
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
//                print(json)
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
