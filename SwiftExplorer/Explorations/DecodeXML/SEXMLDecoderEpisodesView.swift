//
//  SEXMLDecoderEpisodesView.swift
//  SwiftExplorer
//
//  Created by Kenny Leung on 9/12/20.
//  Copyright © 2020 Kenny Leung. All rights reserved.
//

import SwiftUI
import hexdreamsCocoa

struct SEXMLDecoderEpisodesView: View {
    static var DATE_FORMATTER:DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, dd MMM yyy HH:mm:ss Z"
        return formatter;
    }

    let channel:SEDecodableChannel
    
    // Can make custom navigation title views in iOS 14
    // https://sarunw.com/posts/custom-navigation-bar-title-view-in-swiftui/
    var body: some View {
        List {
            VStack {
                HXAsyncImage(url:channel.itunesImage) {
                    Image("ChannelImageDefault")
                        .resizable()
                }.aspectRatio(contentMode: ContentMode.fill)
                .frame(width:150, height:150, alignment:.center)
                .clipped()
                
                Text(self.channel.description)
            }
            .padding(.top, 20.0)
            .padding(.bottom, 20.0)
            .padding(.leading, 10.0)
            .padding(.trailing, 10.0)
            .frame(maxWidth:.infinity, alignment:.center)
            .background(Color(Color.RGBColorSpace.displayP3, white:0.9, opacity:1.0))
            
            ForEach(self.channel.items, id:\SEDecodableItem.guid) { item in
                SEXMLDecoderEpisodeCell(item:item)
            }
        }
    }
}
