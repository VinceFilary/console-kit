/// Represents a top-level group of configured commands. This is usually created by calling `resolve(for:)` on `CommandConfig`.
public struct Commands: ExpressibleByDictionaryLiteral {
    /// Top-level available commands, stored by unique name.
    public let commands: [String: AnyCommand]

    /// If set, this is the default top-level command that should run if no other commands are specified.
    public let defaultCommand: AnyCommand?

    /// Creates a new `ConfiguredCommands` struct. This is usually done by calling `resolve(for:)` on `CommandConfig`.
    ///
    /// - parameters:
    ///     - commands: Top-level available commands, stored by unique name.
    ///     - defaultCommand: If set, this is the default top-level command that should run if no other commands are specified.
    public init(commands: [String: AnyCommand] = [:], defaultCommand: AnyCommand? = nil) {
        self.commands = commands
        self.defaultCommand = defaultCommand
    }

    /// See `ExpressibleByDictionaryLiteral`.
    public init(dictionaryLiteral elements: (String, AnyCommand)...) {
        var commands: [String: AnyCommand] = [:]
        for (key, val) in elements {
            commands[key] = val
        }
        self.init(commands: commands, defaultCommand: nil)
    }

    /// Creates a `CommandGroup` for this `Commands`.
    ///
    ///     var env = Environment.testing
    ///     let container: Container = ...
    ///     var config = CommandConfig()
    ///     config.use(CowsayCommand(), as: "cowsay")
    ///     let group = try config.resolve(for: container).group()
    ///     try console.run(group, input: &env.commandInput, on: container).wait()
    ///
    /// - parameters:
    ///     - help: Optional help messages to include.
    /// - returns: A `CommandGroup` with commands and defaultCommand configured.
    public func group(help: String = "") -> CommandGroup {
        return _Group(commands: self.commands, defaultCommand: self.defaultCommand, help: help)
    }
}

private struct _Group: CommandGroup {
    let commands: [String: AnyCommand]
    var defaultCommand: AnyCommand?
    let help: String
}
