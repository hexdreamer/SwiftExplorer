//
//  KeyPathTest.swift
//  SwiftExplorer
//
//  Created by Kenny Leung on 9/18/20.
//  Copyright © 2020 Kenny Leung. All rights reserved.
//

import Foundation

struct KeyPathTest {
    let a:Int
    let b:String
}

func loopOver<T>(keys:[PartialKeyPath<T>], in obj:T) -> Void {
    for key in keys {
        print("key:\(key) value:\(obj[keyPath:key])")
    }
}

func testKeyPaths() {
    let tester = KeyPathTest(a: 5, b: "five")
    loopOver(keys:[\KeyPathTest.a, \KeyPathTest.b], in:tester)
    
    // output:
    // key:Swift.KeyPath<SwiftExplorer.KeyPathTest, Swift.Int> value:5
    // key:Swift.KeyPath<SwiftExplorer.KeyPathTest, Swift.String> value:five
}
