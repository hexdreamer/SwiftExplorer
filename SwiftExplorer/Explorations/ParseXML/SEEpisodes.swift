//
//  Episodes.swift
//  DailyRadio
//
//  Created by Kenny Leung on 9/13/20.
//

import SwiftUI

struct SEEpisodes: View {
    static var DATE_FORMATTER:DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d yyy hh:mma"
        return formatter;
    }

    let channel:SECustomXMLChannel

    // Can make custom navigation title views in iOS 14
    // https://sarunw.com/posts/custom-navigation-bar-title-view-in-swiftui/
    var body: some View {
        List {
            VStack {
                SEAsyncImage(url:channel.itunesImage) {
                    Image("ChannelImageDefault")
                        .resizable()
                }.aspectRatio(contentMode: ContentMode.fill)
                .frame(width:150, height:150, alignment:.center)
                .clipped()
                
                if self.channel.description != nil {
                    Text(self.channel.description!)
                }
            }
            .padding(.top, 20.0)
            .padding(.bottom, 20.0)
            .padding(.leading, 10.0)
            .padding(.trailing, 10.0)
            .frame(maxWidth:.infinity, alignment:.center)
            .background(Color(Color.RGBColorSpace.displayP3, white:0.9, opacity:1.0))
            
            ForEach(self.channel.items, id:\SECustomXMLItem.guid) { item in
                HStack(alignment:.top) {
                    VStack(alignment:.leading, spacing:3.0) {
                        Text(verbatim:item.title ?? "NO TITLE")
                        Text(item.pubDate.map({Self.DATE_FORMATTER.string(from:$0)}) ?? "NO DATE")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer().frame(maxHeight:2.0)
                        if item.descriptionData != nil {
                            Text(item.itemDescription)
                                .font(.caption)
                        } else if item.itunesSummaryData != nil {
                            Text(item.itunesSummary)
                                .font(.caption)
                        }
                    }
                    if item.itunesImage != nil {
                        Spacer()
                        SEAsyncImage(url:item.itunesImage) {
                            Image("ChannelImageDefault")
                                .resizable()
                        }.aspectRatio(contentMode: ContentMode.fill)
                        .frame(width:80, height:80, alignment:.center)
                        .clipped()
                    }
                }
            }
        }
    }
}
