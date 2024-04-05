//
//  AboutView.swift
//  Stock App CSCI 571
//
//  Created by Akshil Shah on 4/5/24.
//

import SwiftUI

struct AboutView: View {
    let companyName: String
        let ipoDate: String
        let industry: String
        let webpage: String
        let peers: [String]

  var body: some View {
    VStack(alignment: .leading) {
      Text("About")
        .font(.title)
        .padding(.bottom,10)
      HStack(spacing: 16) {
        VStack(alignment: .leading, spacing: 8) {
          Text("IPO Start Date:")
                .font(.callout)
            .bold()
          Text("Industry:")
                .font(.callout)
            .bold()
          Text("Webpage:")
                .font(.callout)
            .bold()
          Text("Company Peers:")
                .font(.callout)
            .bold()
        }
        VStack(alignment: .leading, spacing: 8) {
          Text("\(ipoDate)")
            .font(.callout)
          Text("\(industry)")
            .font(.callout)
          Link(destination: URL(string: webpage)!) {
            Text("\(webpage)")
              .font(.callout)
          }
            ScrollView(.horizontal) {
                                    HStack(spacing: 2) {
                                        ForEach(peers, id: \.self) { peer in
                                            NavigationLink(destination: StockData(displaySymbol: peer)) {
                                                    Text("\(peer), ")
                                                    .font(.callout)
                                                    .foregroundColor(.blue)
                                                                            }
//                                            Button(action: {
//                                                
//                                            }) {
//                                                Text("\(peer), ")
//                                                    .font(.callout)
//                                                    .foregroundColor(.blue)
//                                            }
                                        }
                                    }
                                }
        }
      }
    }
    .padding()
  }
}

struct AboutView_Previews: PreviewProvider {
  static var previews: some View {
    StockData(displaySymbol: "NVDA")
  }
}
