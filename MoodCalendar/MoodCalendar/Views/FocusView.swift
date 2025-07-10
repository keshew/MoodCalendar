import SwiftUI

struct FocusView: View {
    @State private var timeRemaining = 300 // 5 minutes in seconds
    @State private var timer: Timer?
    @State private var isActive = false
    @State private var animationScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 80) {
            Text(timeString)
                .font(.system(size: 64, weight: .bold))
                .monospacedDigit()
                .foregroundColor(.customText)
            
            Circle()
                .stroke(Color.customText, lineWidth: 2)
                .frame(width: 200, height: 200)
                .scaleEffect(animationScale)
                .opacity(2 - animationScale)
                .animation(
                    .easeInOut(duration: 2)
                    .repeatForever(autoreverses: true),
                    value: animationScale
                )
            
            Text("Take a deep breath and think about your mood...")
                .multilineTextAlignment(.center)
                .foregroundColor(.customText)
                .padding()
            
            Button(action: toggleTimer) {
                Text(isActive ? "Stop" : "Start")
                    .font(.title2)
                    .foregroundColor(.customBackground)
                    .frame(width: 200, height: 50)
                    .background(isActive ? Color.red : Color.customText)
                    .cornerRadius(10)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.customBackground)
        .onAppear {
            withAnimation {
                animationScale = 1.5
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func toggleTimer() {
        if isActive {
            timer?.invalidate()
            timer = nil
            isActive = false
            timeRemaining = 300
        } else {
            isActive = true
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    timer?.invalidate()
                    timer = nil
                    isActive = false
                    timeRemaining = 300
                }
            }
        }
    }
}

#Preview {
    FocusView()
} 
