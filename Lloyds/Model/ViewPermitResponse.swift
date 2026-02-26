//
//  ViewPermitResponse.swift
//  Lloyds
//
//  Created by Manisha on 24/12/25.
//


import Foundation
import SwiftUI

struct ViewPermitResponse: Codable {
    var data: PermitData?
}

struct PermitData: Codable {
    var sections: [ViewPermitSection]? = []
    var errorMessage: String? = nil
    var permitState: CampaignPermitState?
}

struct ViewPermitSection: Codable {
    var title: String?
    var permitStatus: String?
    var subtitle: String?
    var fields: [PermitField]?
    var grids: [Grid]?
    var sections: [ViewPermitSection]?
    var field: [Field]?
    var errorMessage: String?
    var twoColumnType: String?
    var expandable: Bool?
    var expanded: Bool?
}

struct Grid: Codable {
    var numberColumn: Int?
    var numberRow: Int?
    var title: String?
    var subtitle: String?
    var fields: [PermitField]?
}

struct PermitField: Codable {
    var name: String?
    var type: String?
    var tableName: String?
    var returnColumn: String?
    var condition: ConditionValue?
    var listOfElements: [String]?
    var radioButtonValue: String?
    var selectedValues: [String]?
    var required: Bool?
    var editable: Bool?
    var readonly: Bool?
    var description: String?
    var iconName: String?
    var textValue: String?
    var defaultValueRadioButton: Bool?  // ✅ ADDED THIS
    let optionsAvailable: [String]? 
    
    // Extra fields for BUTTON type
    var activeButtonsText: [String]?
    var activeButtonActions: [String]?
    var deactivateButtonText: String?
    var alertName: String?
    var action: String?
}

enum ConditionValue: Codable {
    case string(String)
    case array([String])
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let str = try? container.decode(String.self) {
            self = .string(str)
        } else if let arr = try? container.decode([String].self) {
            self = .array(arr)
        } else {
            self = .string("")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let str):
            try container.encode(str)
        case .array(let arr):
            try container.encode(arr)
        }
    }
    
    var asString: String {
        switch self {
        case .string(let str): return str
        case .array(let arr): return arr.joined(separator: ", ")
        }
    }
    
    var asArray: [String] {
        switch self {
        case .string(let str): return [str]
        case .array(let arr): return arr
        }
    }
}

struct Field: Codable, Identifiable {
    let id = UUID()
    let name: String
    let type: String?
    let description: String?
    let required: Bool?
    let defaultValueRadioButton: Bool?
    
    enum CodingKeys: String, CodingKey {
        case name, type, description, required, defaultValueRadioButton
    }
}

struct CampaignPermitState: Codable {

    let userType: String?
    let permitStage: String?
    let activeButtonsText: [String]?
    let activeButtonActions: [String]?
    let deactivateButtonText: String?

}


struct Observation: Codable, Identifiable {
    var id: String { uuid }
    var uuid: String
    var pendingAt: String?
    var selectRCA: String?
    var selectStatus: String?
    var selectPriority: String?
    var selectCategory: String?
    var finalActionTaken: String?
    var observationStatus: String?
    var uploadAfterImage: [String]?
    var selectSubCategory: String?
    
    
    var uploadBeforeImage: [String]?
    
    var isActionToBeTakenByE: Bool?
    var isActionToBeTakenByAO: Bool?
    var selectBusinessPartner: String?
    var enterBusinessPartnerName: String?
    var proposeSuggestActionPlan: String?
    var enterObservationDescription: String?
    var selectTypeOfObservation: String?
    
    
   
        let isActionToBeTakenByO: Bool?
    
    
    
    
//    
//    enum CodingKeys: String, CodingKey {
//        case uuid
//        case pendingAt = "Pending At"
//        case selectRCA = "Select_RCA"
//        case selectStatus = "Select_Status"
//        case selectPriority = "Select_Priority"
//        case selectCategory = "Select_Categories"
//        case finalActionTaken = "Final_Action_Taken"
//        case observationStatus = "Observation Status"
//        case uploadAfterImage = "Upload After Image"
//        case selectSubCategory = "Select_Sub_Category"
//        case uploadBeforeImage = "Upload Before Image"
//        case isActionToBeTakenByE
//        case isActionToBeTakenByAO
//        case selectBusinessPartner = "Select_Business_Partner"
//        case enterBusinessPartnerName = "Enter_Business_Partner_name"
//        case proposeSuggestActionPlan = "Propose_Suggest_Action_Plan"
//        case enterObservationDescription = "Enter_Observation_Description"
//        case selectTypeOfObservation = "Select_the_type_of_Observation"
//        case isActionToBeTakenByO
//        
//        
//        
//    }

    
    enum CodingKeys: String, CodingKey {

        case uuid

        case pendingAt = "Pending At"

        case selectRCA = "Select_RCA"

        case selectStatus = "Select_Status"   // 👈 FIX
        case selectPriority = "Select_Priority" // 👈 FIX
        case selectCategory = "Select_Categories" // 👈 FIX
        case finalActionTaken = "Final_Action_Taken" // 👈 FIX

        case observationStatus = "Observation Status"

        case uploadAfterImage = "Upload After Image"
        case uploadBeforeImage = "Upload Before Image"

        case selectSubCategory = "Select_Sub_Category" // 👈 FIX

        case selectBusinessPartner = "Select_Business_Partner" // 👈 FIX
        case enterBusinessPartnerName = "Enter_Business_Partner_name" // 👈 FIX
        case proposeSuggestActionPlan = "Propose_Suggest_Action_Plan" // 👈 FIX
        case enterObservationDescription = "Enter_Observation_Description" // 👈 FIX
        case selectTypeOfObservation = "Select_the_type_of_Observation" // 👈 FIX

        case isActionToBeTakenByE
        case isActionToBeTakenByAO
        case isActionToBeTakenByO
    }
    
    // --- Custom Decoding Logic ---
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Normal Fields
        uuid = try container.decode(String.self, forKey: .uuid)
        pendingAt = try container.decodeIfPresent(String.self, forKey: .pendingAt)
        selectRCA = try container.decodeIfPresent(String.self, forKey: .selectRCA)
        selectStatus = try container.decodeIfPresent(String.self, forKey: .selectStatus)
        selectPriority = try container.decodeIfPresent(String.self, forKey: .selectPriority)
        selectCategory = try container.decodeIfPresent(String.self, forKey: .selectCategory)
        finalActionTaken = try container.decodeIfPresent(String.self, forKey: .finalActionTaken)
        observationStatus = try container.decodeIfPresent(String.self, forKey: .observationStatus)
       // uploadAfterImage = try container.decodeIfPresent([String].self, forKey: .uploadAfterImage)
        selectSubCategory = try container.decodeIfPresent(String.self, forKey: .selectSubCategory)
        isActionToBeTakenByE = try container.decodeIfPresent(Bool.self, forKey: .isActionToBeTakenByE)
        isActionToBeTakenByAO = try container.decodeIfPresent(Bool.self, forKey: .isActionToBeTakenByAO)
        selectBusinessPartner = try container.decodeIfPresent(String.self, forKey: .selectBusinessPartner)
        enterBusinessPartnerName = try container.decodeIfPresent(String.self, forKey: .enterBusinessPartnerName)
        proposeSuggestActionPlan = try container.decodeIfPresent(String.self, forKey: .proposeSuggestActionPlan)
        enterObservationDescription = try container.decodeIfPresent(String.self, forKey: .enterObservationDescription)
        selectTypeOfObservation = try container.decodeIfPresent(String.self, forKey: .selectTypeOfObservation)
        isActionToBeTakenByO = try container.decodeIfPresent(Bool.self, forKey: .isActionToBeTakenByO)
        // Special Handling for uploadBeforeImage (Array OR String)
        if let array = try? container.decode([String].self, forKey: .uploadBeforeImage) {
            uploadBeforeImage = array
        } else if let string = try? container.decode(String.self, forKey: .uploadBeforeImage) {
            uploadBeforeImage = string.isEmpty ? [] : [string]
        } else {
            uploadBeforeImage = []
        }
        
        
        if let array = try? container.decode([String].self, forKey: .uploadAfterImage) {
            uploadAfterImage = array
        } else if let string = try? container.decode(String.self, forKey: .uploadAfterImage) {
            uploadAfterImage = string.isEmpty ? [] : [string]
        } else {
            uploadAfterImage = []
        }
    }
}

extension Observation {

    var dynamicFields: [(key: String, value: String)] {

        var fields: [(String, String)] = []

        // ✅ Existing (same as your code)
        fields.append((
            "Upload Before Image",
            (uploadBeforeImage ?? []).joined(separator: ", ")
        ))

        fields.append((
            "Upload After Image",
            (uploadAfterImage ?? []).joined(separator: ", ")
        ))

        fields.append(("UUID", uuid))
        fields.append(("Pending At", pendingAt ?? ""))
        fields.append(("Status", selectStatus ?? ""))
        fields.append(("Priority", selectPriority ?? ""))
        fields.append(("Description", enterObservationDescription ?? ""))

        // 🔥 NEW FIELDS ADD (without touching old ones)

        fields.append(("RCA", selectRCA ?? ""))
        fields.append(("Category", selectCategory ?? ""))
        fields.append(("Final Action Taken", finalActionTaken ?? ""))
        fields.append(("Observation Status", observationStatus ?? ""))
        fields.append(("Sub Category", selectSubCategory ?? ""))
        fields.append(("Business Partner", selectBusinessPartner ?? ""))
        fields.append(("Business Partner Name", enterBusinessPartnerName ?? ""))
        fields.append(("Action Plan", proposeSuggestActionPlan ?? ""))
        fields.append(("Type Of Observation", selectTypeOfObservation ?? ""))

        // ✅ Boolean fields (convert to readable text)
        if let isE = isActionToBeTakenByE {
            fields.append(("Action By Executor", isE ? "Yes" : "No"))
        }

        if let isAO = isActionToBeTakenByAO {
            fields.append(("Action By Area Owner", isAO ? "Yes" : "No"))
        }

        if let isO = isActionToBeTakenByO {
            fields.append(("Action By Observer", isO ? "Yes" : "No"))
        }

        return fields
    }
}
