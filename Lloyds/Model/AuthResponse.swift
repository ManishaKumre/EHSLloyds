//
//  AuthResponse.swift
//  Lloyds
//
//  Created by Manisha on 23/12/25.
//

import Foundation


// Defines a structure to represent the authentication response from an API

struct AuthResponse: Codable {
    
    let id: Int
    let username: String
    let email: String?
    let department: String?
    let designation: String?
    let empId: String?
    let workAtHeightOrConfinedSpacePass: String?
    let isolationPoint: String?
    let phoneNumber: String?
    let companyAccountId: Int
    let company_account_name: String
    let roles: [String]
    let customRoles: [String]
    let userHierarchy: UserHierarchy?
    let accessToken: String  // The access token received from the server after authentication
    let tokenType: String   // The type of the token, typically "Bearer"
    
    var userType: String {
           customRoles.first ?? ""
       }
    //  Custom initializer for manual creation (SSO login support)
    init(id: Int = 0,
         username: String = "User",
         email: String? = nil,
         department: String? = nil,
         designation: String? = nil,
         empId: String? = nil,
         workAtHeightOrConfinedSpacePass: String? = nil,
         isolationPoint: String? = nil,
         phoneNumber: String? = nil,
         companyAccountId: Int = 0,
         company_account_name: String = "Company",
         roles: [String] = [],
         customRoles: [String] = [],
         userHierarchy: UserHierarchy? = nil,
         accessToken: String = "",
         tokenType: String = "Bearer") {
        self.id = id
        self.username = username
        self.email = email
        self.department = department
        self.designation = designation
        self.empId = empId
        self.workAtHeightOrConfinedSpacePass = workAtHeightOrConfinedSpacePass
        self.isolationPoint = isolationPoint
        self.phoneNumber = phoneNumber
        self.companyAccountId = companyAccountId
        self.company_account_name = company_account_name
        self.roles = roles
        self.customRoles = customRoles
        self.userHierarchy = userHierarchy
        self.accessToken = accessToken
        self.tokenType = tokenType
        
    }
}

struct UserHierarchy: Codable {
    
}


// MARK: - Refresh token response
struct RefreshResponse: Codable {
    let data: String   // the new access token
}


struct AlertMessage: Identifiable {
    let id = UUID()
    let text: String
}
