//
// Created by dragoncodes on 25.04.18.

import Foundation

func readFile(_ inputFilePath: String) -> Either<FileError, String> {

    guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        return Either.fromLeft(FileError.fileNotFound)
    }

    let fileURL = dir.appendingPathComponent(inputFilePath)

    do {
        let data = try String(contentsOf: fileURL, encoding: .utf8)

        return Either.fromRight(data)
    } catch {
        return Either.fromLeft(FileError.fileParsingError(message: error.localizedDescription))
    }
}

enum FileError {
    case fileParsingError(message: String)

    case fileNotFound
}