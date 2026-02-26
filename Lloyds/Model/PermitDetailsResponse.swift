//
//  PermitDetailsResponse.swift
//  Lloyds
//
//  Created by Manisha on 24/12/25.
//


import SwiftUI
import Foundation





//Universal Safe Decoding Property Wrapper
@propertyWrapper
struct SafeDecode<T: Decodable>: Decodable {
    var wrappedValue: T?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        // Try normal decode
        if let value = try? container.decode(T.self) {
            wrappedValue = value
        }
        // Try stringified JSON decode
        else if let string = try? container.decode(String.self),
                let data = string.data(using: .utf8),
                let decoded = try? JSONDecoder().decode(T.self, from: data) {
            wrappedValue = decoded
        } else {
            wrappedValue = nil
        }
    }
}

//Universal String-or-Array type
enum StringOrArray: Codable {
    case string(String)
    case array([String])
    
    var strings: [String] {
        switch self {
        case .string(let s): return [s]
        case .array(let arr): return arr
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let arr = try? container.decode([String].self) {
            self = .array(arr)
        } else if let str = try? container.decode(String.self) {
            self = .string(str)
        } else {
            self = .array([])
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let s): try container.encode(s)
        case .array(let arr): try container.encode(arr)
        }
    }
}





// Root response wrapper
struct PermitDetailsAPIResponse: Codable {
    let data: String?   // <- stringified JSON from API
}

// Inner JSON
struct PermitDetailsResponse: Codable {
    let isolationDetails: [PermitIsolationPoint]?
}

// Isolation Point
struct PermitIsolationPoint: Codable, Identifiable, Hashable {
    var id: String { isolationPointId }
       
       let isolationPointId: String
       let isolationPointName: String
       let isIsolated: Bool?
    let isDeIsolated:Bool?
       let equipments: [String]?
       let padlockName: String?
       let uuid: String?
       
       // NEW FIELDS
       let deIsolationIssuer: String?
       let imageUrl: String?
       let isolationIssuer: String?
       let isolationType: String?  // optional, default Electrical
   }

enum CodingKeys: String, CodingKey {
    case isolationPointId
    case isolationPointName
    case isIsolated
    case isDeIsolated
    
    case equipments = "Equipments"
    case padlockName
    case uuid
    case deIsolationIssuer
    case imageUrl
    case isolationIssuer
    case isolationType
}








struct RootModel<T: Decodable>: Decodable {
    let data: T
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try normal object
        if let obj = try? container.decode(T.self, forKey: .data) {
            data = obj
        }
        // Try stringified JSON
        else if let jsonString = try? container.decode(String.self, forKey: .data),
                let jsonData = jsonString.data(using: .utf8) {
            let decoded = try JSONDecoder().decode(T.self, from: jsonData)
            data = decoded
        } else {
            throw DecodingError.typeMismatch(
                T.self,
                .init(codingPath: [CodingKeys.data],
                      debugDescription: "Expected object or stringified JSON")
            )
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case data
    }
}


// MARK: - Decoded Data Model
struct RootData: Decodable {
    let userLists: UserLists
    let fieldValues: PFieldValues
    let permitState: PPermitState
    let isolationDetails: [PermitIsolationPoint]
    let isolationPointIds: [String]
    let isIsolationRequired: Bool
    let nextActionToBeTaken: StringOrArray
    let techniciansActionList: String?
    let equipments: [String]?
    
    enum CodingKeys: String, CodingKey {
        case userLists
        case fieldValues
        case permitState
        case isolationDetails
        case isolationPointIds
        case isIsolationRequired
        case nextActionToBeTaken
        case techniciansActionList
        case equipments = "Equipments"
    }
}

// MARK: - User Lists
struct UserLists: Decodable {
    let iTHead: [String]
    let ehsHead: [String]
    let custodian: [String]
    let groupTagger: [String]
    let sectionHead: [String]
    let technicians: [String]
    let utilityHead: [String]
    let permitIssuer: StringOrArray?
    let departmentHead: [String]
    let electricalHead: [String]
    let mechanicalHead: [String]
    let permitReceiver: [String]
    let isolationIssuer: [String]
    let horticultureHead: [String]
    let instrumentalHead: [String]
    let administratorHead: [String]
    let isolationTechnician: StringOrArray?
    
    enum CodingKeys: String, CodingKey {
        case iTHead
        case ehsHead
        case custodian
        case groupTagger
        case sectionHead
        case technicians
        case utilityHead
        case permitIssuer
        case departmentHead
        case electricalHead
        case mechanicalHead
        case permitReceiver
        case isolationIssuer
        case horticultureHead
        case instrumentalHead
        case administratorHead
        case isolationTechnician
    }
}

struct PFieldValues: Codable {
    let uuid: String?
    let pdfMap: [String: PDFInfo]?
    let remarks: String?
    let location: String?
    let approvals: PApprovals?
    let multiteam: Bool?
    let equipments: [String]?
    let startTime: String?
    let permitType: Bool?
    let selectArea: String?
    let selectUnit: String?
    let selectPlant: String?
    let typeOfWork: String?
    let imageUrl: String?
    
    // Add your remaining fields as needed...
    // For this example, keeping only some to illustrate
    
    enum CodingKeys: String, CodingKey {
        case uuid, pdfMap, remarks, location, approvals, multiteam, equipments, startTime
        case permitType = "PERMIT TYPE"
        case selectArea = "Select Area"
        case selectUnit = "Select Unit"
        case selectPlant = "Select Plant"
        case typeOfWork = "Type of Work"
        case imageUrl
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Safe decode helper: try to decode, else return nil
        func decodeSafely<T: Decodable>(_ key: CodingKeys) -> T? {
            return try? container.decodeIfPresent(T.self, forKey: key)
        }
        
        uuid = decodeSafely(.uuid)
        pdfMap = decodeSafely(.pdfMap)
        remarks = decodeSafely(.remarks)
        location = decodeSafely(.location)
        approvals = decodeSafely(.approvals)
        multiteam = decodeSafely(.multiteam)
        equipments = decodeSafely(.equipments)
        startTime = decodeSafely(.startTime)
        permitType = decodeSafely(.permitType)
        selectArea = decodeSafely(.selectArea)
        selectUnit = decodeSafely(.selectUnit)
        selectPlant = decodeSafely(.selectPlant)
        typeOfWork = decodeSafely(.typeOfWork)
        imageUrl = decodeSafely(.imageUrl)
    }
}

// MARK: - Approvals
struct PApprovals: Codable {
    let electricalApproval: Bool
    let mechanicalApproval: Bool
    let horticultureApproval: Bool
    let instrumentationApproval: Bool
    let itApprovalForExcavation: Bool
    let utilityApprovalForExcavation: Bool
    
    enum CodingKeys: String, CodingKey {
        case electricalApproval = "Electrical Approval"
        case mechanicalApproval = "Mechanical Approval"
        case horticultureApproval = "Horticulture Approval"
        case instrumentationApproval = "Instrumentation Approval"
        case itApprovalForExcavation = "IT Approval For Excavation"
        case utilityApprovalForExcavation = "Utility Approval For Excavation"
    }
}

// MARK: - PDF Info
struct PDFInfo: Codable {
    let user: String
    let dateTime: String
}

// MARK: - PermitState
struct PPermitState: Codable {
    let userType: String
    let permitState: String?
    let permitStage: String
    let buttonAction: String
    let activeButtonsText: [String]
    let activeButtonActions: [String]
    let deactivateButtonText: String
    
    enum CodingKeys: String, CodingKey {
        case userType = "userType"
        case permitState = "PermitState"
        case permitStage = "permitStage"
        case buttonAction = "buttonAction"
        case activeButtonsText = "activeButtonsText"
        case activeButtonActions = "activeButtonActions"
        case deactivateButtonText = "deactivateButtonText"
    }
}
