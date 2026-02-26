//
//  Permit models.swift
//  Lloyds
//
//  Created by Manisha on 24/12/25.
//


import Foundation
// MARK: - Response Wrapper
struct PermitResponse: Codable {
    let data: [Permit]
}

struct Permit: Identifiable, Codable, Hashable {
    let id: Int
    let cardDetails: String?   // raw string
    let details: String?
    let uuid: String?
    var permitCode: String?
    let cardDetailsJson: CardDetailsJson?
    
    
    
    
    // Decode cardDetails JSON string
    private var decodedCardDetails: CardDetails? {
        guard let cardDetails = cardDetails,
              let data = cardDetails.data(using: .utf8)
        else { return nil }
        return try? JSONDecoder().decode(CardDetails.self, from: data)
    }
    
   
    
    
    // Decode details JSON string
    private var decodedDetails: Details? {
        guard let details = details,
              let data = details.data(using: .utf8)
        else { return nil }
        return try? JSONDecoder().decode(Details.self, from: data)
    }
    
    var title: String? {
        decodedCardDetails?.sections.first?.title
    }
    
    var resolvedTitle: String {
            if let title = cardDetailsJson?.sections.first?.title,
               !title.isEmpty {
                return title
            }
            return "—"
        }
    
    var status: String? {
        decodedCardDetails?.sections.first?.permitStatus
    }
    
    var isolationPoints: [String] {
        decodedDetails?.isolationList.compactMap { $0.isolationPointName } ?? []
    }
}


// MARK: - Details JSON
struct Details: Codable {
    let isolationDetails: String?
    
    var isolationList: [IsolationDetail] {
        guard let isolationDetails = isolationDetails,
              let data = isolationDetails.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([IsolationDetail].self, from: data)
        else { return [] }
        return decoded
    }
}

// MARK: - Isolation Detail
//struct IsolationDetail: Codable {
//    let isolationPointName: String?
//}




// Isolation detail struct
struct IsolationDetail: Codable {
    var imageUrl: String? // filename or url
    var isDeIsolated: Bool
    var isIsolated: Bool
    var isolationIssuer: String? // eg "1090"
    var isolationPointId: String?
    var deIsolationIssuer: String?
    var isolationPointName: String?
    var isolationType: String? // e.g. "Electrical"
    var padlockName: String?
    var uuid: String?


    
    enum CodingKeys: String, CodingKey {
        case imageUrl
        case isDeIsolated
        case isIsolated
        case isolationIssuer
        case deIsolationIssuer         // ✅ ADD this
        case isolationPointId
        case isolationPointName
        case isolationType
        case padlockName
        case uuid
    }
}




// MARK: - Nested JSON inside cardDetails
struct CardDetails: Codable {
    let sections: [Section]
    
    struct Section: Codable {
        let title: String?
        let permitStatus: String?
    }
}





struct CardDetailsJson: Codable, Hashable {
    let sections: [Section]

    struct Section: Codable, Hashable {
        let title: String?
        let permitStatus: String?
    }
}


extension Permit {
    var deactivateButtonText: String? {
        guard let json = details,
              let data = json.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let permitState = dict["permitState"] as? [String: Any],
              let text = permitState["deactivateButtonText"] as? String
        else { return nil }

        return text
    }
}


extension Permit {

    private var fieldValues: [String: Any]? {
        guard
            let json = details,
            let data = json.data(using: .utf8),
            let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let detailsJson = dict["fieldValues"] as? [String: Any]
        else { return nil }

        return detailsJson
    }

    var unitName: String {
        fieldValues?["Select Unit"] as? String ?? ""
    }

    var locationName: String {
        fieldValues?["Select Location"] as? String ?? ""
    }

    var subAreaName: String {
        fieldValues?["Select Sub Area"] as? String ?? ""
    }

    var permitType: String {
        fieldValues?["Select Type of Permit"] as? String ?? ""
    }

    var incidentDateTime: String {
        fieldValues?["Select Incident Date & Time"] as? String ?? ""
    }
}
