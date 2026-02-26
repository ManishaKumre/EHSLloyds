//
//  ActionField.swift
//  Lloyds
//
//  Created by Manisha on 24/12/25.
//



import Foundation

struct ActionField: Identifiable, Codable {
    let id = UUID()
    let name: String
    let type: String
    let description: String?
    let condition: [String]?
    var textValue: String? // Toggle state: "true" ya "false"
    var reasonText: String?
    var listOfElements: [String]?    // dropdown options
    var selectedValues: [String]?    // multi selected values
    var defaultValueRadioButton: Bool?
    let optionsAvailable: [String]?
}

struct ActionSection: Codable {
    let title: String
    var fields: [ActionField]
}
