import SwiftUI

struct PhotoDisplayData: Identifiable {
    let id = UUID()
    let photos: [JournalPhoto]
    let images: [UIImage]
    let initialIndex: Int
}

struct PhotoGalleryView: View {
    let photos: [JournalPhoto]
    @State private var selectedPhotoData: PhotoDisplayData?
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                if let uiImage = photo.load() {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .onTapGesture {
                            print("DEBUG: Tapping photo \(index + 1) of \(photos.count)")
                            // Load all images upfront for smooth swiping
                            let allImages = photos.compactMap { $0.load() }
                            selectedPhotoData = PhotoDisplayData(
                                photos: photos,
                                images: allImages,
                                initialIndex: index
                            )
                            print("DEBUG: selectedPhotoData set with \(allImages.count) images")
                        }
                } else {
                    // Debug: Show placeholder when image fails to load
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 120)
                        .overlay(
                            VStack {
                                Image(systemName: "exclamationmark.triangle")
                                Text("Failed to load")
                                    .font(.caption)
                                Text(photo.fileName)
                                    .font(.caption2)
                            }
                            .foregroundColor(.red)
                        )
                }
            }
        }
        .sheet(item: $selectedPhotoData) { photoData in
            PhotoSwipeView(
                photos: photoData.photos,
                images: photoData.images,
                initialIndex: photoData.initialIndex,
                onDismiss: {
                    selectedPhotoData = nil
                }
            )
        }
    }
}

struct PhotoSwipeView: View {
    let photos: [JournalPhoto]
    let images: [UIImage]
    let initialIndex: Int
    let onDismiss: () -> Void
    
    @State private var currentIndex: Int
    
    init(photos: [JournalPhoto], images: [UIImage], initialIndex: Int, onDismiss: @escaping () -> Void) {
        self.photos = photos
        self.images = images
        self.initialIndex = initialIndex
        self.onDismiss = onDismiss
        self._currentIndex = State(initialValue: initialIndex)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Photo counter
                if photos.count > 1 {
                    Text("\(currentIndex + 1) of \(photos.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
                
                // Photo pager
                TabView(selection: $currentIndex) {
                    ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                        ZoomableScrollView {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: photos.count > 1 ? .automatic : .never))
            }
            .navigationTitle(currentPhoto?.caption ?? "Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        onDismiss()
                    }
                }
            }
        }
    }
    
    private var currentPhoto: JournalPhoto? {
        guard currentIndex >= 0 && currentIndex < photos.count else { return nil }
        return photos[currentIndex]
    }
}

struct ZoomableScrollView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView([.horizontal, .vertical]) {
                content
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .scaledToFit()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}
