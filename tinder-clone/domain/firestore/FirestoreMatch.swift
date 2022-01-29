//
//  FirebaseMatch.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 23/1/22.
//

import Foundation

struct FirestoreMatch: Codable{
    let usersMatched: [String]
    let timestamp: Date
}
