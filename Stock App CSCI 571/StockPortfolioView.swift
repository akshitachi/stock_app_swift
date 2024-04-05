//
//  StockPortfolioView.swift
//  Stock App CSCI 571
//
//  Created by Akshil Shah on 4/5/24.
//

import SwiftUI

struct StockPortfolio: View {
    
    @State private var shareCount: Int = 0
    @State private var avgCostPerShare: Double = 171.23
    
    var body: some View {
        VStack {
            Text("Portfolio")
                .font(.title)
            if shareCount > 0 {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Shares Owned: \(shareCount)")
                        Text("Avg. Cost / Share: $\(avgCostPerShare, specifier: "%.2f")")
//                        Text("Total Cost: $\((shareCount * avgCostPerShare), specifier: "%.2f")")
                        Text("Change: $\(-0.42, specifier: "%.2f")")
//                        Text("Market Value: $\((shareCount * avgCostPerShare), specifier: "%.2f")")
                    }
//                    Spacer()
                    Button(action: {}, label: {
                        Text("Trade")
                            .foregroundColor(.green)
                            .padding(.vertical)
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(10)
                    })
                }
            } else {
                Text("You have 0 shares of AAPL.")
                Text("Start trading!")
            }
        }
//        .padding()
    }
}

struct StockPortfolio_Previews: PreviewProvider {
    static var previews: some View {
        StockPortfolio()
    }
}


//#Preview {
//    StockPortfolioView()
//}
