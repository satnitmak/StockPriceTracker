import Foundation

// MARK:  -  Price Message Codec  -

/// Converts PriceUpdate values to and from the JSON text sent over the socket.
public enum PriceMessageCodec {
    public static func encode(_ update: PriceUpdate) throws -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        return String(decoding: try encoder.encode(update), as: UTF8.self)
    }

    public static func decode(_ text: String) throws -> PriceUpdate {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return try decoder.decode(PriceUpdate.self, from: Data(text.utf8))
    }
}
