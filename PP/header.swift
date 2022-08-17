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

struct pixelRGB {
    var r: UInt8
    var g: UInt8
    var b: UInt8
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

func getPixel(id: CGDirectDisplayID, mouse: CGPoint) -> pixelRGB {
    let bounds = CGDisplayBounds(id)
    let relativePoint = CGPoint(x: mouse.x - bounds.origin.x, y: mouse.y - bounds.origin.y)
    // 1 pixel
    let size = CGSize(width: 1, height: 1)
    let rect = CGRect(origin: relativePoint, size: size)
    let imageRef = CGDisplayCreateImage(id, rect: rect)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    var rawData = [CUnsignedChar](repeating: 0, count: Int(size.height * size.width) * 4)
    let bytesPerPixel = 4
    let bytesPerRow = bytesPerPixel * Int(size.width)
    let bitsPerComponent = 8
    //let context = CGBitmapContextCreate()
    let context = CGContext(data: &rawData, width: Int(size.width), height: Int(size.height), bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue)
    context?.draw(imageRef!, in: CGRect(x:0, y:0, width:size.width, height: size.height))
    
    return pixelRGB(r: rawData[0], g: rawData[1], b: rawData[2])
}

func getHexString(pixel: pixelRGB) -> String {
    return String(format: "%X%X%X", pixel.r, pixel.g, pixel.b)
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

