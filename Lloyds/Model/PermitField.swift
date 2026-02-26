//
//  PermitField.swift
//  Lloyds
//
//  Created by Manisha on 24/12/25.
//


import Foundation

// MARK: - Request Model

struct PermitRequest: Codable {
    let data: RequestData
    let id: Int
}

struct RequestData: Codable {
    let fieldValues: FieldValues
    let permitState: PutPermitState
}

struct FieldValues: Codable {
    let uuid: String
    let remarks: String
    let location: String
    let approvals: Approvals
    let multiteam: Bool
    let startTime: String
    let fireTender: Bool
    let oxygenTest: Bool
    let permitType: Bool
    let selectArea: String
    let selectPlant: String
    let createPermit: Bool
    let specialPermit: [String]
    let explosiveTest: Bool
    let legProtection: Bool
    let generalDetails: Bool
    let headProtection: Bool
    let screenOffArea: Bool
    let ppeAndOthers: Bool
    let selectEquipment: String
    let portableCOMeter: Bool
    let proposedEndTime: String
    let suppressMultiTeam: Bool
    let fireExtinguishers: Bool
    let isolationRequired: Bool
    let pressureFireHose: Bool
    let carbonMonoxideTest: Bool
    let selectSubEquipment: String
    let selectTypeOfPermit: String
    let competentFireWatcher: Bool
    let selectIsolationPoints: [Int]
    let selectPermitAuthorizer: [String]
    let enterDescriptionOfWork: String
    let selectRequisitionerDept: String
    let eyeFaceEarProtection: Bool
    let equipmentIsolationsDetails: Bool
    let roofLadderGasCuttingSets: Bool
    let specialCertificateSelection: Bool
    let respiratoryProtectionBASet: Bool
    let firePrecautionsAndGasTests: Bool
    let specialCertificateSelectionDropdown: [String]
    let bodyProtectionFullBodySafetyHarness: Bool
    let showSpecialCertificateSelectionDropdown: Bool
    let safeMeansOfAccessScaffoldingEnclosures: Bool
    let descriptionOfLoad: String
    let weightOfLoad: String
    let dimensions: String
    let crane: String
    let type: String
    let model: String
    let competentPersonTestCert: String
    let maxOperatingRadius: String
    let mainBoomLength: String
    let jibLength: String
    let jibOffset: String
    let attachments: String
    let counterweightsRequired: String
    let verticalClearance: String
    let drivingLicense: String
    let medicalFitness: String
    let certifiedOEMTraining: String
    let craneOperatorName: String
    let obstructions: String
    let distanceFromPowerLines: String
    let groundStability: String
    let undergroundUtilities: String
    let woodenStoppersOrMats: String
    let liftingCapacity: String
    
    let totalWeightOfAccessories: String
    let totalWeightOfLift: String
    let authorizedEngineer: String
    var imageUrl: [String]
}

struct Approvals: Codable {
    let electricalApproval: Bool
    let mechanicalApproval: Bool
    let horticultureApproval: Bool
    let instrumentationApproval: Bool
    let itApprovalForExcavation: Bool
    let utilityApprovalForExcavation: Bool
}

//struct PutPermitState: Codable {
//    let buttonAction: String
//}
//
//
//// MARK: - Response Model
//
//struct PutPermitResponse: Codable {
//    let fieldValues: FieldValues
//    let permitState: PutPermitState
//}


