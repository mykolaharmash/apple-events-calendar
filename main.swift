import Foundation

func readEventsList(from path: String) throws -> [URL] {
  let directoryURL = URL(fileURLWithPath: path)
  let eventsURLs: [URL] = try FileManager.default.contentsOfDirectory(
    at: directoryURL,
    includingPropertiesForKeys: nil
    ).filter { !$0.hasDirectoryPath }
  
  if (eventsURLs.count == 0) {
    throw ParseError.NoEvents
  }
  
  return eventsURLs
}

func getEventsDir(from args: [String]) throws -> String {
  guard args.count > 1 else {
    throw ParseError.NoEventsFolder
  }
  
  return CommandLine.arguments[1]
}

func getGoogleAPIKey(from env: [String: String]) throws -> String {
  let key: String? = env["GOOGLE_API_KEY"]
  
  guard key != nil else {
    throw ArgumentsError.NoGoogleAPIKey
  }
  
  return key!
}

func readEvents(from filesList: [URL]) throws -> [AppleEvent] {
  return try filesList.map { try AppleEvent(fromURL: $0) }
}

let eventsDir: String
let eventsFileList: [URL]
let eventsList: [AppleEvent]
let googleApiKey: String

do {
  googleApiKey = try getGoogleAPIKey(from: ProcessInfo.processInfo.environment)
  eventsDir = try getEventsDir(from: CommandLine.arguments)
  eventsFileList = try readEventsList(from: eventsDir)
  eventsList = try readEvents(from: eventsFileList)
} catch {
  print(error)
  exit(1)
}

eventsList.forEach { (event: AppleEvent) in
  event.calculateStartTime(apiKey: googleApiKey) { (result: String?, error: Error?) in
    guard error == nil else {
      print(error!)
      exit(1)
    }
    
    print(result!)
  }
}

RunLoop.main.run()

//print(ProcessInfo.processInfo.environment["GOOGLE_API_KEY"])


