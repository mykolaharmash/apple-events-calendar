import Foundation
import Yams

private enum AppleEventError: Error {
  case error(String)
}

private struct AppleEventDetails: Decodable {
  let name: String
  let link: URL
  var city: String
  let date: String
  let startTime: String
  
  enum CodingKeys: String, CodingKey {
    case name
    case link
    case city
    case date
    case startTime = "start-time"
  }
  
  static let DEFAULT_CITY = "San Jose, CA"

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    name = try container.decode(String.self, forKey: .name)
    link = try container.decode(URL.self, forKey: .link)
    city = try container.decodeIfPresent(String.self, forKey: .city) ?? AppleEventDetails.DEFAULT_CITY
    date = try container.decode(String.self, forKey: .date)
    startTime = try container.decode(String.self, forKey: .startTime)
  }
}


class AppleEvent {
  let name: String
  let link: URL
  let city: String
  var timeZone: TimeZone?
  var startsAt: Date?
  
  private let rawDate: String
  private let rawStartTime: String
  
  init(fromURL url: URL) throws {
    let content: Data! = FileManager.default.contents(atPath: url.path)
    let encodedYAML = String(bytes: content, encoding: String.Encoding.utf8)!
    
    let decoder = YAMLDecoder()
    let decodedYAML = try decoder.decode(AppleEventDetails.self, from: encodedYAML)
    
    name = decodedYAML.name
    link = decodedYAML.link
    city = decodedYAML.city
    rawDate = decodedYAML.date
    rawStartTime = decodedYAML.startTime
  }
  
  func fetchCityTimeZone() {
    
  }
  
  func calculateStartsAt() throws {
    guard timeZone != nil else {
      throw AppleEventError.error("Time zone is unknown, calculate it before calculating start time.")
    }
    
    let dateFormatter = DateFormatter()
    
    dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
    dateFormatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
    
    let combinedDate = dateFormatter.date(from: "\(rawDate) \(rawStartTime)")

    guard combinedDate != nil else {
      throw ParseError.NoEventDate
    }

    startsAt = combinedDate!
  }
}
