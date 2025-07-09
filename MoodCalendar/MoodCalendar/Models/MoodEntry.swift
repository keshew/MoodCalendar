import SwiftUI

struct MoodEntry: Identifiable, Codable {
    var id: UUID
    var date: Date
    var mood: Mood
    var note: String?
    var timestamp: Date
    
    init(id: UUID = UUID(), date: Date = Date(), mood: Mood, note: String? = nil) {
        self.id = id
        self.date = Calendar.current.startOfDay(for: date)
        self.mood = mood
        self.note = note
        self.timestamp = date
    }
}

enum Mood: String, Codable, CaseIterable {
    case great = "Great"
    case happy = "Happy"
    case neutral = "Neutral"
    case sad = "Sad"
    case terrible = "Terrible"
    
    var icon: String {
        switch self {
        case .great: return "😊"
        case .happy: return "🙂"
        case .neutral: return "😐"
        case .sad: return "😔"
        case .terrible: return "😢"
        }
    }
    
    var color: Color {
        switch self {
        case .great: return .moodGreat
        case .happy: return .moodHappy
        case .neutral: return .moodNeutral
        case .sad: return .moodSad
        case .terrible: return .moodTerrible
        }
    }
} 
