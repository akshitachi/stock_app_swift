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
    let displaySymbol: String // Symbol to be passed to HTML file
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

struct StockData: View {
    let displaySymbol:String
    @State private var stockData: JSON = JSON()
    @State private var isLoading = true
    @State private var selectedTab = 0

    var body: some View {
        NavigationView {
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
                        }
                        .navigationBarTitle(displaySymbol)
                        .padding()
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
//                        tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .frame(height: 460)
                        StockPortfolio()
                        let stats = StockStats(
                            highPrice: String("$\(String(format: "%.2f", stockData["quote"]["h"].doubleValue))"),
                                                    openPrice: String("$\(String(format: "%.2f", stockData["quote"]["o"].doubleValue))"),
                                                    lowPrice: String("$\(String(format: "%.2f", stockData["quote"]["l"].doubleValue))"),
                                                    previousClose: String("$\(String(format: "%.2f", stockData["quote"]["c"].doubleValue))")
                                                )
                        StockStatsView(stats:stats)
                        AboutView(companyName: stockData["profile"]["name"].stringValue,
                                                          ipoDate: stockData["profile"]["ipo"].stringValue,
                                                          industry: stockData["profile"]["finnhubIndustry"].stringValue,
                                                          webpage: stockData["profile"]["weburl"].stringValue,
                                                          peers: stockData["peers"].arrayValue.map { $0.stringValue }
                        )
                    }
                }
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
struct StockData_Previews : PreviewProvider {
    static var previews : some View {
       StockData(displaySymbol: "NVDA")
    }
}
