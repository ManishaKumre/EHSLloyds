//
//  CreateCampaignViewModel.swift
//  Lloyds
//
//  Created by Manisha on 28/12/25.
//


extension Notification.Name {
    static let unitSelected = Notification.Name("unitSelected")
    static let locationSelected = Notification.Name("locationSelected")
    
    static let categorySelected = Notification.Name("categorySelected")
    static let subCategorySelected = Notification.Name("subCategorySelected")
    
    
    static let statusSelected = Notification.Name("statusSelected")
        static let businessPartnerSelected = Notification.Name("businessPartnerSelected")
    static let prioritySelected = Notification.Name("prioritySelected")
    
}




import SwiftUI
import Combine

final class CreateCampaignViewModel: ObservableObject {
    @Published var sections: [CampaignSection] = []
    @Published var showLoader = false
    @Published var errorMessage: String?
    
    @Published var navigateToPermitType = false
       @Published var selectedCampaignType = ""
    
    @Published var collectedFieldValues: [String: Any] = [:]
    
    private let baseUrl = "https://test.deltafour.co/api"
    
    // MARK: - API CALL
    func fetchCampaignData() {
        guard let url = URL(string: "\(baseUrl)/v1/workflow/newpermit") else { return }
        
        showLoader = true
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        if let token = KeychainHelper.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔐 Token added to request")
        } else {
            print("⚠️ No token found!")
            DispatchQueue.main.async {
                self.errorMessage = "Please login first"
                self.showLoader = false
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

                // 🔥 ONLY Campaign TYPE section
                let campaignTypeSection = decoded.sections.filter {
                    $0.title == "Campaign TYPE"
                }

                DispatchQueue.main.async {
                    self?.sections = campaignTypeSection
                }

            } catch {
                print("❌ DECODING ERROR:", error)
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                }
            }

        }.resume()
    }
    
    
    // MARK: - Validation
    var isFormValid: Bool {
        for section in sections {
            for field in section.fields {
                if field.required == true {
                    if field.type == "DROPDOWN_SINGLE" && (field.selectedValue ?? "").isEmpty {
                        return false
                    }
                    if (field.textValue ?? "").isEmpty && (field.type == "TEXTBOX" || field.type == "OPTIONALTEXTBOX") {
                        return false
                    }
                }
            }
        }
        return true
    }
    
 

    
    func submitCampaign() {
        print("Form Submitted!")
        
       
        var fieldValues: [String: Any] = [:]
        
        for section in sections {
            for field in section.fields {
                switch field.type {
                case "DROPDOWN_SINGLE":
                    if let value = field.selectedValue, !value.isEmpty {
                        fieldValues[field.name] = value
                    }
                case "TEXTBOX", "OPTIONALTEXTBOX":
                    if let value = field.textValue, !value.isEmpty {
                        fieldValues[field.name] = value
                    }
                case "TIME":
                    if let value = field.timeValue {
                        fieldValues[field.name] = value
                    }
                case "BUTTON":
                    fieldValues[field.name] = true
                default:
                    break
                }
            }
        }
        
       
        collectedFieldValues = fieldValues
        selectedCampaignType = fieldValues["Select Type of Campaign"] as? String ?? ""
        
        print("📤 Collected Field Values:", fieldValues)
        
       
        navigateToPermitType = true
    }
    
    
}

