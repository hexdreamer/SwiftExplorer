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