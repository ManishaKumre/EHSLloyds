//
//  ViewPermitView.swift
//  Lloyds
//
//  Created by Manisha on 24/12/25.
//

//



import SwiftUI

struct ViewPermitView: View {

    @StateObject private var viewModel = ViewPermitViewModel()

    let permitId: Int
    let permittitle: String
    let permit: Permit?
    let isIncident: Bool
    let isCompleted: Bool   // 👈 ADD THIS
    // 🔥 FAB STATES
    @State private var showFabMenu = false
    @State private var navigateToCreateCampaign = false
    @State private var selectedObservation: Observation? = nil
    @State private var showObservationPopup = false
    @State private var expandedSections: Set<String> = ["Work Summary"]

    @State private var showActionAlert = false
    @State private var selectedAction: String = ""
    @State private var isLoadingAction = false
    @State private var navigateToSSScreen = false
    @State private var navigateToAddTeamLead = false
    
    @State private var navigateToAction = false
    @State private var selectedObservationForAction: Observation? = nil
    @State private var navigateToRCAScreen = false
    @State private var navigateToAuditTrail = false
    @Environment(\.dismiss) var dismiss
    

    var body: some View {
        ZStack {

            VStack(spacing: 0) {

                headerView
//              sectionsView
                if isIncident {
                    incidentDetailView
                } else {
                    sectionsView   // ✅ Campaign ka existing UI
                }
                NavigationLink(
                    destination: CreateCampaignView(),
                    isActive: $navigateToCreateCampaign
                ) {
                    EmptyView()
                }
                
                
                NavigationLink(
                               destination: IncidentReportView(),
                               isActive: $navigateToSSScreen
                           ) {
                               EmptyView()
                           }
                
                NavigationLink(
                    destination: AddTeamLeadView(permitId: permitId), // Aapki nayi screen
                    isActive: $navigateToAddTeamLead
                ) {
                    EmptyView()
                }
                
                NavigationLink(
                    destination: RCAScreenView(permitId: permitId), // Aapki nayi screen
                    isActive: $navigateToRCAScreen
                ) {
                    EmptyView()
                }
                
                NavigationLink(
                    destination: AuditTrailView(permitId: permitId),
                    isActive: $navigateToAuditTrail
                ) {
                    EmptyView()
                }
                
            }

           // fabView
        }

        
        .onAppear {
            if isIncident {
                viewModel.loadIncidentDetail(permitId: permitId)  // ✅ Incident API
            } else {
             //   viewModel.reset()
                            viewModel.permitId = permitId
                viewModel.loadPermitDetail(permitId: permitId)    // ✅ Campaign API
            }
            viewModel.permitId = permitId
            print("🟢 PermitId set:", permitId)
        }
        
        .onReceive(NotificationCenter.default.publisher(for: .didUpdateObservation)) { _ in
            print("🔄 ViewPermitView REFRESH")
            viewModel.loadPermitDetail(permitId: permitId)
        }
        

        .navigationDestination(isPresented: $viewModel.navigateToPermitType) {
          
            let _ = print("🚀 DEBUG: Navigating to PermitScreenView with openCompleted: \(viewModel.actionWasClose)")
            PermitScreenView(openCompleted: viewModel.actionWasClose)
        }
        
        
        
        .navigationTitle("View Campaign")
        .navigationBarTitleDisplayMode(.automatic)
    }
    
    
    
}
private extension ViewPermitView {

    var headerView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(permittitle)
                .font(.title3)
                .bold()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}


private extension ViewPermitView {

    var workSummarySection: ViewPermitSection? {
        guard let sections = viewModel.permitDetail?.data?.sections else {
            return nil
        }

        return sections.first {
            ($0.title ?? "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased() == "work summary"
        }
    }

    var observationSections: [ViewPermitSection] {
        guard let sections = viewModel.permitDetail?.data?.sections else {
            return []
        }

        return sections.filter {
            ($0.title ?? "")
                .lowercased()
                .contains("observation")
        }
    }
}


private extension ViewPermitView {

    
    var sectionsView: some View {
        let sections = viewModel.permitDetail?.data?.sections ?? []
        
        let hasObservations = sections.contains {
            $0.title?.lowercased().contains("observation") == true
        }

        return ZStack {
            ScrollView {
                VStack(spacing: 16) {
                    if viewModel.permitDetail == nil {
                        ProgressView("Loading Campaign...")
                    } else {

                        // 1. DYNAMIC SECTIONS FROM JSON
                        ForEach(Array(sections.enumerated()), id: \.offset) { index, section in
                            
                            if let fields = section.fields {
                                let detailFields = fields.filter { $0.type == "DETAIL_LABEL" }
                                
                                if !detailFields.isEmpty {
                                    DynamicSectionView(section: section)
                                }
                            }
                        }

                        // 2. OBSERVATION CARDS
                        if hasObservations {
//                            ForEach(Array(viewModel.observations.enumerated()), id: \.element.id) { index, observation in
                            
                            let _ = print("🔵 viewModel.observations count: \(viewModel.observations.count)")
                                let _ = print("🔵 filteredObservations count: \(filteredObservations.count)")
                                let _ = print("🔵 loggedInUserType: \(UserDefaults.standard.string(forKey: "loggedInUserType") ?? "EMPTY")")
                            
                            ForEach(Array(filteredObservations.enumerated()), id: \.element.id){ index, observation in
                                
                                let _ = print("""
                                  🧾 OBS DEBUG
                                  desc: \(observation.enterObservationDescription ?? "nil")
                                  priority: \(observation.selectPriority ?? "nil")
                                  status: \(observation.selectStatus ?? "nil")
                                  """)
                                let showTakeAction = canTakeAction(observation: observation)
                               
                                ObservationCardView(
                                    observationIndex: index + 1,
                                    description: observation.enterObservationDescription ?? "-",
                                    dependency: observation.pendingAt ?? "-",
                                    priority: observation.selectPriority ?? "-",
                                    status: observation.selectStatus ?? "-",
                                   // actionButtonTitle: showTakeAction ? "Take Action" : "View",
                                    //actionButtonTitle: "Take Action",
                                    actionButtonTitle: "Take Action",
                                        showActionButton: !isCompleted,
                                   // showActionButton: showTakeAction && !isCompleted,
                                    onViewDetails: {
                                        selectedObservation = observation
                                        showObservationPopup = true
                                    },
                                    onTakeAction: {
                                        selectedObservationForAction = observation
                                        navigateToAction = true
                                    }
                                )
                                
                            }
                        }
                        
                        // 3. FORM ACTION BUTTON (Campaign ke liye)
                        if let sections = viewModel.permitDetail?.data?.sections,
                           let formSection = sections.first(where: { $0.title == "Form Action" }),
                           let fields = formSection.fields,
                           let firstField = fields.first {
                            
                            if isCompleted {
                                // ✅ Completed → sirf Audit Trail button dikhao
                                Button {
                                    navigateToAuditTrail = true
                                } label: {
                                    Text("Audit Trail")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .cornerRadius(30)
                                }
                            } else {
                                // ✅ Active → activeButtonsText wale buttons dikhao
                                let activeButtons = firstField.activeButtonsText ?? []
                                let deactivateText = firstField.deactivateButtonText ?? ""
                                
                                if !activeButtons.isEmpty {
                                    ForEach(activeButtons, id: \.self) { text in
                                        Button {
                                            // action handle karo
                                        } label: {
                                            Text(text)
                                                .font(.headline)
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(Color.gray)
                                                .cornerRadius(30)
                                            
                                        }
                                    }
                                } else {
                                    Button(action: {}) {
                                        Text(deactivateText.isEmpty ? "No Action Available" : deactivateText)
                                            .foregroundColor(.white)
                                            .bold()
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.gray)
                                            .cornerRadius(30)
                                    }
                                    .disabled(true)
                                }
                            }
                        }
              
                        
                    }
                }
                .padding()
            }
        }
        .navigationDestination(isPresented: $navigateToAction) {
            if let obs = selectedObservationForAction {
                ActionOnObservationView(observation: obs, statusList: viewModel.statusOptions,
                                        isPresented: $navigateToAction)
                    .environmentObject(viewModel)
            }
        }

        
        .sheet(item: $selectedObservation) { obs in
            ObservationDetailPopupView(
                observation: obs,
                isPresented: .constant(true),
                showActionButton: !isCompleted
            )
            .environmentObject(viewModel)
            .presentationDetents([.medium, .large])
        }
        
        .onChange(of: viewModel.shouldCloseObservationPopup) { value in
        if value {
            showObservationPopup = false   // 🔥 ACTUAL CLOSE
            viewModel.shouldCloseObservationPopup = false
        }
    }
    }
    

    
    var filteredObservations: [Observation] {

        
        let loggedInUserType = UserDefaults.standard.string(forKey: "loggedInUserType") ?? ""

        if isCompleted {
               return viewModel.observations
           }

        if loggedInUserType.isEmpty {
               return viewModel.observations  // ✅ sab dikhao
           }
        
        print("🟡 LoggedIn userType: '\(loggedInUserType)'")
        print("🔢 Total observations:", viewModel.observations.count)
        return viewModel.observations.filter { observation in
            let pendingAt = observation.pendingAt ?? ""

            print("""
            🔍 FILTER CHECK
            desc     : \(observation.enterObservationDescription ?? "")
            pendingAt: '\(pendingAt)'
            loggedIn : '\(loggedInUserType)'
            MATCH    : \(pendingAt == loggedInUserType)
            """)

            return pendingAt.uppercased().trimmingCharacters(in: .whitespaces)
                == loggedInUserType.uppercased().trimmingCharacters(in: .whitespaces)
        }
    }
    
    
    func canTakeAction(observation: Observation) -> Bool {

        guard let userType = viewModel.permitDetail?.data?.permitState?.userType else {
            return false
        }

        switch userType {

        case "EXECUTOR":
            return observation.isActionToBeTakenByE == true

        case "AREA_OWNER":
            return observation.isActionToBeTakenByAO == true

        case "OBSERVER":
            return observation.isActionToBeTakenByO == true

        default:
            return false
        }
    }
    
    
    
}


private extension ViewPermitView {
    
    struct DynamicSectionView: View {
        let section: ViewPermitSection // Updated name as per your model
        @State private var isExpanded: Bool

        init(section: ViewPermitSection) {
            self.section = section
           
            _isExpanded = State(initialValue: section.expanded ?? false)
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                if let title = section.title {
                    Button(action: {
                        if section.expandable == true {
                            withAnimation { isExpanded.toggle() }
                        }
                    }) {
                        HStack {
                            Text(title)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(hex: "00529B")) // Primary Blue
                            Spacer()
                            if section.expandable == true {
                                Image(systemName: "chevron.right")
                                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.05))
                    }
                }

                // Fields Logic
                if isExpanded || (section.expandable ?? false) == false {
                    VStack(alignment: .leading, spacing: 12) {
                        if let fields = section.fields {
                            ForEach(fields, id: \.name) { field in
                                renderField(field)
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2)
        }

        @ViewBuilder
        private func renderField(_ field: PermitField) -> some View {
            VStack(alignment: .leading, spacing: 4) {
                switch field.type {
                case "DETAIL_LABEL":
                    HStack(alignment: .top, spacing: 10) {
                        // Icon logic from your JSON
                        Image(field.iconName ?? "ic_worktype")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading) {
                            Text(field.name ?? "")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(field.description ?? "-")
                                .font(.system(size: 14, weight: .medium))
                        }
                    }

                case "SECTION_HEADER":
                    Text(field.name ?? "")
                        .font(.subheadline).bold()
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(6)
                        .padding(.top, 8)

                case "DROPDOWN_SINGLE", "DROPDOWN_MULTI_FILTER":
                    FieldTitleView(title: field.name ?? "", isRequired: field.required ?? false)
                    HStack {
                        Text(field.description ?? "Select")
                        Spacer()
                        Image(systemName: "chevron.down").font(.caption)
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))

                case "TEXTBOX":
                    FieldTitleView(title: field.name ?? "", isRequired: field.required ?? false)
                    Text(field.description ?? "")
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))

                case "BUTTON":
                    Button(action: { /* Handle action */ }) {
                        Text(field.name ?? "Submit")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(field.editable == true ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)

                default:
                    EmptyView()
                }
            }
        }
    }

    // Helper view for required labels
    struct FieldTitleView: View {
        let title: String
        let isRequired: Bool
        var body: some View {
            HStack(spacing: 2) {
                Text(title).font(.caption).foregroundColor(.secondary)
                if isRequired { Text("*").foregroundColor(.red) }
            }
        }
    }
    
  

    var fabView: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()

                VStack(alignment: .trailing, spacing: 14) {

                    if showFabMenu {
                        fabOption(
                            title: "Create Campaign",
                            icon: "megaphone.fill"
                        ) {
                            showFabMenu = false
                            navigateToCreateCampaign = true
                        }
                    }

                    Button {
                        withAnimation(.spring()) {
                            showFabMenu.toggle()
                        }
                    } label: {
                        Image(systemName: showFabMenu ? "xmark" : "plus")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(radius: 6)
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 24)
            }
        }
    }
}
private extension ViewPermitView {

    func fabOption(
        title: String,
        icon: String,
        action: @escaping () -> Void
    ) -> some View {

        Button(action: action) {
            HStack(spacing: 10) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white)

                Image(systemName: icon)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.blue)
            .cornerRadius(22)
            .shadow(radius: 4)
        }
    }
}


private extension ViewPermitView {

    var incidentDetailView: some View {
        ScrollView {
            VStack(spacing: 14) {

                if let sections = viewModel.incidentSections {

//                
                    ForEach(sections.indices, id: \.self) { index in
                        let section = sections[index]
                        let title = section["title"] as? String ?? ""

                        // Hide Action & Form Action sections
                        if title != "Action" && title != "Form Action" {
                            dropdownSection(section)
                        }
                    }


                    dynamicIncidentActionView


                } else {
                    ProgressView("Loading Incident...")
                        .padding()
                }
            }
            .padding()
        }
        .alert("Confirm Action", isPresented: $showActionAlert) {
            
            Button("Cancel", role: .cancel) {}
            
            Button("OK") {
                callWorkflowActionAPI(action: selectedAction)
            }
            
        } message: {
            Text("Are you sure you want to \(selectedAction)?")
        }
        
       

    }
        


    
    func dropdownSection(_ section: [String: Any]) -> some View {

        let title = section["title"] as? String ?? ""
        let fields = section["fields"] as? [[String: Any]] ?? []

        return VStack(alignment: .leading, spacing: 12) {

            // Header Button
            Button(action: {
                if expandedSections.contains(title) {
                    expandedSections.remove(title)
                } else {
                    expandedSections.insert(title)
                }
            }) {
                HStack {
                    Text(title.uppercased())
                        .foregroundColor(.gray)
                        .font(.headline)

                    Spacer()

                    Image(systemName:
                            expandedSections.contains(title)
                          ? "chevron.up"
                          : "chevron.down")
                }
            }

            // Content
            if expandedSections.contains(title) {

                if title == "Injured Person Details" {
                    injuredTable(fields)
                } else {

                    VStack(spacing: 16) {
                        ForEach(fields.indices, id: \.self) { index in
                            let field = fields[index]

                            infoItem(
                                field["name"] as? String ?? "",
                                field["description"] ?? "-"
                            )
                        }
                    }
                    .padding()
                    .background(Color(.darkGray))
                    .cornerRadius(14)
                }
            }


        }
        .padding()
        //.background(Color(.systemGray6))
        .cornerRadius(14)
    }

    func injuredTable(_ fields: [[String: Any]]) -> some View {

        ScrollView(.horizontal, showsIndicators: false) {

            VStack(spacing: 0) {

                HStack {
                    tableHeader("Name")
                    tableHeader("Gender")
                    tableHeader("Type of Incident")
                    tableHeader("Immediate Action")
                }

                let rowSize = 8
                let rows = stride(from: 0, to: fields.count, by: rowSize)

                ForEach(Array(rows), id: \.self) { startIndex in

                    if startIndex + 7 < fields.count {

                        HStack {
                            tableCell(fields[startIndex]["name"])
                            tableCell(fields[startIndex + 1]["name"])
                            tableCell(fields[startIndex + 6]["name"])
                            tableCell(fields[startIndex + 7]["name"])
                        }
                    }
                }
            }
        }
    }

    func valueFromSection(
        _ sections: [[String: Any]],
        sectionTitle: String,
        fieldName: String
    ) -> String {

        guard let section = sections.first(where: {
            ($0["title"] as? String) == sectionTitle
        }) else { return "-" }

        guard let fields = section["fields"] as? [[String: Any]] else {
            return "-"
        }

        return fields.first(where: {
            ($0["name"] as? String) == fieldName
        })?["description"] as? String ?? "-"
    }


    func incidentTopSection(_ sections: [[String: Any]]) -> some View {

        VStack(spacing: 16) {

            HStack {
                infoItem("Incident Description",
                         valueFromSection(sections,
                                          sectionTitle: "Work Summary",
                                          fieldName: "Incident Description"))

                infoItem("Area",
                         valueFromSection(sections,
                                          sectionTitle: "Work Summary",
                                          fieldName: "Area"))
            }

            HStack {
                infoItem("Location",
                         valueFromSection(sections,
                                          sectionTitle: "Work Summary",
                                          fieldName: "Location"))

                infoItem("Start time and Date",
                         valueFromSection(sections,
                                          sectionTitle: "Work Summary",
                                          fieldName: "Start time and Date"))
            }

            HStack {
                infoItem("Unit",
                         valueFromSection(sections,
                                          sectionTitle: "Work Summary",
                                          fieldName: "Unit"))

                infoItem("Name of Witness",
                         valueFromSection(sections,
                                          sectionTitle: "Work Summary",
                                          fieldName: "Name of Witness"))
            }

            HStack {
                infoItem("Investigation Detail Findings",
                         valueFromSection(sections,
                                          sectionTitle: "Work Summary",
                                          fieldName: "Investigation Detail Findings"))
                Spacer()
            }
        }
        .padding()
        .background(Color(.darkGray))
        .cornerRadius(14)
    }


    
    func teamInfoSection(_ sections: [[String: Any]]) -> some View {

        VStack(alignment: .leading, spacing: 16) {

            Text("2. TEAM INFORMATION")
                .foregroundColor(.gray)
                .font(.headline)

            VStack(spacing: 16) {

                HStack {
                    infoItem("Team Lead",
                             valueFromSection(sections,
                                              sectionTitle: "Team Information",
                                              fieldName: "Team Lead"))

                    infoItem("Team Info",
                             valueFromSection(sections,
                                              sectionTitle: "Team Information",
                                              fieldName: "Team Info"))
                }
            }
            .padding()
            
            .cornerRadius(14)
        }
    }


    func injuredPersonSection(_ sections: [[String: Any]]) -> some View {

        guard let section = sections.first(where: {
            ($0["title"] as? String) == "Injured Person Details"
        }),
        let grids = section["grids"] as? [[String: Any]],
        let firstGrid = grids.first,
        let fields = firstGrid["fields"] as? [[String: Any]]
        else {
            return AnyView(EmptyView())
        }

        return AnyView(
            VStack(alignment: .leading, spacing: 16) {

                Text("3. INJURED PERSON DETAILS")
                    .foregroundColor(.gray)
                    .font(.headline)

                ScrollView(.horizontal, showsIndicators: false) {

                    VStack(spacing: 0) {

                        HStack {
                            tableHeader("Name")
                            tableHeader("Gender")
                            tableHeader("Type of Incident")
                            tableHeader("Immediate Action")
                        }

                        // ✅ GROUP EVERY 8 FIELDS AS 1 ROW
                        let rowSize = 8
                        let rows = stride(from: 0, to: fields.count, by: rowSize)

                        ForEach(Array(rows), id: \.self) { startIndex in

                            if startIndex + 7 < fields.count {

                                HStack {
                                    tableCell(fields[startIndex]["name"])
                                    tableCell(fields[startIndex + 1]["name"])
                                    tableCell(fields[startIndex + 6]["name"])
                                    tableCell(fields[startIndex + 7]["name"])
                                }
                            }
                        }
                    }
                }
            }
        )
    }



    
    func infoItem(_ title: String, _ value: Any?) -> some View {

        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)

            Text("\(value ?? "Not Uploaded Yet")")
                .foregroundColor(.white)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    
    func tableHeader(_ title: String) -> some View {
        Text(title)
            .font(.caption)
            .bold()
            .frame(width: 120, height: 40)
            .background(Color.white)
    }

    
    func tableCell(_ value: Any?) -> some View {
        Text("\(value ?? "-")")
            .font(.caption)
            .frame(width: 120, height: 40)
            .background(Color(.darkGray))
            .foregroundColor(.white)
            .border(Color.gray.opacity(0.3))
    }

    var dynamicIncidentActionView: some View {

        guard let sections = viewModel.incidentSections,
              let formSection = sections.first(where: {
                  ($0["title"] as? String) == "Form Action"
              }),
              let fields = formSection["fields"] as? [[String: Any]],
              let firstField = fields.first else {
            return AnyView(EmptyView())
        }

        let activeButtons = firstField["activeButtonsText"] as? [String] ?? []
        let deactivateText = firstField["deactivateButtonText"] as? String ?? ""

        return AnyView(
            VStack(spacing: 12) {

                //  ACTIVE BUTTONS (Blue)
                if !activeButtons.isEmpty {

                    ForEach(activeButtons, id: \.self) { text in
//
                        Button {

                            selectedAction = text

                         
                            
                            if text == "Add Team Lead" {
                                    navigateToAddTeamLead = true
                                } else if text == "RCA" { // <--- New Condition for your Image UI
                                    navigateToRCAScreen = true
                                } else {
                                    // Default logic for other buttons
                                    let hasActionSection = viewModel.incidentSections?.contains(where: {
                                        ($0["title"] as? String) == "Action"
                                    }) ?? false
                                    
                                    if hasActionSection {
                                        navigateToSSScreen = true
                                    } else {
                                        showActionAlert = true
                                    }
                                }
                            } label: {
                                Text(text)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    // Optional: Give RCA a unique color like the brown/red in your image
                                    .background(text == "RCA" ? Color(hex: "#8B4513") : (text == "Add Team Lead" ? Color.green : Color.blue))
                                    .cornerRadius(30)
                            }
                    }

                } else {

                    // ❌ DEACTIVE BUTTON (Gray)
                    Button(action: {}) {
                        Text(deactivateText.isEmpty
                             ? "No Action Available"
                             : deactivateText)
                            .foregroundColor(.white)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(30)
                    }
                    .disabled(true)
                }
            }
        )
    }



    
}


private extension ViewPermitView {

    func keyValueCard(title: String, value: Any?) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)

            Text("\(value ?? "-")")
                .font(.body)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
       // .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

private extension ViewPermitView {

    func injuredPersonSection(_ value: Any?) -> some View {

        guard let persons = value as? [[String: Any]] else {
            return AnyView(EmptyView())
        }

        return AnyView(
            VStack(alignment: .leading, spacing: 12) {

                Text("Injured Person Details")
                    .font(.headline)

                ForEach(persons.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 6) {

                        Text("Person \(index + 1)")
                            .bold()

                        ForEach(persons[index].keys.sorted(), id: \.self) { key in
                            Text("\(key): \(persons[index][key] ?? "-")")
                                .font(.subheadline)
                        }
                    }
                    .padding()
                    .background(Color.red.opacity(0.05))
                    .cornerRadius(10)
                }
            }
        )
    }
}



extension ViewPermitView{
    
    
    func callWorkflowActionAPI(action: String) {
        
      //  guard let url = URL(string: "https://imomtest.deltafour.co/api/v1/workflow/auxiliary/permit") else { return }
        
        guard let url = URL(string: APIEndpoints.incidentPermitAction) else { return }
        
        var request = URLRequest(url: url)
        
        if let token = KeychainHelper.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "data": [
                "fieldValues": [:],
                "permitState": [
                    "buttonAction": action
                ]
            ],
            "id": permitId   // ✅ Dynamic ID
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        isLoadingAction = true
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                isLoadingAction = false
            }
            
           
            if let error = error {
                print("❌ Error:", error.localizedDescription)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("✅ Status Code:", httpResponse.statusCode)
            }
         

            if let data = data {
                let responseString = String(data: data, encoding: .utf8)
                print("📦 Response:", responseString ?? "")
            }
            
         
            DispatchQueue.main.async {
                
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 200 {
                    
                    print("✅ Action Success")
                    
                    dismiss()
                }
            }

            
        }.resume()
    }

}
