//
//  CreateProfileModel.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 8/6/23.
//

import Foundation
import UIKit


struct CreateProfileModel{
    let name: String
    let birthDate: Date
    let bio: String
    let isMale: Bool
    let orientation: Orientation
    let pictures: [UIImage]
}
