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

func readEvents(from filesList: [URL]) throws -> [AppleEvent] {
  return try filesList.map { try AppleEvent(fromURL: $0) }
}

let eventsDir: String
let eventsFileList: [URL]
let eventsList: [AppleEvent]

do {
  eventsDir = try getEventsDir(from: CommandLine.arguments)
  eventsFileList = try readEventsList(from: eventsDir)
  eventsList = try readEvents(from: eventsFileList)
} catch let error as ParseError {
  print(error.rawValue)
  throw error
} catch {
  print(error)
  throw error
}

eventsList.map { print($0.details) }


