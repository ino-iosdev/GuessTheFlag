//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Ino Yang Popper on 1/28/25.
//

import SwiftUI

struct FlagImage: View {
    var country: String
    
    var body: some View {
        Image(country)
            .clipShape(.capsule)
            .shadow(radius: 5)
            .accessibilityLabel("Flag of \(country)")
    }
}

struct ContentView: View {
    static let allCountries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Spain", "UK", "Ukraine", "US"]

    @State private var countries = allCountries.shuffled()
    @State private var correctAnswer = Int.random(in: 0...2)

    @State private var showingFinalAlert = false
    @State private var showingScore = false
    @State private var scoreTitle = ""
   
    @State private var questionCount = 0
    @State private var score = 0
    
    // New state variable to track the selected flag
    @State private var selectedFlag: Int? = nil
    
    var body: some View {
        ZStack {
            RadialGradient(stops: [
                .init(color: Color(red: 0.1, green: 0.2, blue: 0.45), location: 0.3),
                .init(color: Color(red: 0.76, green: 0.15, blue: 0.26), location: 0.3)
            ], center: .top, startRadius: 200, endRadius: 700)
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Text("Guess the Flag")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                
                VStack(spacing: 15) {
                    VStack {
                        Text("Tap the flag of")
                            .foregroundStyle(.secondary)
                            .font(.subheadline.weight(.heavy))
                        
                        Text(countries[correctAnswer])
                            .font(.largeTitle.weight(.semibold))
                    }
                    
                    ForEach(0..<3) { number in
                        Button {
                            withAnimation {
                                selectedFlag = number // Track the selected flag
                            }
                            flagTapped(number)
                        } label: {
                            FlagImage(country: countries[number])
                                // Apply rotation effect to the selected flag
                                .rotation3DEffect(
                                    .degrees(selectedFlag == number ? 360 : 0),
                                    axis: (x: 0, y: 1, z: 0)
                                )
                                // Apply scaling and opacity effects to unselected flags
                                .scaleEffect(selectedFlag == nil || selectedFlag == number ? 1 : 0.5)
                                .opacity(selectedFlag == nil || selectedFlag == number ? 1 : 0.25) // Fade out non-selected flags
                                .animation(.easeInOut(duration: 1), value: selectedFlag)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: 20))
                
                Spacer()
                Spacer()
                
                Text("Score: \(score)")
                    .foregroundStyle(.white)
                    .font(.title.bold())
                
                Spacer()
            }
            .padding()
        }
        .alert(scoreTitle, isPresented: $showingScore) {
            Button("Continue", action: askQuestion)
        } message: {
            Text("Your score is \(score)")
        }
        .alert("Game Over", isPresented: $showingFinalAlert) {
            Button("Restart", action: resetGame)
        } message: {
            Text("Your final score is \(score) out of 8.")
        }
    }
    
    func flagTapped(_ number: Int) {
        if number == correctAnswer {
            scoreTitle = "Correct"
            score += 1
        } else {
            let needsThe = ["UK", "US"]
            let theirAnswer = countries[number]

            if needsThe.contains(theirAnswer) {
                scoreTitle = "Wrong! That's the flag of the \(theirAnswer)."
            } else {
                scoreTitle = "Wrong! That's the flag of \(theirAnswer)."
            }
            
            if score > 0 {
                score -= 1
            }
        }
        
        if questionCount == 8 {
            showingFinalAlert = true
        } else {
            showingScore = true
        }
    }
    
    func askQuestion() {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        questionCount += 1
        selectedFlag = nil // Reset the selected flag
    }
    
    func resetGame() {
        score = 0
        questionCount = 0
        countries = Self.allCountries
        askQuestion()
    }
}

#Preview {
    ContentView()
}
