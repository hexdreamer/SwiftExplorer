//
//  SEFeedNavigationLink.swift
//  SwiftExplorer
//
//  Created by Kenny Leung on 9/29/20.
//  Copyright © 2020 Kenny Leung. All rights reserved.
//

import SwiftUI

struct HXNavigationLink<Label:View,Destination:View> : View {

    private let destination:Destination?
    private let label:()->Label

    init(destination:Destination?, label:@escaping ()->Label) {
        self.destination = destination
        self.label = label
    }

    var body: some View {
        if self.destination == nil {
            label()
        } else {
            NavigationLink(destination:self.destination!, label:label);
        }
    }
}
