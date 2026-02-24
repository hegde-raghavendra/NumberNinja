import SwiftUI

struct MultiplicationTableView: View {
    // The base number to multiply
    @State private var base: Int = 5
    // The range up to which we'll multiply
    @State private var upTo: Int = 12
    // The list of multiplication results as strings
    @State private var rows: [String] = []
    
    var body: some View {
        ZStack {
            // Background gradient with soft colors
            LinearGradient(colors: [Color.pink.opacity(0.6), Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Title text at the top
                Text("📚 Multiplication Table")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                
                // Controls to pick the base number and the range (up to)
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading) {
                        Text("Number")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Picker("Number", selection: $base) {
                            ForEach(1...12, id: \.self) { n in Text("\(n)").tag(n) }
                        }
                        .pickerStyle(.segmented)
                    }
                    VStack(alignment: .leading) {
                        Text("Up To")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Picker("Up To", selection: $upTo) {
                            ForEach(1...12, id: \.self) { n in Text("\(n)").tag(n) }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .padding(8)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                
                // Button to generate the multiplication table
                Button {
                    // Animate the generation of the rows
                    withAnimation(.easeInOut) {
                        rows = (1...upTo).map { m in
                            "\(base) × \(m) = \(base * m)"
                        }
                    }
                } label: {
                    Label("Generate Table", systemImage: "list.number")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundStyle(.white)
                        .background(LinearGradient(colors: [Color.blue, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: Color.purple.opacity(0.4), radius: 10, x: 0, y: 6)
                }
                
                // Show a message if no table is generated yet
                if rows.isEmpty {
                    Text("Pick a number and tap Generate Table.")
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                } else {
                    // Scrollable list of multiplication results as colorful cards
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(rows.indices, id: \.self) { idx in
                                let text = rows[idx]
                                HStack {
                                    Text(text)
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)
                                    Spacer()
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(colors: idx % 2 == 0 ? [Color.teal, Color.green] : [Color.pink, Color.orange],
                                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 4)
                            }
                        }
                    }
                }
                
                Spacer(minLength: 0)
            }
            .padding()
        }
        .navigationTitle("Number Ninja Jr")
    }
}

#Preview {
    NavigationStack {
        MultiplicationTableView()
    }
}
