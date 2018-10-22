import Foundation

internal enum ArgumentsError: String, Error {
  case NoGoogleAPIKey = "No Google API Key was provided in GOOGLE_API_KEY environment variable"
}

internal enum ParseError: String, Error {
  case NoEventsFolder = "No folder was provided as an argument to parse events from"
  case NoEvents = "No events were found in the provided folder"
  case NoEventDate = "Event's date or start time are not properly formatted"
}
