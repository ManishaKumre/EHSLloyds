//
//  Encodable.swift
//  Lloyds
//
//  Created by Manisha on 23/12/25.
//

import Foundation
import Foundation

extension Encodable {
    /// Convert any Encodable struct to [String: Any]
    func asDictionary() -> [String: Any]? {
        do {
            // 1️⃣ Encode struct to JSON data
            let data = try JSONEncoder().encode(self)
            
            // 2️⃣ Convert JSON data to Any object
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            // 3️⃣ Cast Any to [String: Any]
            return jsonObject as? [String: Any]
        } catch {
            print("Failed to convert \(self) to dictionary: \(error)")
            return nil
        }
    }
}

//
//struct CodableValue: Codable {
//    let value: Any
//
//    init(_ value: Any) { self.value = value }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        switch value {
//        case let int as Int: try container.encode(int)
//        case let str as String: try container.encode(str)
//        case let bool as Bool: try container.encode(bool)
//        case let arr as [String]: try container.encode(arr)
//        case let dict as [String: Any]:
//            let codableDict = dict.mapValues { CodableValue($0) }
//            try container.encode(codableDict)
//        default:
//            try container.encodeNil()
//        }
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        if let int = try? container.decode(Int.self) { value = int; return }
//        if let str = try? container.decode(String.self) { value = str; return }
//        if let bool = try? container.decode(Bool.self) { value = bool; return }
//        if let arr = try? container.decode([String].self) { value = arr; return }
//        if let dict = try? container.decode([String: CodableValue].self) {
//            value = dict.mapValues { $0.value }
//            return
//        }
//        value = ()
//    }
//}

extension CodableValue {
    static func fromAny(_ value: Any) -> CodableValue {
        if let str = value as? String {
            return .string(str)
        } else if let bool = value as? Bool {
            return .bool(bool)
        } else if let int = value as? Int {
            return .int(int)
        } else if let double = value as? Double {
            return .double(double)
        } else if let arr = value as? [Any] {
            return .array(arr.map { CodableValue.fromAny($0) })
        } else if let dict = value as? [String: Any] {
            return .dictionary(dict.mapValues { CodableValue.fromAny($0) })
        } else {
            return .string("\(value)")
        }
    }
}
