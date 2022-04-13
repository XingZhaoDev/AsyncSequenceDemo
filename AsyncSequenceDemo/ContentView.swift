//
//  ContentView.swift
//  AsyncSequenceDemo
//
//  Created by Xing Zhao on 2022-04-12.
//

import SwiftUI

struct ExampleView: View {
    @ObservedObject var viewModel: ExampleViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 16.0) {
            VStack {
                Text("Portrait from publisher \(viewModel.isPortraitFromPublisher ? "yes" : "no")")
                Text("Portrait from sequence \(viewModel.isPortraitFromSequence ? "yes" : "no")")
            }
            Button("Dismiss") {
                dismiss()
            }
        }
        .onAppear {
            viewModel.setup()
        }
    }
}

struct ContentView: View {
    @State var showExampleView = false
    
    var body: some View {
        Button("Show example") {
            showExampleView = true
        }.sheet(isPresented: $showExampleView) {
            ExampleView(viewModel: ExampleViewModel())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
