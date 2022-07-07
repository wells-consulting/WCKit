// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import Foundation

private protocol MultipartFormContent {
    var name: String { get }
    var summary: String { get }
    func encode(into data: NSMutableData)
}

public final class MultipartForm {
    // MARK: - Properties

    private var contents = [MultipartFormContent]()

    var isEmpty: Bool {
        contents.isEmpty
    }

    var summary: String? {
        contents.map(\.summary).joined(separator: "\n")
    }

    // MARK: - API

    func generateData() -> Data {
        let data = NSMutableData()

        for content in contents {
            data.append("\r\n--\(HTTP.multipartFormBoundary)\r\n".data(using: String.Encoding.utf8)!)
            content.encode(into: data)
        }

        data.append("\r\n--\(HTTP.multipartFormBoundary)--\r\n".data(using: String.Encoding.utf8)!)

        return data as Data
    }

    func contains(_ name: String) -> Bool {
        !contents.filter { $0.name.hasPrefix(name) }.isEmpty
    }

    func getStringContentWithName(_ name: String) -> String? {
        if let content = contents.first(where: { $0 is StringContent && $0.name == name }) {
            return (content as? StringContent)?.value
        }
        return nil
    }

    func addContent(_ value: Bool, withName name: String) {
        contents.append(StringContent(value: value ? "true" : "false", name: name))
    }

    func addContent(_ value: String, withName name: String) {
        contents.append(StringContent(value: value, name: name))
    }

    func addContent(_ value: Int, withName name: String) {
        contents.append(StringContent(value: String(value), name: name))
    }

    func addContent(_ value: Int32, withName name: String) {
        contents.append(StringContent(value: String(value), name: name))
    }

    func addContent(_ value: Int64, withName name: String) {
        contents.append(StringContent(value: String(value), name: name))
    }

    func addContent(_ value: Double, withName name: String) {
        contents.append(StringContent(value: String(value), name: name))
    }

    func addContent(_ value: Date, withName name: String) {
        contents.append(StringContent(value: value.asISO8601String(), name: name))
    }

    func addContent(_ value: UUID, withName name: String) {
        contents.append(StringContent(value: value.uuidString, name: name))
    }

    func addContent(_ value: Data, withName name: String, savingTo filename: String) {
        contents.append(FileContent(value: value, name: name, filename: filename))
    }

    func addContent<T: Encodable>(_ value: T, withName name: String) throws {
        contents.append(try JSONContent(value: value, name: name))
    }

    // MARK: - Private Implementation

    class StringContent: MultipartFormContent {
        let name: String
        let value: String

        var summary: String {
            """
            { "\(name)": "\(value)" }
            """
        }

        init(value: String, name: String) {
            self.name = name
            self.value = value
        }

        func encode(into data: NSMutableData) {
            data.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: String.Encoding.utf8)!)
            data.append(value.data(using: String.Encoding.utf8)!)
        }
    }

    struct JSONContent<T: Encodable>: MultipartFormContent {
        let name: String
        let data: Data

        var summary: String {
            let dataByteCount = data.count.asCount()
            return """
                { "name": "\(name)", "data":"\(dataByteCount)" }
            """
        }

        init(value: T, name: String) throws {
            self.name = name
            data = try JSON.encode(value)
        }

        func encode(into data: NSMutableData) {
            data.append(
                "Content-Disposition: form-data; name=\"\(name)\"\r\n"
                    .data(using: String.Encoding.utf8)!
            )
            data.append(
                "Content-Type: application/json\r\n\r\n"
                    .data(using: String.Encoding.utf8)!
            )
            data.append(self.data)
        }
    }

    struct FileContent: MultipartFormContent {
        let name: String
        let filename: String
        let data: Data

        var summary: String {
            let dataByteCount = data.count.asCount()
            return """
                { "name": "\(name)", "filename": "\(filename)", "data":"\(dataByteCount)" }
            """
        }

        init(value: Data, name: String, filename: String) {
            self.name = name
            self.filename = filename
            data = value
        }

        func encode(into data: NSMutableData) {
            data.append(
                "Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n"
                    .data(using: String.Encoding.utf8)!
            )
            data.append(
                "Content-Type: application/octet-stream\r\n\r\n"
                    .data(using: String.Encoding.utf8)!
            )
            data.append(self.data)
        }
    }
}

// MARK: -

struct MultipartFormError: LocalizedError {
    let message: String
    let form: MultipartForm
    let flag: String?

    public var errorDescription: String? {
        message
    }

    init(message: String, form: MultipartForm, flag: String? = nil) {
        self.message = message
        self.form = form
        self.flag = flag
    }
}
