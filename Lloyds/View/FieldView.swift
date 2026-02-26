//
//  FieldView.swift
//  Lloyds
//
//  Created by Manisha on 28/12/25.
//

//import SwiftUI
//
//struct FieldView: View {
//
//    @State var field: CampaignField
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 6) {
//
//            if field.type != .SECTION_HEADER {
//                Text(field.name)
//                    .font(.subheadline)
//            }
//
//            switch field.type {
//
//            case .TEXTBOX, .OPTIONALTEXTBOX:
//                TextField("Enter", text: Binding(
//                    get: { field.textValue ?? "" },
//                    set: { field.textValue = $0 }
//                ))
//                .textFieldStyle(.roundedBorder)
//
//            case .DROPDOWN_SINGLE:
//                Picker(field.name, selection: Binding(
//                    get: { field.selectedValue ?? "" },
//                    set: { field.selectedValue = $0 }
//                )) {
//                    ForEach(field.optionsAvailable ?? [], id: \.self) {
//                        Text($0)
//                    }
//                }
//                .pickerStyle(.menu)
//
//            case .TIME:
//                Text(field.timeValue ?? "Select Date & Time")
//                    .padding()
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .background(Color.white)
//                    .cornerRadius(8)
//
//            case .BUTTON:
//                Button(field.name) {
//                    print("Button tapped: \(field.name)")
//                }
//                .buttonStyle(.borderedProminent)
//
//            case .SECTION_HEADER:
//                Text(field.name)
//                    .font(.title3)
//                    .bold()
//            }
//        }
//    }
//}
//


import SwiftUI

struct FieldView: View {

    @State var field: CampaignField

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            if field.type != "SECTION_HEADER" {
                Text(field.name)
                    .font(.subheadline)
            }

            switch field.type {

            case "TEXTBOX", "OPTIONALTEXTBOX":
                TextField(
                    "Enter",
                    text: Binding(
                        get: { field.textValue ?? "" },
                        set: { field.textValue = $0 }
                    )
                )
                .textFieldStyle(.roundedBorder)

            case "DROPDOWN_SINGLE":
                Menu {
                    ForEach(field.optionsAvailable ?? [], id: \.self) { option in
                        Button(option) {
                            field.selectedValue = option
                        }
                    }
                } label: {
                    HStack {
                        Text(field.selectedValue ?? field.name)
                            .foregroundColor(field.selectedValue == nil ? .gray : .black)

                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.4))
                    )
                }

            case "TIME":
                Text(field.timeValue ?? "Select Date & Time")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(8)

            case "BUTTON":
                Button(field.name) {
                    print("Button tapped:", field.name)
                }
                .buttonStyle(.borderedProminent)

            case "SECTION_HEADER":
                Text(field.name)
                    .font(.title3)
                    .bold()

            default:
                EmptyView()
            }
        }
    }
}
