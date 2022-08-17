//
//  header.swift
//  PP
//
//  Created by Lorenzo Vaccarini on 17/08/22.
//

import Foundation
import CoreGraphics
import ApplicationServices
import AppKit

struct pxl: Hashable{
    let hex: String
    let r: UInt8
    let g: UInt8
    let b: UInt8
}

func CGInit(){
    CGMainDisplayID();
}

func requestAccess() {
    CGPreflightScreenCaptureAccess();
    CGRequestScreenCaptureAccess();
}

func getMouseCoordinates() -> CGPoint {
    let event = CGEvent(source: nil)
    let point = event!.location
    
    return point
}

func getIdFromMouseCoordinates(_ mouse: CGPoint) -> CGDirectDisplayID{
    
    var numScreen: CGDisplayCount = 0
    CGGetOnlineDisplayList(UInt32.max, nil, &numScreen)

    var screenList = [CGDirectDisplayID](repeating: 0, count: Int(numScreen))
    CGGetOnlineDisplayList(UInt32.max, &screenList, &numScreen);
    
    var curDisplay: UInt32 = 0

    for display in screenList {
        let bounds = CGDisplayBounds(display)
        let origin = bounds.origin
        let size = bounds.size
        let xRange = origin.x...origin.x + size.width
        let yRange = origin.y...origin.y + size.height
        
        if yRange.contains(mouse.y) && xRange.contains(mouse.x) {
            curDisplay = display
        }
    }
    
    return curDisplay
}


func getHexString(r: UInt8, g: UInt8, b:UInt8) -> String {
    let r_hex = r < 16 ? String(format: "0%X", r) : String(format: "%X", r)
    let g_hex = r < 16 ? String(format: "0%X", g) : String(format: "%X", g)
    let b_hex = r < 16 ? String(format: "0%X", b) : String(format: "%X", b)

    return r_hex + g_hex + b_hex
}

func getImage(id: CGDirectDisplayID, size: Int, mouse: CGPoint) -> CGImage {
    let bounds = CGDisplayBounds(id)
    let relativePoint = CGPoint(x: mouse.x - bounds.origin.x, y: mouse.y - bounds.origin.y)
    // 10 pixel
    let size = CGSize(width: size, height: size)
    
    //Centering the rect
    let originPoint = CGPoint(x: relativePoint.x - size.width/2, y: relativePoint.y - size.height/2)
    
    let rect = CGRect(origin: originPoint, size: size)
    return CGDisplayCreateImage(id, rect: rect)!
}

func getRelatedPixel(p: pxl, dict: [pxl: Int]) -> (pxl, Int)?{
    for item in dict {
        
        let rDelta = (item.key.r < 245 && item.key.r > 9) ? 10 : min(255 - item.key.r, item.key.r)
        
        let gDelta = (item.key.g < 245 && item.key.g > 9) ? 10 : min(255 - item.key.g, item.key.g)
        
        let bDelta = (item.key.b < 245 && item.key.b > 9) ? 10 : min(255 - item.key.b, item.key.b)
        
        let rRange = item.key.r - rDelta ... item.key.r + rDelta
        let gRange = item.key.g - gDelta ... item.key.g + gDelta
        let bRange = item.key.b - bDelta ... item.key.b + bDelta
        if rRange.contains(p.r) && gRange.contains(p.g) && bRange.contains(p.b) {
            return item
        }
    }
    return nil;
}

func votePixel(rawData: [CUnsignedChar], size: Int) -> String {
    var pixelDict: [pxl : Int] = [:]
    // RGBA
    let shift = 4
    let bytesPerPixel = 4
    let bytesPerRow = bytesPerPixel * Int(size)
    let bitsPerComponent = 8
    
    for w in 0..<size {
        for h in 0..<size {
            var base = h * bytesPerRow + w * shift
            let r = rawData[base]
            let g = rawData[base + 1]
            let b = rawData[base + 2]
            
            print(r, g, b)
            
            let hex = getHexString(r: r, g: g, b: b)
            let p = pxl(hex: hex, r: r, g: g, b: b)
            let relatedPixel = getRelatedPixel(p: p, dict: pixelDict)
            
            if pixelDict.isEmpty || relatedPixel == nil {
                pixelDict[p] = 1
            } else {
                pixelDict[relatedPixel!.0] = relatedPixel!.1 + 1
            }
        }
    }
    //print(pixelDict)
    let maxPixel = pixelDict.max { a, b in
        a.value < b.value
    }
    if maxPixel != nil {
        return maxPixel!.key.hex
    }
    //print(pixelDict)
    return "ERROR"

}

func getPixel(id: CGDirectDisplayID, mouse: CGPoint) -> String {
    
    // 10px x 10px
    var size = 5
    
    if CommandLine.arguments.count > 1 {
        size = Int(CommandLine.arguments[1])!
    }
    
    let imageRef = getImage(id: id, size: size, mouse: mouse)

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    var rawData = [CUnsignedChar](repeating: 0, count: Int(size * size) * 4)
    let bytesPerPixel = 4
    let bytesPerRow = bytesPerPixel * Int(size)
    let bitsPerComponent = 8
    //let context = CGBitmapContextCreate()
    let context = CGContext(data: &rawData, width: size, height: size, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue)
    context?.draw(imageRef, in: CGRect(x:0, y:0, width:size, height: size))
    
    // Get the pixel with most occurences
    let votedPixel = votePixel(rawData: rawData, size: size)

    return votedPixel
}


func copyToClipboard(string: String) {
    let pasteboard = NSPasteboard.general
    pasteboard.declareTypes([.string], owner: nil)
    pasteboard.setString(string, forType: .string)
}

func getContextualFromPersistent(persistent: String) -> CGDirectDisplayID {
    let uuidString = CFStringCreateWithCString(kCFAllocatorDefault, persistent, kCFStringEncodingASCII)
    let uuid = CFUUIDCreateFromString(kCFAllocatorDefault, uuidString)
    return CGDisplayGetDisplayIDFromUUID(uuid)
}

