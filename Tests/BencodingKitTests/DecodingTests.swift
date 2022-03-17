import XCTest
@testable import BencodingKit

final class BencodingKitDecodingTests: XCTestCase {
    //MARK: - Integer
    func testInteger0() throws {
        XCTAssertEqual(try Decoding("i0e".data(using: .ascii)!).decode() as? Int, 0)
    }

    func testIntegerPositive() throws {
        XCTAssertEqual(try Decoding("i15e".data(using: .ascii)!).decode() as? Int, 15)
        XCTAssertEqual(try Decoding("i1e".data(using: .ascii)!).decode() as? Int, 1)
        XCTAssertEqual(try Decoding("i17203e".data(using: .ascii)!).decode() as? Int, 17203)
        XCTAssertEqual(try Decoding("i6e".data(using: .ascii)!).decode() as? Int, 6)
        XCTAssertEqual(try Decoding("i111111111e".data(using: .ascii)!).decode() as? Int, 111111111)
    }

    func testIntegerNegative() throws {
        XCTAssertEqual(try Decoding("i-1e".data(using: .ascii)!).decode() as? Int, -1)
        XCTAssertEqual(try Decoding("i-7e".data(using: .ascii)!).decode() as? Int, -7)
        XCTAssertEqual(try Decoding("i-111111111e".data(using: .ascii)!).decode() as? Int, -111111111)
        XCTAssertEqual(try Decoding("i-567e".data(using: .ascii)!).decode() as? Int, -567)
    }

    //MARK: - Dictionary
    func testDictionaryEmpty() throws {
        XCTAssertEqual((try Decoding("de".data(using: .ascii)!).decode() as? Dictionary<String, Any>)?.count, 0)
    }

    func testDictionarySingleItem() throws {
        XCTAssertEqual(try Decoding("d5:hello5:worlde".data(using: .ascii)!).decode() as? [String : String], ["hello": "world"])
        XCTAssertEqual(try Decoding("d6:answeri42ee".data(using: .ascii)!).decode() as? [String: Int], ["answer": 42])
    }

    func testDictionaryNotStringKey() throws {
        XCTAssertThrowsError(try Decoding("di1:4e4:foure".data(using: .ascii)!).decode(), "Dictionaries must have string keys")
    }

    func testDictionaryHomogeneous() throws {
        XCTAssertEqual(try Decoding("d1:5i5e4:6789i6789e1:8i8ee".data(using: .ascii)!).decode() as? [String: Int], ["5": 5, "8": 8, "6789": 6789])
        XCTAssertEqual(try Decoding("d3:arr2:ay4:dict6:ionary3:int4:eger3:str3:inge".data(using: .ascii)!).decode() as? [String: String], ["dict": "ionary", "arr": "ay", "int": "eger", "str": "ing"])
    }

    func testDictionaryHetergeneous() throws {
        XCTAssertTrue(try { () -> Bool in
            guard let dict = try Decoding("d5:arrayli5ei6ei7ei8ee10:dictionaryd1:1i1ee7:integeri13e6:string6:stringe".data(using: .ascii)!).decode() as? [String: Any] else {
                return false
            }
            guard dict.count == 4 else {
                return false
            }
            guard dict["string"] as? String == "string" else {
                return false
            }
            guard dict["integer"] as? Int == 13 else {
                return false
            }
            guard let arr = dict["array"] as? [Int], arr == [5,6,7,8] else {
                return false
            }
            guard let d2 = dict["dictionary"] as? [String: Int], d2 == ["1": 1] else {
                return false
            }
            return true
        }())
//        XCTAssertEqual(try Encoding().encode(["string": "string", "integer": 13, "array": [5,6,7,8], "dictionary": ["1": 1]] as [String: Any]), "d5:arrayli5ei6ei7ei8ee10:dictionaryd1:1i1ee7:integeri13e6:string6:stringe".data(using: .ascii))
    }

    //MARK: - Array
    func testArrayEmpty() throws {
        XCTAssertEqual((try Decoding("le".data(using: .ascii)!).decode() as? Array<Any>)?.count, 0)
    }

    func testArraySingleItem() throws {
        XCTAssertEqual(try Decoding("l4:iteme".data(using: .ascii)!).decode() as? [String], ["item"])
        XCTAssertEqual(try Decoding("li42ee".data(using: .ascii)!).decode() as? [Int], [42])
    }

    func testArrayHomogeneous() throws {
        XCTAssertEqual(try Decoding("l3:one3:two5:three4:foure".data(using: .ascii)!).decode() as? [String], ["one", "two", "three", "four"])
        XCTAssertEqual(try Decoding("li1ei2ei3ei4ee".data(using: .ascii)!).decode() as? [Int], [1,2,3,4])
    }

    func testArrayHeterogeneous() throws {
        XCTAssertTrue(try { () -> Bool in
            guard let arr = try Decoding("li1e6:secondl5:thirded6:fourthi4eee".data(using: .ascii)!).decode() as? [Any] else {
                return false
            }
            guard arr.count == 4 else {
                return false
            }
            guard arr[0] as? Int == 1 else {
                return false
            }
            guard arr[1] as? String == "second" else {
                return false
            }
            guard let a2 = arr[2] as? [String], a2 == ["third"] else {
                return false
            }
            guard let dict = arr[3] as? [String: Int], dict == ["fourth": 4] else {
                return false
            }
            return true
        }())
//        XCTAssertEqual(try Encoding().encode([1, "second", ["third"], ["fourth": 4]]), "li1e6:secondl5:thirded6:fourthi4eee".data(using: .ascii))
    }

    //MARK: - String
    func testStringEmpty() throws {
        XCTAssertEqual(try Decoding("0:".data(using: .ascii)!).decode() as? String, "")
    }

    func testStringActual() throws {
        XCTAssertEqual(try Decoding("1:4".data(using: .ascii)!).decode() as? String, "4")
        XCTAssertEqual(try Decoding("4:four".data(using: .ascii)!).decode() as? String, "four")
        XCTAssertEqual(try Decoding("20:a string with spaces".data(using: .ascii)!).decode() as? String, "a string with spaces")
    }
}
