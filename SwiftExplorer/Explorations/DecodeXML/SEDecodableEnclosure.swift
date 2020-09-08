//
//  SEDecodableEnclosure.swift
//  SwiftExplorer
//
//  Created by Kenny Leung on 9/7/20.
//  Copyright © 2020 Kenny Leung. All rights reserved.
//

import Foundation

// A struct cannot recursively contain itself, even if it's optional
public class SEDecodableEnclosure : Decodable {
    
    let url:URL
    let type:String
    let length:UInt32
        
    enum CodingKeys: String, CodingKey {
        case url           = "@url"
        case type          = "@type"
        case length        = "@length"
    }

}
