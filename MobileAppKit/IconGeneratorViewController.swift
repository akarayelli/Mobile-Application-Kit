//
//  IconGeneratorViewController.swift
//  AppIconResizer
//
//  Created by Aykut Ersahin on 21.12.2017.
//  Copyright © 2017 msn. All rights reserved.
//

import Cocoa

class IconGeneratorViewController: NSViewController {
    
    
    @IBOutlet weak var checkBox20x20: NSButton!
    @IBOutlet weak var checkBox29x29: NSButton!
    @IBOutlet weak var checkBox40x40: NSButton!
    @IBOutlet weak var checkBox58x58: NSButton!
    @IBOutlet weak var checkBox60x60: NSButton!
    @IBOutlet weak var checkBox76x76: NSButton!
    @IBOutlet weak var checkBox80x80: NSButton!
    @IBOutlet weak var checkBox87x87: NSButton!
    @IBOutlet weak var checkBox120x120: NSButton!
    @IBOutlet weak var checkBox152x152: NSButton!
    @IBOutlet weak var checkBox167x167: NSButton!
    @IBOutlet weak var checkBox180x180: NSButton!
    
    @IBOutlet weak var checkBox48x48: NSButton!
    @IBOutlet weak var checkBox72x72: NSButton!
    @IBOutlet weak var checkBox96x96: NSButton!
    @IBOutlet weak var checkBox144x144: NSButton!
    @IBOutlet weak var checkBox192x192: NSButton!
    
    @IBOutlet weak var checkBoxOther: NSButton!
    @IBOutlet weak var textfieldOther: NSTextField!
    
    
    
    
    @IBOutlet weak var textFieldImageURL: NSTextField!
    @IBOutlet weak var textFieldExportDirectoryURL: NSTextField!
    
    var checkBoxes: [NSButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkBoxes.append(checkBox20x20)
        checkBoxes.append(checkBox29x29)
        checkBoxes.append(checkBox40x40)
        checkBoxes.append(checkBox58x58)
        checkBoxes.append(checkBox60x60)
        checkBoxes.append(checkBox76x76)
        checkBoxes.append(checkBox80x80)
        checkBoxes.append(checkBox87x87)
        checkBoxes.append(checkBox120x120)
        checkBoxes.append(checkBox152x152)
        checkBoxes.append(checkBox167x167)
        checkBoxes.append(checkBox180x180)
        checkBoxes.append(checkBox48x48)
        checkBoxes.append(checkBox72x72)
        checkBoxes.append(checkBox96x96)
        checkBoxes.append(checkBox144x144)
        checkBoxes.append(checkBox192x192)
        checkBoxes.append(checkBoxOther)
        
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
    @IBAction func browseImage(_ sender: Any) {
        
        let dialog = NSOpenPanel();
        dialog.title                   = "Choose a .png file"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseFiles          = true
        dialog.canChooseDirectories    = false
        dialog.canCreateDirectories    = false
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes        = ["png"]
        
        if (dialog.runModal() == .OK) {
            if let result = dialog.url {
                
                if let mainImage = NSImage.init(contentsOf: result) {
                    
                    if mainImage.size.width == mainImage.size.height {
                        textFieldImageURL.stringValue = result.path
                    }
                    else {
                        textFieldImageURL.stringValue = ""
                        showAlert(message: "Image width and height is not equal")
                    }
                    return
                }
            }
        } else {
            return
        }
    }
    
    @IBAction func browseExportDirectory(_ sender: Any) {
        
        let dialog = NSOpenPanel();
        dialog.title                   = "Choose directory to export images";
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseFiles          = false
        dialog.canChooseDirectories    = true
        dialog.canCreateDirectories    = true
        dialog.allowsMultipleSelection = false
        
        if (dialog.runModal() == .OK) {
            if let result = dialog.url {
                
                if (result.isFileURL) {
                    if FileManager.default.fileExists(atPath: result.path) {
                        textFieldExportDirectoryURL.stringValue = result.path
                    }
                }
            }
        }
        else {
            return
        }
    }
    
    @IBAction func generateIcons(_ sender: Any) {
        if textFieldImageURL.stringValue.count > 0, textFieldExportDirectoryURL.stringValue.count > 0 {
            runSizing()
        }
        else {
            showAlert(message: "Please select image and export directory")
        }
    }
    
    func runSizing() {
        
        if let mainImage = NSImage.init(contentsOf: URL.init(string: "file://" + textFieldImageURL.stringValue)!) {
            
            var urlString = "file://" + textFieldExportDirectoryURL.stringValue + "/"
            let folderUrl = "appicons/"
            
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: urlString + folderUrl, isDirectory:nil) {
                do {
                    try fileManager.createDirectory(at: URL.init(string: urlString + folderUrl)!, withIntermediateDirectories: true, attributes: nil)
                    urlString += folderUrl
                } catch {
                    
                }
            }
            
            
            for checkBox in checkBoxes {
                
                if checkBox.state == .on {
                    
                    if checkBox == checkBoxOther {
                        if let size = Int(textfieldOther.stringValue) {
                            let newImage = resizeImage(image: mainImage, w: size, h: size)
                            newImage.saveAsPNG(url: URL.init(string: urlString.appending("\(size)x\(size).png"))!)
                        }
                    }
                    else {
                        let tempArray = checkBox.title.split(separator: "x")
                        if let size = Int(tempArray[0]) {
                            let newImage = resizeImage(image: mainImage, w: size, h: size)
                            newImage.saveAsPNG(url: URL.init(string: urlString.appending("\(size)x\(size).png"))!)
                        }
                    }
                }
            }
            
            showAlert(message: "Icons generated successfully")
            
        }
    }
    
    
    
    
    func resizeImage(image: NSImage, w: Int, h: Int) -> NSImage {
        let destSize = NSMakeSize(CGFloat(w), CGFloat(h))
        let newImage = NSImage(size: destSize)
        newImage.lockFocus()
        image.draw(in: NSMakeRect(0, 0, destSize.width, destSize.height), from: NSMakeRect(0, 0, image.size.width, image.size.height), operation: .sourceOver, fraction: CGFloat(1))
        newImage.unlockFocus()
        newImage.size = destSize
        return NSImage(data: newImage.tiffRepresentation!)!
    }
    
    func showAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = "App Icon Generator"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
}

