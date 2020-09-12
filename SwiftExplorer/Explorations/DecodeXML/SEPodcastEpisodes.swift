//
//  SEPodcastEpisodes.swift
//  SwiftExplorer
//
//  Created by Kenny Leung on 9/12/20.
//  Copyright © 2020 Kenny Leung. All rights reserved.
//

import SwiftUI

struct SEPodcastEpisodes: View {
    static var DATE_FORMATTER:DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, dd MMM yyy HH:mm:ss Z"
        return formatter;
    }

    let channel:SEDecodableChannel
    
    // Can make custom navigation title views in iOS 14
    // https://sarunw.com/posts/custom-navigation-bar-title-view-in-swiftui/
    var body: some View {
        List(self.channel.items, id:\SEDecodableItem.guid) { item in
            VStack(alignment:.leading, spacing:3.0) {
                Text(item.title)
                Text(Self.DATE_FORMATTER.string(from:item.pubDate))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

//struct SEPodcastEpisodes_Previews: PreviewProvider {
//    static var previews: some View {
//        SEPodcastEpisodes()
//    }
//}
