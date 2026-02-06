import Foundation
import Combine

class TimeManager: ObservableObject {
    @Published var currentTime = Date()
    @Published var selectedTimeZoneIdentifiers: [String] = [] {
        didSet {
            UserDefaults.standard.set(selectedTimeZoneIdentifiers, forKey: "SelectedTimeZones")
        }
    }
    @Published var is24HourFormat: Bool = false {
        didSet {
            UserDefaults.standard.set(is24HourFormat, forKey: "Is24HourFormat")
        }
    }
    
    struct StatusProfile: Codable, Equatable {
        var name: String
        var color: String
        var startHour: Int
        var endHour: Int
    }
    
    @Published var statusProfiles: [StatusProfile] = [] {
        didSet {
            if let encoded = try? JSONEncoder().encode(statusProfiles) {
                UserDefaults.standard.set(encoded, forKey: "StatusProfiles")
            }
        }
    }
    
    @Published var timezoneStrings: [String: String] = [:]
    
    private var timer: AnyCancellable?
    
    var availableTimeZones: [String] {
        TimeZone.knownTimeZoneIdentifiers.sorted()
    }
    
    init() {
        if let savedStatus = UserDefaults.standard.object(forKey: "Is24HourFormat") as? Bool {
            self.is24HourFormat = savedStatus
        } else {
            self.is24HourFormat = false
        }
        
        if let savedProfilesData = UserDefaults.standard.data(forKey: "StatusProfiles"),
           let savedProfiles = try? JSONDecoder().decode([StatusProfile].self, from: savedProfilesData) {
            self.statusProfiles = savedProfiles
        } else {
            self.statusProfiles = [
                StatusProfile(name: "Working", color: "green", startHour: 9, endHour: 17),
                StatusProfile(name: "Awake", color: "yellow", startHour: 7, endHour: 22),
                StatusProfile(name: "Annoying", color: "orange", startHour: 22, endHour: 0),
                StatusProfile(name: "Asleep", color: "purple", startHour: 0, endHour: 7)
            ]
        }
        
        if let saved = UserDefaults.standard.stringArray(forKey: "SelectedTimeZones") {
            self.selectedTimeZoneIdentifiers = saved
        } else {
            self.selectedTimeZoneIdentifiers = [TimeZone.current.identifier]
        }
        updateTimezoneStrings()
        startTimer()
    }
    
    func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.currentTime = Date()
            }
    }
    
    func updateTimezoneStrings() {
        var newStrings: [String: String] = [:]
        for id in selectedTimeZoneIdentifiers {
            let timezone = TimeZone(identifier: id) ?? TimeZone.current
            let abbreviation = timezone.abbreviation() ?? "UTC"
            let seconds = timezone.secondsFromGMT()
            let hours = seconds / 3600
            let gmtOffset = hours >= 0 ? "+\(hours)" : "\(hours)"
            newStrings[id] = "\(id.replacingOccurrences(of: "_", with: " ")) (\(abbreviation) GMT\(gmtOffset))"
        }
        timezoneStrings = newStrings
    }
    
    func getFormattedTime(for date: Date, timezoneIdentifier: String) -> String {
        let formatter = DateFormatter()
        if is24HourFormat {
            formatter.dateFormat = "HH:mm"
        } else {
            formatter.dateFormat = "hh:mm a"
        }
        formatter.timeZone = TimeZone(identifier: timezoneIdentifier)
        return formatter.string(from: date)
    }

    func getTimeOffset(for identifier: String) -> String {
        let targetTZ = TimeZone(identifier: identifier) ?? TimeZone.current
        let localTZ = TimeZone.current
        
        let seconds = targetTZ.secondsFromGMT() - localTZ.secondsFromGMT()
        let hours = Int(Double(seconds) / 3600.0)
        
        if hours == 0 { return "Local" }
        return hours > 0 ? "+\(hours)h" : "\(hours)h"
    }
    
    func getStatus(for identifier: String) -> StatusProfile {
        let timezone = TimeZone(identifier: identifier) ?? TimeZone.current
        let calendar = Calendar.current
        var targetCalendar = calendar
        targetCalendar.timeZone = timezone
        
        let hour = targetCalendar.component(.hour, from: Date())
        
        // Find matching profile. Annoying and Asleep might overlap midnight, so we check carefully.
        for profile in statusProfiles {
            if profile.startHour < profile.endHour {
                if hour >= profile.startHour && hour < profile.endHour {
                    return profile
                }
            } else {
                // Overlaps midnight (e.g., 22 to 7)
                if hour >= profile.startHour || hour < profile.endHour {
                    return profile
                }
            }
        }
        
        // Default to last profile if none match (shouldn't happen with full coverage)
        return statusProfiles.last ?? StatusProfile(name: "Unknown", color: "gray", startHour: 0, endHour: 24)
    }
    
    func toggleTimeZone(_ identifier: String) {
        if selectedTimeZoneIdentifiers.contains(identifier) {
            if selectedTimeZoneIdentifiers.count > 1 {
                selectedTimeZoneIdentifiers.removeAll(where: { $0 == identifier })
            }
        } else {
            selectedTimeZoneIdentifiers.append(identifier)
        }
        updateTimezoneStrings()
    }
}
