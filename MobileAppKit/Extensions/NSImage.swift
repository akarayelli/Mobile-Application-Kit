//
//  NSImage.swift
//  MobileAppKit
//
//  Created by Aykut Ersahin on 22.12.2017.
//  Copyright © 2017 MSN. All rights reserved.
//

import AppKit

extension NSImage {
    @discardableResult
    func saveAsPNG(url: URL) -> Bool {
        guard let tiffData = self.tiffRepresentation else {
            print("failed to get tiffRepresentation. url: \(url)")
            return false
        }
        let imageRep = NSBitmapImageRep(data: tiffData)
        guard let imageData = imageRep?.representation(using: .png, properties: [:]) else {
            print("failed to get PNG representation. url: \(url)")
            return false
        }
        do {
            try imageData.write(to: url)
            return true
        } catch {
            print("failed to write to disk. url: \(url)")
            return false
        }
    }
}
