/// A type-erased `Command`.
public protocol AnyCommand {
    /// Text that will be displayed when `--help` is passed.
    var help: String { get }
    
    /// Runs the command against the supplied input.
    func run(using context: inout CommandContext) throws
    func outputAutoComplete(using context: inout CommandContext) throws
    func outputHelp(using context: inout CommandContext) throws
}

extension AnyCommand {
    public func outputAutoComplete(using context: inout CommandContext) {
        // do nothing
    }

    public func outputHelp(using context: inout CommandContext) {
        // do nothing
    }
}
