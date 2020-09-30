//
//  Feeds.swift
//  DailyRadio
//
//  Created by Kenny Leung on 9/13/20.
//

import SwiftUI

public struct SEFeeds: View {    
    @State var feeds = SEFeed.examples
            
    public var body: some View {
        List(self.feeds, id:\SEFeed.name) { feed in
            SEFeedCell(feed:feed)
        }
    }
}
