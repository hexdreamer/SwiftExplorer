import SwiftUI
import Combine
import UIKit

// https://www.vadimbulavin.com/asynchronous-swiftui-image-loading-from-url-with-combine-and-swift/
struct SEAsyncImage<Content:View>: View {
    @ObservedObject private var loader: SEImageLoader
    private let placeholder:()->Content
        
    init(url:URL?, placeholder:@escaping ()->Content) {
        self.loader = SEImageLoader(url:url)
        self.placeholder = placeholder
    }
        
    // Two things I don't like about this:
    // 1) The Group
    // 2) self.loader.image!
    var body: some View {
        Group {
            if ( self.loader.image == nil) {
                self.placeholder()
                    .onAppear(perform: loader.load)
                    .onDisappear(perform: loader.cancel)
            } else {
                Image(uiImage:self.loader.image!)
                    .resizable()
            }
        }
    }
}

class SEImageLoader: ObservableObject {
    @Published var image:UIImage?
    
    private let url:URL?
    private var dataTask:AnyCancellable?
    
    init(url:URL?) {
        self.url = url
    }
    
    deinit {
        self.cancel()
    }
    
    func load() {
        guard let url = self.url else {
            return
        }
        self.dataTask = URLSession.shared.dataTaskPublisher(for:url)
            .map { UIImage(data:$0.data) }
            .replaceError(with:nil)
            .receive(on:DispatchQueue.main)
            .assign(to:\.image, on:self)
    }
    
    func cancel() {
        self.dataTask?.cancel()
    }
}
