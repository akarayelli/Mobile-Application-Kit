//
//  IconGeneratorViewController.swift
//  AppIconResizer
//
//  Created by Aykut Ersahin on 21.12.2017.
//  Copyright © 2017 msn. All rights reserved.
//

import Cocoa

class IconGeneratorViewController: NSViewController {
    
    
    
    @IBOutlet weak var textFieldImageURL: NSTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
    @IBAction func browseImage(_ sender: Any) {
        
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose a .png file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["png"];
        
        if (dialog.runModal() == .OK) {
            
            if let result = dialog.url {
                textFieldImageURL.stringValue = result.path
                //runSizing(fileURL: result!)
            }
        } else {
            return
        }
    }
    
    func runSizing(fileURL: URL){
        if let mainImage = NSImage.init(contentsOf: fileURL) {
           
            if mainImage.size.width != mainImage.size.height {
                let alert = NSAlert()
                alert.messageText = "Warning"
                alert.informativeText = "Image width and height is not equal"
                alert.alertStyle = .warning
                alert.addButton(withTitle: "OK")
                alert.runModal()
                return
            }
            
            
            let newImage = resizeImage(image: mainImage, maxSize: NSSize(width: 100, height: 100))
            print(newImage.size)
            print(newImage.size)
            
        }
    }
    
    
    func resizeImage(image:NSImage, maxSize:NSSize) -> NSImage {
        
        var ratio:Float = 0.0
        let imageWidth = Float(image.size.width)
        let imageHeight = Float(image.size.height)
        let maxWidth = Float(maxSize.width)

        ratio = maxWidth / imageWidth;

        // Calculate new size based on the ratio
        let newWidth = imageWidth * ratio
        let newHeight = imageHeight * ratio
        
        // Create a new NSSize object with the newly calculated size
        let newSize:NSSize = NSSize(width: Int(newWidth), height: Int(newHeight))
        
        // Cast the NSImage to a CGImage
        var imageRect:CGRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        let imageRef = image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
        
        // Create NSImage from the CGImage using the new size
        let imageWithNewSize = NSImage(cgImage: imageRef!, size: newSize)
        
        // Return the new image
        return imageWithNewSize
    }

}

