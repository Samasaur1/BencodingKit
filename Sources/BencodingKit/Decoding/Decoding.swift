import Foundation

class Decoding {
    enum Error: Swift.Error {
        case illegallyKeyedDictionary
        case invalidData
    }
    //MARK: - Private variables
    private let data: Data
    private var index = 0

    //MARK: - Public interface
    init(_ data: Data) {
        self.data = data
    }

//    case ":": return Data(repeating: 58, count: 1)
//    case "d": return Data(repeating: 100, count: 1)
//    case "e": return Data(repeating: 101, count: 1)
//    case "i": return Data(repeating: 105, count: 1)
//    case "l": return Data(repeating: 108, count: 1)
    func decode() throws -> Any {
        index = 0
        return try decodeAnything()
    }

    //MARK: - Private decoding/parsing methods
    private func decodeAnything() throws -> Any {
        switch data[index] {
        case 100: //d => dict
            return try decodeDict()
        case 101: //e => invalid data
            fatalError()
        case 105: //i => integer
            return decodeInt()
        case 108: //l => array
            return try decodeArray()
        case let x where x >= 48 && x <= 57: //digit => string
            return try decodeString()
        default: //invalid data
            throw Error.invalidData
        }
    }

    private func decodeDict() throws -> Dictionary<String, Any> {
        precondition(data[index] == 100)
        index += 1

        var d: [String: Any] = [:]

        while data[index] != 101 {
            let key = try decodeString()
            let value = try decodeAnything()
            d[key] = value
        }

        index += 1 //skip past 'e', we know we must have hit it because we're out of the loop
        return d
    }

    private func decodeArray() throws -> Array<Any> {
        precondition(data[index] == 108)
        index += 1

        var arr: [Any] = []

        while data[index] != 101 {
            let val = try decodeAnything()
            arr.append(val)
        }

        index += 1
        return arr
    }

    private func decodeString() throws -> String {
        guard data[index] >= 48 && data[index] <= 57 else {
            throw Error.illegallyKeyedDictionary
        }
//        precondition(data[index] >= 48 && data[index] <= 57)

        var len: Int = 0

        while data[index] >= 48 && data[index] <= 57 {
            len *= 10
            len += Int(data[index]) - 48
            index += 1
        }

        precondition(data[index] == 58)
        index += 1

        //TODO: no leading zeroes unless the length string is only "0"

        let str = String(bytes: data[index..<(index + len)], encoding: .ascii)!
        index += len

        return str
    }

    private func decodeInt() -> Int {
        precondition(data[index] == 105)
        index += 1

        let e = data[index...].firstIndex(of: 101)!
        let str_num = String(bytes: data[index..<e], encoding: .ascii)!

//        precondition(!str_num.contains { !"-0123456789".contains($0) }) //does not contain any non-digits
        //TODO: no leading zeroes unless the number is exactly "0"

        let num = Int(str_num)!

        index = e + 1

        return num
    }
}
