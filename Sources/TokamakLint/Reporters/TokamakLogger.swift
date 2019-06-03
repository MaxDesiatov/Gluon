//
//  TokamakLogger.swift
//  TokamakLint
//
//  Created by Matvii Hodovaniuk on 5/30/19.
//

import Foundation
import Logging

public struct LogFileCreationError: Error {
  public init() {}
}

public struct Outputs: OptionSet {
  public init(rawValue: Int) {
    self.rawValue = rawValue
  }

  public let rawValue: Int

  public static let stdout = Outputs(rawValue: 1)
  public static let file = Outputs(rawValue: 2)
}

public struct TokamakLogger: LogHandler {
  public var metadata: Logger.Metadata = [:]

  public init(label: String, path: String?) throws {
    fileManager = FileManager.default
    if let path = path {
      if !fileManager.fileExists(atPath: path) {
        fileManager.createFile(atPath: path, contents: "".data(using: .utf8))
      }
      guard let fileHandle = try? FileHandle(
        forWritingTo: URL(fileURLWithPath: path)
      )
      else { throw LogFileCreationError() }

      self.fileHandle = fileHandle
    }
  }

  public var outputs = [Outputs.stdout]

  private var fileManager: FileManager
  private var fileHandle: FileHandle?

  public var logLevel: Logger.Level = .info

  public func log(
    level: Logger.Level,
    message: Logger.Message,
    metadata: Logger.Metadata?,
    file: String,
    function: String,
    line: UInt
  ) {
    if outputs.contains(Outputs.stdout) {
      print(message.description)
    }

    if outputs.contains(Outputs.file) {
      write(message.description)
    }
  }

  public func log(message: Logger.Message) {
    log(
      level: logLevel,
      message: message,
      metadata: .none,
      file: "",
      function: "",
      line: 0
    )
  }

  private func write(_ string: String) {
    fileHandle?.seekToEndOfFile()
    fileHandle?.write(string.data(using: .utf8)!)
    fileHandle?.write("\n".data(using: .utf8)!)
  }

  public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
    get {
      return metadata[metadataKey]
    }
    set(newValue) {
      metadata[metadataKey] = newValue
    }
  }
}