//
//  Untitled.swift
//  Lloyds
//
//  Created by Manisha on 19/02/26.
//


import SwiftUI

struct AccountDetailScreen: View {

    let user: AuthResponse

    // 3 column grid for roles
    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        ScrollView {

            VStack(spacing: 24) {

                // MARK: Profile Header
                VStack(spacing: 12) {

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 110, height: 110)
                        .overlay(
                            Text(String(user.username.prefix(1)).uppercased())
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .shadow(radius: 6)

                    Text(user.username)
                        .font(.title3)
                        .fontWeight(.bold)

                    Text(user.company_account_name ?? "Company")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .padding(.top, 30)

                // MARK: Details Card
                VStack(spacing: 16) {

                    profileRow(title: "Email", value: user.email)
                    profileRow(title: "Phone", value: user.phoneNumber)
                    profileRow(title: "Emp ID", value: user.empId)
                    profileRow(title: "Department", value: user.department)
                    profileRow(title: "Designation", value: user.designation)
                    profileRow(title: "Work at Height Pass", value: user.workAtHeightOrConfinedSpacePass)

                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 6)
                .padding(.horizontal)

                // MARK: Roles Section
                if !user.roles.isEmpty || !user.customRoles.isEmpty {

                    VStack(alignment: .leading, spacing: 12) {

                        Text("Roles")
                            .font(.headline)
                            .padding(.horizontal)

                        LazyVGrid(columns: columns, spacing: 10) {

                            ForEach(user.roles, id: \.self) { role in
                                roleTag(text: role)
                            }

                            ForEach(user.customRoles, id: \.self) { role in
                                roleTag(text: role)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                Spacer(minLength: 40)
            }
        }
        .background(Color(.systemGray6))
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Profile Row
    private func profileRow(title: String, value: String?) -> some View {

        HStack {
            Text(title)
                .fontWeight(.medium)

            Spacer()

            Text(value?.isEmpty == false ? value! : "NA")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }

    // MARK: Role Tag
    private func roleTag(text: String) -> some View {

        Text(text)
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.15))
            .cornerRadius(10)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
