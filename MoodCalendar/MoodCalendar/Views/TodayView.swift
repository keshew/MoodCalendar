import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var viewModel: MoodCalendarViewModel
    @State private var note: String = ""
    @State private var showingNoteSheet = false
    @State private var selectedMood: Mood?
    
    // Размер экрана для расчета размеров кнопок
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    private var buttonSize: CGFloat {
        (screenWidth - 60) / 3 // 60 = отступы по бокам (16*2) + промежутки между кнопками (16*2)
    }
    
    var body: some View {
        ZStack {
            Color.customBackground
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("How are you feeling today?")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.customText)
                    .padding()
                
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        ForEach(Array(Mood.allCases.prefix(3)), id: \.self) { mood in
                            MoodButton(mood: mood, isSelected: selectedMood == mood) {
                                selectedMood = mood
                                showingNoteSheet = true
                            }
                            .frame(width: buttonSize, height: buttonSize)
                        }
                    }
                    
                    HStack(spacing: 16) {
                        ForEach(Array(Mood.allCases.suffix(3)), id: \.self) { mood in
                            MoodButton(mood: mood, isSelected: selectedMood == mood) {
                                selectedMood = mood
                                showingNoteSheet = true
                            }
                            .frame(width: buttonSize, height: buttonSize)
                        }
                    }
                }
                .padding(.horizontal, 16)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showingNoteSheet) {
            NavigationView {
                NoteView(note: $note) {
                    if let mood = selectedMood {
                        viewModel.addMoodEntry(mood: mood, note: note.isEmpty ? nil : note)
                        note = ""
                        selectedMood = nil
                    }
                }
            }
        }
    }
}

struct MoodButton: View {
    let mood: Mood
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Text(mood.icon)
                    .font(.system(size: 40))
                Text(mood.rawValue)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(.customText)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 69/255, green: 149/255, blue: 191/255))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isSelected ? .customText : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct NoteView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var note: String
    let onSave: () -> Void
    
    var body: some View {
        ZStack {
            Color.customBackground
                .ignoresSafeArea()
            
            Form {
                Section(header: Text("Add a note (optional)")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(.customText)) {
                    TextEditor(text: $note)
                        .frame(height: 100)
                        .font(.system(.subheadline, design: .rounded))
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Add Note")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.customBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarItems(
            leading: Button("Cancel") {
                dismiss()
            }
            .font(.system(.subheadline, design: .rounded))
            .foregroundColor(.customText),
            trailing: Button("Save") {
                onSave()
                dismiss()
            }
            .font(.system(.subheadline, design: .rounded))
            .foregroundColor(.customText)
        )
    }
}

#Preview {
    TodayView()
        .environmentObject(MoodCalendarViewModel())
} 
