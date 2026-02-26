//
//  PermitScreenViewModel.swift
//  Lloyds
//
//  Created by Manisha on 24/12/25.
//


import Foundation
import Combine
import CoreLocation

class PermitScreenViewModel: ObservableObject {
    
    @Published var pnePolygon: [CLLocationCoordinate2D] = []
    
//    @Published var closedPermitUUIDs: Set<String> = []
    @Published var closedPermitIds: Set<Int> = []
    static let shared = PermitScreenViewModel()
    
    @Published var isLoading: Bool = false
    @Published var isInitialLoadDone: Bool = false
    
    @Published var username: String = ""
    @Published var companyName: String = ""
    @Published var userImageURL: String?
    @Published var currentUser: String = ""
    
    @Published var totalCount: Int = 0
    @Published var lastSyncTime: String = ""
    
    @Published var permits: [Permit] = [] {
        didSet { applySearchFilter() }
    }
    
    var createdBy: String?
    var createdAt: String?
    
    @Published var filteredPermits: [Permit] = []
    
    @Published var searchText: String = "" {
        didSet { applySearchFilter() }
    }
    
    @Published var isActiveTab: Bool = true
    {      // true = Active, false = Completed
        didSet { resetAndFetch()
            }
    }
    
    @Published var isForMe: Bool = false {         // false = All, true = For Me
        didSet { resetAndFetch() }
    }
    
    // Date filters
    @Published var startDate: Date = Date().startOfDay() {
        didSet { resetAndFetch() }
    }
    @Published var endDate: Date = Date().endOfDay() {
        didSet { resetAndFetch() }
    }
    
    // Pagination
    @Published var offset: Int = 0
    private let pageSize: Int = 20
    
    @Published var lastSync: Date = Date()
    
    private var cancellables = Set<AnyCancellable>()
    
    
    // MARK: - User
    func fetchUser() {
        guard let user = UserDefaultsHelper.shared.getUser() else { return }
        
        self.username = user.username ?? ""
        self.companyName = user.company_account_name.replacingOccurrences(of: "_", with: " ")
    }
    
    
    // MARK: - Reset + Fetch
    func resetAndFetch() {
//        guard isInitialLoadDone else { return }
        
        offset = 0
        fetchPermits(append: false)
    }
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshUser), name: .userDidLogin, object: nil)
        
        NotificationCenter.default.addObserver(
            forName: .didUpdateObservation,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            
            if let permitId = notification.object as? Int {
                print("✅ Closed Permit ID received:", permitId)
                
                self?.closedPermitIds.insert(permitId)
                
                //  ADD THIS LINE (MOST IMPORTANT)
                self?.removeClosedPermit(id: permitId)
                self?.resetAndFetch()
            }
        }
    }

    @objc func refreshUser() {
        fetchUser()
    }

    func removeClosedPermit(id: Int) {
        permits.removeAll { $0.id == id }
        applySearchFilter()
    }
    
    
    // MARK: - Filter
    func applySearchFilter() {
        
        
         
        
        
        
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            filteredPermits = permits
        } else {
            let q = trimmed.lowercased()
            filteredPermits = permits.filter { permit in
                (permit.title?.lowercased().contains(q) ?? false)
            }
        }
    }
    
 

       
    
    
    // MARK: - Fetch Permits
    func fetchPermits(append: Bool = false) {
        print("🚀 DEBUG 3: API Call Ho Rahi Hai... Tab State: \(isActiveTab)")
        let scope: PermitScope = isForMe ? .me : .all
        let state: PermitState = isActiveTab ? .active : .completed
        
        print("Fetching | scope: \(scope) state: \(state) offset: \(offset) append: \(append)")
        
        
        if !append && !permits.isEmpty {
            print("Keeping existing permits while updating…")
        }
        
        isLoading = true
        
        APIService.shared.fetchPermits(
            scope: scope,
            state: state,
            startDate: startDate,
            endDate: endDate,
            offset: offset
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            guard let self = self else { return }
            self.isLoading = false
            
            if case let .failure(error) = completion {
                print("❌ Error fetching permits:", error)
            }
        } receiveValue: { [weak self] newPermits in
            guard let self = self else { return }
            
            print("📦 RECEIVED PERMITS COUNT:", newPermits.count)

            newPermits.forEach { permit in
                print("➡️ permit.id:", permit.id)
                print("➡️ permit.uuid:", permit.uuid ?? "nil")
                print("➡️ permitStatus:", permit.status ?? "nil")
                print("➡️ finishedAt:", permit.title ?? -1)
                print("-----------")
                
            }
            
            
            do {
                let data = try JSONEncoder().encode(newPermits)
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📦 PermittJSON RESPONSE:\n\(jsonString)")
                }
            } catch {
                print("❌ Failed to encode response:", error)
            }
            
            
            if append {
                self.permits += newPermits
            } else {
                // 🔥 FIX 2 → Only replace on fresh load
                self.permits = newPermits
            }
            
            self.lastSync = Date()
            
            // save IDs for debugging
            let ids = self.permits.map { "\($0.id)" }.joined(separator: ",")
            UserDefaults.standard.set(ids, forKey: "savedPermitIds")
            print("Saved permit IDs:", ids)
        }
        .store(in: &cancellables)
    }
    
    
    // MARK: - First Load
    func initialize() {
        if !isInitialLoadDone {
            isInitialLoadDone = true
            fetchPermits(append: false)
            loadUserInfo()
        }
    }
    
    
    // MARK: - Pagination
    func loadNextPageIfNeeded(currentPermit: Permit) {
        guard let last = permits.last else { return }
        
        if currentPermit.id == last.id {
            offset += pageSize
            fetchPermits(append: true)
        }
    }
    
    
    // MARK: - Image Upload Success
    func onImageUploadSuccess() {
        resetAndFetch()
    }
    
    
    func sync() { resetAndFetch() }
    func addPermit() { print("Add Permit tapped") }
    
    
    
    func loadUserInfo() {
            if let savedCompanyName = UserDefaults.standard.string(forKey: "companyName") {
                self.companyName = savedCompanyName
                print("✅ Company name loaded: \(savedCompanyName)")
            } else {
                self.companyName = "User" // Default fallback
                print("⚠️ No company name in UserDefaults, using default")
            }
            
            if let savedUsername = UserDefaults.standard.string(forKey: "username") {
                self.username = savedUsername
                print("✅ Username loaded: \(savedUsername)")
            }
        }
    
    
   
    
}
