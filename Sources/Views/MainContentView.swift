import SwiftUI

struct MainContentView: View {
    @StateObject private var timeManager = TimeManager()
    @StateObject private var weatherManager = WeatherManager()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Klock")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
                Image(systemName: "globe.americas.fill")
                    .foregroundColor(.blue.opacity(0.8))
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 12)
            
            ClockView(timeManager: timeManager, weatherManager: weatherManager)
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            Button(action: { NSApplication.shared.terminate(nil) }) {
                HStack {
                    Text("Quit Klock")
                        .font(.system(size: 12, weight: .medium))
                    Spacer()
                    Text("⌘Q")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundColor(.white.opacity(0.6))
        }
        .frame(width: 400, height: 620)
        .background(Color(white: 0.05)) // Midnight background
    }
}
