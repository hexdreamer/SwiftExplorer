
import Foundation
import SwiftUI

struct SEDecodeXML : View {
    
    let test:[String:Decodable.Type] = ["Channel":SEDecodableChannel.self]
    
    var channel:SEDecodableChannel? {
        do {
            if let url = Bundle.main.url(forResource: "AccidentalTechPodcast", withExtension: "xml") {
                let data = try Data(contentsOf:url)
                let decoder = SEXMLParser(
                    models:["channel":SEDecodableChannel.self,
                            "itunes:owner":SEDecodableOwner.self,
                            "image":SEDecodableImage.self,
                            "item":SEDecodableItem.self]
                )
                return decoder.parse(data) as? SEDecodableChannel
            }
        } catch (let error) {
            print("Error: \(error)")
        }
        return nil
    }
        
    var body: some View {
        List(self.channel?.items ?? [], id:\SEDecodableItem.guid) { item in
            Text(item.title)
        }
    }
    
}
