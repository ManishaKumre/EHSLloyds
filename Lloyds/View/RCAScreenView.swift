//
//  RCAScreenView.swift
//  Lloyds
//
//  Created by Manisha on 03/03/26.
//

import SwiftUI


struct RCAScreenView:  View {
    @State private var problem: String = ""
    @State private var whys: [String] = Array(repeating: "", count: 5)
    @State private var rootCause: String = ""
    @State private var mainCause: String = ""
    let permitId: Int
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // --- DEFINE THE PROBLEM SECTION ---
                HStack(alignment: .top) {
                    Text("DEFINE THE\nPROBLEM")
                        .font(.caption).bold()
                        .foregroundColor(.white)
                        .frame(width: 80)
                        .padding(.vertical)
                    
                    VStack(alignment: .leading) {
                        Text("Define problem here").font(.subheadline)
                        TextField("Test", text: $problem)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                }
                .background(Color(hex: "#7B3F3F")) // Dark Red/Brown sidebar
                
                // --- 5 WHYS SECTION ---
                HStack(alignment: .top) {
                    Text("WHY IS THIS\nA PROBLEM?")
                        .font(.caption).bold()
                        .foregroundColor(.white)
                        .frame(width: 80)
                        .padding(.top)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("PRIMARY CAUSE").font(.headline).padding(.top)
                        
                        ForEach(0..<5, id: \.self) { index in
                            HStack {
                                Text("\(index + 1)").bold()
                                    .padding(8).background(Color.gray.opacity(0.3)).clipShape(Circle())
                                
                                VStack(alignment: .leading) {
                                    Text(index == 0 ? "Why is it happening?" : "Why is that?").font(.caption)
                                    TextField("", text: $whys[index])
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                            }
                            .padding(.leading, CGFloat(index * 20)) // Indentation like the image
                        }
                        
                        // Root Cause & Main Cause Fields
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Root Cause").font(.caption)
                                TextField("Main Cause", text: $rootCause).textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            VStack(alignment: .leading) {
                                Text("Main Cause").font(.caption)
                                TextField("Money problem", text: $mainCause).textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                        }
                    }
                    .padding()
                    .background(Color(hex: "#E5C1C1")) // Light pinkish background
                }
                .background(Color(hex: "#8B4545"))
                
                // --- 4M METHOD SECTION ---
                // Add similar logic for Human/System factors here...
            }
        }
        .navigationTitle("Complete analysis details")
    }
}
