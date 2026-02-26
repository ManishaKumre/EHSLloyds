import Foundation
import SwiftUI

struct IncidentField: Codable, Identifiable {
    let id = UUID()

    let name: String
    let type: String
    let tableName: String?
    let returnColumn: String?
    let condition: String?
    let listOfElements: String?
    let radioButtonValue: String?
    let selectedValues: [String]?
    let required: Bool?
    let editable: Bool?
    let readonly: Bool?
    let description: String?
    var  optionsAvailable: [String]?
    let activeButtonsText: [String]?
    let activeButtonActions: [String]?
    let deactivateButtonText: String?
    let alertName: String?
    let action: String?

    var textValue: String? = nil
    var selectedValue: String? = nil
    var timeValue: String? = nil
    var dateValue: Date? = nil

    var image: UIImage?
    
    enum CodingKeys: String, CodingKey {
        case name, type, tableName, returnColumn, condition
        case listOfElements, radioButtonValue, selectedValues
        case required, editable, readonly, description
        case optionsAvailable, activeButtonsText, activeButtonActions
        case deactivateButtonText, alertName, action
        case textValue, selectedValue, timeValue
       
    }
}


//enum FieldType: String, Codable {
//    case DROPDOWN_SINGLE
//    case TEXTBOX
//    case OPTIONALTEXTBOX
//    case TIME
//    case BUTTON
//    case SECTION_HEADER
//}
//
//  Untitled.swift
//  Lloyds
//
//  Created by Manisha on 30/01/26.
//

