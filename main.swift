import Foundation

func readEventsList(from path: String) throws -> [String] {
  let events: [String] = try FileManager.default.contentsOfDirectory(atPath: path)
  
  if (events.count == 0) {
      throw ParseError.NoEvents
  }
  
  return events
}

func getEventsDir(from args: [String]) throws -> String {
  guard args.count > 1 else {
    throw ParseError.NoEventsFolder
  }
  
  return CommandLine.arguments[1]
}

let eventsDir: String
let eventsFileList: [String]

do {
  eventsDir = try getEventsDir(from: CommandLine.arguments)
  eventsFileList = try readEventsList(from: eventsDir)
} catch let error as ParseError {
  print(error.rawValue)
  throw error
} catch {
  print(error)
  throw error
}

print(eventsFileList)
