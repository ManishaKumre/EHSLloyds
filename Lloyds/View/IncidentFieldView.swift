//
//  IncidentFieldView.swift
//  Lloyds
//
//  Created by Manisha on 30/01/26.
//

import SwiftUI

//struct IncidentFieldView: View {
//
//    @Binding var field: IncidentFormField
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 6) {
//
//            // Title
//            Text(field.name)
//                .font(.subheadline)
//
//            switch field.type {
//
//            case .TEXTBOX :
//                TextField(
//                    "Enter",
//                    text: Binding(
//                        get: { field.textValue ?? "" },
//                        set: { field.textValue = $0 }
//                    )
//                )
//                .textFieldStyle(.roundedBorder)
//
//            case .DROPDOWN_SINGLE:
//                Menu {
//                    ForEach(field.optionsAvailable ?? [], id: \.self) { option in
//                        Button(option) {
//                            field.selectedValue = option
//                        }
//                    }
//                } label: {
//                    HStack {
//                        Text(field.selectedValue ?? "Select")
//                            .foregroundColor(field.selectedValue == nil ? .gray : .black)
//                        Spacer()
//                        Image(systemName: "chevron.down")
//                    }
//                    .padding()
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 8)
//                            .stroke(Color.gray.opacity(0.4))
//                    )
//                }
//
//            case .TIME:
//                Text(field.timeValue ?? "Select Date & Time")
//                    .padding()
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .background(Color.white)
//                    .cornerRadius(8)
//            }
//        }
//    }
//}
