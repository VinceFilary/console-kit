/// A group of named commands that can be run through a `Console`.
///
/// Usually you will use `CommandConfig` to register commands and create a group.
///
///     var env = Environment.testing
///     let container: Container = ...
///     var config = CommandConfig()
///     config.use(CowsayCommand(), as: "cowsay")
///     let group = try config.resolve(for: container).group()
///     try console.run(group, input: &env.commandInput, on: container).wait()
///
/// You can create your own `CommandGroup` if you want to support custom `CommandOptions`.
public protocol CommandGroup: AnyCommand {
    var commands: [String: AnyCommand] { get }
    var defaultCommand: AnyCommand? { get }
}

extension CommandGroup {
    public var defaultCommand: AnyCommand? {
        return nil
    }
}

extension CommandGroup {
    public func run(using context: inout CommandContext) throws {
        if let command = try self.commmand(using: &context) {
            try command.run(using: &context)
        } else if let `default` = self.defaultCommand {
            return try `default`.run(using: &context)
        } else {
            try self.outputHelp(using: &context)
            throw CommandError(identifier: "noCommand", reason: "Missing command")
        }
    }

    public func outputAutoComplete(using context: inout CommandContext) {
        var autocomplete: [String] = []
        autocomplete += self.commands.map { $0.key }
        context.console.output(autocomplete.joined(separator: " "), style: .plain)
    }

    public func outputHelp(using context: inout CommandContext) throws {
        if let command = try self.commmand(using: &context) {
            try command.outputHelp(using: &context)
        } else {
            self.outputGroupHelp(using: &context)
        }
    }

    private func outputGroupHelp(using context: inout CommandContext) {
        context.console.output("Usage: ".consoleText(.info) + context.input.executable.consoleText() + " ", newLine: false)
        context.console.output("<command> ".consoleText(.warning), newLine: false)
        context.console.print()

        if !self.help.isEmpty {
            context.console.print()
            context.console.print(self.help)
        }

        let padding = self.commands.map { $0.key }.longestCount + 2
        if self.commands.count > 0 {
            context.console.print()
            context.console.output("Commands:".consoleText(.success))
            for (key, command) in self.commands {
                context.console.outputHelpListItem(
                    name: key,
                    help: command.help,
                    style: .warning,
                    padding: padding
                )
            }
        }

        context.console.print()
        context.console.print("Use `\(context.input.executable) ", newLine: false)
        context.console.output("<command>".consoleText(.warning), newLine: false)
        context.console.output(" [--help,-h]".consoleText(.success) + "` for more information on a command.")
    }

    private func commmand(using context: inout CommandContext) throws -> AnyCommand? {
        if let name = context.input.arguments.popFirst() {
            guard let command = self.commands[name] else {
                throw CommandError(
                    identifier: "unknownCommand",
                    reason: "Unknown command `\(name)`"
                )
            }
            // executable should include all subcommands
            // to get to the desired command
            context.input.executablePath.append(name)
            return command
        } else {
            return nil
        }
    }
}
