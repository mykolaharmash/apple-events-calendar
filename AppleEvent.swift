import Foundation
import Yams

struct AppleEventDetails: Decodable {
  let name: String
  let startsAt: Date
  let link: URL
  var city: String
  
  enum CodingKeys: String, CodingKey {
    case name
    case date
    case startTime = "start-time"
    case link
    case city
  }
  
  static let DEFAULT_CITY = "San Jose, CA"
  
  static func combine(date: String, time: String) -> Date? {
    let dateFormatter = DateFormatter()
    
    dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
    dateFormatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
    
    return dateFormatter.date(from: "\(date) \(time)")
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    name = try container.decode(String.self, forKey: .name)
    link = try container.decode(URL.self, forKey: .link)
    city = try container.decodeIfPresent(String.self, forKey: .city) ?? AppleEventDetails.DEFAULT_CITY
    
    let date = try container.decode(String.self, forKey: .date)
    let time = try container.decode(String.self, forKey: .startTime)
    let combinedDate = AppleEventDetails.combine(date: date, time: time)
    
    guard combinedDate != nil else {
      throw ParseError.NoEventDate
    }
    
    startsAt = combinedDate!
    
//    print(Locale.availableIdentifiers)
//    print(TimeZone.knownTimeZoneIdentifiers)
  }
}


struct AppleEvent {
  let details: AppleEventDetails
  
  init(details: AppleEventDetails) {
    self.details = details
  }
  
  init(fromURL url: URL) throws {
    let content: Data! = FileManager.default.contents(atPath: url.path)
    let encodedYAML = String(bytes: content, encoding: String.Encoding.utf8)!
    
    let decoder = YAMLDecoder()
    let decodedYAML = try decoder.decode(AppleEventDetails.self, from: encodedYAML)
    
    self.init(details: decodedYAML)
  }
}
