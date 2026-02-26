//
//  UploadModels.swift
//  Lloyds
//
//  Created by Manisha on 24/12/25.
//

import Foundation




struct PutIsolationPoint: Codable {
    let uuid: String
    let imageUrl: String
    let isolated: Bool
    let deIsolated: Bool
    let isIsolated: Bool
    let isDeIsolated: Bool
    let isolationType: String
    let isolationIssuer: String
    let isolationPointId: String
    let deIsolationIssuer: String?
    let isolationPointName: String
}

//struct PutPermitState: Codable {
//    let buttonAction: String
//}
//
//struct PutPermitRequest: Codable {
////    let isolationDetails: [PutIsolationPoint]
//    let permitState: PutPermitState
////    var  permitId : Int
////    let fieldValues: [String: String]?
//}
//
//struct PutPermitResponse: Codable {
//    let data: PutPermitRequest
//    let id: Int
//}


// Define the structure for request body


//struct PutPermitRequest: Codable {
//    struct DataWrapper: Codable {
//        let permitState: PutPermitState
//        var fieldValues: [String: String]
//
//    }
//    let data: DataWrapper
//    let id: Int
//
//}


struct PutPermitRequest: Codable {
    var data: DataWrapper
    var id: Int
    
    struct DataWrapper: Codable {
        var isolationDetails: [IsolationDetail]?
        var permitState: PutPermitState
        var fieldValues: [String: CodableValue]
    }
}

struct PutPermitState: Codable {
    let buttonAction: String
}
//struct PutPermitResponse: Codable {
//    let data: PutPermitRequest.DataWrapper
//    let id: Int
//}

struct PutPermitResponse: Codable {
    let fieldValues: [String: CodableValue]
    let permitState: PutPermitState
}


enum CodableValue: Codable {
    case string(String)
    case bool(Bool)
    case int(Int)
    case double(Double)
    case array([CodableValue])
    case dictionary([String: CodableValue])
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let v = try? container.decode(String.self) {
            self = .string(v)
        } else if let v = try? container.decode(Bool.self) {
            self = .bool(v)
        } else if let v = try? container.decode(Int.self) {
            self = .int(v)
        } else if let v = try? container.decode(Double.self) {
            self = .double(v)
        } else if let v = try? container.decode([String: CodableValue].self) {
            self = .dictionary(v)
        } else if let v = try? container.decode([CodableValue].self) {
            self = .array(v)
        } else {
            throw DecodingError.typeMismatch(
                CodableValue.self,
                .init(codingPath: decoder.codingPath, debugDescription: "Unsupported JSON type")
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let v):
            try container.encode(v)
        case .bool(let v):
            try container.encode(v)
        case .int(let v):
            try container.encode(v)
        case .double(let v):
            try container.encode(v)
        case .array(let v):
            try container.encode(v)
        case .dictionary(let v):
            try container.encode(v)
        }
    }
}
