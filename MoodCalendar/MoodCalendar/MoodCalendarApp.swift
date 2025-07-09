import SwiftUI

@main
struct MoodCalendarApp: App {
    @StateObject private var viewModel = MoodCalendarViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .tint(.customText)
                .background(Color.customBackground)
        }
    }
} 