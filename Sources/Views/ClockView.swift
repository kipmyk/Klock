import SwiftUI

struct ClockView: View {
    @ObservedObject var timeManager: TimeManager
    @ObservedObject var weatherManager: WeatherManager
    @State private var showTimeZonePicker = false
    @State private var searchText = ""
    
    var filteredTimeZones: [String] {
        if searchText.isEmpty {
            return timeManager.availableTimeZones
        } else {
            return timeManager.availableTimeZones.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(timeManager.selectedTimeZoneIdentifiers, id: \.self) { id in
                        ClockCard(id: id, timeManager: timeManager, weatherManager: weatherManager)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .frame(maxHeight: .infinity)
            
            HStack(spacing: 20) {
                Button(action: { showTimeZonePicker.toggle() }) {
                    HStack {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                        Text("Add city")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                
                Button(action: { timeManager.is24HourFormat.toggle() }) {
                    Text(timeManager.is24HourFormat ? "24H" : "12H")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                
                StatusSettingsButton(timeManager: timeManager)
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
            .popover(isPresented: $showTimeZonePicker) {
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search for a city...", text: $searchText)
                            .textFieldStyle(.plain)
                    }
                    .padding()
                    .background(Color(white: 0.1))
                    
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(filteredTimeZones, id: \.self) { id in
                                TimeZoneRow(id: id, timeManager: timeManager, weatherManager: weatherManager)
                            }
                        }
                    }
                    .frame(width: 300, height: 400)
                }
                .background(Color(white: 0.05))
            }
        }
        .onAppear {
            for id in timeManager.selectedTimeZoneIdentifiers {
                weatherManager.fetchWeather(for: id)
            }
        }
        .onChange(of: timeManager.selectedTimeZoneIdentifiers) { oldValue, newValue in
            for id in newValue {
                if weatherManager.weatherCache[id] == nil {
                    weatherManager.fetchWeather(for: id)
                }
            }
        }
    }
}

struct ClockCard: View {
    let id: String
    @ObservedObject var timeManager: TimeManager
    @ObservedObject var weatherManager: WeatherManager
    @State private var isHovering = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Status Dot
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(id.split(separator: "/").last?.replacingOccurrences(of: "_", with: " ") ?? id)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    let status = timeManager.getStatus(for: id)
                    Text(status.name.uppercased())
                        .font(.system(size: 8, weight: .black))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(ColorFromHex(status.color).opacity(0.2))
                        .foregroundColor(ColorFromHex(status.color))
                        .cornerRadius(3)
                }
                
                HStack(spacing: 4) {
                    Text(timeManager.getTimeOffset(for: id))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))
                    
                    if let weather = weatherManager.weatherCache[id] {
                        Text("•")
                            .foregroundColor(.white.opacity(0.2))
                        Image(systemName: weatherManager.weatherIcon(for: weather.weatherCode))
                            .font(.system(size: 10))
                        Text("\(Int(weather.temperature))°")
                            .font(.system(size: 11, weight: .bold))
                    }
                }
                .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Text(timeManager.getFormattedTime(for: timeManager.currentTime, timezoneIdentifier: id))
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.9))
            
            if isHovering {
                Button(action: { timeManager.toggleTimeZone(id) }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.3))
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(Color.white.opacity(isHovering ? 0.08 : 0.04))
        .cornerRadius(12)
        .onHover { h in withAnimation(.spring()) { isHovering = h } }
    }
    
    var statusColor: Color {
        ColorFromHex(timeManager.getStatus(for: id).color)
    }
}

func ColorFromHex(_ name: String) -> Color {
    switch name.lowercased() {
    case "green": return .green
    case "yellow": return .yellow
    case "orange": return .orange
    case "purple": return .purple
    case "red": return .red
    case "blue": return .blue
    default: return .gray
    }
}

struct StatusSettingsButton: View {
    @ObservedObject var timeManager: TimeManager
    @State private var showSettings = false
    
    var body: some View {
        Button(action: { showSettings.toggle() }) {
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.white.opacity(0.05))
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showSettings) {
            VStack(spacing: 16) {
                Text("Status Ranges")
                    .font(.headline)
                    .foregroundColor(.white)
                
                VStack(spacing: 12) {
                    ForEach(0..<timeManager.statusProfiles.count, id: \.self) { index in
                        StatusEditorRow(profile: $timeManager.statusProfiles[index])
                    }
                }
            }
            .padding()
            .frame(width: 280)
            .background(Color(white: 0.1))
        }
    }
}

struct StatusEditorRow: View {
    @Binding var profile: TimeManager.StatusProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Circle()
                    .fill(ColorFromHex(profile.color))
                    .frame(width: 8, height: 8)
                Text(profile.name)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text("\(profile.startHour):00 - \(profile.endHour):00")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Start")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                    Stepper("", value: $profile.startHour, in: 0...23)
                        .labelsHidden()
                }
                
                VStack(alignment: .leading) {
                    Text("End")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                    Stepper("", value: $profile.endHour, in: 0...23)
                        .labelsHidden()
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Color")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                    Picker("", selection: $profile.color) {
                        Text("Green").tag("green")
                        Text("Yellow").tag("yellow")
                        Text("Orange").tag("orange")
                        Text("Purple").tag("purple")
                        Text("Red").tag("red")
                    }
                    .labelsHidden()
                }
            }
        }
        .padding(8)
        .background(Color.white.opacity(0.05))
        .cornerRadius(6)
    }
}

struct TimeZoneRow: View {
    let id: String
    @ObservedObject var timeManager: TimeManager
    @ObservedObject var weatherManager: WeatherManager
    
    var body: some View {
        Button(action: {
            timeManager.toggleTimeZone(id)
        }) {
            HStack {
                Text(id.replacingOccurrences(of: "_", with: " "))
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                if timeManager.selectedTimeZoneIdentifiers.contains(id) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(timeManager.selectedTimeZoneIdentifiers.contains(id) ? Color.blue.opacity(0.1) : Color.clear)
    }
}
