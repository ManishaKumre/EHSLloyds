//
//  ObservationDetailPopupView.swift
//  Lloyds
//
//  Created by Manisha on 27/01/26.
//


//
//import SwiftUI
//
//struct ObservationDetailPopupView: View {
//
//    let observation: Observation
//    @Environment(\.dismiss) var dismiss
//    @Binding var isPresented: Bool
//    @State private var navigateToAction = false
//    @EnvironmentObject var viewModel: ViewPermitViewModel
//    let showActionButton: Bool
//    @State private var selectedImageKey: String? = nil
//    @State private var showImageViewer = false
//    
//    var body: some View {
//
//        if #available(iOS 16.0, *) {
//
//            NavigationStack {
//
//                VStack(spacing: 16) {
//
//                    // HEADER
//                    HStack {
//                        Text("Observation")
//                            .font(.headline)
//
//                        Spacer()
//
//                        Button("Close") {
//                            dismiss()
//                        }
//                    }
//
//                    // 🔥 DYNAMIC DATA
//                    ScrollView {
//
//                        VStack(spacing: 12) {
//
//                            ForEach(observation.dynamicFields, id: \.0) { item in
//                                detailRow(
//                                    title: item.key,
//                                    value: item.value
//                                )
//                            }
//
//                        }
//                    }
//
//                    // TAKE ACTION BUTTON (CONDITION APPLY)
//                    if showActionButton {
//                        Button {
//                            navigateToAction = true
//                        } label: {
//                            Text("Take Action")
//                                .frame(maxWidth: .infinity)
//                        }
//                        .buttonStyle(CardButtonStyle(color: .blue))
//                    }
//                    
//                    // NAVIGATION
//                    NavigationLink(
//                        destination: ActionOnObservationView(
//                            observation: observation,
//                            statusList: viewModel.statusOptions, isPresented: $navigateToAction 
//                        )
//                        .environmentObject(viewModel),
//                        isActive: $navigateToAction
//                    ) {
//                        EmptyView()
//                    }
//                }
//                .padding()
//            }
//
//        } else {
//            Text("iOS 16 required")
//        }
//
//        // ❗ KEEP THIS (parent navigation)
//        NavigationLink(
//            destination: PermitScreenView(),
//            isActive: $viewModel.navigateToPermitType
//        ) {
//            EmptyView()
//        }
//    }
//}
//
//
//@ViewBuilder
//func detailRow(title: String, value: String?) -> some View {
//
//    VStack(alignment: .leading, spacing: 6) {
//
//        Text(title)
//            .font(.caption)
//            .foregroundColor(.gray)
//
//        Text(value ?? "-")
//            .padding()
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .background(Color(.systemGray5))
//            .cornerRadius(10)
//    }
//}
//


import SwiftUI

struct ObservationDetailPopupView: View {

    let observation: Observation
    @Environment(\.dismiss) var dismiss
    @Binding var isPresented: Bool
    @State private var navigateToAction = false
    @EnvironmentObject var viewModel: ViewPermitViewModel
    let showActionButton: Bool

    //  IMAGE STATES
    @State private var selectedImageKey: String? = nil
    @State private var showImageViewer = false

    var body: some View {

        if #available(iOS 16.0, *) {

            NavigationStack {

                VStack(spacing: 16) {

                    // HEADER
                    HStack {
                        Text("Observation")
                            .font(.headline)

                        Spacer()

                        Button("Close") {
                            dismiss()
                        }
                    }

                    //  DYNAMIC DATA
                    ScrollView {

                        VStack(spacing: 12) {

                            ForEach(observation.dynamicFields, id: \.key) { item in
                                detailRow(
                                    title: item.key,
                                    value: item.value
                                )
                            }

                        }
                    }

                    // TAKE ACTION BUTTON
                    if showActionButton {
                        Button {
                            navigateToAction = true
                        } label: {
                            Text("Take Action")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(CardButtonStyle(color: .blue))
                    }

                    // NAVIGATION
                    NavigationLink(
                        destination: ActionOnObservationView(
                            observation: observation,
                            statusList: viewModel.statusOptions,
                            isPresented: $navigateToAction
                        )
                        .environmentObject(viewModel),
                        isActive: $navigateToAction
                    ) {
                        EmptyView()
                    }
                }
                .padding()

                //  IMAGE VIEW SHEET
                .sheet(isPresented: $showImageViewer) {
                    if let key = selectedImageKey {
                        ImageViewerView(imageKey: key)
                    }
                }
            }

        } else {
            Text("iOS 16 required")
        }

        //  Parent Navigation
        NavigationLink(
            destination: PermitScreenView(),
            isActive: $viewModel.navigateToPermitType
        ) {
            EmptyView()
        }
    }

    //  UPDATED DETAIL ROW
//    @ViewBuilder
//    func detailRow(title: String, value: String?) -> some View {
//
//        let isImageField = title.lowercased().contains("image")
//
//        VStack(alignment: .leading, spacing: 6) {
//
//            Text(title)
//                .font(.caption)
//                .foregroundColor(.gray)
//
//            if isImageField,
//               let value = value,
//               !value.isEmpty {
//
//                Button {
//
//                    selectedImageKey = value
//                    showImageViewer = true
//
//                } label: {
//                    HStack {
//                        Text("View Image")
//                            .foregroundColor(.blue)
//
//                        Spacer()
//
//                        Image(systemName: "eye")
//                            .foregroundColor(.blue)
//                    }
//                    .padding()
//                    .background(Color(.systemGray5))
//                    .cornerRadius(10)
//                }
//
//            } else {
//
//                Text(value ?? "-")
//                    .padding()
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .background(Color(.systemGray5))
//                    .cornerRadius(10)
//            }
//        }
//    }
    
    
    
    @ViewBuilder
    func detailRow(title: String, value: String?) -> some View {

        let isImageField = title.lowercased().contains("image")

        VStack(alignment: .leading, spacing: 6) {

            Text(title)
                .font(.caption)
                .foregroundColor(.gray)

            if isImageField, let value = value, !value.isEmpty {

                // ✅ Comma se split karo - multiple images handle hongi
                let imageKeys = value
                    .components(separatedBy: ", ")
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }

                if imageKeys.isEmpty {
                    Text("-")
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray5))
                        .cornerRadius(10)
                } else {
                    ForEach(Array(imageKeys.enumerated()), id: \.offset) { index, key in
                        Button {
                            selectedImageKey = key  // ✅ Sirf ek key pass hogi
                            showImageViewer = true
                            print("🖼 Opening image key: \(key)")
                        } label: {
                            HStack {
                                Image(systemName: "photo.fill")
                                    .foregroundColor(.blue)
                                Text(imageKeys.count > 1 ? "View Image \(index + 1)" : "View Image")
                                    .foregroundColor(.blue)
                                Spacer()
                                Image(systemName: "eye")
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(10)
                        }
                    }
                }

            } else {
                Text(value ?? "-")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
            }
        }
    }
    
    
    
}


