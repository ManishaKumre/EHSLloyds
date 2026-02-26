//
//  AuditTrailView.swift
//  Lloyds
//
//  Created by Manisha on 04/04/26.
//

import SwiftUI

struct AuditTrailView: View {
    
    let permitId: Int
    @State private var historyItems: [(date: String, action: String)] = []
    @State private var isLoading = true
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            
            if isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(historyItems.indices, id: \.self) { index in
                            HStack(alignment: .top, spacing: 16) {
                                
                                // Blue Avatar Icon
                                ZStack {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 18))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(historyItems[index].action)
                                        .font(.system(size: 15))
                                        .foregroundColor(.primary)
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: "clock")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Text(historyItems[index].date)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            
                            if index < historyItems.count - 1 {
                                Divider()
                                    .padding(.leading, 72)
                            }
                        }
                    }
                }
                
                // CLOSE Button
                Button {
                    dismiss()
                } label: {
                    Text("CLOSE")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(30)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
                .padding(.top, 16)
            }
        }
        .navigationTitle("Activity History")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchHistory()
        }
    }
    
    func fetchHistory() {
       // guard let url = URL(string: "https://imomtest.deltafour.co/api/v1/workflow/permit/history?permit_id=\(permitId)") else { return }
        
        guard let url = URL(string: APIEndpoints.permitHistory(permitId: permitId)) else { return }

        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let token = KeychainHelper.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data else { return }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                let dataString = json?["data"] as? String ?? ""
                let innerData = dataString.data(using: .utf8) ?? Data()
                let inner = try JSONSerialization.jsonObject(with: innerData) as? [String: Any]
                let items = inner?["data"] as? [[String: String]] ?? []
                
                var result: [(date: String, action: String)] = []
                for item in items {
                    for (date, action) in item {
                        result.append((date: date, action: action))
                    }
                }
                
                DispatchQueue.main.async {
                    self.historyItems = result
                    self.isLoading = false
                }
            } catch {
                print("❌ History decode error:", error)
                DispatchQueue.main.async { self.isLoading = false }
            }
        }.resume()
    }
}
