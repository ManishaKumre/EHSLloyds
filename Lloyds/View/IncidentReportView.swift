//
//  Untitled.swift
//  Lloyds
//
//  Created by Manisha on 21/02/26.
//

//import SwiftUI
//
//struct IncidentReportView: View {
//    
//    @State private var selectedPart = "Select Part"
//    @State private var selectedSubPart = "Select Sub Part"
//    @State private var selectedCategory = "Select Category"
//    @State private var selectedInjuryType = "Select Injury Type"
//    
//    @State private var extraRemarkEnabled = true
//    @State private var extraRemarkText = ""
//    
//    // MARK: - Data
//    
//    let subPartsOfParts: [String: [String]] = [
//        "Head": ["Skull", "Face", "Jaw", "Scalp"],
//        "Neck": ["Front Neck", "Back Neck", "Throat"],
//        "Chest": ["Upper Chest", "Sternum", "Ribs"]
//    ]
//    
//    let injuryCategories: [String: [String]] = [
//        "Physical Injuries": [
//            "Cut / Laceration",
//            "Abrasion / Scratch",
//            "Bruise / Contusion"
//        ],
//        "Burn & Exposure Injuries": [
//            "Thermal Burn",
//            "Chemical Burn",
//            "Electrical Burn"
//        ]
//    ]
//    
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 20) {
//                
//                VStack(alignment: .leading, spacing: 15) {
//                    
//                    Text("Incident Injury Details")
//                        .font(.headline)
//                    
//                    // PART DROPDOWN
//                    dropdown(
//                        title: $selectedPart,
//                        options: Array(subPartsOfParts.keys)
//                    ) {
//                        selectedSubPart = "Select Sub Part"
//                    }
//                    
//                    // SUB PART DROPDOWN
//                    dropdown(
//                        title: $selectedSubPart,
//                        options: subPartsOfParts[selectedPart] ?? []
//                    )
//                    
//                    // CATEGORY DROPDOWN
//                    dropdown(
//                        title: $selectedCategory,
//                        options: Array(injuryCategories.keys)
//                    ) {
//                        selectedInjuryType = "Select Injury Type"
//                    }
//                    
//                    // INJURY TYPE DROPDOWN
//                    dropdown(
//                        title: $selectedInjuryType,
//                        options: injuryCategories[selectedCategory] ?? []
//                    )
//                }
//                .padding()
//                .background(Color(.systemGray6))
//                .cornerRadius(15)
//                
//                // Extra Remark Section
//                VStack(alignment: .leading, spacing: 10) {
//                    
//                    Toggle("Extra Remark", isOn: $extraRemarkEnabled)
//                    
//                    if extraRemarkEnabled {
//                        TextField("Extra Remark", text: $extraRemarkText)
//                            .padding()
//                            .background(Color.white)
//                            .cornerRadius(8)
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 8)
//                                    .stroke(Color.blue)
//                            )
//                    }
//                }
//                
//                // Submit Button
//                Button {
//                    
//                    // Simple validation
//                    if selectedPart.contains("Select") ||
//                        selectedSubPart.contains("Select") ||
//                        selectedCategory.contains("Select") ||
//                        selectedInjuryType.contains("Select") {
//                        
//                        print("⚠️ Please select all fields")
//                        return
//                    }
//                    
//                    print("Part:", selectedPart)
//                    print("SubPart:", selectedSubPart)
//                    print("Category:", selectedCategory)
//                    print("Injury:", selectedInjuryType)
//                    print("Remark:", extraRemarkText)
//                    
//                } label: {
//                    Text("SUBMIT")
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.blue)
//                        .cornerRadius(25)
//                }
//            }
//            .padding()
//        }
//        .navigationTitle("Action on Incident Report")
//    }
//}
//
////MARK: - Reusable Dropdown
//
//@ViewBuilder
//func dropdown(
//    title: Binding<String>,
//    options: [String],
//    onSelectReset: (() -> Void)? = nil
//) -> some View {
//    
//    Menu {
//        ForEach(options, id: \.self) { option in
//            Button(option) {
//                title.wrappedValue = option
//                onSelectReset?()
//            }
//        }
//    } label: {
//        HStack {
//            Text(title.wrappedValue)
//                .foregroundColor(
//                    title.wrappedValue.contains("Select") ? .gray : .black
//                )
//            Spacer()
//            Image(systemName: "chevron.down")
//                .foregroundColor(.gray)
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(10)
//        .overlay(
//            RoundedRectangle(cornerRadius: 10)
//                .stroke(Color.gray.opacity(0.5))
//        )
//    }
//}
//


import SwiftUI

struct IncidentReportView: View {
    
    @State private var selectedPart = "Select Part"
    @State private var selectedSubPart = "Select Sub Part"
    @State private var selectedCategory = "Select Category"
    @State private var selectedInjuryType = "Select Injury Type"
    
    @State private var extraRemarkEnabled = true
    @State private var extraRemarkText = ""
    
    // API Calling state (Optional but recommended)
    @State private var isSubmitting = false
    
    // MARK: - Data
    let subPartsOfParts: [String: [String]] = [
        "Head": ["Skull", "Face", "Jaw", "Scalp"],
        "Neck": ["Front Neck", "Back Neck", "Throat"],
        "Chest": ["Upper Chest", "Sternum", "Ribs"]
    ]
    
    let injuryCategories: [String: [String]] = [
        "Physical Injuries": ["Cut / Laceration", "Abrasion / Scratch", "Bruise / Contusion"],
        "Burn & Exposure Injuries": ["Thermal Burn", "Chemical Burn", "Electrical Burn"]
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Incident Injury Details")
                        .font(.headline)
                    
                    dropdown(title: $selectedPart, options: Array(subPartsOfParts.keys)) {
                        selectedSubPart = "Select Sub Part"
                    }
                    
                    dropdown(title: $selectedSubPart, options: subPartsOfParts[selectedPart] ?? [])
                    
                    dropdown(title: $selectedCategory, options: Array(injuryCategories.keys)) {
                        selectedInjuryType = "Select Injury Type"
                    }
                    
                    dropdown(title: $selectedInjuryType, options: injuryCategories[selectedCategory] ?? [])
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
                
                VStack(alignment: .leading, spacing: 10) {
                    Toggle("Extra Remark", isOn: $extraRemarkEnabled)
                    
                    if extraRemarkEnabled {
                        TextField("Extra Remark", text: $extraRemarkText)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.blue))
                    }
                }
                
                // Submit Button logic
                Button {
                    if validateFields() {
                        submitIncidentReport()
                    }
                } label: {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("SUBMIT")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(validateFields() ? Color.blue : Color.gray)
                .cornerRadius(25)
                .disabled(isSubmitting) // API call ke waqt button disable
            }
            .padding()
        }
        .navigationTitle("Action on Incident Report")
    }
    
    // MARK: - Validation
    func validateFields() -> Bool {
        return !selectedPart.contains("Select") &&
               !selectedSubPart.contains("Select") &&
               !selectedCategory.contains("Select") &&
               !selectedInjuryType.contains("Select")
    }
    
    // MARK: - API Call (PUT Request)
    func submitIncidentReport() {
        // 1. URL Setup
        guard let url = URL(string: "https://your-api-endpoint.com/api/incident/update") else {
            print("❌ Invalid URL")
            return
        }
        
        isSubmitting = true
        
        // 2. Body Taiyar Karna
        let bodyData: [String: Any] = [
            "part": selectedPart,
            "sub_part": selectedSubPart,
            "category": selectedCategory,
            "injury_type": selectedInjuryType,
            "extra_remark": extraRemarkEnabled ? extraRemarkText : ""
        ]
        
        // 3. Request Configure Karna
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add Auth Token if needed
        // request.setValue("Bearer YOUR_TOKEN", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: bodyData)
        } catch {
            print("❌ Error serializing JSON: \(error)")
            isSubmitting = false
            return
        }
        
        // 4. API Call Execute Karna
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isSubmitting = false
                
                if let error = error {
                    print("❌ API Error: \(error.localizedDescription)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if (200...299).contains(httpResponse.statusCode) {
                        print("✅ Success! Status Code: \(httpResponse.statusCode)")
                        // Yahan aap Success Alert dikha sakte hain
                    } else {
                        print("⚠️ Server returned status: \(httpResponse.statusCode)")
                    }
                }
            }
        }.resume()
    }
}

// MARK: - Helper View
@ViewBuilder
func dropdown(title: Binding<String>, options: [String], onSelectReset: (() -> Void)? = nil) -> some View {
    Menu {
        ForEach(options, id: \.self) { option in
            Button(option) {
                title.wrappedValue = option
                onSelectReset?()
            }
        }
    } label: {
        HStack {
            Text(title.wrappedValue)
                .foregroundColor(title.wrappedValue.contains("Select") ? .gray : .primary)
            Spacer()
            Image(systemName: "chevron.down").foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))
    }
}
