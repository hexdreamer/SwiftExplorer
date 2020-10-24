//
//  SEXMLDecoderEpisodeCell.swift
//  SwiftExplorer
//
//  Created by Kenny Leung on 10/24/20.
//  Copyright © 2020 Kenny Leung. All rights reserved.
//

import SwiftUI
import hexdreamsCocoa

struct SEXMLDecoderEpisodeCell: View {
    static var DATE_FORMATTER:DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d yyy hh:mma"
        return formatter;
    }

    let item:SEDecodableItem
    
    var body: some View {
        HStack(alignment:.top) {
            VStack(alignment:.leading, spacing:3.0) {
                Text(verbatim:item.title)
                Text(Self.DATE_FORMATTER.string(from:item.pubDate))
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer().frame(maxHeight:2.0)
                if item.itunesSummary != nil {
                    HXHTMLView(data:item.itunesSummary)
                        .font(.caption)
                } else if item.description != nil {
                    HXHTMLView(data:item.description)
                        .font(.caption)
                }
            }
            if item.itunesImage != nil {
                Spacer()
                HXAsyncImage(url:item.itunesImage) {
                    Image("ChannelImageDefault")
                        .resizable()
                }.aspectRatio(contentMode: ContentMode.fill)
                .frame(width:80, height:80, alignment:.center)
                .clipped()
            }
        }
    }
}
