/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A generic NSCollectionViewItem that has an NSTextField and an enclosing NSBox
*/

import Cocoa

let shouldCheckIfImageIsNilBeforeSetting = true

class ImageItem: NSCollectionViewItem {

    static let reuseIdentifier = NSUserInterfaceItemIdentifier("image-item-reuse-identifier")

    private var icon: NSImage!
    
    @objc dynamic var shouldProgressAnimate: Bool = true
    
    override func prepareForReuse() {
        super.prepareForReuse()
        print("Eccoci")
        self.imageView?.image = nil
        self.shouldProgressAnimate = true
    }
    
    var iconURL: URL! {
        didSet {
            self.downloadImage(at: self.iconURL) { [weak self](success: Bool, data: Data?, image: NSImage?) in
                DispatchQueue.main.async {
                    self?.shouldProgressAnimate = false
                    if self?.imageView?.image == nil || !shouldCheckIfImageIsNilBeforeSetting {
                        self?.imageView?.image = image
                        self?.imageView?.animator().isHidden = false
                    } else {
                        self?.imageView?.isHidden = false
                    }
                }
            }
        }
    }

    override var highlightState: NSCollectionViewItem.HighlightState {
        didSet {
            updateSelectionHighlighting()
        }
    }

    override var isSelected: Bool {
        didSet {
            updateSelectionHighlighting()
        }
    }

    private func updateSelectionHighlighting() {
        
        if !isViewLoaded {
            return
        }

        let showAsHighlighted = (highlightState == .forSelection) ||
            (isSelected && highlightState != .forDeselection) ||
            (highlightState == .asDropTarget)
        
        if let box = view as? NSBox {
            box.fillColor = showAsHighlighted ? .selectedControlColor : .cornflowerBlue
        }
    }
    
    func downloadImage(at url: URL?, completionHandler: @escaping (_ success: Bool, _ outputData: Data?, _ outputImage: NSImage?) -> Void) {
    
        let session = URLSession.shared
    
        var request: URLRequest? = nil
        if let url = url {
            request = URLRequest(url: url)
        }
    
        var dataTask: URLSessionDataTask? = nil
        if let request = request {
            dataTask = session.dataTask(with: request, completionHandler: { data, response, error in
    
                if error != nil {
                    completionHandler(false, nil, nil)
                    return
                }
    
                var outputImage: NSImage? = nil
                if let data = data {
                    outputImage = NSImage(data: data)
                    
                    if let image = outputImage {
                        completionHandler(true, data, image)
                        return
                    }
                
                }
    
                completionHandler(false, nil, nil)
                return
    
            })
        }
    
        dataTask?.resume()
    
    }
}

fileprivate extension NSColor {
    static var cornflowerBlue: NSColor {
        return NSColor(displayP3Red: 85.0 / 255.0, green: 151.0 / 255.0, blue: 244.0 / 255.0, alpha: 1.0)
    }
}
