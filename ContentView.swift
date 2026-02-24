//
//  ContentView.swift
//  Number Ninja Jr
//
//  A colorful, kid-friendly multiplication practice app using SwiftUI.
//  Now acts as a home hub for multiple quiz modes and a homework tracker.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var progress = ProgressStore()

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient with playful colors
                LinearGradient(colors: [Color.pink.opacity(0.6), Color.blue.opacity(0.6), Color.purple.opacity(0.6), Color.yellow.opacity(0.6), Color.green.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // HOME HEADER
                        VStack(spacing: 16) {
                            Text("✨ Number Ninja Jr ✨")
                                .font(.system(size: 36, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white)
                                .shadow(radius: 4)
                                .padding(.top, 8)

                            HStack(spacing: 16) {
                                Text("🌈")
                                Text("🚀")
                                Text("⭐️")
                                Text("🦄")
                                Text("🎈")
                            }
                            .font(.system(size: 28))
                            .shadow(radius: 2)
                        }
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(LinearGradient(colors: [Color.white.opacity(0.6), Color.white.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 6)

                        // PRACTICE MODE BUTTONS
                        VStack(spacing: 14) {
                            Text("🥷 Practice Modes")
                                .font(.system(size: 24, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white)

                            NavigationLink {
                                QuizView(kind: .addition)
                                    .environmentObject(progress)
                            } label: {
                                bigModeButton(title: "Addition Quiz", gradient: [Color.cyan, Color.blue], symbol: "+")
                            }

                            NavigationLink {
                                QuizView(kind: .subtraction)
                                    .environmentObject(progress)
                            } label: {
                                bigModeButton(title: "Subtraction Quiz", gradient: [Color.orange, Color.red], symbol: "−")
                            }

                            NavigationLink {
                                QuizView(kind: .multiplication)
                                    .environmentObject(progress)
                            } label: {
                                bigModeButton(title: "Multiplication Quiz", gradient: [Color.purple, Color.pink], symbol: "×")
                            }
                            
                            NavigationLink {
                                QuizView(kind: .division)
                                    .environmentObject(progress)
                            } label: {
                                bigModeButton(title: "Division Quiz", gradient: [Color.indigo, Color.cyan], symbol: "÷")
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(LinearGradient(colors: [Color.white.opacity(0.6), Color.white.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 6)

                        // HOMEWORK TRACKER
                        VStack(spacing: 12) {
                            Text("📅 Homework Tracker")
                                .font(.system(size: 24, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white)

                            NavigationLink {
                                CalendarView()
                                    .environmentObject(progress)
                            } label: {
                                Label("Open Tracker", systemImage: "calendar")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .foregroundStyle(.white)
                                    .background(
                                        LinearGradient(colors: [Color.green, Color.teal], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                    .shadow(color: Color.teal.opacity(0.4), radius: 10, x: 0, y: 6)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(LinearGradient(colors: [Color.white.opacity(0.6), Color.white.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 6)
                        
                        // REFERENCE TOOLS
                        VStack(spacing: 12) {
                            Text("📚 Reference")
                                .font(.system(size: 24, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white)

                            NavigationLink {
                                MultiplicationTableView()
                            } label: {
                                Label("Multiplication Table", systemImage: "list.number")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .foregroundStyle(.white)
                                    .background(
                                        LinearGradient(colors: [Color.indigo, Color.cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                    .shadow(color: Color.cyan.opacity(0.4), radius: 10, x: 0, y: 6)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(LinearGradient(colors: [Color.white.opacity(0.6), Color.white.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 6)
                    }
                    .padding()
                }
            }
            .navigationTitle("")
        }
        // Inject the store into the environment for this view hierarchy
        .environmentObject(progress)
    }

    // Big rounded gradient button used for each practice mode
    private func bigModeButton(title: String, gradient: [Color], symbol: String) -> some View {
        HStack {
            Text(symbol)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .padding(.trailing, 6)
            Text(title)
                .font(.system(size: 22, weight: .bold, design: .rounded))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .foregroundStyle(.white)
        .background(
            LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 6)
    }
}

#Preview {
    ContentView()
}
