
struct SEDecodableOwner : Decodable {
    
    let itunesEmail:String
    let itunesName:String
    
    enum CodingKeys: String, CodingKey {
        case itunesEmail = "itunes:email"
        case itunesName  = "itunes:name"
    }

}
