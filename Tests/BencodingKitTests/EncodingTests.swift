import XCTest
@testable import BencodingKit

final class BencodingKitEncodingTests: XCTestCase {
    //MARK: - Integer
    func testInteger0() throws {
        XCTAssertEqual(try Encoding().encode(0), "i0e".data(using: .ascii))
    }

    func testIntegerPositive() throws {
        XCTAssertEqual(try Encoding().encode(15), "i15e".data(using: .ascii))
        XCTAssertEqual(try Encoding().encode(1), "i1e".data(using: .ascii))
        XCTAssertEqual(try Encoding().encode(17203), "i17203e".data(using: .ascii))
        XCTAssertEqual(try Encoding().encode(6), "i6e".data(using: .ascii))
        XCTAssertEqual(try Encoding().encode(111111111), "i111111111e".data(using: .ascii))
    }

    func testIntegerNegative() throws {
        XCTAssertEqual(try Encoding().encode(-1), "i-1e".data(using: .ascii))
        XCTAssertEqual(try Encoding().encode(-7), "i-7e".data(using: .ascii))
        XCTAssertEqual(try Encoding().encode(-111111111), "i-111111111e".data(using: .ascii))
        XCTAssertEqual(try Encoding().encode(-567), "i-567e".data(using: .ascii))
    }

    //MARK: - Dictionary
    func testDictionaryEmpty() throws {
        XCTAssertEqual(try Encoding().encode([:]), "de".data(using: .ascii))
    }

    func testDictionarySingleItem() throws {
        XCTAssertEqual(try Encoding().encode(["hello": "world"]), "d5:hello5:worlde".data(using: .ascii))
        XCTAssertEqual(try Encoding().encode(["answer": 42]), "d6:answeri42ee".data(using: .ascii))
    }

    func testDictionaryNotStringKey() throws {
        XCTAssertThrowsError(try Encoding().encode([5: 6]), "Dictionaries must have string keys") { error in
            XCTAssertTrue({ () -> Bool in
                if case Encoding.Error.illegallyKeyedDictionary = error {
                    return true
                }
                return false
            }())
        }
    }

    func testDictionaryHomogeneous() throws {
        XCTAssertEqual(try Encoding().encode(["5": 5, "8": 8, "6789": 6789]), "d1:5i5e4:6789i6789e1:8i8ee".data(using: .ascii))
        XCTAssertEqual(try Encoding().encode(["dict": "ionary", "arr": "ay", "int": "eger", "str": "ing"]), "d3:arr2:ay4:dict6:ionary3:int4:eger3:str3:inge".data(using: .ascii))
    }

    func testDictionaryHetergeneous() throws {
        XCTAssertEqual(try Encoding().encode(["string": "string", "integer": 13, "array": [5,6,7,8], "dictionary": ["1": 1]] as [String: Any]), "d5:arrayli5ei6ei7ei8ee10:dictionaryd1:1i1ee7:integeri13e6:string6:stringe".data(using: .ascii))
    }

    //MARK: - Array
    func testArrayEmpty() throws {
        XCTAssertEqual(try Encoding().encode([]), "le".data(using: .ascii))
    }

    func testArraySingleItem() throws {
        XCTAssertEqual(try Encoding().encode(["item"]), "l4:iteme".data(using: .ascii))
        XCTAssertEqual(try Encoding().encode([42]), "li42ee".data(using: .ascii))
    }

    func testArrayHomogeneous() throws {
        XCTAssertEqual(try Encoding().encode(["one", "two", "three", "four"]), "l3:one3:two5:three4:foure".data(using: .ascii))
        XCTAssertEqual(try Encoding().encode([1,2,3,4]), "li1ei2ei3ei4ee".data(using: .ascii))
    }

    func testArrayHeterogeneous() throws {
        XCTAssertEqual(try Encoding().encode([1, "second", ["third"], ["fourth": 4]]), "li1e6:secondl5:thirded6:fourthi4eee".data(using: .ascii))
    }

    //MARK: - String
    func testStringEmpty() throws {
        XCTAssertEqual(try Encoding().encode(""), "0:".data(using: .ascii))
    }

    func testStringActual() throws {
        XCTAssertEqual(try Encoding().encode("4"), "1:4".data(using: .ascii))
        XCTAssertEqual(try Encoding().encode("four"), "4:four".data(using: .ascii))
        XCTAssertEqual(try Encoding().encode("a string with spaces"), "20:a string with spaces".data(using: .ascii))
    }
}
