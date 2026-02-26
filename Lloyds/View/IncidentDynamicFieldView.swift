//
//  IncidentDynamicFieldView.swift
//  Lloyds
//
//  Created by Manisha on 30/01/26.
//

import SwiftUI

struct IncidentDynamicFieldView: View {

    @Binding var field: IncidentFormField
    @State private var showOptions = false
    @Binding var allFieldsInSection: [IncidentFormField]

    @State private var showDatePicker = false
    @State private var selectedDate = Date()
    
    
    var body: some View {
        
        if shouldShowField() {
                    VStack(alignment: .leading, spacing: 8) {
                        
                        // 2️⃣ Immediate Action Taken Layout (Like Android)
                        if field.description == "Immediate_action_taken" {
                            immediateActionLayout
                        } else {
                            // Baaki saare normal fields ka switch case
                            renderNormalFields
                        }
                    }
                }
            }
        
        
        @ViewBuilder
    private var renderNormalFields: some View {
        switch field.type {
            
        case .TEXTBOX, .OPTIONALTEXTBOX:
            TextField(field.name, text: Binding(
                get: { field.textValue ?? "" },
                set: { field.textValue = $0 }
            ))
            .padding()
            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
            
        case .TIME:
            
            Button {
                selectedDate = field.dateValue ?? Date()
                showDatePicker = true
            } label: {
                HStack {
                    Text(field.timeValue ?? field.name)
                        .foregroundColor(field.timeValue == nil ? .gray : .black)
                    Spacer()
                    Image(systemName: "calendar")
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
            }
            .sheet(isPresented: $showDatePicker) {
                
                if #available(iOS 16.0, *) {
                    VStack(spacing: 20) {
                        
                        DatePicker(
                            "Select Date & Time",
                            selection: $selectedDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.graphical)
                        .padding()
                        
                        Button("Done") {
                            
                            // ✅ Update model
                            field.dateValue = selectedDate
                            field.timeValue = formatDate(selectedDate)
                            
                            showDatePicker = false
                            
                            
                            DispatchQueue.main.async {
                                field.timeValue = formatDate(selectedDate)
                            }
                            
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    .presentationDetents([.medium, .large])
                    .ignoresSafeArea(.container, edges: .bottom)
                } else {
                    // Fallback on earlier versions
                }
            }
            
        case .DROPDOWN_SINGLE:
            Button {
                showOptions = true
            } label: {
                HStack {
                    Text(field.selectedValue ?? field.name)
                        .foregroundColor(field.selectedValue == nil ? .gray : .black)
                    Spacer()
                    Image(systemName: "chevron.down")
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
            }
            .sheet(isPresented: $showOptions) {
                List(field.optionsAvailable ?? [], id: \.self) { option in
                    Text(option)
                        .onTapGesture {
                            field.selectedValue = option
                            showOptions = false
                        }
                }
            }
            
            
            .onChange(of: field.selectedValue) { newValue in
                guard let value = newValue else { return }
                
                switch field.description {
                    
                case "Select_Unit":
                    // 1️⃣ Unit selected
                    selectedUnitChanged(value)
                    
                case "Select_Location":
                    // 2️⃣ Location selected
                    selectedLocationChanged(value)
                    
                default:
                    break
                }
            }
            
        case .SECTION_HEADER:
            Text(field.name)
                .font(.headline)
                .padding(.vertical, 8)
            
        case .BUTTON:
            Button(field.name) { }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            
        case .unknown:
            EmptyView()
        }
        
    }
        
        
    
    private var immediateActionLayout: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 1. Checkbox Row
            HStack {
                Image(systemName: (field.selectedValue == "true") ? "checkmark.square.fill" : "square")
                    .foregroundColor((field.selectedValue == "true") ? .blue : .gray)
                    .onTapGesture {
                        // Toggle logic
                        field.selectedValue = (field.selectedValue == "true") ? "false" : "true"
                        
                        // Agar uncheck kiya, toh text ko clear karna hai ya nahi ye aap decide kar sakte hain
                        if field.selectedValue == "false" {
                            field.textValue = ""
                        }
                    }
                
                Text("Immediate action taken")
                    .font(.subheadline)
            }
            
            // 2. Conditional TextField: Sirf tab dikhega jab checkbox true hoga
            if field.selectedValue == "true" {
                TextField("Immediate action taken", text: Binding(
                    get: { field.textValue ?? "" },
                    set: { field.textValue = $0 }
                ))
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
                .transition(.opacity.combined(with: .move(edge: .top))) // Smooth appearance
            }
        }
        .animation(.easeInOut, value: field.selectedValue) // Animation trigger
    }

        private func shouldShowField() -> Bool {
            if field.description == "Enter_Employee_Type" {
               
                let partnerField = allFieldsInSection.first(where: { $0.description == "Select_Employee_Type" })
               
                return partnerField?.selectedValue == "External"
            }
            return true
        }
    }
    
    
    
    
    private func selectedUnitChanged(_ unit: String) {
        // 🔹 Save selected unit
        NotificationCenter.default.post(
            name: .incidentUnitSelected,
            object: unit
        )
    }

    private func selectedLocationChanged(_ location: String) {
        NotificationCenter.default.post(
            name: .incidentLocationSelected,
            object: location
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm dd-MMM-yyyy"
        return formatter.string(from: date)
    }


