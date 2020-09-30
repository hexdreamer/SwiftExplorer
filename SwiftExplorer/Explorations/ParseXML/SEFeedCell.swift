//
//  SEFeedCell.swift
//  SwiftExplorer
//
//  Created by Kenny Leung on 9/28/20.
//  Copyright © 2020 Kenny Leung. All rights reserved.
//

import SwiftUI

struct SEFeedCell: View {
    static var DATE_FORMATTER:DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, dd MMM yyy HH:mm:ss Z"
        return formatter;
    }

    @ObservedObject private var loader:SEFeedLoader
    
    init(feed:SEFeed) {
        self.loader = SEFeedLoader(feed:feed)
    }
    
    var body: some View {
        HXNavigationLink(destination:self.loader.channel.map{SEEpisodes(channel:$0)}) {
            HStack(alignment:.top) {
                SEAsyncImage(url:self.loader.channel?.itunesImage) {
                    Text("")
                }.aspectRatio(contentMode: ContentMode.fill)
                .frame(width:50, height:50, alignment:.center)
                .clipped()
                
                VStack(alignment:.leading, spacing:3.0) {
                    Text(self.loader.channel?.title ?? self.loader.feed.title)
                    Text(self.loader.channel?.latestItem?.pubDate.map{Self.DATE_FORMATTER.string(from:$0)} ?? "")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}
