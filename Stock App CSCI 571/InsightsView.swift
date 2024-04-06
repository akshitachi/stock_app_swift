//
//  InsightsView.swift
//  Stock App CSCI 571
//
//  Created by Akshil Shah on 4/5/24.
//

import SwiftUI

struct InsiderSentiment: Codable, Hashable {
    let symbol: String
    let year: Int
    let month: Int
    let change: Double
    let mspr: Double
}


struct InsightsView: View {
    let totalMSPR: Double
    let positiveMSPR: Double
    let negativeMSPR: Double
    let totalChange: Int
    let positiveChange: Int
    let negativeChange: Int
    let ticker: String
  var body: some View {
      
    VStack(alignment: .leading) {
        Text("Insights")
            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
            .padding(.bottom, 10)
      Text("Insider Sentiments")
            .font(.title)
            .padding(.leading, 60)
            .padding(.bottom, 10)
      
      HStack {
        Text(ticker)
          .fontWeight(.bold)
          .frame(minWidth: 0, maxWidth: .infinity,alignment: .leading)
        Text("MSPR")
          .fontWeight(.bold)
          .frame(minWidth: 0, maxWidth: .infinity)
        Text("Change")
          .fontWeight(.bold)
          .frame(minWidth: 0, maxWidth: .infinity)
      }
      Divider()
      HStack {
        Text("Total")
          .frame(minWidth: 0, maxWidth: .infinity,alignment: .leading)
          .bold()
          Text(String(format: "%.2f", totalMSPR))
          .frame(minWidth: 0, maxWidth: .infinity)
        Text("\(totalChange)")
          .frame(minWidth: 0, maxWidth: .infinity)
      }
        Divider()
      HStack {
        Text("Positive")
        .bold()
          .frame(minWidth: 0, maxWidth: .infinity,alignment: .leading)
          Text(String(format: "%.2f", positiveMSPR))
          .frame(minWidth: 0, maxWidth: .infinity)
        Text("\(positiveChange)")
          .frame(minWidth: 0, maxWidth: .infinity)
      }
    Divider()
      HStack {
        Text("Negative")
              .bold()
          .frame(minWidth: 0, maxWidth: .infinity,alignment: .leading)
          Text(String(format: "%.2f", negativeMSPR))
          .frame(minWidth: 0, maxWidth: .infinity)
        Text("\(negativeChange)")
          .frame(minWidth: 0, maxWidth: .infinity)
      }
        Divider()
    }
    .padding()
  }
}

struct InsightsView_Previews: PreviewProvider {
  static var previews: some View {
    StockData(displaySymbol: "NVDA")
  }
}

