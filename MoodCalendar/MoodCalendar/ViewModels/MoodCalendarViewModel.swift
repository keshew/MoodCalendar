import Foundation
import SwiftUI

class MoodCalendarViewModel: ObservableObject {
    @Published var moodEntries: [MoodEntry] = []
    private let userDefaultsKey = "moodEntries"
    
    init() {
        loadMoodEntries()
    }
    
    func addMoodEntry(mood: Mood, note: String? = nil) {
        let entry = MoodEntry(mood: mood, note: note)
        moodEntries.append(entry)
        saveMoodEntries()
    }
    
    func updateMoodEntry(_ entry: MoodEntry) {
        if let index = moodEntries.firstIndex(where: { $0.id == entry.id }) {
            moodEntries[index] = entry
            saveMoodEntries()
        }
    }
    
    func deleteMoodEntry(_ entry: MoodEntry) {
        moodEntries.removeAll { $0.id == entry.id }
        saveMoodEntries()
    }
    
    func getMoodEntries(for month: Date) -> [MoodEntry] {
        return moodEntries.filter { Calendar.current.isDate($0.date, equalTo: month, toGranularity: .month) }
    }
    
    private func saveMoodEntries() {
        if let encoded = try? JSONEncoder().encode(moodEntries) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadMoodEntries() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([MoodEntry].self, from: data) {
            moodEntries = decoded
        }
    }
} 