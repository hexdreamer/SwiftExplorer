//
//  ContentView.swift
//  SwiftUIExplorer
//
//  Created by Kenny Leung on 8/30/20.
//  Copyright © 2020 Kenny Leung. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(
                    destination:RegionMarkerRectangle()
                        .navigationBarTitle("Rectangle Based")
                ){
                    Text("Region Marker (Rectangle Based)")
                }
                
                NavigationLink(
                    destination:RegionMarkerCorners()
                        .navigationBarTitle("Corner Based")
                ) {
                    Text("Region Marker (Corner Based)")
                }
                
                NavigationLink(
                    destination:RegionMarkerOffset()
                        .navigationBarTitle("By Offset")
                ) {
                    Text("Region Marker (By Offset)")
                }
                
                NavigationLink(
                    destination:HiraganaKeyboard()
                        .navigationBarTitle("Hiragana Keyboard")
                ) {
                    Text("Hiragana Keyboard")
                }

                NavigationLink(
                    destination:KatakanaKeyboard()
                        .navigationBarTitle("Katakana Keyboard")
                ) {
                    Text("Katakana Keyboard")
                }

                NavigationLink(
                    destination:SECustomXMLParsing()
                        .navigationBarTitle("Custom XML Parser")
                ) {
                    Text("Custom XML Parser")
                }
                
                NavigationLink(
                    destination:SEDecodeXML()
                        .navigationBarTitle("XML Decoder")
                ) {
                    Text("XML Decoder")
                }
                
                NavigationLink(
                    destination:SEEvenOddFill()
                        .navigationBarTitle("Even Odd Fill")
                ) {
                    Text("Even Odd Fill")
                }

                NavigationLink(
                    destination:SEEvenOddFillUIKit()
                        .navigationBarTitle("Even Odd Fill UIKit")
                ) {
                    Text("Even Odd Fill UIKit")
                }
            }
            .navigationBarTitle("Explorations")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
