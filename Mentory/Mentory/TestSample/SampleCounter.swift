//
//  ObservationCounter.swift
//  Mentory
//
//  Created by 김민우 on 11/24/25.
//
import SwiftUI


// MARK: Object
@MainActor @Observable
fileprivate final class SampleCounter {
    var number: Int = 1
    
    func increment() {
        self.number += 1
    }
    func decrement() {
        self.number -= 1
    }
}



// MARK: View
fileprivate struct SampleCountetView: View {
    let counter = SampleCounter()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("현재 값: \(counter.number)")
                .font(.largeTitle)
                .bold()

            HStack(spacing: 16) {
                Button(action: {
                    counter.decrement()
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 40))
                }

                Button(action: {
                    counter.increment()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 40))
                }
            }
        }
        .padding()
        .onChange(of: counter.number) { oldValue, newValue in
            print("\(oldValue) -> \(newValue)")
        }
    }
}


// MARK: Preview
#Preview {
    SampleCountetView()
}
