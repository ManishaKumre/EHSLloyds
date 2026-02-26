//
//  ActionOnObservationView.swift
//  Lloyds
//
//  Created by Manisha on 27/01/26.
//


import SwiftUI

struct ActionOnObservationView: View {

    let observation: Observation
    let statusList: [String]

    @EnvironmentObject var viewModel: ViewPermitViewModel

    @State private var selectedStatus: String = ""
    @State private var targetDate = Date()

    @State private var showImagePicker = false
    @State private var imageSource: UIImagePickerController.SourceType = .photoLibrary

    @State private var uploadingField: ActionField?
    @State private var showUploadAlert = false
    @State private var uploadMessage = ""
    @Environment(\.dismiss) var dismiss
    @State private var selectedExecutorId: Int?
    @Binding var isPresented: Bool
    

//    var userRole: String {
//        viewModel.permitDetail?.data?.permitState?.userType ?? ""
//    }
    
    @State private var showValidationAlert = false
    @State private var validationMessage = ""
    
    
    var userRole: String {

        if observation.isActionToBeTakenByAO == true {
            return "AO"
        }

        if observation.isActionToBeTakenByE == true {
            return "EXECUTOR"
        }

        if observation.isActionToBeTakenByO == true {
            return "OWNER"
        }

        return ""
    }
    

    let statusFieldMap: [String: [String]] = [
        "Open": [
            "Enter_Area_Owner_Action",
            "Select_Executor",
            "Select_Target_Date"
        ],
        "Close": [
           // "Enter_Area_Owner_Action",
            "Final_Action_Taken",
            "Upload_After_Image",
          //  "Select_Target_Date"
        ],
        "Partially Close": [
            "Select_Priority",
            "Enter_Feedback_or_Temporary_Control_Taken",
            //"Select_Target_Date"
        ],
        "Reject": [
            "Reject_Remarks",
          //  "Select_Target_Date"
        ]
    ]

    
    let executorStatusFieldMap: [String: [String]] = [

        "Open": [
            "Upload_After_Image",
            "Final_Action_Taken"
        ],

        "Close": [
            "Reject_Remarks",
            "Upload_After_Image",
            "Final_Action_Taken"
        ]
    ]

    
    
    
    
    // MARK: - FILTERED FIELDS


    var filteredFields: [ActionField] {

        // EXECUTOR ROLE
        if userRole.uppercased() == "EXECUTOR" {

            guard let allowedFields = executorStatusFieldMap[selectedStatus] else {
                return []
            }

            return viewModel.actionFields.filter { field in
                allowedFields.contains(field.description ?? "")
            }
        }

        // OTHER ROLES
        guard let allowedFields = statusFieldMap[selectedStatus] else {
            return []
        }

        return viewModel.actionFields.filter { field in
            allowedFields.contains(field.description ?? "")
        }
    }

    var filteredStatusList: [String] {

        if userRole.uppercased() == "EXECUTOR" {
            return ["Open", "Close"]
        }

        return statusList
    }


    // MARK: - BODY

    var body: some View {

        ScrollView {

            LazyVStack(spacing: 20) {

                // HEADER
                HStack {
                    Text("Action on Observation")
                        .font(.headline)
                    Spacer()
                }

                // STATUS DROPDOWN
                Menu {
                  //  ForEach(statusList, id: \.self) { status in
                        ForEach(filteredStatusList, id: \.self) { status in

                        Button(status) {
                            selectedStatus = status
                            print("🟣 Selected status:", status)
                        }
                    }
                } label: {
                    dropdownLabel(
                        title: "Select Status",
                        value: selectedStatus.isEmpty ? nil : selectedStatus
                    )
                }

                // DYNAMIC FIELDS
                ForEach(filteredFields) { field in
                    renderField(field)
                }

                // SUBMIT BUTTON
                Button {
                   // submitAction()
                    validateAndSubmit()
                } label: {
                    Text("SUBMIT")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(24)
                }

            }
            .padding()
        }
        
        .alert("Validation Error", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(validationMessage)
        }

        .onAppear {
            
            
            print("""
                🔍 DEBUG ACTION SCREEN
                UserRole: \(userRole)

                AO: \(observation.isActionToBeTakenByAO ?? false)
                E: \(observation.isActionToBeTakenByE ?? false)
                O: \(observation.isActionToBeTakenByO ?? false)
                🔍 END
                """)

            print("🟢 Available status:", statusList)
            print("🟢 Action fields:", viewModel.actionFields.count)

            if let permitId = viewModel.permitId {
                print("🟢 permitId:", permitId)
            }
            
            
            
            if selectedStatus.isEmpty {
                selectedStatus = filteredStatusList.first ?? ""
            }

        }

        .onChange(of: selectedStatus) { newValue in

            print("🟢 Status changed:", newValue)

            if newValue == "Open" {
                viewModel.fetchExecutors()
            }

            print("🟢 Filtered fields:",
                  filteredFields.map { $0.description ?? "" })
        }

        .sheet(isPresented: $showImagePicker) {

            ImagePicker(sourceType: imageSource) { image in

                guard let field = uploadingField else { return }

                viewModel.uploadAfterImage(image: image) { response in

                    DispatchQueue.main.async {

                        if let response {

//
                            let fileName = extractFileName(from: response)

                            // ❌ STOP if invalid
                            guard !fileName.isEmpty else {
                                print("❌ Invalid filename from upload")
                                return
                            }

                            let existingImages = field.textValue?
                                .split(separator: ",")
                                .map { String($0) } ?? []

                            let updatedImages = existingImages + [fileName]

                            updateField(
                                field,
                                value: updatedImages.joined(separator: ",")
                            )

                            uploadMessage = "Image uploaded successfully"
                            showUploadAlert = true
                        }
                    }
                }
            }
        }

        .alert("Success", isPresented: $showUploadAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(uploadMessage)
        }

        .alert("Success", isPresented: $viewModel.showSuccessAlert) {

            Button("OK") {
          
                
//
                viewModel.shouldCloseObservationPopup = true
         
                dismiss()
                
               
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    
                    if isPresented {
                        isPresented = false
                    }
                    
                    if self.selectedStatus == "Close" {
                        viewModel.actionWasClose = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        viewModel.navigateToPermitType = true
                    }
                }
                

                }
                         

        } message: {

            Text(viewModel.successMessage ?? "Action submitted successfully")

        }

        .alert("Error", isPresented: $viewModel.showErrorAlert) {

            Button("OK", role: .cancel) { }

        } message: {

            Text(viewModel.errorMessage ?? "Action failed")

        }
        
        
        
    }

    // MARK: - FIELD RENDERER

    @ViewBuilder
    func renderField(_ field: ActionField) -> some View {

        VStack(alignment: .leading, spacing: 8) {

            HStack(spacing: 2) {

                Text(field.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                if isRequiredField(field) {
                    Text("*")
                        .foregroundColor(.red)
                }
            }

            switch field.type {

            case "TEXTBOX":

                TextField(
                    "Enter here",
                    text: Binding(
                        get: { field.textValue ?? "" },
                        set: { updateField(field, value: $0) }
                    )
                )
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)

            case "DROPDOWN_SINGLE":

                Menu {

                    ForEach(field.optionsAvailable ?? [], id: \.self) { option in

                        Button(option) {
                            updateField(field, value: option)
                        }
                    }

                } label: {

                    HStack {

                        Text(field.textValue ?? "Select")
                            .foregroundColor(
                                field.textValue == nil ? .gray : .black
                            )

                        Spacer()

                        Image(systemName: "chevron.down")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }

            case "DROPDOWN_MULTI_FILTER":

                if field.description == "Select_Executor" {

                    Menu {

                        ForEach(viewModel.executorUsers, id: \.id) { user in

                            Button(user.displayName) {

                                updateField(field, value: user.displayName)

                                selectedExecutorId = user.id
                            }
                        }

                    } label: {

                        HStack {

                            Text(field.textValue ?? "Select Executor")
                                .foregroundColor(
                                    field.textValue == nil ? .gray : .black
                                )

                            Spacer()

                            Image(systemName: "chevron.down")
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }

                } else {

                    Menu {

                        ForEach(field.optionsAvailable ?? [], id: \.self) { option in

                            Button(option) {
                                updateField(field, value: option)
                            }
                        }

                    } label: {

                        HStack {

                            Text(field.textValue ?? "Select")

                            Spacer()

                            Image(systemName: "chevron.down")
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }

//
                
            case "TIME":

                VStack(alignment: .leading, spacing: 6) {

                    // ✅ Selected Date Label
                    Text(field.textValue ?? "Select date")
                        .foregroundColor(field.textValue == nil ? .gray : .black)

                    DatePicker(
                        "",
                        selection: Binding(
                            get: { targetDate },
                            set: { newValue in
                                targetDate = newValue

                                let formatter = DateFormatter()
                                formatter.dateFormat = "HH:mm dd-MMM-yyyy"

                                let formatted = formatter.string(from: newValue)

                                // 🔥 IMPORTANT: update field value
                                updateField(field, value: formatted)
                            }
                        ),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                

            case "BUTTON":

                if field.description == "Upload_After_Image"{
                 //  selectedStatus == "Close" {

                    VStack(alignment: .leading, spacing: 6) {

                        Button(field.name) {

                            uploadingField = field
                            imageSource = .photoLibrary
                            showImagePicker = true
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)

                        if let fileName = field.textValue,
                           !fileName.isEmpty {

                            HStack(spacing: 6) {

                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)

                                Text(fileName)
                                    .font(.caption)
                                    .foregroundColor(.green)
                                    .lineLimit(1)
                            }
                        }
                    }
                }

            default:
                EmptyView()
            }
        }
    }

    // MARK: - HELPERS

    func updateField(_ field: ActionField, value: String) {

        if let index = viewModel.actionFields.firstIndex(
            where: { $0.id == field.id }
        ) {

            viewModel.actionFields[index].textValue = value
        }
    }

    func dropdownLabel(title: String, value: String?) -> some View {

        HStack {

            Text(value ?? title)
                .foregroundColor(value == nil ? .gray : .black)

            Spacer()

            Image(systemName: "chevron.down")
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.4))
        )
    }

    func validateAndSubmit() {

        if selectedStatus.isEmpty {
            validationMessage = "Please select status"
            showValidationAlert = true
            return
        }

        for field in filteredFields {

            if isRequiredField(field) {

                let value = field.textValue ?? ""

                // ✅ DATE FIX
                if field.description == "Select_Target_Date" {

                    if value.isEmpty {
                        validationMessage = "Please select date"
                        showValidationAlert = true
                        return
                    }

                }
                // ✅ IMAGE FIX
                else if field.description == "Upload_After_Image" {

                    let images = value
                        .split(separator: ",")
                        .map { String($0) }
                        .filter { !$0.isEmpty }

                    if images.isEmpty {
                        validationMessage = "Please upload image"
                        showValidationAlert = true
                        return
                    }

                }
                // ✅ NORMAL FIELDS
                else {

                    if value.trimmingCharacters(in: .whitespaces).isEmpty {
                        validationMessage = "Please fill \(field.name)"
                        showValidationAlert = true
                        return
                    }
                }
            }
        }

        submitAction()
    }
    
    
    
    func submitAction() {

        print("🚀 SUBMIT ACTION")
        print("Status:", selectedStatus)

        for field in filteredFields {
            print("➡️ \(field.description ?? "") = \(field.textValue ?? "")")
        }

        let body = buildRequestBody()

        print("📤 FINAL BODY:", body)

        viewModel.submitObservationAction(body: body) { success in

            if success {

                print("✅ ACTION SUBMITTED SUCCESSFULLY")
                print("🚀 DEBUG 1: Notification Post Ho Rahi Hai!")
               
            } else {

                print("❌ ACTION FAILED")
            }
        }
      
    }


    func isRequiredField(_ field: ActionField) -> Bool {

        return [
            "Enter_Area_Owner_Action",
            "Select_Executor",
            "Select_Target_Date",
            "Final_Action_Taken",
            "Reject_Remarks",
            "Enter_Feedback_or_Temporary_Control_Taken",
            "Select_Priority",
            "Upload_After_Image"
        ].contains(field.description ?? "")
    }


    
    func buildObservationPayload() -> [String: Any] {

        var payload: [String: Any] = [:]

        payload["Action"] = true
        payload["Select_Status"] = selectedStatus
        payload["uuid"] = observation.uuid

        for field in filteredFields {

            if let key = field.description,
               let value = field.textValue,
               !value.isEmpty {

               
                    
                
                if key == "Upload_After_Image" {
                    
                    let imagesArray = value
                        .split(separator: ",")
                        .map { String($0) }
                        .filter { !$0.isEmpty && $0 != "Image Uploaded" } // ✅ FIX
                    
                    payload["Upload After Image"] = imagesArray
                    
                } else if key == "Select_Executor" {
                    
                    payload[key] = [selectedExecutorId ?? 0]
                    
                } else {
                    
                    payload[key] = value
                }
                
                
            }
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm dd-MMM-yyyy"

        // FIX FIELD NAME
      //  payload["Select_Target_Date"] = formatter.string(from: targetDate)
        
        if filteredFields.contains(where: { $0.description == "Select_Target_Date" }) {
            payload["Select_Target_Date"] = formatter.string(from: targetDate)
        }
        print("Observation Payload:", payload)

        return payload
    }
    

    func buildRequestBody() -> [String: Any] {

        return [

            "data": [
                "fieldValues": [
                    "observations": [
                        buildObservationPayload()
                    ]
                ],
                "permitState": [
                    "buttonAction": "Take Action"
                ]
            ],

            "id": viewModel.permitId ?? 0
        ]
    }

    
    
    func extractFileName(from response: String) -> String {
        
        // ✅ Parse JSON response
        if let data = response.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let fileName = json["data"] as? String {
            
            return fileName   // ✅ CORRECT filename
        }
        
        return ""
    }
}




extension Notification.Name {
    static let didUpdateObservation = Notification.Name("didUpdateObservation")
}
