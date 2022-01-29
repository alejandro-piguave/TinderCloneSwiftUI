//
//  DropOutsideDelegate.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 13/1/22.
//

import SwiftUI

struct DropOutsideDelegate: DropDelegate {
    @Binding var droppedOutside: Bool
        
    func performDrop(info: DropInfo) -> Bool {
        droppedOutside = true
        return true
    }
}
