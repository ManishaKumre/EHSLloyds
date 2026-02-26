//
//  Untitled.swift
//  Lloyds
//
//  Created by Manisha on 06/01/26.
//



import SwiftUI

struct DynamicFieldView: View {

    // MARK: - Bindings
    @Binding var field: CampaignField
    @Binding var campaignStartDate: Date?

    // MARK: - State
    @State private var showDatePicker = false
    @State private var tempDate = Date()

    @State private var showImagePicker = false
    @State private var imageSource: UIImagePickerController.SourceType = .photoLibrary
    
    @State private var showUploadSuccessAlert = false
    @State private var uploadMessage = ""

    let sectionId: UUID

    // MARK: - Environment
    @EnvironmentObject var vm: PermitTypeViewModel

    // MARK: - Body
    var body: some View {

        Group {
            switch field.type {

            // MARK: - TEXT / OPTIONAL TEXT
            case "TEXTBOX", "OPTIONALTEXTBOX":

                if shouldShowTextField {
                    TextField(field.name, text: Binding(
                        get: { field.textValue ?? "" },
                        set: { field.textValue = $0 }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                }

            // MARK: - DROPDOWN
            case "DROPDOWN_SINGLE":

//                if field.description == "Select_RCA",
//                   vm.selectedPriority != "P1" {
//                    EmptyView()
//                } else {
//                    dropdownView
//                }
                if field.description == "Select_RCA",
                   value(for: "Select_Priority") != "P1" {
                    EmptyView()
                } else {
                    dropdownView
                }

//            // MARK: - IMAGE
//            case "IMAGE":
//
//                if field.description == "Upload_After_Image" {
////                    if vm.selectedStatus == "Close" {
////                        ImageFieldView(field: $field)
////                    }
//                    if value(for: "Select_Status") == "Close" {
//                        ImageFieldView(field: $field)
//                    }
//                } else {
//                    ImageFieldView(field: $field)
//                }
                // MARK: - IMAGE
                case "IMAGE":

                    if field.description == "Upload_After_Image" {
                        if value(for: "Select_Status") == "Close" {
                            
                            // ✅ VStack mein wrap karo
                            VStack(alignment: .leading, spacing: 6) {
                                ImageFieldView(field: $field)
                                
                                // ✅ Filename niche dikhao
                                if let fileName = field.selectedValue, !fileName.isEmpty {
                                    HStack(spacing: 6) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.caption)
                                        Text(fileName)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .lineLimit(1)
                                            .truncationMode(.middle)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(6)
                                }
                            }
                        }
                    } else {
                        
                        // ✅ VStack mein wrap karo
                        VStack(alignment: .leading, spacing: 6) {
                            ImageFieldView(field: $field)
                            
                            // ✅ Filename niche dikhao
                            if let fileName = field.selectedValue, !fileName.isEmpty {
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.caption)
                                    Text(fileName)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(6)
                            }
                        }
                    }
                
                
                // MARK: - BUTTON
                case "BUTTON":

                    if field.description == "Upload_After_Image" {
                        if value(for: "Select_Status") == "Close" {
                            // ✅ VStack mein wrap karo
                            VStack(alignment: .leading, spacing: 6) {
                                imageButton
                                
                                // ✅ Filename niche dikhao
                                if let fileName = field.selectedValue, !fileName.isEmpty {
                                    HStack(spacing: 6) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.caption)
                                        Text(fileName)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .lineLimit(1)
                                            .truncationMode(.middle)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(6)
                                }
                            }
                        }
                    } else {
                        // ✅ Upload Before Image - hamesha dikhao
                        VStack(alignment: .leading, spacing: 6) {
                            imageButton
                            
                            // ✅ Filename niche dikhao
                            if let fileName = field.selectedValue, !fileName.isEmpty {
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.caption)
                                    Text(fileName)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(6)
                            }
                        }
                    }

//            // MARK: - BUTTON
//            case "BUTTON":
//
//                if field.description == "Upload_After_Image" {
////                    if vm.selectedStatus == "Close" {
////                        imageButton
////                    }
//                    if value(for: "Select_Status") == "Close" {
//                        imageButton
//                    }
//                } else {
//                    imageButton
//                }

            // MARK: - TIME
            case "TIME":
                timePickerView

            default:
                EmptyView()
            }
        }

        // MARK: - Image Picker Sheet
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: imageSource) { image in

                if field.description == "Upload_Before_Image" {

                    vm.uploadBeforeImage(image) { response in
                        DispatchQueue.main.async {
                            if let response {
                                let fileName = extractFileName(from: response)
                                                    DispatchQueue.main.async {
                                                        // Dono update karein
                                                        self.field.selectedValue = fileName
                                                        self.field.textValue = fileName
                                                        
                                                        uploadMessage = "Before image uploaded: \(fileName)"
                                                        showUploadSuccessAlert = true
                                                        print("✅ Field updated with filename: \(fileName)")
                                                    }
                            }
                            
                        }
                        
                    }


                } else if field.description == "Upload_After_Image" {

                    vm.uploadAfterImage(image) { response in
                        DispatchQueue.main.async {
                            if let response {
                                let fileName = extractFileName(from: response)
                                                    DispatchQueue.main.async {
                                                        // Dono update karein
                                                        self.field.selectedValue = fileName
                                                        self.field.textValue = fileName
                                                        
                                                        uploadMessage = "After image uploaded: \(fileName)"
                                                        showUploadSuccessAlert = true
                                                        print("✅ Field updated with filename: \(fileName)")
                                                    }
                            }
                        }
                    }

                }
            }
        }
        
        .alert("Success", isPresented: $showUploadSuccessAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(uploadMessage)
        }

    }

    // MARK: - Computed Views & Helpers

    private var shouldShowTextField: Bool {


        
        if field.description == "Enter_Business_Partner_name" {
            return value(for: "Select_Business_Partner") == "2.External"
        }

        if field.description == "Final_Action_Taken" {
            return value(for: "Select_Status") == "Close"
        }

        return true
    }

    private var dropdownView: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Header
            Text(field.name) // API field name
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // Actual dropdown
            Menu {
                ForEach(field.optionsAvailable ?? [], id: \.self) { option in
                    Button(option) {
                        field.selectedValue = option
                    }
                }
            } label: {
                HStack {
                    Text(field.selectedValue ?? "\(field.name)")
                        .foregroundColor(field.selectedValue == nil ? .gray : .black)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.4))
                )
            }
        }
//    }

        .onChange(of: field.selectedValue) { value in
            guard let value else { return }

            switch field.description {

            // --- Functional Location ---
            case "Select_Unit":              // user selects Unit
                NotificationCenter.default.post(name: .unitSelected, object: value)
                
            case "Select_Location":          // user selects MainArea
                NotificationCenter.default.post(name: .locationSelected, object: value)

            // --- Categories ---
            case "Select_Categories":
                NotificationCenter.default.post(name: .categorySelected, object: [
                    "value": value,
                    "sectionId": sectionId
                ])
            case "Select_Sub_Category":
                NotificationCenter.default.post(name: .subCategorySelected, object: [
                    "value": value,
                    "sectionId": sectionId
                ])
         

            case "Select_Priority":
                NotificationCenter.default.post(
                    name: .prioritySelected,
                    object: [
                        "value": value,
                        "sectionId": sectionId
                    ]
                )

            case "Select_Status":
                NotificationCenter.default.post(
                    name: .statusSelected,
                    object: [
                        "value": value,
                        "sectionId": sectionId
                    ]
                )

            case "Select_Business_Partner":
                NotificationCenter.default.post(
                    name: .businessPartnerSelected,
                    object: [
                        "value": value,
                        "sectionId": sectionId
                    ]
                )
                
            default:
                break
            }
        }

    }

    private var imageButton: some View {
        Button {
            imageSource = .photoLibrary
            showImagePicker = true
        } label: {
            Text(field.name)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }

    private var timePickerView: some View {

        let isStartDate =
        field.description == "Select_Campaign_Start_time_and_Date"

        let isEndDate =
        field.description == "Select_Campaign_End_time_and_Date"

        return Button {
            tempDate = field.dateValue ?? Date()
            showDatePicker = true
        } label: {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.gray)

                Text(field.textValue ?? "Set date and time")
                    .foregroundColor(field.textValue == nil ? .gray : .black)

                Spacer()
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3))
            )
        }
        .sheet(isPresented: $showDatePicker) {
            DateTimeBottomSheet(
                selectedDate: $tempDate,
                isPresented: $showDatePicker,
                minDate: isEndDate ? campaignStartDate : nil,
                maxDate: isEndDate ? Date() : nil,
                lockTimeToNow: isEndDate,
                onSet: {
                    if isStartDate {
                        campaignStartDate = tempDate
                    }
                    field.dateValue = tempDate
                    field.textValue = formatDate(tempDate)
                    print("📅 DATE VALUE for \(field.name):", field.dateValue)
                },
                onClear: {
                    field.dateValue = nil
                    field.textValue = nil
                    if isStartDate {
                        campaignStartDate = nil
                    }
                }
            )
        }
    }

    // MARK: - Date Formatter
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy hh:mm a"
        return formatter.string(from: date)
    }
    
    

//    private func extractFileName(from response: String) -> String {
//      
//        let cleanResponse = response.trimmingCharacters(in: CharacterSet(charactersIn: "\" "))
//        
//        
//        if let url = URL(string: cleanResponse), !url.lastPathComponent.isEmpty {
//            return url.lastPathComponent
//        }
//        return cleanResponse
//    }
    
    
    private func extractFileName(from response: String) -> String {
        // Agar response {"data":"filename.png"} hai toh sirf filename nikalo
        if let data = response.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let fileName = json["data"] as? String {
            return fileName
        }
        
        // Agar response pehle se saaf hai ya koi aur format hai
        return response.trimmingCharacters(in: CharacterSet(charactersIn: "\" "))
    }
    
    private func value(for description: String) -> String? {
        vm.sections
            .first(where: { $0.id == sectionId })?
            .fields
            .first(where: { $0.description == description })?
            .selectedValue
    }

}
