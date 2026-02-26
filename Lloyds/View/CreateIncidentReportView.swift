//
//  CreateIncidentReportView.swift
//  Lloyds
//
//  Created by Manisha on 30/01/26.
//



import SwiftUI

struct CreateIncidentReportView: View {

    @StateObject private var viewModel = IncidentFormViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {

            if viewModel.isLoading {
                ProgressView()
            }

            ScrollView {
                VStack(spacing: 16) {

                    ForEach($viewModel.sections) { $section in
                        DisclosureGroup(
                            isExpanded: Binding(
                                get: { section.expanded },
                                set: { section.expanded = $0 }
                            )
                        ) {
                            IncidentSectionView(section: $section)
                                .padding(.top, 5)
                        } label: {
                            HStack {

                                if viewModel.isInjuredSection(section) {
                                    Text(section.subtitle ?? section.title)
                                        .font(.headline)
                                } else {
                                    Text(section.title)
                                        .font(.headline)
                                }

                                Spacer()

                                if viewModel.isInjuredSection(section) &&
                                   viewModel.IncidentCount > 1 {

                                    Button {
                                        viewModel.removeObservation(id: section.id)
                                    } label: {
                                        Image(systemName: "trash.fill")
                                            .foregroundColor(.red)
                                            .padding(8)
                                            .background(Color.red.opacity(0.1))
                                            .clipShape(Circle())
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
            
            Button {
                viewModel.addObservation()
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Incident")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.15))
                .cornerRadius(12)
            }
            .padding(.horizontal)


            Button("SUBMIT") {
                viewModel.submitIncident()
                print(viewModel.sections)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(14)
            .padding()
        }
        .navigationTitle("Create Incident Report")
        .alert(isPresented: $viewModel.showAlert) {
                    Alert(
                        title: Text(viewModel.isSuccess ? "Success" : "Error"),
                        message: Text(viewModel.alertMessage),
                        dismissButton: .default(Text("OK")) {
                            if viewModel.isSuccess {
                                dismiss() 
                            }
                        }
                    )
                }

        
        .onAppear {
            viewModel.fetchIncidentForm{
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    viewModel.fetchFunctionalLocations()
                }
            }
            
        }
        
    }
}
