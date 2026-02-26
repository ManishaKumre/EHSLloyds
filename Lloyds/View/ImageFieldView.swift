//
//  ImageFieldView.swift
//  Lloyds
//
//  Created by Manisha on 05/01/26.
//
import SwiftUI

struct ImageFieldView: View {
    @Binding var field: CampaignField
    @State private var showPicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text(field.name)
                .font(.subheadline)

            Button {
                sourceType = .photoLibrary
                showPicker = true
            } label: {
                if let image = field.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .clipped()
                        .cornerRadius(10)
                } else {
                    HStack {
                        Image(systemName: "photo")
                        Text("Upload Image")
                        Spacer()
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.4))
                    )
                }
            }
        }
        .sheet(isPresented: $showPicker) {
            ImagePicker(sourceType: sourceType) { image in
                field.image = image
                field.textValue = "image_selected"
            }
        }
    }
}
