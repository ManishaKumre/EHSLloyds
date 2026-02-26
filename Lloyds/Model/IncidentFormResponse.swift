//
//  IncidentFormResponse.swift
//  Lloyds
//
//  Created by Manisha on 30/01/26.
//

import SwiftUI

import Foundation

struct IncidentFormResponse: Decodable {
    let sections: [FormSection]
   
}




struct FormSection: Identifiable, Decodable {
    var id = UUID()

    let title: String
    var subtitle: String?
    var fields: [IncidentFormField]

    var expanded: Bool = true

    enum CodingKeys: String, CodingKey {
        case title, subtitle, fields
    }
}






struct IncidentFormField: Identifiable, Decodable {
    let id = UUID()

    let name: String
    let type: FieldType

    let required: Bool
    let editable: Bool
    let readonly: Bool

    let description: String?

    var optionsAvailable: [String]?

    var textValue: String?
    var selectedValue: String?
    var dateValue: Date?
    var timeValue: String?

    enum CodingKeys: String, CodingKey {
        case name, type, required, editable, readonly
        case description
        case optionsAvailable
        case textValue
        case selectedValue
        case timeValue
       
    }
}



enum FieldType: Decodable {
    case TEXTBOX
    case DROPDOWN_SINGLE
    case TIME
    case OPTIONALTEXTBOX
    case BUTTON
    case SECTION_HEADER
    case unknown(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)

        switch value {
        case "TEXTBOX": self = .TEXTBOX
        case "DROPDOWN_SINGLE": self = .DROPDOWN_SINGLE
        case "TIME": self = .TIME
        case "OPTIONALTEXTBOX": self = .OPTIONALTEXTBOX
        case "BUTTON": self = .BUTTON
        case "SECTION_HEADER": self = .SECTION_HEADER
        default:
            self = .unknown(value)
        }
    }
}

