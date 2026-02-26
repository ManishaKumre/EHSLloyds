//
//  ViewPermitViewModel.swift
//  Lloyds
//
//  Created by Manisha on 24/12/25.
//

struct IsolationField: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let type: String
    var textValue: String?
}




import Foundation
import Combine
import UIKit


class ViewPermitViewModel: ObservableObject {
    @Published var permitDetail: ViewPermitResponse?
    @Published var permitDetails: RootData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var fieldValues: FieldValues?
    @Published var DEfieldValues: PFieldValues?
//    @Published var actionChecklist: [DChecklistModalView] = []
    @Published var successMessage: String?
    @Published var rootData: RootData?
//    weak var flowVM: IsolationFlowViewModel?
    @Published var mandatoryFields: [Field] = []
    @Published var isUpdatingPermit = false
    
    @Published var fields: [ActionField] = []
    
    @Published var selectedActionName: String? = nil
//    @Published var actionSection: ActionSection? = nil //bind
    @Published var showActionFormScreen: Bool = false
    @Published var showOtherActionScreen: Bool = false
    @Published var permitFieldValues: [String: CodableValue] = [:]
    private var cancellables = Set<AnyCancellable>()
    @Published var isolationFields: [IsolationField] = []
    @Published var permit: PermitResponse?
    @Published var localIsolationDetails: [IsolationDetail] = []
    @Published var permitId: Int?
    @Published var isolationDetails: [String: Any]? = nil
//    @Published var checkedItemsFields: [ActionField] = []
    @Published var originalIsolationData: [String: IsolationDetail] = [:]
    @Published var isolationPoints: [[String: String]] = []
    @Published var viewPermitSections: [ViewPermitSection] = []
       @Published var observations: [Observation] = []
    @Published var actionFields: [ActionField] = []
    @Published var executorUsers: [WorkflowUser] = []

    @Published var incidentFieldValues: [String: Any]?

    @Published var incidentSections: [[String: Any]]?
    
    @Published var showSuccessAlert = false
    @Published var showErrorAlert = false
   
    @Published var navigateToPermitType = false
    
    @Published var shouldCloseObservationPopup = false
    
    
    var actionWasClose: Bool = false 
    
    
   
    // MARK: - Action Helpers

    var statusOptions: [String] {
        actionFields.first(where: { $0.description == "Select_Status" })?
            .optionsAvailable ?? []
    }

    
    
    // Add this function in ViewPermitViewModel
    func updateIsolationDetails(_ isolationDetails: [IsolationDetail]) {
        print("📝 Updating isolation details in ViewPermit")
        print("   Received \(isolationDetails.count) isolation point(s)")
        
        // Store in local array
        self.localIsolationDetails = isolationDetails
        
        
        
        // 🔥 UI ke liye isolationFields bhi update karo
        self.isolationFields = isolationDetails.map {
            IsolationField(
                name: $0.isolationPointName ?? "",
                description: $0.padlockName ?? "",
                type: "grid",
                textValue: $0.imageUrl
            )
        }
        
        // Print details for debugging
        for (index, detail) in isolationDetails.enumerated() {
            print("   [\(index + 1)] \(detail.isolationPointName)")
            print("       Padlock: \(detail.padlockName ?? "None")")
            print("       Image: \(detail.imageUrl ?? "None")")
            print("       Status: \(detail.isIsolated ? "Isolated ✓" : "Not Isolated")")
        }
        
        print("✅ ViewPermit updated with \(localIsolationDetails.count) points")
    }
    
    
    
    
    
    func loadPermitDetail(permitId: Int, completion: (() -> Void)? = nil) {
        
        self.incidentFieldValues = nil 
        
        isLoading = true
        errorMessage = nil
        
        //        self.isUpdatingPermit = true
        APIService.shared.fetchPermitDetail(permitId: permitId)
        
            .receive(on: DispatchQueue.main)
            .sink { completion in
                self.isLoading = false
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { detail in
                
                self.permitDetail = detail
                
//                self.rootData = detail  // ✅ This already exists in your code
                self.fetchPermitDetails(permitId: permitId)
                
                if let sections = detail.data?.sections {
                    self.extractActionFields(from: sections)
                }


                self.filterActionSection()
                
                guard let sections = detail.data?.sections else { return }
                
                for section in sections {
                    print("🔍 Section Title: \(section.title ?? "NO TITLE")")
                    print("🔍 Section fields Count: \(section.fields?.count ?? 0)")
                    
                    // ---- MANDATORY CHECKLIST SECTION ----
                    if section.title == "Mandatory Checklist" {
                        
                        guard let permitFields = section.fields, !permitFields.isEmpty else {
                            print("❌ No fields found in Mandatory Checklist")
                            return
                        }
                        
                        print("✅ Found \(permitFields.count) fields in Mandatory Checklist")
                        
                        // ✅ Convert PermitField → Field
                        self.mandatoryFields = permitFields.compactMap { permitField in
                            Field(
                                name: permitField.name ?? "",
                                type: permitField.type,
                                description: permitField.description,
                                required: permitField.required,
                                defaultValueRadioButton: permitField.defaultValueRadioButton
                            )
                        }
                        
                        
                        
                        
                        
                        print("✅ Converted to \(self.mandatoryFields.count) Field objects")
                      
                            
                           
                          
                        }
                   
                    
                    
                    
                    if section.title == "Isolation Details" {

                        print("🟦 Found Isolation Details section")

                        // Clear old values
                        self.isolationFields.removeAll()

                        // Traverse grids → fields
                        for grid in section.grids ?? [] {
                            for field in grid.fields ?? [] {

                                let model = IsolationField(
                                    name: field.name ?? "",
                                    description: field.description ?? "",
                                    type: field.type ?? "",
                                    textValue: field.textValue
                                )

                                self.isolationFields.append(model)

                                print("➡️ Added Isolation Field: \(field.name ?? "")")
                            }
                        }

                        print("✅ total isolation fields = \(self.isolationFields.count)")
                    }

                    
                    if section.title == "Action" {
                                        
                                        guard let actionFields = section.fields else {
                                            print("❌ No fields in Action Section")
                                            continue
                                        }
                                        
                                        print("🟦 Action Fields: \(actionFields.count)")
                                        
                                        // Convert to DChecklistModalView
//                                        self.actionChecklist = actionFields.map { field in
//                                            DChecklistModalView(
//                                                title: field.name ?? "",
//                                                description: field.description ?? "",
//                                                isOn: field.defaultValueRadioButton ?? false
//                                            )
//                                        }
                                        
//                                        print("🟩 Created \(self.actionChecklist.count) Action Checklist items")
                                        
                                        
                                        // ---- INIT DEFAULT VALUES FOR ACTION ----
                                        DispatchQueue.main.async { [weak self] in
//                                            guard let self = self, let flowVM = self.flowVM else { return }
                                            
//                                            for item in self.actionChecklist {
//                                                let key = item.description
//                                                
//                                                if flowVM.actionChecklistResponses[key] == nil {
//                                                    flowVM.actionChecklistResponses[key] = item.isOn
//                                                    print("🔵 Init Action → \(key) = \(item.isOn)")
//                                                }
//                                            }
                                        }
                                    }
               

                                }
                }
            
            .store(in: &cancellables)
        
//        if let points = permitDetails?.isolationDetails {
//            DispatchQueue.main.async {
//                self.flowVM?.isolationPoints = points.map {
//                    IsolationPoint(
//                        id: Int($0.isolationPointId) ?? 0,
//                        isolationPointName: $0.isolationPointName,
//                        isolationPointType: $0.isolationType
//                    )
//                }
//            }
//        }

        
        
        
    }
    
    func reset() {
        print("🧹 Resetting ViewModel")

        permitDetail = nil
        observations = []
        actionFields = []
        executorUsers = []
    }
    
    func extractActionFields(from sections: [ViewPermitSection]) {

        guard let actionSection = sections.first(where: { $0.title == "Action" }),
              let permitFields = actionSection.fields else {
            print("❌ No Action section found")
            return
        }

        self.actionFields = permitFields.map { field in
            ActionField(
                name: field.name ?? "",
                type: field.type ?? "",
                description: field.description,
                condition: field.condition?.asArray,
         // ✅ ADD THIS
                textValue: nil,
                reasonText: nil,
                listOfElements: field.listOfElements,
                selectedValues: field.selectedValues,
                defaultValueRadioButton: field.defaultValueRadioButton,
                optionsAvailable: field.optionsAvailable
            )

        }

        print("✅ Extracted \(self.actionFields.count) ActionFields")
    }

    
    
    // Filter the "Action" section from the permitDetail
    func filterActionSection() {
        if let sections = permitDetail?.data?.sections {
            if let actionSection = sections.first(where: { $0.title == "Action" }) {
                print("actionSection.fields?===> \(actionSection.fields)")
//                self.actionSection = ActionSection(
//                    
//                    title: actionSection.title ?? "Action",
//                    fields: actionSection.fields?.compactMap { field in
//                        // Map PermitField to ActionField
//                        ActionField(
//                            name: field.name ?? "",
//                            type: field.type ?? "",
//                            description: field.description,
//                            condition: field.condition?.asArray,
//                            textValue: field.textValue // Using textValue from PermitField
//                        )
//                    } ?? []
//                )
            }
            
            // After you set self.actionSection = ...
            // Build actionChecklist robustly (handle Bool or String)
//            self.actionChecklist = actionSection?.fields.compactMap { field -> DChecklistModalView? in
//                let title = field.name ?? field.description ?? "Unnamed Action"
//                // defaultValueRadioButton might be Bool? or String? depending on server parsing
//                var defaultBool = false
//                if let boolVal = (field.defaultValueRadioButton as? Bool) {
//                    defaultBool = boolVal
//                } else if let strVal = (field.defaultValueRadioButton as? String) {
//                    defaultBool = (strVal.lowercased() == "true")
//                } else {
//                    // if your model already typed it as Bool? then simply:
//                    if let typedBool = field.defaultValueRadioButton as? Bool {
//                        defaultBool = typedBool
//                    }
//                }
//
//                return DChecklistModalView(title: title, description: "ggfht", isOn: defaultBool)
//            } ?? []

            
        }
    }
    //   }
    
    
    
    
    func handleActionButtonTap(actionName: String, section: ActionSection?) {
        if actionName == "Update Details" {
//            self.actionSection = section
            self.showActionFormScreen = true
        } else {
            self.selectedActionName = actionName
            self.showOtherActionScreen = true
        }
    }
    
   
 
    
}



extension ViewPermitViewModel {
    
    func toggleSection(at index: Int) {
        guard var sections = permitDetail?.data?.sections else { return }
        sections[index].expanded?.toggle()
        permitDetail?.data?.sections = sections
    }
    
    // Expand all
    func expandAll() {
        guard var sections = permitDetail?.data?.sections else { return }
        for i in sections.indices { sections[i].expanded = true }
        permitDetail?.data?.sections = sections
    }
    
    
    // Collapse all
    func collapseAll() {
        guard var sections = permitDetail?.data?.sections else { return }
        for i in sections.indices { sections[i].expanded = false }
        permitDetail?.data?.sections = sections
    }
    
    func toggleMultiSelection(fieldId: UUID, value: String) {
        guard let index = fields.firstIndex(where: { $0.id == fieldId }) else { return }
        
        if fields[index].selectedValues == nil {
            fields[index].selectedValues = []
        }
        
        if fields[index].selectedValues!.contains(value) {
            fields[index].selectedValues!.removeAll { $0 == value }
        } else {
            fields[index].selectedValues!.append(value)
        }
        
        objectWillChange.send()
    }
    
}






extension ViewPermitViewModel {
    
   
    func updatePermit(requestBody: PutPermitRequest, token: String) {
        guard let url = URL(string: APIConfig.updatePermitURL) else {
                    errorMessage = "Invalid URL"
                    return
                }
        
        isLoading = true
        successMessage = nil
        errorMessage = nil
        
        do {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "PUT"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let encoder = JSONEncoder()
            urlRequest.httpBody = try encoder.encode(requestBody)
            
            // 🟦 PRINT FINAL REQUEST BODY BEFORE API CALL
            if let jsonString = String(data: urlRequest.httpBody!, encoding: .utf8) {
                print("==============================")
                print("📤 FINAL REQUEST BODY SENT TO SERVER")
                print(jsonString)
                print("==============================")
            }
            
            URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        print("❌ ERROR:", error.localizedDescription)
                        return
                    }
                    
                    guard let http = response as? HTTPURLResponse else {
                        self?.errorMessage = "No HTTP response"
                        return
                    }
                    
                    // 🟥 HANDLE FAILURE
                    if !(200...299).contains(http.statusCode) {
                        print("❌ SERVER ERROR: \(http.statusCode)")
                        if let d = data, let str = String(data: d, encoding: .utf8) {
                            print("📩 SERVER RESPONSE:", str)
                            self?.errorMessage = str
                        } else {
                            self?.errorMessage = "Unexpected server response"
                        }
                        return
                    }
                    
                    // 🟩 SUCCESS RESPONSE PRINT
                    if let d = data, let str = String(data: d, encoding: .utf8) {
                        print("✅ SUCCESS RESPONSE FROM SERVER:")
                        print(str)
                    }
                    
                    self?.successMessage = "Permit updated successfully."
                }
            }.resume()
            
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
    
    
}




extension ViewPermitViewModel {
    func createPermitRequest(from rootData: RootData, actionTitle: String, permitId: Int) -> PermitRequest {
        let fv = rootData.fieldValues
        
        let approvals = Approvals(
            electricalApproval: fv.approvals?.electricalApproval ?? false ,
            mechanicalApproval: fv.approvals?.mechanicalApproval ?? false,
            horticultureApproval: fv.approvals?.horticultureApproval ?? false,
            instrumentationApproval: fv.approvals?.instrumentationApproval ?? false,
            itApprovalForExcavation: fv.approvals?.itApprovalForExcavation ?? false,
            utilityApprovalForExcavation: fv.approvals?.utilityApprovalForExcavation ?? false
        )
        
        // MARK: - Create valid FieldValues
        let fieldValues = FieldValues(
            uuid: fv.uuid ?? "",
            remarks: fv.remarks ?? "",
            location: fv.location ?? "",
            approvals: approvals,
            multiteam: fv.multiteam ?? false,
            startTime: fv.startTime ?? "",
            fireTender: false,
            oxygenTest: false,
            permitType: fv.permitType ?? false,
            selectArea: fv.selectArea ?? "",
            selectPlant: fv.selectPlant ?? "",
            createPermit: false,
            specialPermit: [],
            explosiveTest: false,
            legProtection: false,
            generalDetails: false,
            headProtection: false,
            screenOffArea: false,
            ppeAndOthers: false,
            selectEquipment: fv.equipments?.first ?? "",
            portableCOMeter: false,
            proposedEndTime: "",
            suppressMultiTeam: false,
            fireExtinguishers: false,
            isolationRequired: false,
            pressureFireHose: false,
            carbonMonoxideTest: false,
            selectSubEquipment: "",
            selectTypeOfPermit: "",
            competentFireWatcher: false,
            selectIsolationPoints: [],
            selectPermitAuthorizer: [],
            enterDescriptionOfWork: fv.typeOfWork ?? "",
            selectRequisitionerDept: "",
            eyeFaceEarProtection: false,
            equipmentIsolationsDetails: false,
            roofLadderGasCuttingSets: false,
            specialCertificateSelection: false,
            respiratoryProtectionBASet: false,
            firePrecautionsAndGasTests: false,
            specialCertificateSelectionDropdown: [], // ✅ FIXED: empty array instead of false
            bodyProtectionFullBodySafetyHarness: false,
            showSpecialCertificateSelectionDropdown: false,
            safeMeansOfAccessScaffoldingEnclosures: false,
            descriptionOfLoad: "",
            weightOfLoad: "",
            dimensions: "",
            crane: "",
            type: "",
            model: "",
            competentPersonTestCert: "",
            maxOperatingRadius: "",
            mainBoomLength: "",
            jibLength: "",
            jibOffset: "",
            attachments: "",
            counterweightsRequired: "",
            verticalClearance: "",
            drivingLicense: "",
            medicalFitness: "",
            certifiedOEMTraining: "",
            craneOperatorName: "",
            obstructions: "",
            distanceFromPowerLines: "",
            groundStability: "",
            undergroundUtilities: "",
            woodenStoppersOrMats: "",
            liftingCapacity: "",
            totalWeightOfAccessories: "",
            totalWeightOfLift: "",
            authorizedEngineer: "",
            imageUrl: fv.pdfMap?.keys.map { $0 } ?? [] // ✅ correct array
        )
        
        
        return PermitRequest(
            data: RequestData(
                fieldValues: fieldValues,
                permitState: PutPermitState(buttonAction: actionTitle)
            ),
            id: permitId
        )
    }
    
    
    
  
    
    
}




struct IsolationDetailPayload {
    let imageUrl: String
    let isDeIsolated: Bool
    let isIsolated: Bool
    let isolationIssuer: String
    let isolationPointId: String
    let isolationPointName: String
    let isolationType: String
    let padlockName: String
    let uuid: String
}



extension ViewPermitViewModel {

    func fetchPermitDetails(permitId: Int) {

        guard let url = URL(string: APIEndpoints.permitDetails(permitId: permitId)) else {
            print("❌ Invalid URL")
            return
        }

        // ✅ Create URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // ✅ Attach Authorization Token (SAME AS isolation API)
        if let token = KeychainHelper.shared.getToken(), !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔐 Token attached: \(token.prefix(20))...")
        } else {
            print("⚠️ No token found, request may fail")
        }

        print("📡 Fetching permit details from:", url.absoluteString)

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                print("❌ API error:", error)
                return
            }

            guard let data = data else {
                print("❌ No data received")
                return
            }

            do {
                print("🔍 viewRAW RESPONSE:", String(data: data, encoding: .utf8) ?? "nil")

                let outerJson = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                guard let dataValue = outerJson?["data"] else {
                    print("❌ data key missing")
                    return
                }

                let innerData: Data

                // ✅ CASE 1: data is STRING
                if let dataString = dataValue as? String {
                    guard let d = dataString.data(using: .utf8) else {
                        print("❌ String → Data failed")
                        return
                    }
                    innerData = d
                }
                // ✅ CASE 2: data is OBJECT
                else {
                    innerData = try JSONSerialization.data(withJSONObject: dataValue)
                }

                let details = try JSONDecoder().decode(
                    CampaignDetailsAPIModel.self,
                    from: innerData
                )

                DispatchQueue.main.async {
                    self.observations = details.fieldValues.observations ?? []
                    self.permitDetail?.data?.permitState = details.permitState
                   
                    print("✅ Observations count:", self.observations.count)
                    self.matchObservationsWithSections()
                }

            } catch {
                print("❌ Decode error:", error)
            }

        }.resume()
    }


    
 
    func matchObservationsWithSections() {

        guard var sections = permitDetail?.data?.sections else { return }

        for sectionIndex in sections.indices {

            // ✅ Sirf Observation sections
            guard sections[sectionIndex].title?
                .lowercased()
                .contains("observation") == true else { continue }

            guard let grids = sections[sectionIndex].grids else { continue }

            for gridIndex in grids.indices {

                guard let fields = grids[gridIndex].fields else { continue }

                for fieldIndex in fields.indices {

                    // 🔥 YAHI UUID HAI
                    let uuid = fields[fieldIndex].name?
                        .trimmingCharacters(in: .whitespacesAndNewlines)

                    guard let fieldUUID = uuid else { continue }

                    // 🔥 YAHI MATCH HOGA
                    if let obs = observations.first(where: { $0.uuid == fieldUUID }) {

                        sections[sectionIndex]
                            .grids?[gridIndex]
                            .fields?[fieldIndex]
                            .textValue = obs.enterObservationDescription ?? "-"

                        print("✅ Matched Observation UUID:", fieldUUID)
                    }
                }
            }
        }

        DispatchQueue.main.async {
            self.permitDetail?.data?.sections = sections
        }
    }

    
}


extension ViewPermitViewModel{
    
    
//    func fetchExecutors() {
//        guard let url = URL(string: APIEndpoints.userList) else { return }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//
//        if let token = KeychainHelper.shared.getToken(), !token.isEmpty {
//            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        }
//
//        print("📡 Fetching executors:", url.absoluteString)
//
//        URLSession.shared.dataTask(with: request) { data, _, _ in
//            guard let data else { return }
//
//            do {
//                let decoded = try JSONDecoder().decode(WorkflowUserResponse.self, from: data)
//
//                let executors = decoded.data
//                    .filter { $0.customRoles?.contains("EXECUTOR") == true }
//                    .map { $0.displayName }
//
//                DispatchQueue.main.async {
//                    self.executorUsers = executors
//                    print("🟢 Executors loaded:", executors)
//                }
//
//            } catch {
//                print("❌ Executor API error:", error)
//                print("📦 RAW RESPONSE:", String(data: data, encoding: .utf8) ?? "")
//            }
//        }.resume()
//    }

    func fetchExecutors() {

        guard let url = URL(string: APIEndpoints.userList) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if let token = KeychainHelper.shared.getToken(), !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        print("📡 Fetching executors:", url.absoluteString)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data else { return }

            do {

                let decoded = try JSONDecoder().decode(WorkflowUserResponse.self, from: data)

                let executors = decoded.data.filter {
                    $0.customRoles?.contains("EXECUTOR") == true
                }

                DispatchQueue.main.async {

                    self.executorUsers = executors

                    print("🟢 Executors loaded:",
                          executors.map { "\($0.id) - \($0.displayName)" })
                }

            } catch {

                print("❌ Executor API error:", error)
                print("📦 RAW RESPONSE:", String(data: data, encoding: .utf8) ?? "")
            }

        }.resume()
    }

//    func submitObservationAction(
//        body: [String: Any],
//        completion: @escaping (Bool) -> Void
//    ) {
//
//        let url = URL(string: "https://imomtest.deltafour.co/api/v1/workflow/permit")!
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "PUT"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        if let token = KeychainHelper.shared.getToken() {
//            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        }
//
//      //  request.httpBody = try? JSONSerialization.data(withJSONObject: body)
//
//        
//        guard let dataContent = body["data"],
//              let permitId = body["id"] as? Int else {
//            completion(false)
//            return
//        }
//
//        let cleanBody: [String: Any] = [
//            "data": dataContent,
//            "id": permitId      // ✅ Optional nahi, pure Int
//        ]
//
//        if let jsonData = try? JSONSerialization.data(withJSONObject: cleanBody) {
//            request.httpBody = jsonData
//            print("📤 CLEAN JSON:", String(data: jsonData, encoding: .utf8) ?? "")
//        }
//        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//
//            if let error = error {
//                print("❌ API ERROR:", error)
//
//                DispatchQueue.main.async {
//                    self.errorMessage = "Action failed"
//                    self.showErrorAlert = true
//                    completion(false)
//                }
//                return
//            }
//            
//            if let data = data {
//                        let str = String(data: data, encoding: .utf8)
//                        print("🔴 SUBMIT RESPONSE:", str ?? "")  // ✅ YE ADD KARO
//                    }
//
//            if let httpResponse = response as? HTTPURLResponse {
//
//                print("📡 obsrvation STATUS CODE:", httpResponse.statusCode)
//
//                DispatchQueue.main.async {
//
//                    if httpResponse.statusCode == 200 {
//
//                        print("✅ ACTION SUBMITTED SUCCESSFULLY")
//
//                        self.successMessage = "Observation action submitted successfully"
//                        self.showSuccessAlert = true
//
//                        completion(true)
//
//                    } else {
//
//                        self.errorMessage = "Action failed"
//                        self.showErrorAlert = true
//
//                        completion(false)
//                    }
//                }
//            }
//
//        }.resume()
//    }
    
    func submitObservationAction(
        body: [String: Any],
        completion: @escaping (Bool) -> Void
    ) {
        //let url = URL(string: "https://imomtest.deltafour.co/api/v1/workflow/permit")!

        guard let url = URL(string: APIEndpoints.permitWorkflowAction) else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = KeychainHelper.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // ✅ Exact Android order: data pehle, id baad mein
        guard let dataContent = body["data"] as? [String: Any],
              let permitId = body["id"] as? Int,
              let fieldValues = dataContent["fieldValues"] as? [String: Any],
              let observations = fieldValues["observations"] as? [[String: Any]],
              let obsData = try? JSONSerialization.data(withJSONObject: observations),
              let obsString = String(data: obsData, encoding: .utf8) else {
            completion(false)
            return
        }

        let jsonString = "{\"data\":{\"fieldValues\":{\"observations\":\(obsString)},\"permitState\":{\"buttonAction\":\"Take Action\"}},\"id\":\(permitId)}"

        print("📤 FINAL JSON:", jsonString)

        request.httpBody = jsonString.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                print("❌ API ERROR:", error)
                DispatchQueue.main.async {
                    self.errorMessage = "Action failed"
                    self.showErrorAlert = true
                    completion(false)
                }
                return
            }

            if let data = data {
                let str = String(data: data, encoding: .utf8)
                print("🔴 SUBMIT RESPONSE:", str ?? "")
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📡 STATUS CODE:", httpResponse.statusCode)
                DispatchQueue.main.async {
                    if httpResponse.statusCode == 200 {
                        print("✅ ACTION SUBMITTED SUCCESSFULLY")
                        self.successMessage = "Observation action submitted successfully"
                        self.showSuccessAlert = true
                        completion(true)
                    } else {
                        self.errorMessage = "Action failed"
                        self.showErrorAlert = true
                        completion(false)
                    }
                }
            }
        }.resume()
    }

}


extension ViewPermitViewModel {

    func generateAfterImageFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH-mm-ss-SSSZ"
        let date = formatter.string(from: Date())
        return "\(date)__Upload_After_Image_1"
    }
}

extension ViewPermitViewModel {

    func uploadAfterImage(
        image: UIImage,
        completion: @escaping (String?) -> Void
    ) {

        // 🔥 1️⃣ FILE NAME
        let fileName = generateAfterImageFileName()

        // 🔥 2️⃣ URL BUILD
        let encodedFileName =
            fileName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            ?? fileName

        let urlString = APIEndpoints.uploadAfterImage(fileName: encodedFileName)

        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        print("📤 Upload After Image URL:", url.absoluteString)

        // 🔥 3️⃣ REQUEST
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        if let token = KeychainHelper.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let boundary = UUID().uuidString
        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )

        // 🔥 4️⃣ BODY
        var data = Data()

        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append(
            "Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName).jpg\"\r\n"
                .data(using: .utf8)!
        )
        data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        data.append(image.jpegData(compressionQuality: 0.8)!)
        data.append("\r\n".data(using: .utf8)!)
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)

        // 🔥 5️⃣ API CALL
        URLSession.shared.uploadTask(with: request, from: data) { responseData, _, error in

            guard let responseData,
                  let responseString = String(data: responseData, encoding: .utf8),
                  error == nil else {
                completion(nil)
                return
            }

            print("🟢 After Image Upload Response:", responseString)
            completion(responseString)

        }.resume()
    }
}




extension ViewPermitViewModel{
    
    func loadIncidentDetail(permitId: Int) {

//        guard let url = URL(
//            string: "https://imomtest.deltafour.co/api/v1/workflow/auxiliary/permit?permit_id=\(permitId)"
//          //  string: "https://test.deltafour.co/api/v1/workflow/auxiliary/permit/details?permit_id=\(permitId)"
//        ) else { return }
        
        guard let url = URL(string: APIEndpoints.incidentDetail(permitId: permitId)) else { return }

        print("🌐 Incident API URL:", url.absoluteString)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if let token = KeychainHelper.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, error in

            if let error = error {
                print("❌ Incident API Error:", error)
                return
            }

          
                       guard let data = data else {
                           print("❌ No Data Received")
                           return
                       }

                       // ✅ Print raw response
                       if let rawResponse = String(data: data, encoding: .utf8) {
                           print("📦 Raw API Response:", rawResponse)
                       }

                       do {
                           let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                          // let dataObj = json?["data"] as? [String: Any]

//                           DispatchQueue.main.async {
//                               self.incidentFieldValues = dataObj?["fieldValues"] as? [String: Any]
//                           }
                           
                           let dataObj = json?["data"] as? [String: Any]
                           let sections = dataObj?["sections"] as? [[String: Any]]

                           DispatchQueue.main.async {
                               self.incidentSections = sections
                           }


                       } catch {
                           print("❌ Incident decode error:", error)
                       }

                   }.resume()
               }
    
    
    
    func performIncidentAction(actionName: String) {
           
           print("Action Triggered: \(actionName)")
           
          // isLoading = true
           
           // 👉 Yaha API call karna hai
           // Example:

           DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
             //  self.isLoading = false
               print("API Success for \(actionName)")
           }
       }
    
    
           }

