import SwiftUI
import Combine
import UIKit

// https://www.vadimbulavin.com/asynchronous-swiftui-image-loading-from-url-with-combine-and-swift/
struct SEAsyncImage<Content:View>: View {
    private let image:UIImage?
    // Would like this to be nil-able, but wrapper doesn't allow it
    @ObservedObject private var loader:SEImageLoader
    private let placeholder:(()->Content)?
        
    init(url:URL?, placeholder:@escaping ()->Content) {
        if let image = SEImageLoader.cachedImageForURL(url:url) {
            self.image = image
            self.loader = SEImageLoader(url:nil)
            self.placeholder = nil
        } else {
            self.image = nil
            self.loader = SEImageLoader(url:url)
            self.placeholder = placeholder
            self.loader.load()
        }
    }
        
    // Don't like the overuse of ! here, but if-let is not allowed
    var body: some View {
        if ( self.image != nil ) {
            Image(uiImage:self.image!)
                .resizable()
        } else if ( self.loader.image != nil ) {
            Image(uiImage:self.loader.image!)
                .resizable()
        } else {
            self.placeholder!()
        }
    }
}

class SEImageLoader: ObservableObject {
    static private var cache = NSCache<NSURL,UIImage>()
    
    static func cachedImageForURL(url:URL?) -> UIImage? {
        if let nsurl = url as NSURL? {
            return cache.object(forKey:nsurl)
        }
        return nil
    }
    
    @Published var image:UIImage? {
        didSet {
            if let image = self.image,
               let nsurl = url as NSURL? {
                Self.cache.setObject(image, forKey:nsurl)
            }
            self.url = nil
            self.dataTask = nil
        }
    }
    private var url:URL?
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
