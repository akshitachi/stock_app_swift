import SwiftUI

struct StockStatsView: View {
    var stats: StockStats

    var body: some View {
        VStack(alignment: .leading) {
            Text("Stats")
                .font(.title)
                .padding(.bottom, 10)
            HStack {
                Text("High Price:")
                    .font(.callout)
                    .fontWeight(.semibold) // Make the "High Price" keyword bold
                Text(" \(stats.highPrice)")
                    .font(.callout)
                Spacer()
                Text("Open Price:")
                    .font(.callout)
                    .fontWeight(.semibold) // Make the "Open Price" keyword bold
                Text(" \(stats.openPrice)")
                    .font(.callout)
            }
            .padding(.bottom, 10)
            HStack {
                Text("Low Price:")
                    .font(.callout)
                    .fontWeight(.semibold) // Make the "Low Price" keyword bold
                Text(" \(stats.lowPrice)")
                    .font(.callout)
                Spacer()
                Text("Prev. Close:")
                    .font(.callout)
                    .fontWeight(.semibold) // Make the "Prev. Close" keyword bold
                Text(" \(stats.previousClose)")
                    .font(.callout)
            }
        }
        .padding()
        .padding(.trailing, 30)
        .background(Color.white)
    }
}

struct StockStatsView_Previews: PreviewProvider {
    static var previews: some View {
        StockData(displaySymbol: "NVDA")
    }
}
