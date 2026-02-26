//
//  FunctionalLocation.swift
//  Lloyds
//
//  Created by Manisha on 03/01/26.
//

import SwiftUI

struct FunctionalLocationResponse: Decodable {
    let data: [FunctionalLocation]
}

struct FunctionalLocation: Decodable, Identifiable {
    let id: Int
    let location: String
    let mainArea: String
    let subArea: String
}

