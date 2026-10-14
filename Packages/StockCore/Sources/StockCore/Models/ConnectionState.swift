// MARK:  -  Connection State  -

public enum ConnectionState: Equatable, Sendable {
    case disconnected
    case connecting
    case connected
}
