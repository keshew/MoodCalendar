import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: MoodCalendarViewModel
    
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
            
            FocusView()
                .tabItem {
                    Label("Focus", systemImage: "timer")
                }
            
            StatisticsView()
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar")
                }
        }
        .tint(.black)
        .background(Color.customBackground)
    }
}

#Preview {
    ContentView()
        .environmentObject(MoodCalendarViewModel())
}
