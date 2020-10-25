//
//  SEXMLDecoderFeedCell.swift
//  SwiftExplorer
//
//  Created by Kenny Leung on 10/11/20.
//  Copyright © 2020 Kenny Leung. All rights reserved.
//

import Foundation
import SwiftUI
import hexdreamsCocoa

struct SEXMLDecoderFeedCell: View {
    static var DATE_FORMATTER:DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, dd MMM yyy HH:mm:ss Z"
        return formatter;
    }

    @ObservedObject private var loader:SEXMLDecoderFeedLoader
    
    init(feed:SEXMLDecoderFeed) {
        self.loader = SEXMLDecoderFeedLoader(feed:feed)
    }
    
    var body: some View {
        HXNavigationLink(destination:self.loader.channel.map{SEXMLDecoderEpisodesView(channel:$0)}) {
            HStack(alignment:.top) {
                HXAsyncImage(url:self.loader.channel?.itunesImage) {
                    Text("")
                }.aspectRatio(contentMode: ContentMode.fill)
                .frame(width:50, height:50, alignment:.center)
                .clipped()
                
                VStack(alignment:.leading, spacing:3.0) {
                    Text(self.loader.channel?.title ?? "")
                    let pubDate:Date? = self.loader.channel?.latestItem?.pubDate
                    Text(pubDate.map{Self.DATE_FORMATTER.string(from:$0)} ?? "")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}
