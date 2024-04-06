import SwiftUI
import Kingfisher

struct NewsArticleView: View {
    let newsItem: NewsItem

    var body: some View {
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
            Divider()
        }
        .padding(.horizontal)
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

    var body: some View {
        VStack(alignment: .leading) {
            Text("News")
                .font(.title)
                .padding(.bottom, 10)
            if let firstArticle = news.first {
                NewsArticleView(newsItem: firstArticle)
            }
            ForEach(news.dropFirst(), id: \.id) { newsItem in
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
                        Divider()
                    }
                    .padding(.horizontal)
                    KFImage(URL(string: newsItem.image))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width - 280, height: 100)
                        .cornerRadius(10)
                }
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
