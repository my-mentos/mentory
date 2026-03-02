import Foundation

// MentoryiOS에서 연동된 애플워치로 메시지를 보내기 위해 사용 중  
public typealias WatchTodoHandler = @Sendable (String, Bool) -> Void

@MainActor
public protocol WatchConnectivityInterface: Sendable {
    func configureTodoHandler(_ handler: @escaping WatchTodoHandler)
    func setUp() async
    func updateContext(
        message: String?,
        character: String?,
        todos: [String],
        todoCompletions: [Bool]
    ) async
}
