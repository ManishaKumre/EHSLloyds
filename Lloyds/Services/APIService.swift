//
//  Untitled.swift
//  Lloyds
//
//  Created by Manisha on 23/12/25.
//

import Foundation
import Combine
import UIKit



// MARK: - APIService
final class APIService {
    static let shared = APIService()
    //    private init() {}
   
    
    private var urlSession: URLSession
    
    init() {
        // Create fresh URLSession
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        self.urlSession = URLSession(configuration: config)
    }
    
    // ✅ NEW: Server change hone pe ye call karo
    func refreshBaseURL() {
        // Clear all tokens when server changes
//        KeychainHelper.shared.clearToken()
        
        // Create new URLSession to avoid cached connections
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        self.urlSession = URLSession(configuration: config)
        
        print("🔄 APIService refreshed with new base URL: \(APIConfig.baseURL)")
    }
    
    
    
    private let decoder = JSONDecoder()
    private var refreshPublisher: AnyPublisher<String, Error>? // single-flight refresh
  
    
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Login
    func login(username: String, password: String) -> AnyPublisher<AuthResponse, Error> {
        guard let url = URL(string: APIEndpoints.login) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        print(" LOGIN URL:", url.absoluteString)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "username": username,
            "password": password,
            "deviceId": UIDevice.current.identifierForVendor?.uuidString ?? "test",
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
            "web": false
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        print("Sending login request for username: \(username)")
        
        return urlSession.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Login failed response: \(jsonString)")
                    }
                    throw URLError(.badServerResponse)
                }
                print("Login response: \(String(data: data, encoding: .utf8) ?? "")")
                return data
            }
            .decode(type: AuthResponse.self, decoder: decoder)
            .handleEvents(receiveOutput: { auth in
                KeychainHelper.shared.saveToken(auth.accessToken)
                print(" Logged in as: \(auth.username)")
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: - Refresh token
   /* func refreshToken() -> AnyPublisher<String, Error> {
        if let existing = refreshPublisher { return existing }
        
        guard let url = URL(string: APIEndpoints.refreshToken) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        let request = URLRequest(url: url)
        print("Sending refresh token request")
        
        let publisher = urlSession.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Refresh failed response: \(jsonString)")
                    }
                    throw URLError(.badServerResponse)
                }
                print(" Refresh response: \(String(data: data, encoding: .utf8) ?? "")")
                return data
            }
            .decode(type: RefreshResponse.self, decoder: decoder)
            .map { $0.data }
            .handleEvents(receiveOutput: { token in
                KeychainHelper.shared.saveToken(token)
                print("New token saved after refresh: \(token.prefix(20))...")
            }, receiveCompletion: { _ in
                self.refreshPublisher = nil
            }, receiveCancel: {
                self.refreshPublisher = nil
            })
            .share()
            .eraseToAnyPublisher()
        
        refreshPublisher = publisher
        return publisher
    }*/
    
    func refreshToken() -> AnyPublisher<String, Error> {
        if let existing = refreshPublisher { return existing }
        
        guard let oldToken = KeychainHelper.shared.getToken() else {
            return Fail(error: URLError(.userAuthenticationRequired)).eraseToAnyPublisher()
        }
        
        // Build URL with oldToken query param
        var components = URLComponents(string: APIEndpoints.refreshToken)!
        components.queryItems = [URLQueryItem(name: "oldToken", value: oldToken)]
        
        guard let url = components.url else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        print("Sending refresh token request with oldToken: \(oldToken.prefix(20))...")
        
        let publisher = urlSession.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Refresh failed response: \(jsonString)")
                    }
                    throw URLError(.badServerResponse)
                }
                print(" Refresh response: \(String(data: data, encoding: .utf8) ?? "")")
                return data
            }
            .decode(type: RefreshResponse.self, decoder: decoder)
            .map { $0.data }
            .handleEvents(receiveOutput: { token in
                KeychainHelper.shared.saveToken(token)
                print("New token saved after refresh: \(token.prefix(20))...")
            }, receiveCompletion: { _ in
                self.refreshPublisher = nil
            }, receiveCancel: {
                self.refreshPublisher = nil
            })
            .share()
            .eraseToAnyPublisher()
        
        refreshPublisher = publisher
        return publisher
    }

    
    // MARK: - Generic request helper
    private func performRequest<T: Decodable>(makeRequest: @escaping (String?) -> URLRequest)
    -> AnyPublisher<T, Error> {
        
        let request = makeRequest(KeychainHelper.shared.getToken())
        
        return urlSession.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
                if http.statusCode == 401 {
                    print(" 401 Unauthorized - will try refresh token")
                    throw URLError(.userAuthenticationRequired)
                }
                guard 200..<300 ~= http.statusCode else {
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print(" Request failed: \(jsonString)")
                    }
                    throw URLError(.badServerResponse)
                }
                print(" Request success: \(String(data: data, encoding: .utf8) ?? "")")
                return data
            }
            .catch { error -> AnyPublisher<Data, Error> in
                if let urlError = error as? URLError, urlError.code == .userAuthenticationRequired {
                    return self.refreshToken()
                        .flatMap { newToken -> AnyPublisher<Data, Error> in
                            let retryRequest = makeRequest(newToken)
                            print(" Retrying request with new token")
                            return self.urlSession.dataTaskPublisher(for: retryRequest)
                                .tryMap { data, response -> Data in
                                    guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
                                        if let jsonString = String(data: data, encoding: .utf8) {
                                            print(" Retry failed: \(jsonString)")
                                        }
                                        throw URLError(.badServerResponse)
                                    }
                                    print("Retry success: \(String(data: data, encoding: .utf8) ?? "")")
                                    return data
                                }
                                .mapError { $0 as Error }
                                .eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                }
                return Fail(error: error).eraseToAnyPublisher()
            }
            .decode(type: T.self, decoder: decoder)
            .catch { error -> AnyPublisher<T, Error> in
                print(" Decoding failed: \(error)")
                return Fail(error: error).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    
    
}



extension APIService {
    
   
    func fetchPermits(scope: PermitScope,
                      state: PermitState,
                      startDate: Date,
                      endDate: Date,
                      offset: Int = 0) -> AnyPublisher<[Permit], Error> {
        
        let start = startDate.toAPIDate()
        let end   = endDate.toAPIDate()
        
        return performRequest { token in
            
            guard let url = PermitURLBuilder.makeURL(scope: scope,
                                                     state: state,
                                                     startDate: start,
                                                     endDate: end,
                                                     offset: offset)
            else {
                preconditionFailure("❌ Invalid Permit URL")
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // -------------------------------------------------
            // 🔥 **MOST IMPORTANT FIX: USE REFRESHED TOKEN**
            // -------------------------------------------------
            if let token = token {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            // -------------------------------------------------
            // 📄 PRINT LOGS — FULL DEBUGGING
            // -------------------------------------------------
            print("────────────────────────────")
            print("📡 [FETCH PERMITS REQUEST]")
            print("🌍 PermitssURL:", url.absoluteString)
            print("🔐 Token:", token?.prefix(25) ?? "nil", "...")
            print("📬 Headers:", request.allHTTPHeaderFields ?? [:])
            print("────────────────────────────")
            
            return request
        }
        .tryMap { (response: PermitResponse) -> [Permit] in
            
            // JSON PRINT LOG
            if let data = try? JSONEncoder().encode(response),
               let json = String(data: data, encoding: .utf8) {
                print("📦 [API RAW JSON RESPONSE]")
                print(json)
            }
            
            print("✅ [SUCCESS] permits fetched:", response.data.count)
            return response.data
        }
        .handleEvents(receiveSubscription: { _ in
            print("🔄 [START] Fetching permits...")
        }, receiveOutput: { permits in
            print("📋 [OUTPUT] Received:", permits.count)
        }, receiveCompletion: { completion in
            switch completion {
            case .finished:
                print("🎉 [FINISHED] fetchPermits completed")
            case .failure(let error):
                print("❌ [FAILED] Error in fetchPermits:", error.localizedDescription)
            }
        })
        .eraseToAnyPublisher()
    }
    
    
    
    func fetchIncidentPermits(
        startDate: Date,
        endDate: Date,
        offset: Int = 0
    ) -> AnyPublisher<[Permit], Error> {

        let start = startDate.toAPIDate()
        let end   = endDate.toAPIDate()

//        let urlString =
//        "https://test.deltafour.co/api/v1/workflow/auxiliary/permits" +
//        "?status=null" +
//        "&startDate=\(start)" +
//        "&endDate=\(end)" +
//        "&plantRequired=false" +
//        "&offset=\(offset)"

        let urlString = APIEndpoints.incidentPermits(
            start: start,
            end: end,
            offset: offset
        )
        
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        return performRequest { token in
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            if let token = token {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }

            print("📡 [FETCH INCIDENT REQUEST]")
            print("🌍 URL:", url.absoluteString)

            return request
        }
        .tryMap { (response: PermitResponse) -> [Permit] in
            print("✅ Incident permits fetched:", response.data.count)
            return response.data
        }
        .eraseToAnyPublisher()
    }

    
    
}


extension APIService {
    
    /// Fetch Permit Detail by ID
//    func fetchPermitDetail(permitId: Int) -> AnyPublisher<ViewPermitResponse, Error> {
//        guard let url = URL(string: APIEndpoints.permitDetail + "?permit_id=\(permitId)") else {
//            
//            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
//        }
//        print("Permit Detail urll: \(url)")
//        return performRequest(makeRequest: { token in
//            var req = URLRequest(url: url)
//            req.httpMethod = "GET"
//            if let token = token, !token.isEmpty {
//                req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//            }
//            return req
//        })
//        .handleEvents(receiveOutput: { response in
//            print("Permit Detail Response: \(response)")
//        })
//        .eraseToAnyPublisher()
//    }
    
    func fetchPermitDetail(
        permitId: Int,
        type: WorkflowDetailType = .permit
    ) -> AnyPublisher<ViewPermitResponse, Error> {

        let urlString: String

//        switch type {
//        case .permit:
//            urlString =
//                APIConfig.baseURL +
//                "v1/workflow/permit?permit_id=\(permitId)"
//
//        case .incident:
//            urlString =
//                APIConfig.baseURL +
//                "v1/workflow/auxiliary/permit?permit_id=\(permitId)"
//        }

        switch type {
        case .permit:
            urlString = APIEndpoints.permitDetail(permitId: permitId)

        case .incident:
            urlString = APIEndpoints.incidentDetail(permitId: permitId)
        }
        
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        print("📡 Fetching \(type) permit detail:", url.absoluteString)

        return performRequest(makeRequest: { token in
            var req = URLRequest(url: url)
            req.httpMethod = "GET"

            if let token = token, !token.isEmpty {
                req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }

            return req
        })
        .handleEvents(receiveOutput: { response in
            print("✅ Permit Detail Response:", response)
        })
        .eraseToAnyPublisher()
    }

}

enum UploadError: Error {
    case imageEncodingFailed
}


extension APIService{
    
    
    func fetchCampaignPermit(
        permitId: Int
    ) -> AnyPublisher<ViewPermitResponse, Error> {

//        let url = URL(
//            string: "https://test.deltafour.co/api/v1/workflow/permit?permit_id=\(permitId)"
//        )!

        guard let url = URL(
            string: APIEndpoints.permitDetail(permitId: permitId)
        ) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: ViewPermitResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

}
