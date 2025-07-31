import SwiftUI
import SwiftData

struct WelcomeView: View {
    @Environment(\.modelContext) private var context
    @Query private var userPreferences: [UserPreferences]
    @Binding var showWelcome: Bool
    var onComplete: () -> Void
    
    @State private var currentPage = 0
    
    private let lilac = Color(red: 0.784, green: 0.635, blue: 0.784)
    
    private let welcomePages = [
        WelcomePage(
            title: "Welcome to Skorjo!",
            subtitle: "",
            description: "This is your personal space to reflect on your training — not just what you did, but how it felt.\n\nUnlike social platforms built for performance and praise, Skorjo is private by design, encouraging honest journaling and emotional awareness.\n\nAs you log runs, strength sessions, or moments of insight, Skorjo helps you uncover patterns in your mood, motivation, and recovery.\n\nOver time, this becomes more than a training log — it becomes your story.",
            icon: "heart.fill",
            color: Color(red: 0.784, green: 0.635, blue: 0.784)
        )
    ]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [lilac.opacity(0.1), Color(.systemGray6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<welcomePages.count, id: \.self) { index in
                        WelcomePageView(page: welcomePages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Bottom controls
                VStack(spacing: 20) {
                    // Action button
                    Button(action: {
                        completeWelcome()
                    }) {
                        HStack {
                            Text("Get Started")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(lilac)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            setupUserPreferences()
        }
    }
    
    private func setupUserPreferences() {
        // Ensure we have user preferences
        if userPreferences.isEmpty {
            let preferences = UserPreferences()
            context.insert(preferences)
            try? context.save()
        }
    }
    
    private func completeWelcome() {
        // Mark welcome screen as seen
        if let preferences = userPreferences.first {
            preferences.markWelcomeScreenSeen()
            try? context.save()
        }
        // Call the completion handler to transition to main app
        onComplete()
    }
    
    // For testing purposes - reset welcome screen
    static func resetWelcomeScreen(context: ModelContext) {
        let fetchDescriptor = FetchDescriptor<UserPreferences>()
        if let preferences = try? context.fetch(fetchDescriptor).first {
            preferences.hasSeenWelcomeScreen = false
            try? context.save()
        }
    }
}

struct WelcomePage {
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let color: Color
}

struct WelcomePageView: View {
    let page: WelcomePage
    private let lilac = Color(red: 0.784, green: 0.635, blue: 0.784)
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: page.icon)
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(page.color)
            }
            
            // Text content
            VStack(spacing: 20) {
                Text(page.title)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                if !page.subtitle.isEmpty {
                    Text(page.subtitle)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(lilac)
                        .multilineTextAlignment(.center)
                }
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .padding(.horizontal, 30)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    WelcomeView(showWelcome: .constant(true), onComplete: {})
        .modelContainer(for: [JournalEntry.self, UserPreferences.self], inMemory: true)
} 