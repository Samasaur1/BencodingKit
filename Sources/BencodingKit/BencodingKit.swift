import Foundation
public final class Bencoding {
    private init() {}

    public static func object(from data: Data) throws -> Any {
        return try Decoding(data).decode()
    }

    public static func data(from object: Any) throws -> Data {
        return try Encoding().encode(object)
    }
}
