//
//  User.swift
//  Lloyds
//
//  Created by Manisha on 16/03/26.
//

import SwiftUI

struct PlantUser: Codable, Identifiable {

    let id: Int
    let firstname: String
    let lastname: String

    var fullName: String {
        "\(firstname) \(lastname)"
    }
}
