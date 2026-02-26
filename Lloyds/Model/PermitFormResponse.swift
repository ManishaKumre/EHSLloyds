//
//  PermitFormResponse.swift
//  Lloyds
//
//  Created by Manisha on 24/12/25.
//


import SwiftUI
import Foundation

// API response model
struct PermitFormResponse: Codable {
    let sections: [PermitSection]
}

// Form section model
struct PermitSection: Codable, Identifiable {
    var id: String { title }
    let title: String
    let fields: [FormField]
}

// Form field model
struct FormField: Codable, Identifiable {
    var id: String { name }
    
    let name: String
    let type: String
    let description: String
    let required: Bool
    let editable: Bool
    let readonly: Bool
    let optionsAvailable: [String]?
    let textValue: String?
    let timeValue: String?
}
