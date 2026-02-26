//
//  ImageViewerView.swift
//  Lloyds
//
//  Created by Manisha on 03/04/26.
//

import SwiftUI

struct ImageViewerView: View {

    let imageKey: String

    @Environment(\.dismiss) var dismiss

    @State private var imageURL: String? = nil
    @State private var isLoading = true
    @State private var errorMessage: String? = nil

    // 🔥 ZOOM STATES
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    var body: some View {

        ZStack {

            Color.white.ignoresSafeArea()

            VStack {

                // 🔝 HEADER
                HStack {
                    Spacer()

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                }
                .padding()

                Spacer()

                // 🔥 CONTENT
                if isLoading {
                    ProgressView("Loading Image...")
                        .foregroundColor(.white)
                }

                else if let urlString = imageURL,
                        let url = URL(string: urlString) {

                    AsyncImage(url: url) { phase in
                        switch phase {

                        case .empty:
                            ProgressView()
                                .foregroundColor(.white)

                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(scale)
                                .gesture(
                                    MagnificationGesture()
                                        .onChanged { value in
                                            scale = lastScale * value
                                        }
                                        .onEnded { _ in
                                            lastScale = scale
                                        }
                                )
                                .onTapGesture(count: 2) {
                                    // 🔥 DOUBLE TAP ZOOM
                                    withAnimation {
                                        if scale > 1 {
                                            scale = 1
                                            lastScale = 1
                                        } else {
                                            scale = 2
                                            lastScale = 2
                                        }
                                    }
                                }

                        case .failure:
                            Text("❌ Failed to load image")
                                .foregroundColor(.white)

                        @unknown default:
                            EmptyView()
                        }
                    }

                } else {
                    Text(errorMessage ?? "Something went wrong")
                        .foregroundColor(.white)
                }

                Spacer()
            }
        }
        .onAppear {
            fetchImageURL()
        }
    }

    //  API CALL WITH TOKEN
    func fetchImageURL() {

        
        let correctedKey: String
         if imageKey.hasSuffix(".jpg.png") || imageKey.hasSuffix(".png") {
             correctedKey = imageKey  // Already sahi hai
         } else if imageKey.hasSuffix(".jpg") {
             correctedKey = imageKey + ".png"  // ✅ .png add karo
         } else {
             correctedKey = imageKey
         }

         print("🔑 Original key: \(imageKey)")
         print("🔑 Corrected key: \(correctedKey)")

        
        
        
//        guard let url = URL(
//            string: "https://imomtest.deltafour.co/api/v2/documents/download/pre-signed-url?key=\(correctedKey)"
//        ) else {
//            errorMessage = "Invalid URL"
//            return
//        }

        guard let url = URL(
            string: APIEndpoints.preSignedImageURL(key: correctedKey)
        ) else {
            errorMessage = "Invalid URL"
            return
        }
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // ✅ TOKEN
        if let token = KeychainHelper.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in

            DispatchQueue.main.async {
                isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = error.localizedDescription
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "No data received"
                }
                return
            }

            // 🔍 DEBUG (optional)
            let responseString = String(data: data, encoding: .utf8)
            print("📦 IMAGE API RESPONSE:", responseString ?? "")

            do {
                // ✅ CORRECT PARSING (tumhare format ke hisaab se)
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let urlString = json["url"] as? String {

                    DispatchQueue.main.async {
                        self.imageURL = urlString
                    }

                } else {
                    DispatchQueue.main.async {
                        errorMessage = "Invalid response format"
                    }
                }

            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Parsing error"
                }
            }

        }.resume()
    }
}
