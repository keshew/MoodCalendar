import SwiftUI

struct CalendarView: View {
    @EnvironmentObject private var viewModel: MoodCalendarViewModel
    @State private var selectedDate = Date()
    @State private var showingEntryDetails = false
    @State private var selectedDayEntries: [MoodEntry] = []
    @State private var selectedDay: Date?
    
    private let calendar = Calendar.current
    private let daysInWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.customBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    monthSelector
                    daysHeader
                    daysGrid
                    
                    if let _ = selectedDay,
                       !selectedDayEntries.isEmpty {
                        dayEntriesList
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Mood Calendar")
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
    
    private var daysHeader: some View {
        HStack(spacing: 0) {
            ForEach(daysInWeek, id: \.self) { day in
                Text(day)
                    .frame(maxWidth: .infinity)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(.customText)
            }
        }
        .padding(.horizontal)
    }
    
    private var daysGrid: some View {
        let days = daysInMonth()
        let size = UIScreen.main.bounds.width / 7 - 8
        
        return LazyVGrid(columns: Array(repeating: GridItem(.fixed(size), spacing: 4), count: 7), spacing: 4) {
            ForEach(days.indices, id: \.self) { index in
                if let day = days[index] {
                    let entries = getMoodEntries(for: day)
                    DayCell(date: day, moodEntries: entries, isSelected: day == selectedDay)
                        .frame(width: size, height: size)
                        .onTapGesture {
                            if !entries.isEmpty {
                                if selectedDay == day {
                                    selectedDay = nil
                                    selectedDayEntries = []
                                } else {
                                    selectedDay = day
                                    selectedDayEntries = entries
                                }
                            }
                        }
                } else {
                    Color.clear
                        .frame(width: size, height: size)
                }
            }
        }
        .padding(4)
    }
    
    private var dayEntriesList: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(formatDate(selectedDay!))
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.customText)
                Spacer()
                Button {
                    selectedDay = nil
                    selectedDayEntries = []
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.customText)
                }
            }
            .padding(.horizontal)
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(selectedDayEntries) { entry in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(entry.mood.icon)
                                    .font(.system(size: 24))
                                Text(entry.mood.rawValue)
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundColor(.customText)
                                Spacer()
                                Text(formatTime(entry.timestamp))
                                    .font(.system(.caption2, design: .rounded))
                                    .foregroundColor(.customText)
                            }
                            
                            if let note = entry.note {
                                Text(note)
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundColor(.customText)
                            }
                        }
                        .padding()
                        .background(entry.mood.color)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            .frame(maxHeight: 300)
        }
        .padding(.top)
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    private func previousMonth() {
        if let date = calendar.date(byAdding: .month, value: -1, to: selectedDate) {
            selectedDate = date
            selectedDay = nil
            selectedDayEntries = []
        }
    }
    
    private func nextMonth() {
        if let date = calendar.date(byAdding: .month, value: 1, to: selectedDate) {
            selectedDate = date
            selectedDay = nil
            selectedDayEntries = []
        }
    }
    
    private func daysInMonth() -> [Date?] {
        var days: [Date?] = []
        
        let range = calendar.range(of: .day, in: .month, for: selectedDate)!
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        for _ in 1..<firstWeekday {
            days.append(nil)
        }
        
        for day in 1...range.count {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func getMoodEntries(for date: Date) -> [MoodEntry] {
        return viewModel.moodEntries.filter { calendar.isDate($0.date, inSameDayAs: date) }
            .sorted { $0.timestamp > $1.timestamp }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct DayCell: View {
    let date: Date
    let moodEntries: [MoodEntry]
    let isSelected: Bool
    
    private let calendar = Calendar.current
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                
                .fill(Color.white.opacity(0.1))
            
            if isSelected {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.customText, lineWidth: 2)
            }
            
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(.customText)
                
                if !moodEntries.isEmpty {
                    if moodEntries.count == 1 {
                        Text(moodEntries[0].mood.icon)
                            .font(.system(size: 20))
                    } else {
                        HStack(spacing: 2) {
                            ForEach(moodEntries.prefix(2), id: \.id) { entry in
                                Text(entry.mood.icon)
                                    .font(.system(size: 14))
                            }
                            if moodEntries.count > 2 {
                                Text("+")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.customText)
                            }
                        }
                    }
                }
            }
            .padding(2)
        }
    }
}

#Preview {
    CalendarView()
        .environmentObject(MoodCalendarViewModel())
} 
