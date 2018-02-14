//
//  ImageDownloader.swift
//  Pods-Stanwood_Dialog_iOS_Example
//
//  Created by Eugène Peschard on 13/02/2018.
//

class ImageDownloader: Operation {
    let photoRecord: PhotoRecord
    
    init(photoRecord: PhotoRecord) {
        self.photoRecord = photoRecord
    }
    
    override func main() {
        if self.isCancelled {
            return
        }
        do {
            let imageData = try Data(contentsOf: self.photoRecord.url)
            
            if self.isCancelled {
                return
            }
            
            if imageData.count > 0 {
                self.photoRecord.image = UIImage(data: imageData)
                self.photoRecord.state = .downloaded
            } else {
                self.photoRecord.state = .failed
                self.photoRecord.image = UIImage(named: "Failed")
            }
        } catch {
            return
        }
    }
}
