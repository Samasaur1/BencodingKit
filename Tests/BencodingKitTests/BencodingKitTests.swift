import XCTest
@testable import BencodingKit

final class BencodingKitTests: XCTestCase {
    func testExample() throws {
        XCTAssertEqual(try Bencoding.object(from: Bencoding.data(from: 5)) as! Int, 5)
    }

    func testFile() throws {
//        let dict = try Bencoding.object(from: Data(contentsOf: .init(fileURLWithPath: "/Users/sam/Downloads/ubuntu-21.10-desktop-amd64.iso.torrent"))) as! [String: Any]
//        print(dict.count)
//        print(dict.keys) //["comment", "announce", "info", "announce-list", "created by", "creation date"]
//        print(dict["announce"])
//        print(dict["announce-list"])
//        print(dict["created by"])
//        print(dict["creation date"])
//        print(dict["comment"])
//        let info = dict["info"] as! [String: Any]
//        print(info.count)
//        print(info.keys) //["piece length", "length", "name", "pieces"]
//        print(info["name"])
//        print(info["piece length"])
//        print(info["length"])
//        let data = try Bencoding.data(from: dict)
//        try! data.write(to: .init(fileURLWithPath: "/Users/sam/Downloads/ubuntu-21.10-desktop-amd64_2.iso.torrent"))
        let dict = try Bencoding.object(from: Data(contentsOf: .init(fileURLWithPath: "/Users/sam/hackscript.sh.torrent"))) as! [String: Any]
        dump(dict)
        let str = (dict["info"]! as! [String: Any])["pieces"] as! String
        print(str.first)
//        print(str.map { String($0.asciiValue!) }.joined(separator: ""))
        let hash = Data(str.unicodeScalars.map { UInt8($0.value) })
        print(String(bytes: hash, encoding: .ascii))
        print(hash.hexStringEncoded())
    }
}
extension Data {
    private static let hexAlphabet = Array("0123456789abcdef".unicodeScalars)
    func hexStringEncoded() -> String {
        String(reduce(into: "".unicodeScalars) { result, value in
            result.append(Self.hexAlphabet[Int(value / 0x10)])
            result.append(Self.hexAlphabet[Int(value % 0x10)])
        })
    }
}
