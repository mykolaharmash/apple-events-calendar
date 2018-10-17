import Foundation
import Yams

struct AppleEventYAMLSctructure: Decodable {
  let name: String
  let startsAt: Date
  let link: URL
  
  enum CodingKeys: String, CodingKey {
    case name
    case date
    case startTime = "start-time"
    case link
  }
  
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
    
    let date = try container.decode(String.self, forKey: .date)
    let time = try container.decode(String.self, forKey: .startTime)
    let combinedDate = AppleEventYAMLSctructure.combine(date: date, time: time)
    
    guard combinedDate != nil else {
      throw ParseError.NoEventDate
    }
    
    startsAt = combinedDate!
    
//    print(Locale.availableIdentifiers)
//    print(TimeZone.knownTimeZoneIdentifiers)
  }
}


struct AppleEvent {
  let details: AppleEventYAMLSctructure
  
  init(details: AppleEventYAMLSctructure) {
    self.details = details
  }
  
  init(fromURL url: URL) throws {
    let content: Data! = FileManager.default.contents(atPath: url.path)
    let encodedYAML = String(bytes: content, encoding: String.Encoding.utf8)!
    
    let decoder = YAMLDecoder()
    let decodedYAML = try decoder.decode(AppleEventYAMLSctructure.self, from: encodedYAML)
    
    self.init(details: decodedYAML)
  }
}
