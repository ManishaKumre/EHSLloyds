//
//  Untitled.swift
//  Lloyds
//
//  Created by Manisha on 23/12/25.
//


import Foundation

struct APIConfig {

//    static let defaultBaseURL = "https://imomtest.deltafour.co/api/"
    static let defaultBaseURL = "https://imom.deltafour.co/api/"

    static var overrideBaseURL: String? = nil
    
    static var baseURL: String {
        overrideBaseURL ?? defaultBaseURL
    }
    static var loginURL: String {
        baseURL + "v1/auth/signin/"
    }


}
