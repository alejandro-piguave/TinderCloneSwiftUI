//
//  FirestoreUser.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 3/1/22.
//

import Foundation


public struct FirestoreUser: Codable {
    let name: String
    let birthDate: Date
    let bio: String
    let isMale: Bool
    let orientation: Orientation
    let liked: [String]
    let passed: [String]
    
    var age: Int{
        return Date().years(from: birthDate)
    }

    enum CodingKeys: String, CodingKey {
        case name
        case birthDate
        case bio
        case isMale = "male"
        case orientation
        case liked
        case passed
    }
}

public enum Orientation: String, Codable, CaseIterable{
    case men, women, both
}
