//
//  IncidentFormViewModel.swift
//  Lloyds
//
//  Created by Manisha on 30/01/26.
//

//extension Notification.Name {
//    static let incidentUnitSelected = Notification.Name("incidentUnitSelected")
//    static let incidentLocationSelected = Notification.Name("incidentLocationSelected")
//}
//
//
//
//import Foundation
//import Combine
//
//class IncidentFormViewModel: ObservableObject {
//
//    @Published var sections: [FormSection] = []
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//
//    @Published var selectedUnit: String?
//    @Published var selectedLocation: String?
//
//    @Published var functionalLocations: [FunctionalLocation] = []
//
//    
//    init() {
//
//        NotificationCenter.default.addObserver(
//            forName: .incidentUnitSelected,
//            object: nil,
//            queue: .main
//        ) { notification in
//
//            guard let unit = notification.object as? String else { return }
//            self.selectedUnit = unit
//
//            // 🔴 RESET dependent fields
//            self.resetField(description: "Select_Location")
//            self.resetField(description: "Select_Sub_Area")
//
//            // 🟢 Load Location options (API or local)
//            self.loadLocations(for: unit)
//        }
//
//        NotificationCenter.default.addObserver(
//            forName: .incidentLocationSelected,
//            object: nil,
//            queue: .main
//        ) { notification in
//
//            guard let location = notification.object as? String else { return }
//            self.selectedLocation = location
//
//            // 🔴 RESET sub area
//            self.resetField(description: "Select_Sub_Area")
//
//            // 🟢 Load Sub Area options
//            self.loadSubAreas(for: location)
//        }
//    }
//
//    func fetchFunctionalLocations() {
//
//        guard let url = URL(string: "https://test.deltafour.co/api/v1/om/functional-location") else {
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        if let token = KeychainHelper.shared.getToken() {
//            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        }
//
//        URLSession.shared.dataTask(with: request) { data, _, error in
//
//            guard let data else { return }
//
//            print("📦 INCIDENT FUNCTIONAL LOCATION RESPONSE")
//            print(String(data: data, encoding: .utf8) ?? "nil")
//
//            do {
//                let decoded = try JSONDecoder().decode(
//                    FunctionalLocationResponse.self,
//                    from: data
//                )
//
//                DispatchQueue.main.async {
//                    self.functionalLocations = decoded.data
//                    self.mapUnitDropdown()   // 🔥 IMPORTANT
//                }
//
//            } catch {
//                print("❌ Functional location decode error:", error)
//            }
//
//        }.resume()
//    }
//
//    
//    func fetchIncidentForm() {
//
//        isLoading = true
//        errorMessage = nil
//
//        guard let url = URL(string: "https://test.deltafour.co/api/v1/forms/newpermit/type") else {
//            isLoading = false
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("application/json", forHTTPHeaderField: "Accept")
//
//        // ✅ TOKEN FROM KEYCHAIN
//        guard let token = KeychainHelper.shared.getToken(), !token.isEmpty else {
//            print("⚠️ No token found!")
//            DispatchQueue.main.async {
//                self.errorMessage = "Please login first"
//                self.isLoading = false
//            }
//            return
//        }
//
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        print("🔐 Token added to request")
//
//        // ✅ REQUEST BODY (as per your API)
//        let body: [String: Any] = [
//            "data": [
//                "fieldValues": [
//                    "PERMIT TYPE": true,
//                    "Create permit": true,
//                    "Select Type of Permit": "IM"
//                ]
//            ]
//        ]
//
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: body)
//        } catch {
//            print("❌ Body serialization error:", error)
//            isLoading = false
//            return
//        }
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//
//            DispatchQueue.main.async {
//                self.isLoading = false
//            }
//
//            if let error {
//                print("❌ API Error:", error)
//                return
//            }
//
//            guard let data else {
//                print("❌ No data received")
//                return
//            }
//
//            // ✅ RAW RESPONSE (VERY IMPORTANT)
//            print("📦 RAW RESPONSE:")
//            print(String(data: data, encoding: .utf8) ?? "nil")
//
//            do {
//                let decoded = try JSONDecoder().decode(IncidentFormResponse.self, from: data)
//                DispatchQueue.main.async {
//                    self.sections = decoded.sections
//                }
//            } catch {
//                print("❌ Decode Error:", error)
//                DispatchQueue.main.async {
//                    self.errorMessage = "Invalid server response"
//                }
//            }
//
//        }.resume()
//    }
//    
//    
//    func resetField(description: String) {
//        for sectionIndex in sections.indices {
//            for fieldIndex in sections[sectionIndex].fields.indices {
//                if sections[sectionIndex].fields[fieldIndex].description == description {
//                    sections[sectionIndex].fields[fieldIndex].selectedValue = nil
//                    sections[sectionIndex].fields[fieldIndex].optionsAvailable = []
//                }
//            }
//        }
//    }
//
//    
//    
//    func loadLocations(for unit: String) {
//        let locations = ["Location A", "Location B"]
//
//        updateOptions(description: "Select_Location", options: locations)
//    }
//
//    func loadSubAreas(for location: String) {
//        let subAreas = ["SubArea 1", "SubArea 2"]
//
//        updateOptions(description: "Select_Sub_Area", options: subAreas)
//    }
//
//    private func updateOptions(description: String, options: [String]) {
//        for sectionIndex in sections.indices {
//            for fieldIndex in sections[sectionIndex].fields.indices {
//                if sections[sectionIndex].fields[fieldIndex].description == description {
//                    sections[sectionIndex].fields[fieldIndex].optionsAvailable = options
//                }
//            }
//        }
//    }
//
//    func mapUnitDropdown() {
//
//        let units = Array(
//            Set(functionalLocations.map { $0.location })
//        ).sorted()
//
//        updateOptions(
//            description: "Select_Unit",
//            options: units
//        )
//    }
//
//    
//    
//}


extension Notification.Name {
    static let incidentUnitSelected = Notification.Name("incidentUnitSelected")
    static let incidentLocationSelected = Notification.Name("incidentLocationSelected")
}



import Foundation
import Combine
import SwiftUI

class IncidentFormViewModel: ObservableObject {

    @Published var sections: [FormSection] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var selectedUnit: String?
    @Published var selectedLocation: String?

    @Published var functionalLocations: [FunctionalLocation] = []

    
    @Published var showAlert = false
        @Published var alertMessage = ""
        @Published var isSuccess = false
    
    init() {

        NotificationCenter.default.addObserver(
            forName: .incidentUnitSelected,
            object: nil,
            queue: .main
        ) { notification in

            guard let unit = notification.object as? String else { return }
            self.selectedUnit = unit

            // 🔴 RESET dependent fields
            self.resetField(description: "Select_Location")
            self.resetField(description: "Select_Sub_Area")

            // 🟢 Load Location options (API or local)
            self.loadLocations(for: unit)
        }

        NotificationCenter.default.addObserver(
            forName: .incidentLocationSelected,
            object: nil,
            queue: .main
        ) { notification in

            guard let location = notification.object as? String else { return }
            self.selectedLocation = location

            // 🔴 RESET sub area
            self.resetField(description: "Select_Sub_Area")

            // 🟢 Load Sub Area options
            self.loadSubAreas(for: location)
        }
    }

    func fetchFunctionalLocations() {

//        guard let url = URL(string: "https://imomtest.deltafour.co/api/v1/om/functional-location") else {
//            return
//        }
        guard let url = URL(string: APIEndpoints.functionalLocations) else {
               return
           }


        var request = URLRequest(url: url)
        print("functional url-----\(url)")
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = KeychainHelper.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, error in

            guard let data else { return }

            print("📦 INCIDENT FUNCTIONAL LOCATION RESPONSE")
            print(String(data: data, encoding: .utf8) ?? "nil")

            do {
                let decoded = try JSONDecoder().decode(
                    FunctionalLocationResponse.self,
                    from: data
                )

                DispatchQueue.main.async {
                    self.functionalLocations = decoded.data
                    self.mapUnitDropdown()   // 🔥 IMPORTANT
                    print("countttt",self.functionalLocations.count)
                }

            } catch {
                print("❌ Functional location decode error:", error)
            }

        }.resume()
    }

    
    func fetchIncidentForm(completion: @escaping () -> Void) {

        isLoading = true
        errorMessage = nil

//        guard let url = URL(string: "https://test.deltafour.co/api/v1/forms/newpermit/type") else {
//            isLoading = false
//            return
//        }
        guard let url = URL(string: APIEndpoints.incidentForm()) else {
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // ✅ TOKEN FROM KEYCHAIN
        guard let token = KeychainHelper.shared.getToken(), !token.isEmpty else {
            print("⚠️ No token found!")
            DispatchQueue.main.async {
                self.errorMessage = "Please login first"
                self.isLoading = false
            }
            return
        }

        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print("🔐 Token added to request")

        // ✅ REQUEST BODY (as per your API)
        let body: [String: Any] = [
            "data": [
                "fieldValues": [
                    "PERMIT TYPE": true,
                    "Create permit": true,
                    "Select Type of Permit": "IM"
                ]
            ]
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("❌ Body serialization error:", error)
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in

            DispatchQueue.main.async {
                self.isLoading = false
            }

            if let error {
                print("❌ API Error:", error)
                return
            }

            guard let data else {
                print("❌ No data received")
                return
            }

            // ✅ RAW RESPONSE (VERY IMPORTANT)
            print("📦 RAW RESPONSE:")
            print(String(data: data, encoding: .utf8) ?? "nil")

            do {
                let decoded = try JSONDecoder().decode(IncidentFormResponse.self, from: data)
                DispatchQueue.main.async {
                    self.sections = decoded.sections
                    print("sections loaded-----\(self.sections)")
                    completion()
                }
            } catch {
                print("❌ Decode Error:", error)
                DispatchQueue.main.async {
                    self.errorMessage = "Invalid server response"
                }
            }

        }.resume()
    }
    
    
    func resetField(description: String) {
        for sectionIndex in sections.indices {
            for fieldIndex in sections[sectionIndex].fields.indices {
                if sections[sectionIndex].fields[fieldIndex].description == description {
                    sections[sectionIndex].fields[fieldIndex].selectedValue = nil
                    sections[sectionIndex].fields[fieldIndex].optionsAvailable = []
                }
            }
        }
    }

    
    
    func loadLocations(for unit: String) {

        let locations = functionalLocations
            .filter { $0.location == unit }
            .map { $0.mainArea }

        let unique = Array(Set(locations)).sorted()

        updateOptions(
            description: "Select_Location",
            options: unique
        )
    }

    
    func loadSubAreas(for location: String) {

        let subAreas = functionalLocations
            .filter { $0.mainArea == location }
            .map { $0.subArea }

        let unique = Array(Set(subAreas)).sorted()

        updateOptions(
            description: "Select_Sub_Area",
            options: unique
        )
    }


    private func updateOptions(description: String, options: [String]) {
        for sectionIndex in sections.indices {
            for fieldIndex in sections[sectionIndex].fields.indices {
                if sections[sectionIndex].fields[fieldIndex].description == description {
                    sections[sectionIndex].fields[fieldIndex].optionsAvailable = options
                }
            }
        }
        DispatchQueue.main.async {
                self.sections = self.sections
            }
    }

    func mapUnitDropdown() {

        let units = Array(
            Set(functionalLocations.map { $0.location })
        ).sorted()

        updateOptions(
            description: "Select_Unit",
            options: units
        )
    }

    // MARK: - Observation Logic
  func isInjuredSection(_ section: FormSection) -> Bool {
        section.title.lowercased().contains("injured")
    }
 
    var IncidentCount: Int {
        sections.filter { isInjuredSection($0) }.count
    }

    func addObservation() {

        guard let template = sections.first(where: {
            isInjuredSection($0)
        }) else {
            print("❌ Injured section not found in API response")
            return
        }

        var newSection = template
        newSection.id = UUID()
        newSection.expanded = true

        // Subtitle numbering
        newSection.subtitle = "\(template.title) \(IncidentCount + 1)"

        // Reset all fields
        newSection.fields = template.fields.map { field in
            var f = field
            f.textValue = nil
            f.selectedValue = nil
            f.timeValue = nil
            return f
        }

        withAnimation {
            sections.append(newSection)
        }
    }

    func removeObservation(id: UUID) {

        guard IncidentCount > 1 else { return }

        withAnimation {

            sections.removeAll {
                $0.id == id && isInjuredSection($0)
            }

            // Re-number subtitles
            var counter = 1
            for i in sections.indices {
                if isInjuredSection(sections[i]) {
                    sections[i].subtitle = "\(sections[i].title) \(counter)"
                    counter += 1
                }
            }
        }
    }
    
}


extension IncidentFormViewModel{
    
    func shouldShowField(field: FormField, in section: FormSection) -> Bool {
            // Agar field "Enter Employee Type" hai
            if field.description == "Enter_Employee_Type" {
                // "Select Employee Type" wala field dhoondo usi section mein
                if let employeeTypeField = section.fields.first(where: { $0.description == "Select_Employee_Type" }) {
                    // Sirf tab dikhao jab "External" selected ho
                    return employeeTypeField.selectedValue == "External"
                }
            }
            return true // Baaki saare fields hamesha dikhao
        }
  
    
    
    func buildPayload() -> [String: Any] {
        
        // Inital setup with exact keys from Postman
        var fieldValues: [String: Any] = [
            "PERMIT TYPE": true,
            "Create permit": true,
            "Select Type of Permit": "IM"
        ]
        
        var injuredArray: [[String: Any]] = []
        
        for section in sections {
            if isInjuredSection(section) {
                var injuredDict: [String: Any] = [:]
                
                for field in section.fields {
                    let rawKey = field.description ?? ""
                    let value = field.selectedValue ?? field.textValue ?? field.timeValue ?? ""
                    
                    // EXACT MAPPING FOR INJURED SECTION (Postman se match kiya hua)
                    switch rawKey {
                    case "Enter_Name_of_Person_Injured":
                        injuredDict["Enter_Name_of_Person_Injured"] = value
                    case "Gender":
                        injuredDict["Gender"] = value
                    case "Select_Employee_Type":
                        // API expects "1.Internal" or "2.External"
                        injuredDict["Select_Business_Partner"] = (value == "Internal") ? "1.Internal" : "2.External"
                    case "Enter_Employee_Type":
                        injuredDict["Enter_Business_Partner_name"] = value
                    case "Select_Type_of_Incident":
                        injuredDict["Select_Type_of_Incident"] = value
                    case "Immediate_action_taken":
                        injuredDict["Immediate_action_taken"] = value
                    default:
                        if !rawKey.isEmpty { injuredDict[rawKey] = value }
                    }
                }
                injuredArray.append(injuredDict)
                
            } else {
                for field in section.fields {
                    let rawKey = field.description ?? ""
                    let value = field.selectedValue ?? field.textValue ?? field.timeValue ?? ""
                    
                    // EXACT MAPPING FOR GENERAL DETAILS (Spaces vs Underscores fix)
                    switch rawKey {
                    case "Enter_Incident_Description":
                        fieldValues["Enter_Incident_Description"] = value
                    case "Select_Incident_Date___Time":
                        fieldValues["Select Incident Date & Time"] = value
                    case "Select_Unit":
                        fieldValues["Select Unit"] = value
                    case "Select_Location":
                        fieldValues["Select Location"] = value
                    case "Select_Sub_Area":
                        fieldValues["Select Sub Area"] = value
                    case "Enter_Name_of_Witness":
                        fieldValues["Enter_Name_of_Witness"] = value
                    default:
                        if !rawKey.isEmpty { fieldValues[rawKey] = value }
                    }
                }
            }
        }
        
        fieldValues["Injured Person Details"] = injuredArray
        
        // Returning the exact nested structure
        return [
            "data": [
                "fieldValues": fieldValues,
                "permitState": [
                    "buttonAction": "",
                    "activeButtonsText": ["Accept", "Reject"],
                    "activeButtonActions": ["Accept", "Reject"],
                    "deactivateButtonText": "Approval Pending"
                ],
                "isIsolationRequired": false
            ]
        ]
    }
    
    func mapKey(_ key: String) -> String {
        // Agar Postman me "Select_Business_Partner" hai aur code me "Select_Employee_Type"
        if key == "Select_Employee_Type" { return "Select_Business_Partner" }
        if key == "Enter_Employee_Type" { return "Enter_Business_Partner_name" }
        return key
    }
    
    
    func isFormValid() -> (Bool, String?) {
            for section in sections {
                for field in section.fields {
                    // Agar field required hai aur uski saari values (text, selected, time) nil ya empty hain
                    if field.required {
                        let textVal = field.textValue?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                        let selectVal = field.selectedValue?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                        let timeVal = field.timeValue?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                        
                        if textVal.isEmpty && selectVal.isEmpty && timeVal.isEmpty {
                            // Agar khali hai toh field ka naam return karo taaki user ko batayein kya missing hai
                            return (false, field.name)
                        }
                    }
                }
            }
            return (true, nil)
        }
    
    func submitIncident() {
        
        let (valid, missingFieldName) = isFormValid()
                
                if !valid {
                    self.alertMessage = "Please fill the required field: \(missingFieldName ?? "Unknown Field")"
                    self.isSuccess = false
                    self.showAlert = true
                    return 
                }
        
//        guard let url = URL(string: "https://imomtest.deltafour.co/api/v2/workflow/auxiliary/newpermit") else {
//            return
//        }
        
        guard let url = URL(string: APIEndpoints.createIncident) else {
                return
            }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = KeychainHelper.shared.getToken() else {
            print("Token missing")
            return
        }
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let payload = buildPayload()
        
        print("📦 FINAL PAYLOAD:")
        print(payload)
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("Serialization error:", error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                        if let error = error {
                            self.alertMessage = "Error: \(error.localizedDescription)"
                            self.isSuccess = false
                            self.showAlert = true
                            return
                        }
                        
                        guard let data = data,
                              let responseString = String(data: data, encoding: .utf8) else {
                            self.alertMessage = "No response from server"
                            self.isSuccess = false
                            self.showAlert = true
                            return
                        }
                        
                        print("✅ SUBMIT RESPONSE: \(responseString)")

                        // Response check (yahan check karein ki error key hai ya success)
                        if responseString.contains("error") {
                            self.alertMessage = "Submit Failed: \(responseString)"
                            self.isSuccess = false
                        } else {
                            self.alertMessage = "Incident Report Created Successfully!"
                            self.isSuccess = true
                        }
                        self.showAlert = true
                    }
                }.resume()
            }
    
    
}
