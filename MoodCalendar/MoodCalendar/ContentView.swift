import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MoodCalendarViewModel()
    
    var body: some View {
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
        .tint(.customText)
        .background(Color.customBackground)
    }
}

#Preview {
    ContentView()
}
