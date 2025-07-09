import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject private var viewModel: MoodCalendarViewModel
    @State private var selectedMonth = Date()
    
    private let calendar = Calendar.current
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.customBackground
                    .ignoresSafeArea()
                
                VStack {
                    monthSelector
                    
                    if let statistics = calculateStatistics() {
                        List {
                            moodDistributionSection(statistics: statistics)
                            mostFrequentMoodSection(statistics: statistics)
                            streakSection(statistics: statistics)
                            
                            
                        }
                        .scrollContentBackground(.hidden)
                        .listStyle(InsetGroupedListStyle())
                    } else {
                        Text("No mood entries for this month")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.customText)
                            .padding()
                        
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.customBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
    
    private var monthSelector: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.customText)
            }
            
            Text(monthYearString)
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.customText)
                .frame(maxWidth: .infinity)
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.customText)
            }
        }
        .padding()
    }
    
    private func moodDistributionSection(statistics: MoodStatistics) -> some View {
        Section(header: Text("Mood Distribution")
            .font(.system(.caption2, design: .rounded))
            .foregroundColor(.customText)) {
            ForEach(Mood.allCases, id: \.self) { mood in
                HStack {
                    Text(mood.icon)
                    Text(mood.rawValue)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.customText)
                    Spacer()
                    Text("\(statistics.distribution[mood, default: 0])")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.customText)
                }
                .listRowBackground(mood.color)
            }
        }
    }
    
    private func mostFrequentMoodSection(statistics: MoodStatistics) -> some View {
        Section(header: Text("Most Frequent Mood")
            .font(.system(.caption2, design: .rounded))
            .foregroundColor(.customText)) {
            if let mostFrequent = statistics.mostFrequentMood {
                HStack {
                    Text(mostFrequent.icon)
                    Text(mostFrequent.rawValue)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.customText)
                }
                .listRowBackground(mostFrequent.color)
            }
        }
    }
    
    private func streakSection(statistics: MoodStatistics) -> some View {
        Section(header: Text("Current Streak")
            .font(.system(.caption2, design: .rounded))
            .foregroundColor(.customText)) {
            if let streak = statistics.currentStreak {
                HStack {
                    Text(streak.mood.icon)
                    Text("\(streak.count) days")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.customText)
                }
                .listRowBackground(streak.mood.color)
            } else {
                Text("No current streak")
                    .font(.system(.subheadline, design: .rounded))
                    .listRowBackground(Color.inactiveTab)
            }
        }
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedMonth)
    }
    
    private func previousMonth() {
        if let date = calendar.date(byAdding: .month, value: -1, to: selectedMonth) {
            selectedMonth = date
        }
    }
    
    private func nextMonth() {
        if let date = calendar.date(byAdding: .month, value: 1, to: selectedMonth) {
            selectedMonth = date
        }
    }
    
    private func calculateStatistics() -> MoodStatistics? {
        let entries = viewModel.getMoodEntries(for: selectedMonth)
        guard !entries.isEmpty else { return nil }
        
        var distribution: [Mood: Int] = [:]
        var mostFrequentMood: Mood?
        var maxCount = 0
        
        for entry in entries {
            distribution[entry.mood, default: 0] += 1
            if distribution[entry.mood]! > maxCount {
                maxCount = distribution[entry.mood]!
                mostFrequentMood = entry.mood
            }
        }
        
        let sortedEntries = entries.sorted { $0.date > $1.date }
        var streakMood: Mood?
        var streakCount = 0
        
        if let lastEntry = sortedEntries.first {
            streakMood = lastEntry.mood
            streakCount = 1
            
            for i in 1..<sortedEntries.count {
                if sortedEntries[i].mood == streakMood {
                    streakCount += 1
                } else {
                    break
                }
            }
        }
        
        let streak = streakMood.map { Streak(mood: $0, count: streakCount) }
        
        return MoodStatistics(
            distribution: distribution,
            mostFrequentMood: mostFrequentMood,
            currentStreak: streak
        )
    }
}

struct MoodStatistics {
    let distribution: [Mood: Int]
    let mostFrequentMood: Mood?
    let currentStreak: Streak?
}

struct Streak {
    let mood: Mood
    let count: Int
}

#Preview {
    StatisticsView()
        .environmentObject(MoodCalendarViewModel())
} 
