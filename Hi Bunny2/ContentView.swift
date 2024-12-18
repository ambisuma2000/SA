//
//  ContentView.swift
//  Hi Bunny2
//
//  Created by suma Ambadipudi on 17/12/24.
//

import SwiftUI
import SwiftUI
struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack() {
                // Main Bunny Image
                Image ("bunny") // Replace with your bunny image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 960, height: 290.0)
                    .padding()
                NavigationLink(destination: NewTabView()) {
                    Text("Start")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .background(Color.mint.scaledToFill())
            .navigationTitle("Hi Bunny") // Set title for the navigation bar
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView() // Ensure this is only declared once
    }
}

#Preview {
    ContentView()
}

