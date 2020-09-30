//
//  Episodes.swift
//  DailyRadio
//
//  Created by Kenny Leung on 9/13/20.
//

import SwiftUI

struct SEEpisodes: View {
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
                SEEpisodeCell(item:item)
            }
        }
    }
}
