//
//  Untitled.swift
//  Lloyds
//
//  Created by Manisha on 25/02/26.
//

import SwiftUI

struct AddTeamLeadView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedTeamLead: String = ""
    @State private var isLoading: Bool = false
    
    let permitId: Int
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // --- HEADER ---
                headerView
                
                Divider()
                
                // --- FORM CONTENT ---
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 4) {
                        Text("Select Team Lead")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("*")
                            .foregroundColor(.red)
                    }
                    
                    // Dropdown Box
                    HStack {
                        Text(selectedTeamLead.isEmpty ? "Select_Team_Lead" : selectedTeamLead)
                            .foregroundColor(selectedTeamLead.isEmpty ? .gray : .primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray.opacity(0.5))
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(selectedTeamLead.isEmpty ? Color.red.opacity(0.3) : Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .onTapGesture {
                        // Dummy Selection for testing
                        selectedTeamLead = "John Doe (Lead)"
                    }
                    
                    Spacer()
                }
                .padding(24)
                
                Divider()
                
                // --- FOOTER BUTTONS ---
                footerView
            }
            .background(Color.white)
            .cornerRadius(12)
            
            // Loader
            if isLoading {
                Color.black.opacity(0.2).ignoresSafeArea()
                ProgressView()
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - API Logic
private extension AddTeamLeadView {
    
    func submitAction() {
        guard !selectedTeamLead.isEmpty else {
            print("Please select a team lead")
            return
        }
        
        //guard let url = URL(string: "https://imomtest.deltafour.co/api/v1/workflow/auxiliary/permit") else { return }
        
        guard let url = URL(string: APIEndpoints.auxiliaryPermit) else { return }
        
        isLoading = true
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = KeychainHelper.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // 🎯 Yahan data structure dhyaan se dekhein:
        // "Add Team Lead" screen ke liye hum fieldValues mein wo value bhejte hain
        // aur buttonAction mein button ka naam.
        let body: [String: Any] = [
            "data": [
                "fieldValues": [
                    "Add_Team_Lead": selectedTeamLead // Key wahi honi chahiye jo JSON description mein hai
                ],
                "permitState": [
                    "buttonAction": "Add Team Lead"
                ]
            ],
            "id": permitId
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    print("✅ Team Lead Added Successfully")
                    dismiss() // Success hone par screen close ho jayegi
                } else {
                    print("❌ Error in API call")
                }
            }
        }.resume()
    }
}

// MARK: - UI Subviews
private extension AddTeamLeadView {
    var headerView: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Text("Create Action").font(.title3).bold()
                Text("(Fill the below Fields)").font(.subheadline).foregroundColor(.blue)
            }
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark").font(.title3).foregroundColor(.black).padding(8)
            }
        }.padding()
    }
    
    var footerView: some View {
        HStack(spacing: 16) {
            Spacer()
            Button { dismiss() } label: {
                Text("Cancel")
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .frame(width: 100, height: 44)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4), lineWidth: 1))
            }
            
            Button { submitAction() } label: {
                Text("Submit")
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(width: 100, height: 44)
                    .background(selectedTeamLead.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(8)
            }
            .disabled(selectedTeamLead.isEmpty || isLoading)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
    }
}
