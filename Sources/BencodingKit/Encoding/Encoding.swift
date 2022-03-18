import Foundation

class Encoding {
    enum Error: Swift.Error {
        case illegallyKeyedDictionary(object: [AnyHashable: Any], keyType: String)
        case unencodableType(object: Any)
    }
    private func char(_ c: String) -> Data {
        precondition(c.count == 1)
        switch c {
        case ":": return Data(repeating: 58, count: 1)
        case "d": return Data(repeating: 100, count: 1)
        case "e": return Data(repeating: 101, count: 1)
        case "i": return Data(repeating: 105, count: 1)
        case "l": return Data(repeating: 108, count: 1)
        default: fatalError()
        }
    }

    func encode(_ object: Any) throws -> Data {
        if let dict = object as? Dictionary<String, Any> {
            return try encodeDict(dict)
        } else if let arr = object as? Array<Any> {
            return try encodeArray(arr)
        } else if let str = object as? String {
            return encodeString(str)
        } else if let i = object as? Int {
            return encodeInt(i)
        } else if let data = object as? Data {
            return encodeData(data)
        }
        if object is Dictionary<AnyHashable, Any> {
            throw Error.illegallyKeyedDictionary(object: object as! [AnyHashable : Any], keyType: String(String(describing: type(of: object)).dropLast(6).dropFirst(11)))
        }
        throw Error.unencodableType(object: object)
    }

    private func encodeDict(_ d: Dictionary<String, Any>) throws -> Data {
        var data = char("d")

        let sorted = d.sorted { $0.key < $1.key }
        for (key, value) in sorted {
            data.append(try encode(key))
            data.append(try encode(value))
        }

        data.append(char("e"))

        return data
    }

    private func encodeArray(_ a: Array<Any>) throws -> Data {
        var data = char("l")

        for element in a {
            data.append(try encode(element))
        }

        data.append(char("e"))

        return data
    }

    private func encodeString(_ s: String) -> Data {
        var data = Data()

        let length = s.count
        data.append(String(length).data(using: .ascii)!)
        data.append(char(":"))
        data.append(s.data(using: .ascii)!)

        return data
    }

    private func encodeInt(_ i : Int) -> Data {
        var data = char("i")

        data.append(String(i).data(using: .ascii)!)
        data.append(char("e"))

        return data
    }

    private func encodeData(_ data: Data) -> Data {
        return String(data.count).data(using: .ascii)! + char(":") + data
    }
}
