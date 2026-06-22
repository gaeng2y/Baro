#!/usr/bin/swift
import Foundation

let localDirectory = "Tuist/Local"
let teamIDPath = "\(localDirectory)/TeamID.txt"

func readTeamID() -> String {
    if CommandLine.arguments.count > 1 {
        return CommandLine.arguments[1]
    }

    print("Enter your Apple Developer Team ID: ", terminator: "")
    guard let input = readLine() else {
        fatalError("Team ID input was cancelled.")
    }
    return input
}

func normalizedTeamID(_ value: String) -> String {
    value
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .uppercased()
}

func validateTeamID(_ teamID: String) {
    let allowed = CharacterSet.alphanumerics
    guard teamID.count == 10, teamID.unicodeScalars.allSatisfy({ allowed.contains($0) }) else {
        fatalError("Apple Developer Team ID must be 10 alphanumeric characters.")
    }
}

func writeTeamID(_ teamID: String) throws {
    try FileManager.default.createDirectory(
        atPath: localDirectory,
        withIntermediateDirectories: true
    )
    try "\(teamID)\n".write(
        toFile: teamIDPath,
        atomically: true,
        encoding: .utf8
    )
}

let teamID = normalizedTeamID(readTeamID())
validateTeamID(teamID)

do {
    try writeTeamID(teamID)
    print("✅ Apple Developer Team ID saved to \(teamIDPath)")
    print("Run `tuist generate` again to apply it to the Xcode project.")
} catch {
    fatalError("Failed to write Team ID: \(error)")
}
