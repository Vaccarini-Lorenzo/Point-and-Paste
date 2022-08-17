//
//  header.swift
//  PP
//
//  Created by Lorenzo Vaccarini on 17/08/22.
//

import Foundation
import CoreGraphics
import ApplicationServices

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

func getIdFromMouseCoordinates(){
    
    let point = getMouseCoordinates()
    
    var numScreen: CGDisplayCount = 0
    CGGetOnlineDisplayList(UInt32.max, nil, &numScreen)

    var screenList = [CGDirectDisplayID](repeating: 0, count: Int(numScreen))
    CGGetOnlineDisplayList(UInt32.max, &screenList, &numScreen);

    for display in screenList {
        let bounds = CGDisplayBounds(display)
        let origin = bounds.origin
        let size = bounds.size
        let xRange = origin.x...origin.x + size.width
        let yRange = origin.y...origin.y + size.height
        
        if yRange.contains(point.y) && xRange.contains(point.x) {
            print(display)
        }
    }
}

func getContextualFromPersistent(persistent: String) -> CGDirectDisplayID {
    let uuidString = CFStringCreateWithCString(kCFAllocatorDefault, persistent, kCFStringEncodingASCII)
    let uuid = CFUUIDCreateFromString(kCFAllocatorDefault, uuidString)
    return CGDisplayGetDisplayIDFromUUID(uuid)
}

