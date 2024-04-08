//
//  StockPortfolioView.swift
//  Stock App CSCI 571
//
//  Created by Akshil Shah on 4/5/24.
//

import SwiftUI
import Alamofire
import SwiftyJSON

struct StockPortfolio: View {
    @State var ticker:String
    @State private var shareCount: Int = 0
    @State private var avgCostPerShare: Double = 171.23
    @State private var portfolioData: JSON = JSON()
    @State private var quoteData: JSON = JSON()
    @State private var showTradeSheet = false
    
    var body: some View {
        VStack(alignment: .leading) {
                Text("Portfolio")
                    .font(.title)
                    .padding()
            if !portfolioData.isEmpty {
                    HStack {
                        VStack(alignment: .leading) {
                            HStack{
                                Text("Shares Owned: ").bold()
                                Text("\(portfolioData["quantity"])")
                            }.padding(.bottom,15)
                            HStack{
                                Text("Avg. Cost / Share: ").bold()
                            Text("$\(portfolioData["avgCost"])")
                            }.padding(.bottom,15)
          
                            HStack{Text("Total Cost:").bold()
                                Text("$\(portfolioData["totalCost"])")
                            }.padding(.bottom,15)
                            HStack{
                                Text("Change: ").bold()
                                let change = portfolioData["avgCost"].doubleValue - quoteData["quote"]["c"].doubleValue
                                let roundedChange = String(format: "%.2f", change)
                                Text("$\(roundedChange)")
                            }.padding(.bottom,15)
                            HStack{
                                Text("Market Value: ").bold()
                                Text("$\(quoteData["quote"]["c"])")
                            }.padding(.bottom,15)
                        }
                                            Spacer()
                        Button(action: {}, label: {
                            Text("Trade")
                                .foregroundColor(.white)
                                .frame(width: 140,height: 50)
                                .background(Color.green)
                                .cornerRadius(23)
                        })
                    }.padding()
                } else {
                    HStack{
                        VStack(alignment: .leading){
                            Text("You have 0 shares of \(ticker).")
                                .font(.callout)
                            Text("Start trading!")
                                .font(.callout)
                        }
                        Spacer()
                        Button(action: {
                            showTradeSheet.toggle()
                        }) {
                            Text("Trade")
                                .foregroundColor(.white)
                                .frame(width: 140,height: 50)
                                .background(Color.green)
                                .cornerRadius(23)
                        }.sheet(isPresented: $showTradeSheet){
                            TradeView(ticker:ticker,name:String("\(quoteData["profile"]["name"])"),cost: quoteData["quote"]["c"].doubleValue)
                        }
                    }.padding()
                }
        }
        .onAppear{
            fetchportfolio(ticker: ticker) { json in
                portfolioData = json
//                print(portfolioData)
            }
            fetchquote(ticker: ticker) { json in
                quoteData = json
                print(quoteData)
            }
        }
        
    }
}

func fetchportfolio(ticker: String, completionHandler: @escaping (JSON) -> Void) {
    AF.request("http://localhost:8080/getPortfolioItem/\(ticker)")
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

func fetchquote(ticker: String, completionHandler: @escaping (JSON) -> Void) {
    AF.request("http://localhost:8080/quote/\(ticker)")
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

func tradeTicker(completionHandler: @escaping (Bool) -> Void) {
    AF.request("http://localhost:8080/makeportfolio", method: .post)
        .validate()
        .response { response in
            switch response.result {
            case .success:
                completionHandler(true) // Trade successful
            case .failure(let error):
                print("Error trading: \(error)")
                completionHandler(false) // Trade failed
            }
        }
}

struct StockPortfolio_Previews: PreviewProvider {
    static var previews: some View {
        StockData(displaySymbol: "AAPL")
    }
}
