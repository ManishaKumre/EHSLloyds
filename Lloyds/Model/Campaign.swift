//
//  Campaign.swift
//  Lloyds
//
//  Created by Manisha on 30/12/25.
//

import SwiftUI
import Combine


// MARK: - API Root
//struct NewPermitResponse: Decodable {
//    let sections: [CampaignSection]
//}
//
//// MARK: - Section
//struct CampaignSection: Decodable, Identifiable {
//    let id = UUID()
//    let title: String
//    let fields: [CampaignField]
//    let expandable: Bool?
//    var expanded: Bool?
//
//    var isExpandable: Bool {
//        expandable ?? false
//    }
//
//    var isExpanded: Bool {
//        expanded ?? false
//    }
//}
//
//
//
//struct CampaignMock {
//    static let json = """
//    {
//        "sections": []
//    }
//    """
//}
//
//
//// MARK: - Field
////struct CampaignField: Decodable, Identifiable {
////    let id = UUID()
////    let name: String
////    let type: String
////    let optionsAvailable: [String]?
////    let required: Bool
////    var selectedValue: String?
////}
//
//
//
//struct CampaignField: Codable, Identifiable {
//    let id = UUID()
//
//    let name: String
//    let type: FieldType
//
//    let required: Bool?
//    let editable: Bool?
//    let readonly: Bool?
//
//    let description: String?
//
//    let optionsAvailable: [String]?
//
//    var selectedValue: String?
//    var selectedValues: [String]?
//
//    var textValue: String?
//    var timeValue: String?
//
//    // Button related
//    let activeButtonsText: [String]?
//    let activeButtonActions: [String]?
//
//    // Optional Textbox
//    let defaultValueCheckBox: Bool?
//}
//
//
//enum FieldType: String, Codable {
//    case DROPDOWN_SINGLE
//    case TEXTBOX
//    case OPTIONALTEXTBOX
//    case TIME
//    case BUTTON
//    case SECTION_HEADER
//}
//
//
