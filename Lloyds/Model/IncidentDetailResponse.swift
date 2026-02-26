//
//  IncidentDetailResponse.swift
//  Lloyds
//
//  Created by Manisha on 02/02/26.
//

//import SwiftUI
//import Combine
//
//struct IncidentDetailResponse: Decodable {
//    let data: IncidentData
//}

//struct IncidentData: Decodable {
//    let userLists: UserLists
//    let fieldValues: [String: AnyCodable]
//    let permitState: PermitState
//    let isolationDetails: [IsolationDetail]
//    let isolationPointIds: [Int]
//    let isIsolationRequired: Bool
//    let nextActionToBeTaken: String
//    let techniciansActionList: [String]?
//}
//
//
//struct UserLists: Decodable {
//    let executor: [String]
//    let observer: [String]
//    let areaOwner: [String]
//}
//
//struct PermitState: Decodable {
//    let userType: String
//    let permitStage: String
//    let buttonAction: String
//    let activeButtonsText: [String]
//    let activeButtonActions: [String]
//    let deactivateButtonText: String
//}
//
//
//
//struct AnyCodable: Codable {
//    let value: Any
//
//    init(_ value: Any) {
//        self.value = value
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//
//        if let int = try? container.decode(Int.self) {
//            value = int
//        } else if let double = try? container.decode(Double.self) {
//            value = double
//        } else if let bool = try? container.decode(Bool.self) {
//            value = bool
//        } else if let string = try? container.decode(String.self) {
//            value = string
//        } else if let array = try? container.decode([AnyCodable].self) {
//            value = array.map { $0.value }
//        } else if let dict = try? container.decode([String: AnyCodable].self) {
//            value = dict.mapValues { $0.value }
//        } else {
//            value = ""
//        }
//    }
//
//    func encode(to encoder: Encoder) throws {}
//}


import SwiftUI
import Combine

struct IncidentDetailResponse: Codable {
    let data: IncidentData
}

struct IncidentData: Codable {
    let fieldValues: IncidentFieldValues
    let permitState: PutPermitState
}

struct IncidentFieldValues: Codable {
    let uuid: String
    let remarks: String?
    let multiteam: Bool?
    let selectUnit: String?
    let selectLocation: String?
    let selectSubArea: String?
    let selectTypeOfPermit: String?
    let enterIncidentDescription: String?
    let selectIncidentDateTime: String?
    let enterNameOfWitness: String?
    let injuredPersonDetails: [InjuredPerson]?
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case remarks = "Remarks"
        case multiteam
        case selectUnit = "Select Unit"
        case selectLocation = "Select Location"
        case selectSubArea = "Select Sub Area"
        case selectTypeOfPermit = "Select Type of Permit"
        case enterIncidentDescription = "Enter_Incident_Description"
        case selectIncidentDateTime = "Select Incident Date & Time"
        case enterNameOfWitness = "Enter_Name_of_Witness"
        case injuredPersonDetails = "Injured Person Details"
    }
}

struct InjuredPerson: Codable {
    let gender: String?
    let enterEmployeeType: String?
    let selectEmployeeType: String?
    let immediateActionTaken: String?
    let selectTypeOfIncident: String?
    let enterNameOfPersonInjured: String?
    
    enum CodingKeys: String, CodingKey {
        case gender = "Gender"
        case enterEmployeeType = "Enter_Employee_Type"
        case selectEmployeeType = "Select_Employee_Type"
        case immediateActionTaken = "Immediate_action_taken"
        case selectTypeOfIncident = "Select_Type_of_Incident"
        case enterNameOfPersonInjured = "Enter_Name_of_Person_Injured"
    }
}
