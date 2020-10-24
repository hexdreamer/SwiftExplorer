
import Foundation
import SwiftUI
import hexdreamsCocoa

struct SEDecodeXML : View {
    @State var feeds = SEXMLDecoderFeed.examples
            
    public var body: some View {
        List(self.feeds, id:\SEXMLDecoderFeed.name) { feed in
            SEXMLDecoderFeedCell(feed:feed)
        }
    }
}
