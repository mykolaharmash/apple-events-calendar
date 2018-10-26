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

fileprivate struct GoogleGeocoderResults: Decodable {
  let results: [GoogleGeocoderResultItem]
  
  internal struct GoogleGeocoderGeometry: Decodable {
    let location: GoogleGeocoderLocation
  }
  
  internal struct GoogleGeocoderResultItem: Decodable {
    let geometry: GoogleGeocoderGeometry
  }
  
  internal struct GoogleGeocoderLocation: Decodable {
    let lat: Double
    let lng: Double
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
  
  static let GEOCODING_PATH: String = "https://maps.googleapis.com/maps/api/geocode/json"
  
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
  
  func calculateStartTime(apiKey: String, completion: @escaping (_ result: String?, _ error: Error?) -> Void) {
    geocodeCity(apiKey: apiKey) { (result: String?, error: Error?) in
      
      completion(result, error)
    }
  }
  
  func fetchTimezone(city: String, date: Date) {
    
  }
  
  
  func geocodeCity(
    apiKey: String,
    completion: @escaping (_ result: String?, _ error: Error?) -> Void
  ) {
//    let encodedCity = city.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!
//    let encodedApiKey = apiKey.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!
//    let geocoderUrl = URL(string: "\(AppleEvent.GEOCODING_PATH)?address=\(encodedCity)&key=\(encodedApiKey)")!
//
//    let geocodingTask = URLSession.shared.dataTask(with: geocoderUrl) { (data, res, error) in
//      guard error == nil else {
//        return completion(nil, error)
//      }
//
//      let response: HTTPURLResponse = res! as! HTTPURLResponse
//
//      guard response.statusCode == 200 else {
//        return completion(nil, AppleEventError.error("""
//          Unable to geocode \"\(self.city)\", \
//          \(response.statusCode): \(HTTPURLResponse.localizedString(forStatusCode: response.statusCode)).
//          Request URL: \(geocoderUrl).
//          """
//        ))
//      }
//
//      let dataString = String(bytes: data!, encoding: String.Encoding.utf8)
    
      let dataString = """
      {
   \"results\" : [
      {
         \"address_components\" : [
            {
               \"long_name\" : \"San Jose\",
               \"short_name\" : \"San Jose\",
               \"types\" : [ \"locality\", \"political\" ]
            },
            {
               \"long_name\" : \"Santa Clara County\",
               \"short_name\" : \"Santa Clara County\",
               \"types\" : [ \"administrative_area_level_2\", \"political\" ]
            },
            {
               \"long_name\" : \"California\",
               \"short_name\" : \"CA\",
               \"types\" : [ \"administrative_area_level_1\", \"political\" ]
            },
            {
               \"long_name\" : \"United States\",
               \"short_name\" : \"US\",
               \"types\" : [ \"country\", \"political\" ]
            }
         ],
         \"formatted_address\" : \"San Jose, CA, USA\",
         \"geometry\" : {
            \"bounds\" : {
               \"northeast\" : {
                  \"lat\" : 37.4695381,
                  \"lng\" : -121.589154
               },
               \"southwest\" : {
                  \"lat\" : 37.124493,
                  \"lng\" : -122.0456719
               }
            },
            \"location\" : {
               \"lat\" : 37.3382082,
               \"lng\" : -121.8863286
            },
            \"location_type\" : \"APPROXIMATE\",
            \"viewport\" : {
               \"northeast\" : {
                  \"lat\" : 37.4695381,
                  \"lng\" : -121.589154
               },
               \"southwest\" : {
                  \"lat\" : 37.124493,
                  \"lng\" : -122.0456719
               }
            }
         },
         \"place_id\" : \"ChIJ9T_5iuTKj4ARe3GfygqMnbk\",
         \"types\" : [ \"locality\", \"political\" ]
      }
   ],
   \"status\" : \"OK\"
}
""".data(using: String.Encoding.utf8)!
    
      let jsonDecoder = JSONDecoder()
    
    do {
      let json = try jsonDecoder.decode(GoogleGeocoderResults.self, from: dataString)
    
      print(json.results[0].geometry.location)
    } catch {
      print(error)
    }
  
    
//      completion(dataString, nil)
//    }
    
//    geocodingTask.resume()
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
