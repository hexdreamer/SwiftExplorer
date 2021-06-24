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
                ForEach(navLinks, id: \.id) { navLink in
                    NavigationLink(
                        destination: navLink.dest
                            .navigationBarTitle(navLink.navBarTitle)
                    ){
                        Text(navLink.text)
                    }
                }
            }
            .navigationBarTitle("Explorations")
        }
    }
}

struct NavLink {
    let id = UUID()
    let dest:AnyView
    let navBarTitle:String
    let text:String
}

let navLinks = [
    NavLink(dest: AnyView(AffineTransformsViewports()), navBarTitle: "Transforms: Viewports", text: "Affine Transforms - Viewports"),
    NavLink(dest: AnyView(AffineTransformsFlow()), navBarTitle: "Transforms: Data Flow", text: "Affine Transforms - Data Flow"),
    NavLink(dest: AnyView(ClampingDragGesture()), navBarTitle: "Clamp DragGesture", text: "Clamp DragGesture"),
    NavLink(dest: AnyView(RegionMarkerRectangle()), navBarTitle: "Rectangle Based", text: "Region Marker (Rectangle Based)"),
    NavLink(dest: AnyView(RegionMarkerCorners()), navBarTitle: "Corner Based", text: "Region Marker (Corner Based)"),
    NavLink(dest: AnyView(RegionMarkerOffset()), navBarTitle: "By Offset", text: "Region Marker (By Offset)"),
    NavLink(dest: AnyView(HiraganaKeyboard()), navBarTitle: "Hiragana Keyboard", text: "Hiragana Keyboard"),
    NavLink(dest: AnyView(KatakanaKeyboard()), navBarTitle: "Katakana Keyboard", text: "Katakana Keyboard"),
    NavLink(dest: AnyView(SECustomXMLParsing()), navBarTitle: "Custom XML Parser", text: "Custom XML Parser"),
    NavLink(dest: AnyView(SEDecodeXML()), navBarTitle: "XML Decoder", text: "XML Decoder"),
    NavLink(dest: AnyView(SEEvenOddFill()), navBarTitle: "Even Odd Fill", text: "Even Odd Fill"),
    NavLink(dest: AnyView(SEEvenOddFillUIKit()), navBarTitle: "Even Odd Fill UIKit", text: "Even Odd Fill UIKit"),
]

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
