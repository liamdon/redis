import RediStack
import NIO

@available(*, deprecated, renamed: "RESPValue")
public typealias RedisData = RESPValue

@available(*, deprecated, renamed: "RedisConfiguration")
public typealias RedisClientConfig = RedisConfiguration

@available(*, deprecated, renamed: "RESPValueConvertible")
public typealias RedisDataConvertible = RESPValueConvertible

extension RESPValueConvertible {
    @available(*, deprecated, message: "This has been made a failable initializer - init?(fromRESP:)")
    public static func convertFromRedisData(_ data: RESPValue) throws -> Self {
        guard let value = Self(fromRESP: data) else { throw RedisClientError.failedRESPConversion(to: Self.self) }
        return value
    }
    
    @available(*, deprecated, renamed: "convertedToRESPValue()")
    public func convertToRedisData() throws -> RESPValue {
        return self.convertedToRESPValue()
    }
}

extension RedisClient {
    @available(*, deprecated, message: "This method has been removed. Use send(command:arguments:) instead.")
    public func command(_ command: String, _ arguments: [RESPValue] = []) -> EventLoopFuture<RESPValue> {
        self.send(command: command, with: arguments)
    }
    
    @available(*, unavailable, message: "Use send(command:arguments:) instead.")
    public func send(_ message: RESPValue) -> EventLoopFuture<RESPValue> { preconditionFailure("Unavailable API") }
}

// MARK: Commands

extension RedisClient {
    @available(*, deprecated, renamed: "select(database:)")
    public func select(_ database: Int) -> EventLoopFuture<String> {
        return self.select(database: database)
            .map { return "OK" }
    }
    
    @available(*, deprecated, message: "Switch to using the TimeAmount version.")
    public func expire(_ key: String, after deadline: Int) -> EventLoopFuture<Int> {
        return self.expire(key, after: .seconds(.init(deadline)))
            .map { result in result ? 1 : 0 }
    }
    
    @available(*, deprecated, renamed: "get(_:asJSON:)")
    public func jsonGet<D>(_ key: String, as type: D.Type) -> EventLoopFuture<D?> where D: Decodable {
        return self.get(key, asJSON: D.self)
    }
    
    @available(*, deprecated, renamed: "set(_:asJSON:)")
    public func jsonSet<E>(_ key: String, to entity: E) -> EventLoopFuture<Void> where E: Encodable {
        return self.set(key, toJSON: entity)
    }
    
    @available(*, deprecated, renamed: "hkeys(in:)")
    public func hkeys(_ key: String) -> EventLoopFuture<[String]> {
        return self.hkeys(in: key)
    }
    
    // hmget
    // hmset
    // hgetall
    
    @available(*, deprecated, renamed: "hset(_:to:in:)")
    public func hset<E>(_ key: String, field: String, to data: E) -> EventLoopFuture<Int> where E: RESPValueConvertible {
        return self.hset(field, to: data, in: key)
            .map { result in result ? 1 : 0 }
    }
    // hset specialization
    
    @available(*, deprecated, renamed: "hdel(_:from:)")
    public func hdel(_ key: String, fields: String...) -> EventLoopFuture<Int> {
        return self.hdel(fields, from: key)
    }
    
    @available(*, deprecated, renamed: "hdel(_:from:)")
    public func hdel(_ key: String, fields: [String]) -> EventLoopFuture<Int> {
        return self.hdel(fields, from: key)
    }
    
    @available(*, deprecated, renamed: "hexists(_:in:)")
    public func hexists(_ key: String, field: String) -> EventLoopFuture<Bool> {
        return self.hexists(field, in: key)
    }
    
    @available(*, deprecated, renamed: "lrange(within:from:)")
    public func lrange(list: String, range: ClosedRange<Int>) -> EventLoopFuture<RESPValue> {
        return self.lrange(within: (range.lowerBound, range.upperBound), from: list)
            .map { return .array($0) }
    }
    
    @available(*, deprecated, renamed: "lindex(_:from:)")
    public func lIndex(list: String, index: Int) -> EventLoopFuture<RESPValue> {
        return self.lindex(index, from: list)
    }
    
    @available(*, deprecated, renamed: "llen(of:)")
    public func length(of list: String) -> EventLoopFuture<Int> {
        return self.llen(of: list)
    }
    
    @available(*, deprecated, renamed: "lset(index:to:in:)")
    public func lSet(_ item: RESPValue, at index: Int, in list: String) -> EventLoopFuture<Void> {
        return self.lset(index: index, to: item, in: list)
    }
    
    @available(*, deprecated, renamed: "rpop(from:)")
    public func rPop(_ list: String) -> EventLoopFuture<RESPValue> {
        return self.rpop(from: list)
    }
    
    @available(*, deprecated, renamed: "lpop(from:)")
    public func lpop(_ list: String) -> EventLoopFuture<RESPValue> {
        return self.lpop(from: list)
    }
    
    @available(*, deprecated, renamed: "lrem(_:from:count:)")
    public func lrem(_ list: String, count: Int, value: RESPValue) -> EventLoopFuture<Int> {
        return self.lrem(value, from: list, count: count)
    }
    
    @available(*, deprecated, renamed: "rpoplpush(from:to:)")
    public func rpoplpush(source: String, destination: String) -> EventLoopFuture<RESPValue> {
        return self.rpoplpush(from: source, to: destination)
    }
    
    @available(*, deprecated, renamed: "blpop(from:timeout:)")
    public func blpop(_ lists: [String], timeout: Int = 0) -> EventLoopFuture<(String, RESPValue)?> {
        return self.blpop(from: lists, timeout: timeout)
    }
    
    @available(*, deprecated, renamed: "brpop(from:timeout:)")
    public func brpop(_ lists: [String], timeout: Int = 0) -> EventLoopFuture<(String, RESPValue)?> {
        return self.brpop(from: lists, timeout: timeout)
    }
    
    @available(*, deprecated, renamed: "brpoplpush(from:to:timeout:)")
    public func brpoplpush(_ source: String, _ dest: String, timeout: Int = 0) -> EventLoopFuture<RESPValue> {
        return self.brpoplpush(from: source, to: dest, timeout: timeout)
            .map { $0 ?? .null }
    }
    
    @available(*, deprecated, renamed: "smembers(of:)")
    public func smembers(_ key: String) -> EventLoopFuture<RESPValue> {
        return self.smembers(of: key)
            .map { return .array($0) }
    }
    
    @available(*, deprecated, renamed: "sismember(_:of:)")
    public func sismember(_ key: String, item: RESPValue) -> EventLoopFuture<Bool> {
        return self.sismember(item, of: key)
    }
    
    @available(*, deprecated, renamed: "scard(of:)")
    public func scard(_ key: String) -> EventLoopFuture<Int> {
        return self.scard(of: key)
    }
    
    @available(*, deprecated, renamed: "sadd(_:to:)")
    public func sadd(_ key: String, items: [RESPValue]) -> EventLoopFuture<Int> {
        return self.sadd(items, to: key)
    }
    
    @available(*, deprecated, renamed: "srem(_:from:)")
    public func srem(_ key: String, items: [RESPValue]) -> EventLoopFuture<Int> {
        return self.srem(items, from: key)
    }
    
    @available(*, deprecated, renamed: "spop(from:)")
    public func spop(_ key: String) -> EventLoopFuture<RESPValue> {
        return self.spop(from: key)
            .map { return $0[0] }
    }
    
    @available(*, deprecated, renamed: "srandmember(from:max:)")
    public func srandmember(_ key: String, max count: Int = 1) -> EventLoopFuture<RESPValue> {
        return self.srandmember(from: key, max: count)
            .map { return .array($0) }
    }
    
    @available(*, deprecated, renamed: "zadd(_:to:option:returnChangedCount:)")
    public func zadd(_ key: String, items: [(String, RESPValue)], options: [String] = []) -> EventLoopFuture<Int> {
        let convertedItems = items.map { (item: (String, RESPValue)) -> (RESPValue, Double) in
            guard let double = Double(item.0) else { preconditionFailure("Invalid Double representation.") }
            return (item.1, double)
        }
        
        var returnChangedCount = false
        var option: RedisSortedSetAddOption? = nil
        for opt in options {
            switch opt.uppercased() {
            case "XX":
                if option != nil { preconditionFailure("XX and NX are mutually exclusive!") }
                else { option = .onlyUpdateExistingElements }
            case "NX":
                if option != nil { preconditionFailure("XX and NX are mutually exclusive!") }
                else { option = .onlyAddNewElements }
            case "CH":
                returnChangedCount = true
            default: break
            }
        }
        
        return self.zadd(convertedItems, to: key, option: option, returnChangedCount: returnChangedCount)
    }
    
    @available(*, deprecated, renamed: "zcount(of:within:)")
    public func zcount(_ key: String, min: String, max: String) -> EventLoopFuture<Int> {
        return self.zcount(of: key, within: (min, max))
    }
    
    @available(*, deprecated, renamed: "zrange(within:from:withScores:)")
    public func zrange(_ key: String, start: Int, stop: Int, withScores: Bool = false) -> EventLoopFuture<[RESPValue]> {
        return self.zrange(within: (start, stop), from: key, withScores: withScores)
    }
    
    @available(*, deprecated, renamed: "zrangebyscore(_:min:max:withScores:limit:)")
    public func zrangebyscore(_ key: String, min: String, max: String, withScores: Bool = false, limit: (Int, Int)? = nil) -> EventLoopFuture<[RESPValue]> {
        return self.zrangebyscore(within: (min, max), from: key, withScores: withScores, limitBy: limit)
    }
    
    @available(*, deprecated, renamed: "zrem(_:from:)")
    public func zrem(_ key: String, members: [RESPValue]) -> EventLoopFuture<Int> {
        return self.zrem(members, from: key)
    }
    
    @available(*, deprecated, renamed: "mset(_:)")
    public func mset(with values: [String: RESPValue]) -> EventLoopFuture<Void> {
        return self.mset(values)
    }
}
