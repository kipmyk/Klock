import Foundation
import Combine

struct WeatherData: Codable {
    let temperature: Double
    let weatherCode: Int
}

class WeatherManager: ObservableObject {
    @Published var weatherCache: [String: WeatherData] = [:]
    private var cancellables = Set<AnyCancellable>()
    private var refreshTimer: AnyCancellable?
    
    init() {
        startRefreshTimer()
    }
    
    private func startRefreshTimer() {
        refreshTimer = Timer.publish(every: 1800, on: .main, in: .common) // 30 minutes
            .autoconnect()
            .sink { [weak self] _ in
                self?.refreshAll()
            }
    }
    
    func refreshAll() {
        for id in weatherCache.keys {
            fetchWeather(for: id)
        }
    }
    
    func fetchWeather(for timezoneIdentifier: String) {
        let parts = timezoneIdentifier.split(separator: "/")
        let cityName = parts.last?.replacingOccurrences(of: "_", with: " ") ?? ""
        guard !cityName.isEmpty else { return }
        
        // 1. Geocode City Name
        let geocodeUrl = URL(string: "https://geocoding-api.open-meteo.com/v1/search?name=\(cityName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&count=1&language=en&format=json")!
        
        URLSession.shared.dataTaskPublisher(for: geocodeUrl)
            .map(\.data)
            .decode(type: GeocodeResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Geocoding error for \(cityName): \(error)")
                }
            } receiveValue: { [weak self] response in
                if let result = response.results?.first {
                    self?.fetchTemp(lat: result.latitude, lon: result.longitude, identifier: timezoneIdentifier)
                }
            }
            .store(in: &cancellables)
    }
    
    private func fetchTemp(lat: Double, lon: Double, identifier: String) {
        let weatherUrl = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&current_weather=true")!
        
        URLSession.shared.dataTaskPublisher(for: weatherUrl)
            .map(\.data)
            .decode(type: WeatherResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Weather error for \(identifier): \(error)")
                }
            } receiveValue: { [weak self] response in
                let data = WeatherData(
                    temperature: response.current_weather.temperature,
                    weatherCode: response.current_weather.weathercode
                )
                self?.weatherCache[identifier] = data
            }
            .store(in: &cancellables)
    }
    
    func weatherIcon(for code: Int) -> String {
        switch code {
        case 0: return "sun.max.fill"
        case 1, 2, 3: return "cloud.sun.fill"
        case 45, 48: return "fog.fill"
        case 51, 53, 55: return "cloud.drizzle.fill"
        case 61, 63, 65: return "cloud.rain.fill"
        case 71, 73, 75: return "snowflake"
        case 80, 81, 82: return "cloud.heavyrain.fill"
        case 95, 96, 99: return "cloud.bolt.fill"
        default: return "cloud.fill"
        }
    }
}

// Mark: - Supporting Models
struct GeocodeResponse: Codable {
    let results: [GeocodeResult]?
}

struct GeocodeResult: Codable {
    let latitude: Double
    let longitude: Double
}

struct WeatherResponse: Codable {
    let current_weather: CurrentWeather
}

struct CurrentWeather: Codable {
    let temperature: Double
    let weathercode: Int
}
