//
//  main.swift
//  PP
//
//  Created by Lorenzo Vaccarini on 17/08/22.
//

import Foundation

CGInit()
let mouseCoordinates = getMouseCoordinates()
let displayID = getIdFromMouseCoordinates(mouseCoordinates)
let pixel = getPixel(id: displayID, mouse: mouseCoordinates)
let hexString = getHexString(pixel: pixel)
copyToClipboard(string: hexString)
