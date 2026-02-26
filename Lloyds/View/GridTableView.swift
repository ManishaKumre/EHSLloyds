//
//  GridTableView.swift
//  Lloyds
//
//  Created by Manisha on 24/12/25.
//


import SwiftUI

struct GridTableView: View {
    let grid: Grid
    var columnWidth: CGFloat = 140
    var maxLinesForText: Int = 3
    
    
//    @StateObject private var fileHandler = FileHandler()
    @State private var showPreview = false
    
//
//    let token = "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJXb25kZXJhZG1pbiIsImlhdCI6MTc2NTk2NjIyNCwiZXhwIjoxNzY2NTcxMDI0fQ.cpNBDMqTvn0uRaxtzQ303AoxERJLXupKVGS6Hnu-NtYIhuanDZTPiRC2cqxbmK70npW6eoaK9DaOFOXKqV5qqA"  // This is where you get the token
//
   let token = KeychainHelper.shared.getToken()
      
    
    // MARK: - Table generator
//    private func makeTable() -> (headers: [PermitField], rows: [[PermitField]]) {
//        let fields = grid.fields ?? []
//        guard !fields.isEmpty else { return ([], []) }
//        
//        var headerCount = 2
//        
//        if grid.title == "Isolation Point(s)" {
//            headerCount = 3
//        } else if grid.title == "Workers Briefing" {
//            headerCount = 2
//        }
//        
//        let headers = Array(fields.prefix(headerCount))
//        let remaining = Array(fields.dropFirst(headerCount))
//        
//        var rows: [[PermitField]] = []
//        for chunk in stride(from: 0, to: remaining.count, by: headerCount) {
//            let end = min(chunk + headerCount, remaining.count)
//            rows.append(Array(remaining[chunk..<end]))
//        }
//        
//        return (headers, rows)
//    }
//    
//    
//    
//    // MARK: - Body
    var body: some View {
//        let table = makeTable()
//        
//        VStack(alignment: .leading, spacing: 12) {
//            if let title = grid.title, !title.isEmpty {
//                Text("Isolation Details (\(title))")
//                    .font(.headline)
//                    .padding(.bottom, 4)
//            }
//            
//            ScrollView(.horizontal, showsIndicators: true) {
//                VStack(spacing: 0) {
//                    // Headers
//                    HStack(alignment: .top, spacing: 8) {
//                        ForEach(table.headers.indices, id: \.self) { i in
//                            let h = table.headers[i]
//                            Text(h.name ?? "")
//                                .font(.subheadline)
//                                .fontWeight(.semibold)
//                                .padding(6)
//                                .frame(width: columnWidth, alignment: .leading)
//                                .background(Color.gray.opacity(0.15))
//                                .cornerRadius(6)
//                        }
//                    }
//                    .padding(.bottom, 4)
//                    
//                    Divider()
//                    
//                    // Rows
//                    ForEach(table.rows.indices, id: \.self) { r in
//                        HStack(alignment: .top, spacing: 8) {
//                            ForEach(table.rows[r].indices, id: \.self) { c in
//                                let cell = table.rows[r][c]
//                                cellView(cell)
//                                    .frame(width: columnWidth, alignment: .leading)
//                            }
//                        }
//                        .padding(.vertical, 6)
//                        Divider()
//                    }
//                }
//                .padding(.vertical, 8)
//            }
//        }
//        .padding()
//        // MARK: - Sheet for image preview
//        
//        .onAppear {
//            print("🟢 GridTableView LOADED — TOKEN USED:", token)
//        }
//
//      
//        
//        
//        .sheet(isPresented: Binding(
//            get: { fileHandler.localFileURL != nil || fileHandler.errorMessage != nil },
//            set: { if !$0 { fileHandler.cleanup() } }
//        )) {
//            if let localURL = fileHandler.localFileURL {
//                let ext = localURL.pathExtension.lowercased()
//                if ext == "pdf" {
//                    QuickLookPreview(url: localURL) {
//                        fileHandler.cleanup()
//                    }
//                } else if ["jpg", "jpeg", "png"].contains(ext) {
//                    QuickLookPreview(url: localURL) {   // ya koi custom image viewer agar chaho
//                        fileHandler.cleanup()
//                    }
//                } else {
//                    QuickLookPreview(url: localURL) {
//                        fileHandler.cleanup()
//                    }
//                }
//            } else if let error = fileHandler.errorMessage {
//                VStack {
//                    Text("Error: \(error)")
//                        .foregroundColor(.red)
//                        .padding()
//                    Button("Close") { fileHandler.cleanup() }
//                        .padding()
//                }
//            } else {
//                Text("No File Available")
//            }
//        }
//        
//        
//    }
//    
//    // MARK: - Cell renderer
//    @ViewBuilder
//    private func cellView(_ field: PermitField) -> some View {
//        switch field.type {
//        case "CHIP":
//            Text(field.name ?? field.textValue ?? "")
//                .font(.caption)
//                .padding(.vertical, 6)
//                .padding(.horizontal, 10)
//                .background(Color.blue.opacity(0.18))
//                .cornerRadius(10)
//                .fixedSize(horizontal: false, vertical: true)
//                .multilineTextAlignment(.leading)
//            
//        case "BUTTON":
//            Button(action: {
//                if let fileName = field.description, !fileName.isEmpty {
//                    //  Download & prepare file
//                    fileHandler.openFile(fileName: fileName, token: token ?? "")
//                } else {
//                    print("No file available")
//                }
//            }) {
//                Text(field.name ?? field.textValue ?? "View File")
//                    .font(.caption)
//                    .padding(.vertical, 6)
//                    .padding(.horizontal, 10)
//            }
//            .buttonStyle(.bordered)
//            .fixedSize(horizontal: false, vertical: true)
//            .multilineTextAlignment(.leading)
//            
//            
//            
//        default: // TEXTBOX
//            Text(field.textValue ?? field.name ?? "")
//                .font(.body)
//                .lineLimit(maxLinesForText)
//                .multilineTextAlignment(.leading)
//                .fixedSize(horizontal: false, vertical: true)
//        }
    }
//}
//
//// MARK: - Convenience initializer for preview/mock data
//extension PermitField {
//    init(simpleName: String? = nil, simpleType: String? = nil, simpleText: String? = nil) {
//        self.name = simpleName
//        self.type = simpleType
//        self.tableName = nil
//        self.returnColumn = nil
//        self.condition = nil
//        self.listOfElements = nil
//        self.radioButtonValue = nil
//        self.selectedValues = nil
//        self.required = nil
//        self.editable = nil
//        self.readonly = nil
//        self.description = nil
//        self.iconName = nil
//        self.textValue = simpleText
//        self.activeButtonsText = nil
//        self.activeButtonActions = nil
//        self.deactivateButtonText = nil
//        self.alertName = nil
//        self.action = nil
//    }
//}
//
//// MARK: - Preview
//struct GridTableView_Previews: PreviewProvider {
//    static var sampleGrid: Grid {
//        let fields: [PermitField] = [
//            PermitField(simpleName: "Name", simpleType: "HEADER"),
//            PermitField(simpleName: "Padlock", simpleType: "HEADER"),
//            PermitField(simpleName: "Image", simpleType: "HEADER"),
//            
//            // Row values
//            PermitField(simpleName: nil, simpleType: "TEXTBOX",
//                        simpleText: "1. L-2-CM-MCC-113 FEEDER NO-2F3 — this is a long name"),
//            PermitField(simpleName: "Isolated", simpleType: "CHIP"),
//            PermitField(simpleName: "Image", simpleType: "BUTTON"),
//            //                        simpleText: nil, simpleType: "BUTTON", simpleName: "View Image"),
//        ]
//        return Grid(numberColumn: 3, numberRow: 1, title: "Isolation Point(s)", subtitle: nil, fields: fields)
//    }
//    
//    static var previews: some View {
//        GridTableView(grid: sampleGrid, columnWidth: 140, maxLinesForText: 3)
//            .previewLayout(.sizeThatFits)
//        GridTableView(grid: sampleGrid)
//    }
    
}





