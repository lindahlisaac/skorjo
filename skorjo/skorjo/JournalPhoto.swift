import Foundation
import SwiftUI
import PhotosUI
import SwiftData

@Model
class JournalPhoto: Identifiable {
    var id: UUID = UUID()
    var fileName: String = ""
    var caption: String?
    
    init(id: UUID = UUID(), caption: String? = nil) {
        self.id = id
        self.fileName = "\(id.uuidString).jpg"
        self.caption = caption
    }
    
    // File system paths
    var filePath: URL {
        // Get the documents directory
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory.appendingPathComponent("photos").appendingPathComponent(fileName)
    }
    
    // Save image data to file system
    func save(_ imageData: Data) throws {
        let photosDirectory = filePath.deletingLastPathComponent()
        
        // Create photos directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: photosDirectory.path) {
            try FileManager.default.createDirectory(at: photosDirectory, withIntermediateDirectories: true)
        }
        
        // Write image data to file
        try imageData.write(to: filePath)
    }
    
    // Load image data from file system
    func load() -> UIImage? {
        print("DEBUG: Trying to load photo from \(filePath)")
        guard let data = try? Data(contentsOf: filePath) else { 
            print("DEBUG: Failed to load data from \(filePath)")
            return nil 
        }
        let image = UIImage(data: data)
        print("DEBUG: Image loaded successfully: \(image != nil)")
        return image
    }
    
    // Delete photo file
    func delete() {
        try? FileManager.default.removeItem(at: filePath)
    }
    

}

// Helper for compressing and resizing images
extension JournalPhoto {
    static func processImage(_ image: UIImage, maxDimension: CGFloat = 2048) -> Data? {
        // Calculate new size maintaining aspect ratio
        let scale = min(maxDimension / image.size.width, maxDimension / image.size.height)
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        
        // Resize image
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Compress to JPEG
        return resizedImage?.jpegData(compressionQuality: 0.8)
    }
}
