import SwiftUI
import Kingfisher

struct NewsArticleView: View {
    let newsItem: NewsItem
    @State private var showingSheet = false
    var formattedDate: String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM dd, yyyy"
        return dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(newsItem.datetime)))
        }
    var body: some View {
        Button(action: {
            showingSheet.toggle()
        }) {
            VStack(alignment: .leading, spacing: 10) {
                KFImage(URL(string: newsItem.image))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width - 40, height: 200)
                    .cornerRadius(10)
                HStack{
                    Text(newsItem.source)
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.secondary)
                    Text(relativeTime(from: newsItem.datetime))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Text(newsItem.headline)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                Divider()
            }
            .padding(.horizontal)
        }
        .sheet(isPresented: $showingSheet) {
            SheetView(source: newsItem.source,headline: newsItem.headline,datetime: formattedDate,summary: newsItem.summary,url:newsItem.url)
                }
    }
    private func relativeTime(from timestamp: Int) -> String {
        let currentTime = Int(Date().timeIntervalSince1970)
        let elapsedTime = currentTime - timestamp
        
        let minutes = elapsedTime / 60
        let hours = minutes / 60
        
        if hours > 0 {
            let remainingMinutes = minutes % 60
            if remainingMinutes > 0 {
                return "\(hours) hr, \(remainingMinutes) min"
            } else {
                return "\(hours) hr"
            }
        } else {
            return "\(minutes) min"
        }
    }

    }

struct NewsView: View {
    let news: [NewsItem]
    @State private var showingSheetDict: [Int: Bool] = [:]
   
    var body: some View {
        VStack(alignment: .leading) {
            Text("News")
                .font(.title)
                .padding()
            if let firstArticle = news.first {
                NewsArticleView(newsItem: firstArticle)
            }
            ForEach(news.dropFirst(), id: \.id) { newsItem in
                let isSheetPresented = Binding<Bool>(
                        get: { showingSheetDict[newsItem.id] ?? false },
                        set: { showingSheetDict[newsItem.id] = $0 }
                    )
                var formattedDate: String {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MMMM dd, yyyy"
                    return dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(newsItem.datetime)))
                    }
                Button(action: {
                    showingSheetDict[newsItem.id, default: false].toggle()
                }) {
                    HStack{
                        VStack(alignment: .leading, spacing: 10) {
                            HStack{
                                Text(newsItem.source)
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(.secondary)
                                Text(relativeTime(from: newsItem.datetime))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text(newsItem.headline)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                            
                        }
                        .padding(.leading,10)
                       
                        Spacer()
                      
                        KFImage(URL(string: newsItem.image))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width - 320, height: 80)
                            .cornerRadius(10)
                            .padding(.trailing,10)
                    }
                    .sheet(isPresented: isSheetPresented)
                    {
                        SheetView(source: newsItem.source,headline: newsItem.headline,datetime: formattedDate,summary: newsItem.summary,url:newsItem.url)
                    }
            }
                Divider()
            }
        }
        .padding()
    }
    
    private func relativeTime(from timestamp: Int) -> String {
        let currentTime = Int(Date().timeIntervalSince1970)
        let elapsedTime = currentTime - timestamp
        
        let minutes = elapsedTime / 60
        let hours = minutes / 60
        
        if hours > 0 {
            let remainingMinutes = minutes % 60
            if remainingMinutes > 0 {
                return "\(hours) hr, \(remainingMinutes) min"
            } else {
                return "\(hours) hr"
            }
        } else {
            return "\(minutes) min"
        }
    }
}
struct NewsView_Previews : PreviewProvider {
    static var previews : some View {
       StockData(displaySymbol: "AAPL")
    }
}

