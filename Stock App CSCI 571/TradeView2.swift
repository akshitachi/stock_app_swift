//
//  TradeView.swift
//  Stock App CSCI 571
//
//  Created by Akshil Shah on 4/8/24.
//

import SwiftUI
import SwiftyJSON
import Alamofire

struct TradeView2: View {
  var ticker: String
  var name: String
  var cost: Double
    var quantityIhave:Int
  @State private var money: JSON = JSON()
  @State private var response: Bool = false
  @State private var response2: JSON = JSON()
  @State private var response3: Bool = false
  @Environment(\.dismiss) var dismiss
  @State private var numberOfShares: String="0"
  @State private var navigateToSuccessView = false
  @State private var showToast = false
  @State private var messageToShow = ""
 @Binding var shouldReloadData: Bool
 @State var isBuying: Bool = true
  var body: some View {
      VStack {
          if navigateToSuccessView{
              VStack{
                  Spacer()
                  Text("Congratulations!")
                      .bold()
                      .font(.largeTitle)
                      .foregroundColor(.white)
                      .padding(.bottom,12)
                      
                  Text("You have successfully \(isBuying ? "bought" : "sold") \(numberOfShares) \(numberOfShares == "1" ? "share" : "shares") of \(ticker)").foregroundColor(.white)
                                      Spacer()
                  Button(action: {
                      shouldReloadData.toggle()
                      dismiss()
                  }, label: {
                      Text("Done")
                          .foregroundColor(.green)
                          .frame(width: 330,height: 50)
                          .background(Color.white)
                          .cornerRadius(23)
                  })
              }.transition(.move(edge: .bottom))
                  .frame(maxWidth: .infinity, maxHeight: .infinity)
                  .background(Color.green.edgesIgnoringSafeArea(.all))
             
          }
          else{
              NavigationView{
              VStack {
                  Text("Trade \(name) shares").bold()
                  Spacer()
                  HStack{
                      TextField("", text: $numberOfShares)
                          .font(.system(size: 95))
                          .foregroundColor(numberOfShares == "0" ? .secondary : .primary)
                          .keyboardType(.numberPad)
                      Spacer()
                      Text(numberOfShares == "1" || numberOfShares=="0" || numberOfShares == "" ? "Share" : "Shares")
                          .font(.largeTitle)
                  }
                  HStack{
                      Spacer()
                      let roundedCost = String(format: "%.2f", cost)
                      let totalValue = cost*(Double(numberOfShares) ?? 0)
                      let roundedTotal = String(format: "%.2f", totalValue)
                      Text("x $\(roundedCost)/share = $\(roundedTotal)")
                  }
                  Spacer()
                  let roundedMoney = String(format: "%.2f", money.doubleValue)
                  Text("$\(roundedMoney) available to buy \(ticker)").foregroundColor(.secondary)
                  HStack {
                      Button(action: {
                          if Int(numberOfShares) ?? 0 == 0 {
                                              showToast = true
                              messageToShow = "Please enter a valid amount"
                          } else {
                              let totalValue = cost*(Double(numberOfShares) ?? 0)
                              tradeTicker2(ticker: ticker, quantity: Int(numberOfShares) ?? 0, name: name, totalCost: totalValue, avgCost: cost){
                                  success in
                                  response = success
                                  if success{
                                      navigateToSuccessView = true
                                      
                                  }
                                  else{
                                      print(response)
                                  }
                              }
                              let moneyLeft = money.doubleValue - totalValue
                              updateMoney2(moneyLeft: moneyLeft){
                                  success in
                                  response2 = success
                                  print(success)
                              }
                          }
                      }, label: {
                          Text("Buy")
                              .foregroundColor(.white)
                              .frame(width: 170,height: 50)
                              .background(Color.green)
                              .cornerRadius(23)
                      })
                      Spacer()
                      Button(action: {
                          if Int(numberOfShares) ?? 0 == 0 {
                                              showToast = true
                              messageToShow = "Please enter a valid amount"
                          }
                          
                          else if (quantityIhave<(Int(numberOfShares) ?? 0)){
                              showToast = true
                              messageToShow = "Not enough to sell"
                          }
                          else{
                              sellTicker2(ticker: ticker, quantity: Int(numberOfShares) ?? 0, price: cost) {
                                  success in
                                  response3 = success
                                  if success{
                                      isBuying.toggle()
                                      navigateToSuccessView = true
                                  }
                                  else{
                                      print(response)
                                  }
                              }
                              let totalValue = cost*(Double(numberOfShares) ?? 0)
                              let moneyLeft = money.doubleValue + totalValue
                              updateMoney2(moneyLeft: moneyLeft){
                                  success in
                                  response2 = success
                                  print(success)
                              }
                          }
                      }, label: {
                          Text("Sell")
                              .foregroundColor(.white)
                              .frame(width: 170,height: 50)
                              .background(Color.green)
                              .cornerRadius(23)
                      })
                  }
              }
              
              .padding()
              .frame(maxWidth: .infinity)
              .navigationBarItems(trailing:
                                    Button(action: {
                  dismiss()
              }) {
                  Image(systemName: "xmark")
                      .font(.callout)
                      .foregroundColor(.black)
              }
              )
          }
      }
    }.onAppear{
        print(quantityIhave)
        fetchMoney2()
            { json in
                money = json
                print(money)
            }
    }
    .overlay(
                Toast2 (isShowing: $showToast, message: messageToShow)
            )
  }
}
func fetchMoney2( completionHandler: @escaping (JSON) -> Void) {
    AF.request("http://localhost:8080/getMoney")
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

func tradeTicker2(ticker: String, quantity: Int, name: String, totalCost: Double, avgCost: Double, completionHandler: @escaping (Bool) -> Void) {
    let parameters: [String: Any] = [
        "totalCost": totalCost,
        "ticker": ticker,
        "quantity": quantity,
        "name": name,
        "avgCost": avgCost
    ]
    AF.request("http://localhost:8080/updatePortfolio/\(ticker)", method: .post, parameters: parameters, encoding: JSONEncoding.default)
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

  
func updateMoney2(moneyLeft:Double ,completionHandler: @escaping (JSON) -> Void) {
    AF.request("http://localhost:8080/updateMoney/\(moneyLeft)", method: .post)
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

func sellTicker2(ticker: String, quantity: Int,price:Double, completionHandler: @escaping (Bool) -> Void) {
    let parameters: [String: Any] = [
        "price": price,
        "quantity": quantity,
    ]
    AF.request("http://localhost:8080/sellPortfolio/\(ticker)", method: .post, parameters: parameters, encoding: JSONEncoding.default)
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

struct Toast2: View {
    @Binding var isShowing: Bool
    var message: String 
    
    var body: some View {
        if isShowing {
            VStack{
                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: 34)
                        .foregroundColor(.gray)
                        .frame(width:330, height:63)
                    Text(message)
                        .foregroundColor(.white)
                }
                .padding()
                .animation(.default)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isShowing = false
                    }
                }
            }
        } else {
            EmptyView()
        }
    }
}

#Preview {
    StockData(displaySymbol: "AAPL")
}
