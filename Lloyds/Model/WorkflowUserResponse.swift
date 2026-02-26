//
//  WorkflowUserResponse.swift
//  Lloyds
//
//  Created by Manisha on 28/01/26.
//

import SwiftUI

struct WorkflowUserResponse: Codable {
    let data: [WorkflowUser]
}



struct WorkflowUser: Codable {
    let id: Int
    let firstname: String?
    let lastname: String?
    let customRoles: [String]?

    var displayName: String {
        [firstname, lastname]
            .compactMap { $0 }
            .joined(separator: " ")
    }
}

