//
//  HXHTMLView.swift
//  SwiftExplorer
//
//  Created by Kenny Leung on 10/4/20.
//  Copyright © 2020 Kenny Leung. All rights reserved.
//

import SwiftUI

struct HXHTMLView: View {
    
    @ObservedObject var loader:HXHTMLLoader  // ObservedObject cannot be optional
    
    init(data:Data?) {
        self.loader = HXHTMLLoader(data:data)
    }
    
    var body: some View {
        Group {
            Text(self.loader.string ?? "Parsing...")
        }
        .onAppear {
            self.loader.load()
        }
        .onDisappear() {
            self.loader.cancel()
        }
    }
    
}

class HXHTMLLoader : ObservableObject {
    
    var data:Data?
    @Published var string:String?
    var cancelled:Bool = false
    
    init(data:Data?) {
        self.data = data
    }
    
    func load() {
        self.cancelled = false
        if self.data == nil || self.string != nil {
            return
        }
        DispatchQueue.global(qos:.background).async { [weak self] in
            do {
                if let data = self?.data {
                    if self == nil {
                        return
                    }
                    if let x = self?.cancelled, x {
                        return
                    }
                    let unicode = try SEHTMLToUnicode().convert(data)
                    DispatchQueue.main.async { [weak self] in
                        if self == nil {
                            return
                        }
                        if let x = self?.cancelled, x {
                            return
                        }
                        self?.string = unicode
                        self?.data = nil
                    }
                }
            } catch let e {
                print(e)
            }
        }
    }
    
    func cancel() {
        self.cancelled = true
    }

}
