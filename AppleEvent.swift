import Foundation
import Yams

struct AppleEventYAMLSctructure: Decodable {
  let name: String
  let date: String
  let startTime: String
  let link: URL
  
//  let formattedDate: Date
  
  enum CodingKeys: String, CodingKey {
    case name
    case date
    case startTime = "start-time"
    case link
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    name = try container.decode(String.self, forKey: .name)
    date = try container.decode(String.self, forKey: .date)
    startTime = try container.decode(String.self, forKey: .startTime)
    link = try container.decode(URL.self, forKey: .link)
    
//    print(Locale.availableIdentifiers)
    
    let dateFormatter = DateFormatter()
    
    dateFormatter.dateFormat = "dd.MM.yyyy"
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
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
