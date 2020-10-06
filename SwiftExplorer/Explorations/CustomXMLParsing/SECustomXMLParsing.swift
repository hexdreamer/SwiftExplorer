//
//  Feeds.swift
//  DailyRadio
//
//  Created by Kenny Leung on 9/13/20.
//

import SwiftUI

public struct SECustomXMLParsing: View {    
    @State var feeds = SECustomParsingFeed.examples
            
    public var body: some View {
        List(self.feeds, id:\SECustomParsingFeed.name) { feed in
            SECustomParsingFeedCell(feed:feed)
        }
    }
}
