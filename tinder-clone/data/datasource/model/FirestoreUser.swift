//
//  FirestoreUser.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 3/1/22.
//

import Foundation
import FirebaseFirestoreSwift

public struct FirestoreUser: Codable, Equatable {
    @DocumentID var id: String?
    let name: String
    let birthDate: Date
    let bio: String
    let isMale: Bool
    let orientation: Orientation
    let pictures: [String]
    let liked: [String]
    let passed: [String]
    
    var age: Int{
        Date().years(from: birthDate)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case birthDate
        case bio
        case isMale = "male"
        case orientation
        case pictures
        case liked
        case passed
    }
}

public enum Orientation: String, Codable, CaseIterable{
    case men, women, both
}
