import Dispatch
import Foundation
import OSLog

/// Protocols that provide no-op default method implementations can use this protocol to log a message to the console
/// whenever an unimplemented delegate method is called.
///
/// In Swift, optional protocol methods exist only for Objective-C compatibility. However, various protocols in this
/// library follow a classic Objective-C delegate pattern in which the protocol would have a number of optional methods.
/// Instead of the disallowed `optional` keyword, these protocols conform to the ``UnimplementedLogging`` protocol to
/// inform about unimplemented methods at runtime. These console messages are logged to the subsystem `com.mapbox.com`
/// with a category of the format “delegation.<var>ProtocolName</var>”, where <var>ProtocolName</var> is the name of the
/// protocol that defines the method.
///
/// The default method implementations should be provided as part of the protocol or an extension thereof. If the
/// default implementations reside in an extension, the extension should have the same visibility level as the protocol
/// itself.
public protocol UnimplementedLogging {
    /// Prints a warning to standard output.
    /// - Parameters:
    ///   - protocolType: The type of the protocol to implement.
    ///   - level: The log level.
    ///   - function: The function name to be logged.
    func logUnimplemented(protocolType: Any, level: OSLogType, function: String)
}

extension UnimplementedLogging {
    public func logUnimplemented(protocolType: Any, level: OSLogType, function: String = #function) {
        let protocolDescription = String(describing: protocolType)
        let selfDescription = String(describing: type(of: self))

        let description = UnimplementedLoggingState.Description(typeDescription: selfDescription, function: function)

        guard _unimplementedLoggingState.markWarned(description) == .marked else {
            return
        }

        let logMethod: (String, NavigationLogCategory) -> Void = switch level {
        case .debug, .info:
            Log.info
        case .fault:
            Log.fault
        case .error:
            Log.error
        default:
            Log.warning
        }
        logMethod(
            "Unimplemented delegate method in \(selfDescription): \(protocolDescription).\(function). This message will only be logged once.",
            .unimplementedMethods
        )
    }
}

/// Contains a list of unimplemented log descriptions so that we won't log the same warnings twice.
/// Because this state is a global object and part of the public API it has synchronization primitive using a lock.
/// - Note: The type is safe to use from multiple threads.
final class UnimplementedLoggingState {
    struct Description: Equatable {
        let typeDescription: String
        let function: String
    }

    enum MarkingResult {
        case alreadyMarked
        case marked
    }

    private let lock: NSLock = .init()
    private var warned: [Description] = []

    func markWarned(_ description: Description) -> MarkingResult {
        lock.lock(); defer {
            lock.unlock()
        }
        guard !warned.contains(description) else {
            return .alreadyMarked
        }
        warned.append(description)
        return .marked
    }

    func clear() {
        lock.lock(); defer {
            lock.unlock()
        }
        warned.removeAll()
    }

    func countWarned(forTypeDescription typeDescription: String) -> Int {
        return warned
            .filter { $0.typeDescription == typeDescription }
            .count
    }
}

/// - Note: Exposed as internal to verify the behaviour in tests.
let _unimplementedLoggingState: UnimplementedLoggingState = .init()
