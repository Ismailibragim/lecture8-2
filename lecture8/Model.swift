import Foundation

public struct Model: Codable{
    let timezone: String?
    let hourly: [Current]?
    let daily: [Daily]?
    let current: Current?
    let name: String?
}

struct Current: Codable {
    let temp: Double?
    let feels_like: Double?
    let weather: [Weather]?
}

struct Daily: Codable {
    let temp: Temp?
    let feels_like: Temp?
    let weather: [Weather]?
}

struct Temp: Codable {
    let day: Double?
}

struct Weather: Codable {
    let main: String?
    let description: String?
}


