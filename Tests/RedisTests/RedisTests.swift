import Async
import Dispatch
@testable import Redis
import TCP
import XCTest

class RedisTests: XCTestCase {
    func testCRUD() throws {
        let eventLoop = try DefaultEventLoop(label: "codes.vapor.redis.test.crud")
        let redis = try RedisClient.connect(on: eventLoop) { _, error in
            XCTFail("\(error)")
        }
        try redis.set("world", forKey: "hello").await(on: eventLoop)
        let get = try redis.get(String.self, forKey: "hello").await(on: eventLoop)
        XCTAssertEqual(get, "world")
        try redis.remove("hello").await(on: eventLoop)
    }
    
    func testPubSub() throws {
        // Setup
        let eventLoop = try DefaultEventLoop(label: "codes.vapor.redis.test.pubsub")
        let promise = Promise(RedisData.self)
        
        // Subscribe
        try RedisClient.subscribe(to: ["foo"], on: eventLoop) { _, error in
            XCTFail("\(error)")
            }.await(on: eventLoop).drain { data in
                XCTAssertEqual(data.channel, "foo")
                promise.complete(data.data)
            }.catch { error in
                XCTFail("\(error)")
            }.finally {
                // closed
        }
        
        // Publish
        let publisher = try RedisClient.connect(on: eventLoop) { _, error in
            XCTFail("\(error)")
        }
        let publish = try publisher.publish(.bulkString("it worked"), to: "foo").await(on: eventLoop)
        XCTAssertEqual(publish.int, 1)
        
        // Verify
        let data = try promise.future.await(on: eventLoop)
        XCTAssertEqual(data.string, "it worked")
    }
    
    func testStruct() throws {
        struct Hello: Codable {
            var message: String
            var array: [Int]
            var dict: [String: Bool]
        }
        let hello = Hello(message: "world", array: [1, 2, 3], dict: ["yes": true, "false": false])
        let eventLoop = try DefaultEventLoop(label: "codes.vapor.redis.test.struct")
        let redis = try RedisClient.connect(on: eventLoop) { _, error in
            XCTFail("\(error)")
        }
        try redis.set(hello, forKey: "hello").await(on: eventLoop)
        let get = try redis.get(Hello.self, forKey: "hello").await(on: eventLoop)
        XCTAssertEqual(get?.message, "world")
        XCTAssertEqual(get?.array.first, 1)
        XCTAssertEqual(get?.array.last, 3)
        XCTAssertEqual(get?.dict["yes"], true)
        XCTAssertEqual(get?.dict["false"], false)
        try redis.remove("hello").await(on: eventLoop)
        
    }
    
    func testStringCommands() throws {
        let eventLoop = try DefaultEventLoop(label: "codes.vapor.redis.test.struct")
        let redis = try RedisClient.connect(on: eventLoop) { _, error in
            XCTFail("\(error)")
        }
        
        let values = ["hello": RedisData(bulk: "world"), "hello2": RedisData(bulk: "world2")]
        try redis.mset(with: values).await(on: eventLoop)
        let resp = try redis.mget(["hello", "hello2"]).await(on: eventLoop)
        XCTAssertEqual(resp[0].string, "world")
        XCTAssertEqual(resp[1].string, "world2")
        _ = try redis.delete(["hello", "hello2"]).await(on: eventLoop)
        
        
        let number = try redis.increment("number").await(on: eventLoop)
        XCTAssertEqual(number, 1)
        let number2 = try redis.increment("number", by: 10).await(on: eventLoop)
        XCTAssertEqual(number2, 11)
        let number3 = try redis.decrement("number", by: 10).await(on: eventLoop)
        XCTAssertEqual(number3, 1)
        let number4 = try redis.decrement("number").await(on: eventLoop)
        XCTAssertEqual(number4, 0)
        _ = try redis.delete(["number"]).await(on: eventLoop)
        
        
    }
    
    static let allTests = [
        ("testCRUD", testCRUD),
        ("testPubSub", testPubSub),
        ("testStruct", testStruct),
        ("testStringCommands", testStringCommands),
        ]
}
