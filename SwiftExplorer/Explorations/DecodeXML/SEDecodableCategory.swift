//
//  SEDecodableiTunesCategory.swift
//  SwiftExplorer
//
//  Created by Kenny Leung on 9/7/20.
//  Copyright © 2020 Kenny Leung. All rights reserved.
//

import Foundation

// A struct cannot recursively contain itself, even if it's optional
public class SEDecodableCategory : Decodable {
    
    let text:String
    let itunesCategory:SEDecodableCategory?
        
    enum CodingKeys: String, CodingKey {
        case text           = "@text"
        case itunesCategory = "itunes:category"        
    }

}
