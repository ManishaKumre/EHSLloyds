//
//  CreateCampaignView.swift
//  Lloyds
//
//  Created by Manisha on 28/12/25.
//

import SwiftUI

struct CreateCampaignView: View {
    @StateObject private var vm = CreateCampaignViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var campaignStartDate: Date? = nil

    var body: some View {
       // NavigationView {
            VStack {
                if vm.showLoader {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach($vm.sections) { $section in
                                DisclosureGroup(isExpanded: Binding(
                                    get: { section.expanded ?? true },
                                    set: { section.expanded = $0 }
                                )) {
                                    VStack(spacing: 15) {
                                        ForEach($section.fields) { $field in
                                            DynamicFieldView(field: $field,  campaignStartDate: $campaignStartDate,sectionId: section.id)
                                                .environmentObject(vm)
                                        }
                                    }
                                    .padding(.top, 5)
                                } label: {
                                    HStack {
                                        Text(section.title.uppercased())
                                            .font(.headline)
                                        Spacer()
                                    }
                                    .padding(.vertical, 5)
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        .padding()
                        
                        // Submit Button
                        Button {
                            vm.submitCampaign()
                        } label: {
                            Text("SUBMIT")
                                                           .frame(maxWidth: .infinity)
                                                           .padding()
                                                           .background(vm.isFormValid ? Color.blue : Color.gray)
                                                           .foregroundColor(.white)
                                                           .cornerRadius(10)
                                                   }
                                                   .disabled(!vm.isFormValid)
                                                   .padding(.horizontal)
                        
                        // Cancel Button
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                        .padding(.top, 10)
                    }
                }
            }
            .navigationTitle("Create Campaign")
            .onAppear {
                vm.fetchCampaignData()
            }
            
            .background(
                           NavigationLink(
                            destination: PermitTypeView(
                                        selectedCampaignType: vm.selectedCampaignType,
                                        fieldValues: vm.collectedFieldValues  //
                                    ),
                               isActive: $vm.navigateToPermitType
                           ) {
                               EmptyView()
                           }
                       )
       // }
    }
}

// MARK: - Preview

struct CreateCampaignView_Previews: PreviewProvider {
    static var previews: some View {
        CreateCampaignView()
    }
}
