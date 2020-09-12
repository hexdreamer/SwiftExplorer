import SwiftUI
import Combine

// https://www.vadimbulavin.com/asynchronous-swiftui-image-loading-from-url-with-combine-and-swift/
struct SEAsyncImage: View {
    @ObservedObject private var loader: ImageLoader
    private let placeholder:Image
    
    private var image:Image {
        if let image = self.loader.image {
            return Image(uiImage:image)
        } else {
            return placeholder
        }
    }
    
    init(url: URL, placeholder:Image) {
        self.loader = ImageLoader(url: url)
        self.placeholder = placeholder
    }
    
    var body: some View {
        self.image
            .resizable()
            .onAppear(perform:self.loader.load)
            .onDisappear(perform:self.loader.cancel)
    }
}


class ImageLoader: ObservableObject {
    @Published var image:UIImage?
    
    private let url:URL
    private var dataTask:AnyCancellable?
    
    init(url:URL) {
        self.url = url
    }
    
    deinit {
        self.cancel()
    }
    
    func load() {
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
