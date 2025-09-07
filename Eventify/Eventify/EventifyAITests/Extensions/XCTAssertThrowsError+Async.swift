import XCTest

/// Extensión para testear errores async/await de forma más sencilla
extension XCTest {
    func XCTAssertThrowsError<T>(
        _ expression: @autoclosure () async throws -> T,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line,
        _ errorHandler: (_ error: Error) -> Void = { _ in }
    ) async {
        do {
            _ = try await expression()
            XCTFail("Expected expression to throw an error", file: file, line: line)
        } catch {
            errorHandler(error)
        }
    }
}