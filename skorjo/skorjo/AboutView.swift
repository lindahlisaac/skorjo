import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let lilac = Color(red: 0.784, green: 0.635, blue: 0.784)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // App Icon Placeholder
                    VStack(spacing: 16) {
                        Image(systemName: "figure.run.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(lilac)
                        
                        Text("Welcome to Skorjo!")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    
                    // Welcome Message
                    VStack(alignment: .leading, spacing: 16) {
                        Text("This is your personal space to reflect on your training — not just what you did, but how it felt. Unlike social platforms built for performance and praise, Skorjo is private by design, encouraging honest journaling and emotional awareness.")
                            .font(.body)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Text("As you log runs, strength sessions, or moments of insight, Skorjo helps you uncover patterns in your mood, motivation, and recovery. Over time, this becomes more than a training log — it becomes your story.")
                            .font(.body)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                    }
                    
                    // App Info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("App Information")
                            .font(.headline)
                            .foregroundColor(lilac)
                        
                        HStack {
                            Text("Version")
                                .fontWeight(.medium)
                            Spacer()
                            Text("0.1.0")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Build")
                                .fontWeight(.medium)
                            Spacer()
                            Text("1")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AboutView()
} 