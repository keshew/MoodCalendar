import SwiftUI

@main
struct MoodCalendarApp: App {
    @StateObject private var viewModel = MoodCalendarViewModel()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                TodayView()
                    .tabItem {
                        Label("Today", systemImage: "sun.max")
                    }
                
                CalendarView()
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                    }
                
                StatisticsView()
                    .tabItem {
                        Label("Statistics", systemImage: "chart.bar")
                    }
            }
            .environmentObject(viewModel)
        }
    }
} 