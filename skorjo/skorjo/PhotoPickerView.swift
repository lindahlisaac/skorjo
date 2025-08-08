import SwiftUI
import PhotosUI
import SwiftData

struct PhotoPickerView: View {
    @Environment(\.modelContext) private var context
    @Binding var photos: [JournalPhoto]
    let maxPhotos: Int
    let lilac: Color
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Photo grid
            if !photos.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(photos) { photo in
                            if let uiImage = photo.load() {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(
                                        Button(action: { deletePhoto(photo) }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.white)
                                                .background(Circle().fill(Color.black.opacity(0.5)))
                                                .padding(4)
                                        }
                                        .padding(4),
                                        alignment: .topTrailing
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 100)
            }
            
            // Add photo button
            if photos.count < maxPhotos {
                PhotosPicker(selection: $selectedItems,
                           maxSelectionCount: maxPhotos - photos.count,
                           matching: .images,
                           photoLibrary: .shared()) {
                    Label("Add Photos", systemImage: "photo.badge.plus")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(lilac.opacity(0.1))
                        .foregroundColor(lilac)
                        .cornerRadius(8)
                }
                .onChange(of: selectedItems) { items in
                    Task {
                        await processSelectedPhotos(items)
                        selectedItems = []
                    }
                }
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func processSelectedPhotos(_ items: [PhotosPickerItem]) async {
        for item in items {
            do {
                guard let data = try await item.loadTransferable(type: Data.self) else {
                    showError("Failed to load photo data")
                    continue
                }
                
                guard let uiImage = UIImage(data: data),
                      let processedData = JournalPhoto.processImage(uiImage) else {
                    showError("Failed to process photo")
                    continue
                }
                
                let photo = JournalPhoto()
                try photo.save(processedData)
                print("DEBUG: Saved photo to \(photo.filePath)")
                
                await MainActor.run {
                    photos.append(photo)
                }
            } catch {
                showError("Failed to save photo: \(error.localizedDescription)")
            }
        }
    }
    
    private func deletePhoto(_ photo: JournalPhoto) {
        photo.delete()
        photos.removeAll { $0.id == photo.id }
    }
    
    private func showError(_ message: String) {
        Task { @MainActor in
            errorMessage = message
            showingError = true
        }
    }
}

#Preview {
    @State var photos: [JournalPhoto] = []
    return PhotoPickerView(photos: $photos,
                         maxPhotos: 5,
                         lilac: Color(red: 0.784, green: 0.635, blue: 0.784))
}
