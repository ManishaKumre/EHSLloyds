//
//  PermitDetail.swift
//  Lloyds
//
//  Created by Manisha on 21/01/26.
//

import SwiftUI


struct PermitDetails: Decodable {
    let data: String  // notice: data is JSON string
}

struct CampaignDetails: Decodable {
    let fieldValues: PermitFieldValues
}

struct PermitFieldValues: Decodable {
    let uuid: String
    let observations: [PermitObservation]
}

struct PermitObservation: Decodable {
    let uuid: String
    // baaki fields agar chahiye to add kar sakte ho
}

