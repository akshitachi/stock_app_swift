//
//  StockData.swift
//  Stock App CSCI 571
//
//  Created by Akshil Shah on 4/2/24.
//

import SwiftUI
import Alamofire
import SwiftyJSON
import WebKit

struct HighchartsView: UIViewRepresentable {
    let htmlFileName: String
    let displaySymbol: String
    let color: String
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        if let htmlPath = Bundle.main.path(forResource: htmlFileName, ofType: "html") {
            do {
                var htmlString = try String(contentsOfFile: htmlPath)
                // Inject displaySymbol into HTML file
                htmlString = htmlString.replacingOccurrences(of: "{{ symbol }}", with: displaySymbol)
                htmlString = htmlString.replacingOccurrences(of: "{{ color }}", with: color)
                webView.loadHTMLString(htmlString, baseURL: Bundle.main.bundleURL)
            } catch {
                print("Error loading HTML file: \(error)")
            }
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Update the view if needed
    }
}

struct HighchartsView2: UIViewRepresentable {
    let htmlFileName: String
    let displaySymbol: String
    let color: String
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        if let htmlPath = Bundle.main.path(forResource: htmlFileName, ofType: "html") {
            do {
                var htmlString = try String(contentsOfFile: htmlPath)
                htmlString = htmlString.replacingOccurrences(of: "{{ symbol }}", with: displaySymbol)
                htmlString = htmlString.replacingOccurrences(of: "{{ color }}", with: color)
                webView.loadHTMLString(htmlString, baseURL: Bundle.main.bundleURL)
            } catch {
                print("Error loading HTML file: \(error)")
            }
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Update the view if needed
    }
}

struct StockData: View {
    let displaySymbol:String
    @State private var stockData: JSON = JSON()
    @State private var watchlist: JSON = JSON()
    @State private var isLoading = true
    @State private var selectedTab = 0
    @State private var aggregatedMspr: Double = 0
    @State private var positiveMspr: Double = 0
    @State private var negativeMspr: Double = 0
    @State private var aggregatedChange: Int = 0
    @State private var positiveChange: Int = 0
    @State private var negativeChange: Int = 0
    @State private var newsList: [NewsItem] = []
    @State private var showToast = false
    @State private var messageToShow = ""
    @State private var isButtonTapped = false
    
    var body: some View {
        VStack {
            if isLoading {
                VStack {
                    ProgressView()
                    Text("Fetching Data...")
                        .foregroundColor(.secondary)
                }
            } else {
                ScrollView{
                    VStack{
                        VStack(alignment: .leading) {
                            Text("\(stockData["profile"]["name"])")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding(.leading,15)
                            HStack {
                                Text("$\(String(format: "%.2f", stockData["quote"]["c"].doubleValue))")
                                    .foregroundColor(.primary)
                                    .font(.largeTitle)
                                    .fontWeight(.semibold)
                                Image(systemName: arrowImageName(for: stockData["quote"]["dp"].doubleValue))
                                    .foregroundColor(changeColor(stockData["quote"]["d"].doubleValue))
                                    .font(.title2)
                                Text("$\(String(format: "%.2f",stockData["quote"]["d"].doubleValue))")
                                    .foregroundColor(changeColor(stockData["quote"]["d"].doubleValue))
                                    .font(.title2)
                                Text("(\(String(format: "%.2f",stockData["quote"]["dp"].doubleValue))%)")
                                    .foregroundColor(changeColor(stockData["quote"]["d"].doubleValue))
                                    .font(.title2)
                                Spacer()
                            }
                            .padding(.top, 10)
                            .padding(.leading,15)
                        }
                        .navigationBarTitle(displaySymbol)
                        .padding()
                        .navigationBarItems(trailing:
                                        Button(action: {
                            if !watchlist.boolValue{
                                addWatchlist(searchText: displaySymbol){
                                    json in
                                    let x = json
                                }
                                watchlist.boolValue.toggle()
                                showToast = true
                messageToShow = "Added \(displaySymbol) to Favorites"
                            }
                            else{
                                deleteWatchlist(searchText: displaySymbol){
                                    json2 in
                                    let x2 = json2
                                }
                                showToast = true
                messageToShow = "Removing \(displaySymbol) from Favorites"
                                watchlist.boolValue.toggle()
                            }
                                        }) {
                                            Image(systemName: watchlist.boolValue ? "plus.circle.fill" : "plus.circle")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 24, height: 24)
                                                .foregroundColor(.blue)
                                        }
                                    )
                        TabView {
                            HighchartsView(htmlFileName: "index", displaySymbol: displaySymbol, color: changeColor2(stockData["quote"]["d"].doubleValue))
                                .tabItem {
                                    Label("Hourly", systemImage: "chart.xyaxis.line")
                                }
                                .tag(0)
                            HighchartsView(htmlFileName: "historical", displaySymbol: displaySymbol, color: changeColor2(stockData["quote"]["d"].doubleValue))
                                .tabItem {
                                    Label("Historical", systemImage: "clock")
                                }
                                .tag(1)
                        }
                        .frame(height: 460)
                        StockPortfolio(ticker: displaySymbol)
                            .padding(.leading,15)
                        let stats = StockStats(
                            highPrice: String("$\(String(format: "%.2f", stockData["quote"]["h"].doubleValue))"),
                                                    openPrice: String("$\(String(format: "%.2f", stockData["quote"]["o"].doubleValue))"),
                                                    lowPrice: String("$\(String(format: "%.2f", stockData["quote"]["l"].doubleValue))"),
                                                    previousClose: String("$\(String(format: "%.2f", stockData["quote"]["c"].doubleValue))")
                                                )
                        StockStatsView(stats:stats).padding(.leading,15)
                        AboutView(companyName: stockData["profile"]["name"].stringValue,
                                                          ipoDate: stockData["profile"]["ipo"].stringValue,
                                                          industry: stockData["profile"]["finnhubIndustry"].stringValue,
                                                          webpage: stockData["profile"]["weburl"].stringValue,
                                                          peers: stockData["peers"].arrayValue.map { $0.stringValue }
                        ).padding(.leading,15)
                        InsightsView(totalMSPR: aggregatedMspr, positiveMSPR: positiveMspr, negativeMSPR: negativeMspr, totalChange: aggregatedChange, positiveChange: positiveChange, negativeChange: negativeChange,ticker: "\(stockData["profile"]["name"])")
                            .padding(.leading,15)
                        HighchartsView(htmlFileName: "recommendation", displaySymbol: displaySymbol, color: changeColor2(stockData["quote"]["d"].doubleValue)).frame(height: 420)
                            .padding(.leading,15)
                        HighchartsView(htmlFileName: "earnings", displaySymbol: displaySymbol, color: changeColor2(stockData["quote"]["d"].doubleValue)).frame(height: 420)
                            .padding(.leading,15)
                        NewsView(news: newsList)
                            .padding(.leading,10)
                    }
                }
            }
        }
        .onAppear {
            fetchStockData(searchText: displaySymbol) { json in
                stockData = json
                if let insiderSentimentData = stockData["insiderSentiment"]["data"].array {
                    insiderSentimentData.forEach { dataPoint in
                        if let mspr = dataPoint["mspr"].double {
                            aggregatedMspr += mspr
                        }
                        if let mspr = dataPoint["mspr"].double, mspr > 0 {
                                    positiveMspr += mspr
                        }
                        if let mspr = dataPoint["mspr"].double, mspr < 0 {
                                    negativeMspr += mspr
                        }
                        if let change = dataPoint["change"].int {
                            aggregatedChange += change
                        }
                        if let change = dataPoint["change"].int, change > 0 {
                                    positiveChange += change
                        }
                        if let change = dataPoint["change"].int, change < 0 {
                                    negativeChange += change
                        }
                    }
                }
                if let newsData = stockData["news"].array{
                    newsData.forEach { dataPoint in
                           if let related = dataPoint["related"].string,
                              let category = dataPoint["category"].string,
                              let headline = dataPoint["headline"].string,
                              let url = dataPoint["url"].string,
                              let datetime = dataPoint["datetime"].int,
                              let id = dataPoint["id"].int,
                              let source = dataPoint["source"].string,
                              let summary = dataPoint["summary"].string,
                              let image = dataPoint["image"].string {
                               let newsItem = NewsItem(related: related, category: category, headline: headline, url: url, datetime: datetime, id: id, source: source, summary: summary, image: image)
                            
                               newsList.append(newsItem)
                           }
                       }
                }
                checkWatchlist(searchText: displaySymbol){
                    json in
                    watchlist = json
                    isButtonTapped = watchlist.boolValue
                }
                isLoading = false
            }
        }
          .overlay(
            Toast(isShowing: $showToast, message: messageToShow)
        )
    }

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

private func changeColor2(_ value: Double) -> String {
        if value > 0 {
            return "green"
        } else if value < 0 {
            return "red"
        } else {
            return "black"
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


func checkWatchlist(searchText: String, completionHandler: @escaping (JSON) -> Void) {
    AF.request("http://localhost:8080/watchlistCheck/\(searchText)")
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

func addWatchlist(searchText: String, completionHandler: @escaping (Bool) -> Void) {
    AF.request("http://localhost:8080/watchlist/\(searchText)", method: .post)
        .validate()
        .response { response in
            switch response.result {
            case .success:
                completionHandler(true)
            case .failure(let error):
                print("Error trading: \(error)")
                completionHandler(false)
            }
        }
}

func deleteWatchlist(searchText: String, completionHandler: @escaping (Bool) -> Void) {
    AF.request("http://localhost:8080/watchlistDelete/\(searchText)", method: .delete)
        .validate()
        .response { response in
            switch response.result {
            case .success:
                completionHandler(true)
            case .failure(let error):
                print("Error trading: \(error)")
                completionHandler(false)
            }
        }
}
struct StockData_Previews : PreviewProvider {
    static var previews : some View {
       StockData(displaySymbol: "AAPL")
    }
}
