//
//  FirebaseMatch.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 23/1/22.
//

import Foundation
import FirebaseFirestoreSwift

struct FirestoreMatch: Codable{
    @DocumentID var id: String?
    let usersMatched: [String]
    let timestamp: Date
}
