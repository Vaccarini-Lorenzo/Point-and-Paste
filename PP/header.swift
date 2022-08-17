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

    return String(format: "%X%X%X", r, g, b)
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

func votePixel(rawData: [CUnsignedChar], size: Int) -> String {
    var pixelDict: [String : Int] = [:]
    // RGBA
    let shift = 4
    for index in 0..<size*size {
        let r = rawData[index * shift]
        let g = rawData[index * shift + 1]
        let b = rawData[index * shift + 2]
        
        let hex = getHexString(r: r, g: g, b: b)
        if pixelDict[hex] == nil {
            pixelDict[hex] = 1
        } else {
            let value = pixelDict[hex]!
            pixelDict[hex] = value + 1
        }
    }
    //print(pixelDict)
    let maxPixel = pixelDict.max { a, b in
        a.value < b.value
    }
    if maxPixel != nil {
        return maxPixel!.key
    }
    return "ERROR"

}

func getPixel(id: CGDirectDisplayID, mouse: CGPoint) -> String {
    // 10px x 10px
    let size = 5
    
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

