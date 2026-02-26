//
//  PermitScreenView.swift
//  Lloyds
//
//  Created by Manisha on 24/12/25.
//






import SwiftUI
import CoreLocation

struct PermitScreenView: View {

    // MARK: - Bottom Tabs
    enum BottomTab {
        case campaign
        case incident
    }

    @State private var selectedTab: BottomTab = .campaign

    @StateObject private var viewModel = PermitScreenViewModel()
    @StateObject private var incidentVM = IncidentViewModel()

    @EnvironmentObject var appState: AppStateManager

    @State private var showDatePicker = false
    @State private var showSearch = false
    @State private var searchText = ""

    // FAB
    @State private var showFABMenu = false
    @State private var navigateToCreateCampaign = false
    @State private var navigateToCreateIncident = false
    @State private var showSideMenu = false

    
    @Environment(\.scenePhase) private var scenePhase
    
    var openCompleted: Bool = false
    
    @State private var currentTime = Date()
    
    var body: some View {
        if #available(iOS 16.0, *) {
           // NavigationStack {
            ZStack {
                VStack(spacing: 12) {

                    // MARK: Header
                    HStack {
                        Button {
                               withAnimation {
                                   showSideMenu = true
                               }
                           } label: {
                               Text("Hi \(viewModel.username) !")
//                               Text("Hi \(viewModel.currentUser)!")
                                   .font(.title3)
                                   .bold()
                           }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)

                    // MARK: Active / Completed
                    Picker("", selection: $viewModel.isActiveTab) {
                        Text("Active").tag(true)
                        Text("Completed").tag(false)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
//                    .onChange(of: viewModel.isActiveTab) { _ in
//                        viewModel.fetchPermits()
//                    }
                    
                   

                    .onChange(of: viewModel.isActiveTab) { _ in
                        
                        if selectedTab == .campaign {
                            viewModel.resetAndFetch()
                        } else {
                            incidentVM.fetchIncidents(start: viewModel.startDate, end: viewModel.endDate)
                        }
                    }
                    
                    // MARK: Search Bar
                    if showSearch {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            TextField("Search permits...", text: $searchText)
                            Button {
                                showSearch = false
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                            }
                        }
                        .padding(.horizontal)
                    }

                    // MARK: Filters
                    HStack {
//                        Button {
//                            viewModel.isForMe = false
//                            viewModel.fetchPermits()
//                        } label: {
//                            Text("all campaign")
//                                .padding(.horizontal, 12)
//                                .padding(.vertical, 6)
//                                .background(viewModel.isForMe ? Color(.systemGray5) : .blue)
//                                .foregroundColor(viewModel.isForMe ? .black : .white)
//                                .cornerRadius(16)
//                        }
//
//                        Button {
//                            viewModel.isForMe = true
//                            viewModel.fetchPermits()
//                        } label: {
//                            Text("for me")
//                                .padding(.horizontal, 12)
//                                .padding(.vertical, 6)
//                                .background(viewModel.isForMe ? .blue : Color(.systemGray5))
//                                .foregroundColor(viewModel.isForMe ? .white : .black)
//                                .cornerRadius(16)
//                        }

                        Spacer()

                        Button {
                            showSearch.toggle()
                        } label: {
                            Image(systemName: "magnifyingglass")
                        }

                        Button {
                            showDatePicker = true
                        } label: {
                            Image(systemName: "calendar")
                        }
                    }
                    .padding(.horizontal)

                    // MARK: Date + Count
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text("from \(viewModel.startDate.toDisplay()) to \(viewModel.endDate.toDisplay())")
//                            .font(.footnote)
//
////
//                    }
                    //.padding(.horizontal)

                    VStack(alignment: .leading, spacing: 6) {
                        
                        Text("From \(viewModel.startDate.toDisplay()) to \(viewModel.endDate.toDisplay())")
                            .font(.footnote)

                        HStack {
                            Text("\(viewModel.filteredPermits.count) Items")
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            Spacer()

                            Text("Last Sync \(viewModel.lastSync.timeAgoDisplay())")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                    
                    
                    
                    
                    
                    // MARK: Content
                    Group {
                        if selectedTab == .campaign {
                            campaignListView
                        } else {
                            incidentView
                        }
                    }
                }
            
           

                VStack(spacing: 12) {
                    
                }

                if showSideMenu {
                    if let user = UserDefaultsHelper.shared.getUser() {
                        SideMenuView(showMenu: $showSideMenu,
                                     user: user)
                    }

                }
            }

            
            
//                .onAppear {
//
//                    viewModel.fetchUser()
//                    viewModel.initialize()
//                    viewModel.loadUserInfo()
////                    viewModel.resetAndFetch()
//                    
//                    
//                    if openCompleted {
//                          
//                           viewModel.isActiveTab = false
//                       } else {
//                           viewModel.resetAndFetch()
//                       }
//                
//                    }
            
            .onAppear {
                viewModel.fetchUser()
                viewModel.loadUserInfo()
                viewModel.isInitialLoadDone = true
                
                
                NotificationCenter.default.addObserver(
                       forName: .didUpdateObservation,
                       object: nil,
                       queue: .main
                   ) { _ in
                       print("🔄 Notification received → refreshing")
                       viewModel.resetAndFetch()
                   }

                if openCompleted {
                       viewModel.isActiveTab = false   // 👈 Completed tab
                   } else {
                       viewModel.isActiveTab = true    // 👈 Active tab
                   }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                       viewModel.fetchPermits(append: false)
                   }
                
                
                Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                    currentTime = Date()
                }
                
            }
            
            
                .onChange(of: scenePhase) { phase in
                    if phase == .active && !openCompleted {  // ✅ sirf normal case mein refresh
                        refreshScreen()
                    }
                }
            
                .onReceive(NotificationCenter.default.publisher(for: .didUpdateObservation)) { _ in
                    print("🔄 Refresh from notification")
                   
                    viewModel.fetchPermits(append: false)
                }
            
                .navigationDestination(isPresented: $navigateToCreateCampaign) {
                    CreateCampaignView()
                }
                .navigationDestination(isPresented: $navigateToCreateIncident) {
                    CreateIncidentReportView()
                }
                .sheet(isPresented: $showDatePicker) {
                    VStack {
                        DatePicker("Start Date", selection: $viewModel.startDate, displayedComponents: .date)
                        DatePicker("End Date", selection: $viewModel.endDate, displayedComponents: .date)

                        Button("Apply Dates") {
                            viewModel.resetAndFetch()
                            showDatePicker = false
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
                // 🔥 MOST IMPORTANT FIX
                .safeAreaInset(edge: .bottom) {
                    bottomBarWithFAB
                }
                .navigationBarBackButtonHidden(true)
                .interactiveDismissDisabled(true)

           
        }
    }

    
   
    private func refreshCurrentTabData() {
        if selectedTab == .campaign {
            viewModel.resetAndFetch()
        } else {
            incidentVM.fetchIncidents(start: viewModel.startDate, end: viewModel.endDate)
        }
    }
    
    private func refreshScreen() {
        print("🔄 SCREEN REFRESH")

        if selectedTab == .campaign {
            viewModel.resetAndFetch()
        } else {
            incidentVM.fetchIncidents(
                start: viewModel.startDate,
                end: viewModel.endDate
            )
        }
    }
    
    // MARK: - Campaign List (FIXED)
    private var campaignListView: some View {
        Group {
            if searchFilteredPermits.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)

                    Text("0 Permits")
                        .foregroundColor(.gray)
                        .font(.headline)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(searchFilteredPermits) { permit in
//
                            
                            // In campaignListView:
//                            NavigationLink(
//                                destination: ViewPermitView(
//                                    permitId: permit.id,
//                                    permittitle: permit.title ?? "",
//                                    permit: permit,
//                                    isIncident: false  // ✅ Campaign
//                                )
//                            ) {
//                                PermitCardView(permit: permit)
//                            }

                            NavigationLink(
                                destination: ViewPermitView(
                                                            permitId: permit.id,
                                                            permittitle: (selectedTab == .campaign ? permit.title : permit.resolvedTitle) ?? "",
                                                            permit: permit,
                                                            isIncident: selectedTab == .incident,  isCompleted: !viewModel.isActiveTab // Automatically sets true/false
                                                        )
                                                    ) {
                                                        PermitCardView(permit: permit)
                                                    }
                            
                            
                            
                            // In incidentView:
//                            NavigationLink(
//                                destination: ViewPermitView(
//                                    permitId: permit.id,
//                                    permittitle: permit.resolvedTitle ?? "",
//                                    permit: permit,
//                                    isIncident: true  // ✅ Incident
//                                )
//                            ) {
//                                PermitCardView(permit: permit)
//                            }
                            
                            .onAppear {
                                viewModel.loadNextPageIfNeeded(currentPermit: permit)
                                
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 120) // FAB + bottom bar space
                }
                .refreshable {
                    viewModel.resetAndFetch()
                }
            }
        }
    }

    // MARK: Incident Placeholder

    private var incidentView: some View {
        Group {
            if incidentVM.isLoading {
                ProgressView("Loading incidents...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else if incidentVM.incidents.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)

                    Text("0 Incidents")
                        .foregroundColor(.gray)
                        .font(.headline)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(incidentVM.incidents) { permit in
                            NavigationLink(
                                destination: ViewPermitView(
                                    permitId: permit.id,
                                    permittitle: permit.resolvedTitle ?? "",
                                    permit: permit, isIncident: true,  isCompleted: !viewModel.isActiveTab
                                )
                            ) {
                                PermitCardView(permit: permit)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 120)
                }
            }
        }
        .onAppear {
            incidentVM.fetchIncidents(
                start: viewModel.startDate,
                end: viewModel.endDate
            )
        }
    }


    // MARK: Bottom Bar + FAB (SAFE)
    private var bottomBarWithFAB: some View {
        ZStack {

            HStack {
                Button {
                    selectedTab = .campaign
                } label: {
                    VStack {
                        Image(systemName: "megaphone.fill")
                        Text("Campaign").font(.footnote)
                    }
                    .foregroundColor(selectedTab == .campaign ? .blue : .gray)
                }

                Spacer()

                Button {
                    selectedTab = .incident
                } label: {
                    VStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text("Incident").font(.footnote)
                    }
                    .foregroundColor(selectedTab == .incident ? .blue : .gray)
                }
            }
            .padding(.horizontal, 50)
            .padding(.vertical, 14)
            .background(Color(.systemGray6))
            .cornerRadius(30)
            .padding(.horizontal, 16)

            VStack {
                if showFABMenu {
                    Button {
                        showFABMenu = false
                        navigateToCreateCampaign = true
                    } label: {
                        Text("Create Campaign")
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(22)
                    }
                    
                    Button {
                        showFABMenu = false
                        navigateToCreateIncident = true
                    } label: {
                        Text("Create incident report")
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(22)
                    }
                }

                Button {
                    withAnimation {
                        showFABMenu.toggle()
                    }
                } label: {
                    Image(systemName: showFABMenu ? "xmark" : "plus")
                        .foregroundColor(.white)
                        .frame(width: 64, height: 64)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(radius: 6)
                }
            }
            .offset(y: -36)
        }
        .padding(.bottom, 8)
    }

    // MARK: Search Filter
    private var searchFilteredPermits: [Permit] {
        if searchText.isEmpty {
            return viewModel.filteredPermits
        }
        return viewModel.filteredPermits.filter {
            $0.title?.lowercased().contains(searchText.lowercased()) == true
        }
    }
}


extension Date {
    func timeAgoDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        
        if secondsAgo < minute {
            return "just now"
        } else if secondsAgo < hour {
            return "\(secondsAgo / minute) min ago"
        } else {
            return "\(secondsAgo / hour) hr ago"
        }
    }
}
