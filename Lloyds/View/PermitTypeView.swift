//
//  PermitTypeView.swift
//  Lloyds
//
//  Created by Manisha on 30/12/25.
//


//
//import SwiftUI
//
//struct PermitTypeView: View {
//
//    @StateObject private var vm = PermitTypeViewModel()
//    @Environment(\.dismiss) private var dismiss
//
//    let selectedCampaignType: String
//    let fieldValues: [String: Any]
//
//    @State private var campaignStartDate: Date?
//
//    
//   
//    
//    
//    var body: some View {
//        NavigationLink(
//                destination: PermitScreenView(), 
//                isActive: $vm.navigateToPermitType
//            ) {
//                EmptyView()
//            }
//        VStack {
//
//            if vm.showLoader {
//                ProgressView("Loading...")
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//
//            } else {
//
//                ScrollView {
//
//                    VStack(spacing: 20) {
//
//                        ForEach(vm.sections.indices, id: \.self) { index in
//                            PermitFormSectionView(
//                                section: $vm.sections[index],
//                                vm: vm,
//                                campaignStartDate: $campaignStartDate
//                            )
//                        }
//
//                    }
//                    .padding()
//
//                    // Add Observation
//                    Button {
//                        vm.addObservation()
//                    } label: {
//                        HStack {
//                            Image(systemName: "plus.circle.fill")
//                            Text("Add Observation")
//                        }
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.blue.opacity(0.15))
//                        .cornerRadius(10)
//                    }
//                    .padding(.horizontal)
//
//                    // Submit
//                    Button {
////                        if vm.validateVisibleFields() {
////                            let values = vm.getFieldValues()
////                            vm.submitPermit(fieldValues: values)
//                        print("Submit tapped")
//
//                           let isValid = vm.validateVisibleFields()
//                           print("Validation result:", isValid)
//
//                           if isValid {
//                               let values = vm.getFieldValues()
//                               print("Values:", values)
//                               vm.submitPermit(fieldValues: values)
//                           } else {
//                               print("Validation failed")
//                           }
//                        
//                    } label: {
//                        Text("SUBMIT")
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color.blue)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
//                    }
//                    .padding(.horizontal)
//
//                    // Cancel
//                    Button {
//                        dismiss()
//                    } label: {
//                        Text("Cancel")
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color.gray.opacity(0.2))
//                            .cornerRadius(10)
//                    }
//                    .padding(.horizontal)
//                    .padding(.top, 10)
//                }
//            }
//        }
//        
//        // PermitTypeView.swift ke body mein sabse niche:
//
//        .alert("Success", isPresented: $vm.showSuccessAlert) {
//            Button("OK") {
//                //dismiss() // Success hone par screen band ho jayegi
//                vm.navigateToPermitType = true
//            }
//        } message: {
//            Text(vm.successMessage ?? "campaign created successfully")
//        }
//
//        .alert("Error", isPresented: $vm.showErrorAlert) {
//            Button("OK", role: .cancel) { }
//        } message: {
//            Text(vm.errorMessage ?? "campaignfailed ")
//        }
//        
//        .navigationTitle("Campaign Details")
//        .navigationBarTitleDisplayMode(.inline)
//        .onAppear {
//            vm.fetchPermitTypeForm(
//                campaignType: selectedCampaignType,
//                fieldValues: fieldValues
//            )
//            vm.fetchFunctionalLocations()
//            vm.fetchCategories()
//        }
//    }
//}
//
//struct PermitFormSectionView: View {
//
//    @Binding var section: CampaignSection
//    @ObservedObject var vm: PermitTypeViewModel
//    @Binding var campaignStartDate: Date?
//
//    var body: some View {
//
//        DisclosureGroup(
//            isExpanded: Binding(
//                get: { section.expanded ?? true },
//                set: { section.expanded = $0 }
//            )
//        ) {
//
//            VStack(spacing: 15) {
//
//                ForEach(section.fields.indices, id: \.self) { fieldIndex in
//
//                    DynamicFieldView(
//                        field: $section.fields[fieldIndex],
//                        campaignStartDate: $campaignStartDate,
//                        sectionId: section.id
//                    )
//                    .environmentObject(vm)
//                }
//            }
//            .padding(.top, 5)
//
//        } label: {
//
//            HStack {
//
//                if section.title == "Observations" {
////                    Text(section.displayTitle ?? "Observation")
////                        .font(.headline)
//                    
//                    Text(section.displayTitle ?? "Observation")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .padding(.horizontal, 14)
//                        .padding(.vertical, 6)
//                        .background(Color.blue)
//                        .cornerRadius(14)
//
//                    Spacer()
//
//                    // ❌ button sirf tab dikhe jab 1 se zyada observations ho
//                    if vm.observationCount > 1 {
//                        Button {
//                            vm.removeObservation(id: section.id)
//                        } label: {
//                            Image(systemName: "trash.fill")
//                                .foregroundColor(.red)
//                        }
//                    }
//               
//                } else {
//                    Text(section.title.uppercased())
//                        .font(.headline)
//                }
//
//                Spacer()
//            }
//        }
//        .padding()
//        .background(Color.gray.opacity(0.1))
//        .cornerRadius(10)
//    }
//}


import SwiftUI

struct PermitTypeView: View {

    @StateObject private var vm = PermitTypeViewModel()
    @Environment(\.dismiss) private var dismiss

    let selectedCampaignType: String
    let fieldValues: [String: Any]

    @State private var campaignStartDate: Date?

    
   
    
    
    var body: some View {
        NavigationLink(
                destination: PermitScreenView(),
                isActive: $vm.navigateToPermitType
            ) {
                EmptyView()
            }
        VStack {

            if vm.showLoader {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            } else {

                ScrollView {

                    VStack(spacing: 20) {

                        
                        ForEach($vm.sections, id: \.id) { $section in
                            PermitFormSectionView(
                                section: $section,
                                vm: vm,
                                campaignStartDate: $campaignStartDate
                            )
                        }

                    }
                    .padding()

                    // Add Observation
                    Button {
                        vm.addObservation()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Observation")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.15))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    // Submit
                    Button {
//                        if vm.validateVisibleFields() {
//                            let values = vm.getFieldValues()
//                            vm.submitPermit(fieldValues: values)
                        print("Submit tapped")

                           let isValid = vm.validateVisibleFields()
                           print("Validation result:", isValid)

                           if isValid {
                               let values = vm.getFieldValues()
                               print("Values:", values)
                               vm.submitPermit(fieldValues: values)
                           } else {
                               print("Validation failed")
                               vm.showValidationAlert = true
                           }
                        
                    } label: {
                        Text("SUBMIT")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    // Cancel
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
            }
        }
        
        // PermitTypeView.swift ke body mein sabse niche:

        .alert("Success", isPresented: $vm.showSuccessAlert) {
            Button("OK") {
                //dismiss() // Success hone par screen band ho jayegi
                vm.navigateToPermitType = true
            }
        } message: {
            Text(vm.successMessage ?? "campaign created successfully")
        }

        .alert("Error", isPresented: $vm.showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(vm.errorMessage ?? "campaignfailed ")
        }
        
        .alert(
            vm.showValidationAlert ? "Validation Error" : "Error",
            isPresented: Binding(
                get: { vm.showValidationAlert || vm.showErrorAlert },
                set: { _ in
                    vm.showValidationAlert = false
                    vm.showErrorAlert = false
                }
            )
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(vm.errorMessage ?? "")
        }
        
        
        .navigationTitle("Campaign Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            vm.fetchPermitTypeForm(
                campaignType: selectedCampaignType,
                fieldValues: fieldValues
            )
            vm.fetchFunctionalLocations()
            vm.fetchCategories()
        }
    }
}

struct PermitFormSectionView: View {

    @Binding var section: CampaignSection
    @ObservedObject var vm: PermitTypeViewModel
    @Binding var campaignStartDate: Date?

    var body: some View {

        DisclosureGroup(
            isExpanded: Binding(
                get: { section.expanded ?? true },
                set: { section.expanded = $0 }
            )
        ) {

            VStack(spacing: 15) {

                
                ForEach($section.fields, id: \.id) { $field in
                    DynamicFieldView(
                        field: $field,
                        campaignStartDate: $campaignStartDate,
                        sectionId: section.id
                    )
                    .environmentObject(vm)
                }
            }
            .padding(.top, 5)

        } label: {

            HStack {

                if section.title == "Observations" {
//
                    Text(section.displayTitle ?? "Observation")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .cornerRadius(14)

                    Spacer()

                    
                    if vm.observationCount > 1 {
                        Button {
                            vm.removeObservation(id: section.id)
                        } label: {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.red)
                        }
                    }
               
                } else {
                    Text(section.title.uppercased())
                        .font(.headline)
                }

                Spacer()
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}
