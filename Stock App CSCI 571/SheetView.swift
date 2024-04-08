//
//  SheetView.swift
//  Stock App CSCI 571
//
//  Created by Akshil Shah on 4/6/24.
//

import SwiftUI

struct SheetView: View {
    @Environment(\.dismiss) var dismiss
    @State var source:String
    @State var headline:String
    @State var datetime: String
    @State var summary:String
    @State var url:String
    
    var body: some View {
        NavigationView {
            VStack(alignment:.leading) {
                Text(source)
                    .font(.title)
                    .bold()
                Text(datetime)
                    .foregroundColor(.secondary)
                    .padding(.bottom,10)
                Divider()
                Text(headline)
                    .bold()
                    .font(.title3)
                    .multilineTextAlignment(.leading)
                Text(summary)
                    .multilineTextAlignment(.leading)
                    .font(.callout)
                HStack{
                    Text("For more details click")
                        .foregroundColor(.secondary)
                        .font(.callout)
                    Link(destination: URL(string: url)!) {
                        Text("here")
                            .foregroundColor(.blue)
                            .font(.callout)
                    }
                }
                HStack{
                    Link(destination: URL(string: "https://twitter.com/intent/tweet?text=\(headline)&url=\(url)")!) {
                            Image("twitter")
                                .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipped()
                        }
                    Link(destination: URL(string: "https://www.facebook.com/sharer/sharer.php?u=\(url)")!) {
                            Image("facebook")
                                .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipped()
                        }
                }
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
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
        .accentColor(.black) 
    }
}
//struct SheetView_Previews : PreviewProvider {
//    static var previews : some View {
//       StockData(displaySymbol: "AAPL")
//    }
//}
