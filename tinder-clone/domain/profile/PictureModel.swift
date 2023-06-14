//
//  ProfilePictureModel.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 8/6/23.
//

import Foundation
import UIKit

enum PictureModel: Hashable{
    case newPicture(UIImage)
    case storedPicture(String, UIImage)
    
    var picture: UIImage {
        switch self{
        case .newPicture(let image):
            return image
        case .storedPicture(_, let image):
            return image
        }
    }
}
