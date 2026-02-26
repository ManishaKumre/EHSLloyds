//
//  Categories.swift
//  Lloyds
//
//  Created by Manisha on 03/01/26.
//

import SwiftUI

struct CategoryResponse: Decodable {
    let data: [CategoryItem]
}

struct CategoryItem: Codable, Identifiable {
    let id: Int
    let categories: String
    let subCategories: String
    let subSubCategories: String
}


