//
//  CampaignObserv.swift
//  Lloyds
//
//  Created by Manisha on 22/01/26.
//

import SwiftUI

import Foundation
import Combine

//struct CampaignDetailsAPIModel: Codable {
//    let fieldValues: CampaignFieldValues
//}
//
//struct CampaignFieldValues: Codable {
//    let observations: [Observation]?
//}

struct CampaignDetailsAPIModel: Codable {
    let fieldValues: CampaignFieldValues
    let permitState: CampaignPermitState?
}

struct CampaignFieldValues: Codable {
    let observations: [Observation]?
}

//struct CampaignPermitState: Codable {
//
//    let userType: String?
//    let permitStage: String?
//    let activeButtonsText: [String]?
//    let activeButtonActions: [String]?
//    let deactivateButtonText: String?
//
//}
