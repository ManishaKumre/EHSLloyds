//
//  PermitTypeViewModel.swift
//  Lloyds
//
//  Created by Manisha on 30/12/25.
//

import SwiftUI
import Combine

final class PermitTypeViewModel: ObservableObject {
    @Published var sections: [CampaignSection] = []
    @Published var showLoader = false
    @Published var errorMessage: String?
    @Published var functionalLocations: [FunctionalLocation] = []
    @Published var categories: [CategoryItem] = []
//    @Published var selectedStatus: String? = nil
//    @Published var selectedPartner: String? = nil
//    @Published var selectedPriority: String?
    @Published var successMessage: String?
    @Published var showSuccessAlert = false
    @Published var showErrorAlert = false
    @Published var shouldNavigateBack = false
    @Published var navigateToPermitType: Bool = false
    @Published var showValidationAlert: Bool = false
    var selectedCampaignType: String = ""
    
    
    
    private let baseUrl = "https://test.deltafour.co/api"
    
    init() {
        NotificationCenter.default.addObserver(
            forName: .unitSelected,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            
            guard let unit = notification.object as? String else { return }
            
            self?.mapLocationDropdown(for: unit)
        }
        
        NotificationCenter.default.addObserver(
            forName: .locationSelected,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            
            guard let location = notification.object as? String else { return }
            
            self?.mapSubAreaDropdown(for: location)
        }
        
        

        
        
        NotificationCenter.default.addObserver(
            forName: .categorySelected,
            object: nil,
            queue: .main
        ) { [weak self] notification in

            if let data = notification.object as? [String: Any],
               let value = data["value"] as? String,
               let sectionId = data["sectionId"] as? UUID {

                self?.mapSubCategory(for: value, sectionId: sectionId)
            }
        }
        
      
        
        NotificationCenter.default.addObserver(
            forName: .subCategorySelected,
            object: nil,
            queue: .main
        ) { [weak self] notification in

            if let data = notification.object as? [String: Any],
               let value = data["value"] as? String,
               let sectionId = data["sectionId"] as? UUID {

                self?.mapSubSubCategory(for: value, sectionId: sectionId)
            }
        }
        
        
//        NotificationCenter.default.addObserver(
//            forName: .statusSelected,
//            object: nil,
//            queue: .main
//        ) { [weak self] notification in
//            self?.selectedStatus = notification.object as? String
//            print("VM STATUS:", self?.selectedStatus ?? "nil")
//        }
//
//        NotificationCenter.default.addObserver(
//            forName: .businessPartnerSelected,
//            object: nil,
//            queue: .main
//        ) { [weak self] notification in
//            self?.selectedPartner = notification.object as? String
//        }
//
//        NotificationCenter.default.addObserver(
//            forName: .prioritySelected,
//            object: nil,
//            queue: .main
//        ) { notification in
//            self.selectedPriority = notification.object as? String
//        }


        
        
        
    }
    
    
    
    // MARK: - Fetch Permit Type Form
    func fetchPermitTypeForm(campaignType: String, fieldValues: [String: Any]) {  //
        
        self.selectedCampaignType = campaignType
        guard let url = URL(string: "\(baseUrl)/v1/workflow/newpermit/type") else { return }
        
        showLoader = true
        var request = URLRequest(url: url)
        request.httpMethod = "POST"  //
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Token add karo
        if let token = KeychainHelper.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        
        let body: [String: Any] = [
            "data": [
                "fieldValues": fieldValues
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            print("📤 Sending body:", body)
        } catch {
            print("❌ Body encoding error:", error)
            DispatchQueue.main.async {
                self.showLoader = false
                self.errorMessage = "Failed to encode request"
            }
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.showLoader = false
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                }
                return
            }
            
            guard let data = data else { return }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 ACTUAL API RESPONSE:")
                print(jsonString)
                print("📦 END OF RESPONSE")
            }
            
            do {
                let decoded = try JSONDecoder().decode(CampaignResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.sections = decoded.sections
                    self?.mapUnitDropdown()
                    self?.applyCategoryIfPossible()
                    
                   
                    
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                }
                print("❌ DECODING ERROR:", error)
            }
        }.resume()
    }
    
    
    
    let underscoreKeys: Set<String> = [
        "Final_Action_Taken",
        "Enter_Observation_Description",
        "Select_Priority",
        "Select_RCA",
        "Select_Categories",
        "Select_Sub_Category",
        "Select_Sub_Sub_Category",
        "Select_the_type_of_Observation",
        "Select_Business_Partner",
        "Enter_Business_Partner_name",
        "Propose_Suggest_Action_Plan",
        "Select_Status",
        "Enter_no_of_People_Interacted"
    ]
    
    func fetchFunctionalLocations() {
        guard let url = URL(string: "https://test.deltafour.co/api/v1/om/functional-location") else { return }

        showLoader = true

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = KeychainHelper.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async { self?.showLoader = false }

            guard let data = data else { return }

            // 🔥 RAW JSON PRINT
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 FUNCTIONAL LOCATION API RESPONSE:")
                print(jsonString)
                print("📦 END FUNCTIONAL LOCATION RESPONSE")
            }

            
            do {
                let decoded = try JSONDecoder().decode(FunctionalLocationResponse.self, from: data)
                
                
                print("✅ Functional Locations Count:", decoded.data.count)

                for item in decoded.data {
                    print("📍 ID:", item.id)
                    print("📍 Location:", item.location)
                    print("📍 Main Area:", item.mainArea)
                    print("📍 Sub Area:", item.subArea)
                    print("---------------")}
                
                DispatchQueue.main.async {
                    self?.functionalLocations = decoded.data
                    self?.mapUnitDropdown()
                }
            } catch {
                print("❌ Functional Location decode error:", error)
            }
        }.resume()
    }

    func mapUnitDropdown() {
        let unitOptions = Array(
            Set(functionalLocations.map { $0.location })
        ).sorted()

        for sectionIndex in sections.indices {
            for fieldIndex in sections[sectionIndex].fields.indices {

                if sections[sectionIndex].fields[fieldIndex].description == "Select_Unit" {
                    sections[sectionIndex].fields[fieldIndex].optionsAvailable = unitOptions
                }
            }
        }
    }

    
    func mapLocationDropdown(for unit: String) {

        let locations = functionalLocations
            .filter { $0.location == unit }
            .map { $0.mainArea }

        let uniqueLocations = Array(Set(locations)).sorted()

        for sectionIndex in sections.indices {
            for fieldIndex in sections[sectionIndex].fields.indices {

                if sections[sectionIndex].fields[fieldIndex].description == "Select_Location" {
                    sections[sectionIndex].fields[fieldIndex].optionsAvailable = uniqueLocations
                    sections[sectionIndex].fields[fieldIndex].selectedValue = nil
                }

                if sections[sectionIndex].fields[fieldIndex].description == "Select_Sub_Area" {
                    sections[sectionIndex].fields[fieldIndex].optionsAvailable = []
                    sections[sectionIndex].fields[fieldIndex].selectedValue = nil
                }
            }
        }
    }

    
    func mapSubAreaDropdown(for mainArea: String) {

        let subAreas = functionalLocations
            .filter { $0.mainArea == mainArea }
            .map { $0.subArea }

        let uniqueSubAreas = Array(Set(subAreas)).sorted()

        for sectionIndex in sections.indices {
            for fieldIndex in sections[sectionIndex].fields.indices {

                if sections[sectionIndex].fields[fieldIndex].description == "Select_Sub_Area" {
                    sections[sectionIndex].fields[fieldIndex].optionsAvailable = uniqueSubAreas
                    sections[sectionIndex].fields[fieldIndex].selectedValue = nil
                }
            }
        }
    }

    

    func fillLocationFields(using location: FunctionalLocation) {
        for sectionIndex in sections.indices {
            for fieldIndex in sections[sectionIndex].fields.indices {

                let desc = sections[sectionIndex].fields[fieldIndex].description

                if desc == "Select_Location" {
                    sections[sectionIndex].fields[fieldIndex].textValue = location.mainArea
                }

                if desc == "Select_Sub_Area" {
                    sections[sectionIndex].fields[fieldIndex].textValue = location.subArea
                }
            }
        }
    }

    
    
    
    // MARK: - Validation
    var isFormValid: Bool {
        for section in sections {
            for field in section.fields {
                if field.required == true {
                    if field.type == "DROPDOWN_SINGLE" && (field.selectedValue ?? "").isEmpty {
                        return false
                    }
                    if field.type == "TEXTBOX" && (field.textValue ?? "").isEmpty {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    // MARK: - Final Submit
    func submitFinalForm() {
        print("🚀 Final Form Submitted!")

        var payload: [String: Any] = [:]

        for section in sections {
            for field in section.fields {

                switch field.type {

                case "TEXTBOX", "OPTIONALTEXTBOX":
                    if let value = field.textValue {
                        payload[field.name] = value
                    }

                case "DROPDOWN_SINGLE":
                    if let value = field.selectedValue {
                        payload[field.name] = value
                    }

                case "TIME":
                    if let value = field.timeValue {
                        payload[field.name] = value
                    }

                case "DATETIME":
                    if let date = field.dateValue {
                        payload[field.name] = formatDateForAPI(date)
                    }

                case "IMAGE":
                    if let image = field.image,
                       let base64 = imageToBase64(image) {
                        payload[field.name] = base64   // 🔥 YAHI USE
                    }

                default:
                    break
                }
            }
        }

        print("📦 FINAL PAYLOAD:", payload)

       
    }

}



extension PermitTypeViewModel{
    
    func fetchCategories() {
        guard let url = URL(string: "\(baseUrl)/v1/om/category") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = KeychainHelper.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, _, _ in
            guard let data else { return }

            do {
                let decoded = try JSONDecoder().decode(CategoryResponse.self, from: data)

                DispatchQueue.main.async {
                    self?.categories = decoded.data

                    // 🔥 CRITICAL LINE
                    self?.applyCategoryIfPossible()
                }
            } catch {
                print("❌ Category decode error:", error)
            }
        }.resume()
    }

    
    func applyCategoryIfPossible() {
        guard !sections.isEmpty, !categories.isEmpty else {
            print("⏳ Sections or Categories not ready yet")
            return
        }

        print(" Applying Category Dropdown")
        mapCategoryDropdown()
    }

    

    func mapCategoryDropdown() {
        let options = Array(Set(categories.map { $0.categories })).sorted()

        print("🟢 Categories Options:", options)

        for s in sections.indices {
            for f in sections[s].fields.indices {

               
                print("🔍 FIELD DESCRIPTION:", sections[s].fields[f].description)

                if sections[s].fields[f].description == "Select_Categories" {
                    print("✅ MATCH FOUND → Select_Categories")

                    sections[s].fields[f].optionsAvailable = options
                }
            }
        }
    }

    

    func mapSubCategory(for category: String, sectionId: UUID) {

        let subs = categories
            .filter { $0.categories == category }
            .map { $0.subCategories }

        let unique = Array(Set(subs)).sorted()

        guard let sectionIndex = sections.firstIndex(where: { $0.id == sectionId }) else {
            return
        }

        for f in sections[sectionIndex].fields.indices {
            if sections[sectionIndex].fields[f].description == "Select_Sub_Category" {
                sections[sectionIndex].fields[f].optionsAvailable = unique
                sections[sectionIndex].fields[f].selectedValue = nil
            }
        }
    }
    
    

    
    func mapSubSubCategory(for subCategory: String, sectionId: UUID) {

        let subs = categories
            .filter { $0.subCategories == subCategory }
            .map { $0.subSubCategories }

        let unique = Array(Set(subs)).sorted()

        guard let sectionIndex = sections.firstIndex(where: { $0.id == sectionId }) else {
            return
        }

        for f in sections[sectionIndex].fields.indices {
            if sections[sectionIndex].fields[f].description == "Select_Sub_Sub_Category" {
                sections[sectionIndex].fields[f].optionsAvailable = unique
                sections[sectionIndex].fields[f].selectedValue = nil
            }
        }
    }

    
}


extension PermitTypeViewModel{
    
    func uploadBeforeImage(_ image: UIImage, completion: @escaping (String?) -> Void) {

        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            completion(nil)
            return
        }
        let fileName = "\(Int(Date().timeIntervalSince1970 * 1000)).jpg.png"
        let urlString = "\(baseUrl)/v1/amazon-s3/upload-image?fileName=\(fileName)"

        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        if let token = KeychainHelper.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data,
               let response = String(data: data, encoding: .utf8) {
                print("📤 Image Upload Response:", response)
                completion(response)
            } else {
                completion(nil)
            }
        }.resume()
    }

    
    
    func imageToBase64(_ image: UIImage) -> String? {
        image.jpegData(compressionQuality: 0.7)?
            .base64EncodedString()
    }

//    uploadAfterImage
    func uploadAfterImage(_ image: UIImage, completion: @escaping (String?) -> Void) {

        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            completion(nil)
            return
        }

        let fileName = "\(Date().timeIntervalSince1970)_before.jpg"
        let urlString = "\(baseUrl)/v1/amazon-s3/upload-image?fileName=\(fileName)"

        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        if let token = KeychainHelper.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data,
               let response = String(data: data, encoding: .utf8) {
                print("📤 Image Upload Response:", response)
                completion(response)
            } else {
                completion(nil)
            }
        }.resume()
    }

    
    
   
    
}


extension PermitTypeViewModel{
    
    func addObservation() {
        guard let observation = sections.first(where: { $0.title == "Observations" }) else { return }

        var newObservation = observation

        newObservation.fields = observation.fields.map { field in
            var copy = field
            copy.textValue = nil
            copy.selectedValue = nil
            copy.dateValue = nil
            return copy
        }

        let count = sections.filter { $0.title == "Observations" }.count + 1
        newObservation.displayTitle = "Observation \(count)"
        newObservation.id = UUID()
        newObservation.expanded = true

        sections.append(newObservation)
    }

    
    
}


extension PermitTypeViewModel {

    var observationCount: Int {
        sections.filter { $0.title == "Observations" }.count
    }

    func removeObservation(id: UUID) {
        guard observationCount > 1 else { return }

        sections.removeAll {
            $0.id == id && $0.title == "Observations"
        }
    }
}



extension PermitTypeViewModel{
    
    

    
    func submitPermit(fieldValues: [String: Any]) {

//        guard let url = URL(string: "https://imomtest.deltafour.co/api/v2/workflow/newpermit") else {
//            print("❌ Invalid URL")
//            return
//        }
        
        guard let url = URL(string: APIEndpoints.createPermit) else {
            print("❌ Invalid URL")
            return
        }
        

        showLoader = true

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = KeychainHelper.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let body: [String: Any] = [
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


        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])

            request.httpBody = jsonData

            // ✅ Pretty print JSON
            if let prettyData = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted),
               let prettyString = String(data: prettyData, encoding: .utf8) {
                print("📤 Sending JSON:\n\(prettyString)")
            }

        } catch {
            showLoader = false
            errorMessage = "Encoding error"
            return
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in

            DispatchQueue.main.async {
                self?.showLoader = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self?.errorMessage = "Invalid server response"
                }
                return
            }
            print(String(data: request.httpBody!, encoding: .utf8)!)

            print("📡 Status Code:", httpResponse.statusCode)

            guard let data = data else { return }

            let responseString = String(data: data, encoding: .utf8) ?? ""
            print("📦 API Response:", responseString)

            DispatchQueue.main.async {
                if httpResponse.statusCode == 200 {
                    self?.successMessage = "Campaign created successfully ✅"
                    self?.showSuccessAlert = true //  Success alert dikhao
                } else {
                    self?.errorMessage = "Server Error: \(httpResponse.statusCode)"
                    self?.showErrorAlert = true //  Failure alert dikhao
                }
            }
            
            print("🚨 FINAL JSON STRING:")
            if let data = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted),
               let json = String(data: data, encoding: .utf8) {
                print(json)
            }

        }.resume()
    }

    
    func getFieldValues() -> [String: Any] {
        var mainFields: [String: Any] = [:]
        var observationsArray: [[String: Any]] = []

        // ✅ Pehle se jo hain
        mainFields["Campaign TYPE"] = true
        mainFields["Create permit"] = true
        
        // ✅ FIX 1: Yeh 3 manually add karo - Android mein hain
        mainFields["General details"] = true
        mainFields["Observations"] = true
        // selectedCampaignType ViewPermitTypeView se pass hota hai
        mainFields["Select Type of Campaign"] = selectedCampaignType

        for section in sections {

            if section.title == "Observations" {
                var observationDict: [String: Any] = [:]

                for field in section.fields {
                    if isFieldHidden(field, in: section) { continue }

                    let rawKey = field.description ?? field.name
                    if rawKey == "this is description" { continue }

                    let normalizedKey = rawKey.replacingOccurrences(of: " ", with: "_")
                    let key: String
                    if underscoreKeys.contains(normalizedKey) {
                        key = normalizedKey
                    } else {
                        key = rawKey.replacingOccurrences(of: "_", with: " ")
                    }

                    if field.type == "IMAGE" {
                        if let imgName = field.selectedValue, !imgName.isEmpty {
                            // ✅ FIX 2: Array mein wrap karo
                            observationDict[key] = [imgName]
                        }
                    }
                    else if ["DATETIME", "DATE", "TIME"].contains(field.type) {
                        if let date = field.dateValue {
                            observationDict[key] = formatDateForAPI(date)
                        }
                    }
                    else {
                        let value = field.textValue ?? field.selectedValue ?? ""
                        if !value.isEmpty {
                            observationDict[key] = value
                        }
                    }
                }

                observationsArray.append(observationDict)

            } else {
                for field in section.fields {
                    if isFieldHidden(field, in: section) { continue }

                    let rawKey = field.description ?? field.name
                    let normalizedKey = rawKey.replacingOccurrences(of: " ", with: "_")
                    
                    // ✅ FIX 3: Main fields mein bhi underscore logic
                    let key: String
                    if underscoreKeys.contains(normalizedKey) {
                        key = normalizedKey
                    } else {
                        key = rawKey.replacingOccurrences(of: "_", with: " ")
                    }

                    if field.type == "IMAGE" {
                        if let imgName = field.selectedValue, !imgName.isEmpty {
                            mainFields[key] = [imgName]  // Array
                        }
                    }
                    else if ["DATETIME", "DATE", "TIME"].contains(field.type) {
                        if let date = field.dateValue {
                            mainFields[key] = formatDateForAPI(date)
                        }
                    }
                    else {
                        let value = field.textValue ?? field.selectedValue ?? ""
                        if !value.isEmpty {
                            mainFields[key] = value
                        }
                    }
                }
            }
        }

        mainFields["observations"] = observationsArray
        return mainFields
    }
    
  
    // Helper function to handle types consistently
    private func getValue(for field: CampaignField) -> Any? {
        switch field.type {
        case "TEXTBOX", "OPTIONALTEXTBOX":
            return field.textValue ?? ""
        case "DROPDOWN_SINGLE":
            return field.selectedValue ?? ""
        case "DATETIME":
            return field.dateValue != nil ? formatDateForAPI(field.dateValue!) : ""
        case "IMAGE":
            // API expects an array of strings [ "filename.jpg" ]
            if let value = field.selectedValue { return [value] }
            return []
        default:
            return nil
        }
    }
    
    private func formatDateForAPI(_ date: Date) -> String {
        let formatter = DateFormatter()
      //  formatter.dateFormat = "HH:mm dd-MMM-yyyy" // e.g., "12:09 07-Jan-2026"
        formatter.dateFormat = "HH:mm dd-MMM-yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }
    
    
    
    func validateVisibleFields() -> Bool {

        for section in sections {
            for field in section.fields {

                
                
               
                if isFieldHidden(field, in: section) {
                    continue
                }

                
                let fieldName = field.name.lowercased()
                           let fieldDesc = (field.description ?? "").lowercased()

                           // ✅ IMAGE fields - name ya description se check karo
                           let isBeforeImage = fieldName.contains("upload before") ||
                                               fieldDesc.contains("upload_before") ||
                                               fieldDesc.contains("upload before")
                                               
                           let isAfterImage = fieldName.contains("upload after") ||
                                              fieldDesc.contains("upload_after") ||
                                              fieldDesc.contains("upload after")

                           if isBeforeImage {
                               if (field.selectedValue ?? "").isEmpty {
                                   errorMessage = "Upload Before Image is required"
                                   print("❌ Before Image missing in section: \(section.title)")
                                   return false
                               }
                           }

                           if isAfterImage {
                               if (field.selectedValue ?? "").isEmpty {
                                   errorMessage = "Upload After Image is required"
                                   print("❌ After Image missing in section: \(section.title)")
                                   return false
                               }
                           }
                
                // 🔹 Required validation
                if field.required == true {

                    switch field.type {

                    case "DROPDOWN_SINGLE":
                        if (field.selectedValue ?? "").isEmpty {
                            errorMessage = "\(field.name) is required"
                            return false
                        }

                    case "TEXTBOX", "OPTIONALTEXTBOX":
                        if (field.textValue ?? "").isEmpty {
                            errorMessage = "\(field.name) is required"
                            return false
                        }

                    case "TIME":
                        if field.dateValue == nil {
                            errorMessage = "\(field.name) is required"
                            return false
                        }
                        
                    case "IMAGE":
                                       if (field.selectedValue ?? "").isEmpty {
                                           errorMessage = "\(field.name) is required"
                                           return false
                                       }

                    default:
                        break
                    }
                }
            }
        }

        return true
    }


    
    func isFieldHidden(_ field: CampaignField, in section: CampaignSection) -> Bool {

        let priority = section.fields.first(where: {
            $0.description == "Select_Priority"
        })?.selectedValue

        let status = section.fields.first(where: {
            $0.description == "Select_Status"
        })?.selectedValue

        let partner = section.fields.first(where: {
            $0.description == "Select_Business_Partner"
        })?.selectedValue


        switch field.description {

        case "Select_RCA":
            return priority != "P1"

        case "Upload_After_Image",
             "Final_Action_Taken":
            return status != "Close"

        case "Enter_Business_Partner_name":
            return partner != "2.External"

        default:
            return false
        }
    }

    

   }



