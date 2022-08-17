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
let hexString = getPixel(id: displayID, mouse: mouseCoordinates)
copyToClipboard(string: hexString)
