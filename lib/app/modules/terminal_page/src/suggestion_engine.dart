class SuggestionEngine {
  final _specs = <String, FigCommand>{};

  void load(Map<String, dynamic> specs) {
    for (var spec in specs.entries) {
      addSpec(spec.key, FigCommand.fromJson(spec.value));
    }
  }

  void addSpec(String name, FigCommand spec) {
    _specs[name] = spec;
  }

  Iterable<FigToken> getSuggestions(String command) {
    final args = command.split(' ').where((e) => e.isNotEmpty).toList();

    if (args.isEmpty) {
      return [];
    }

    final isComplete = command.endsWith(' ');
    return _getSuggestions(args, _specs, isComplete);
  }

  Iterable<FigToken> _getSuggestions(
    List<String> input,
    Map<String, FigCommand> searchList,
    bool isComplete,
  ) sync* {
    assert(input.isNotEmpty);

    // The subcommand scope we are currently in.
    FigCommand? currentCommand;

    // The last suggestion we recongnized. This is used to determine what to
    // suggest next. Valid values are:
    // - null: We are at the root of the command.
    // - currentCommand
    // - option of currentCommand
    FigToken? last;

    for (final part in input) {
      if (currentCommand == null) {
        currentCommand = searchList[part];
        if (currentCommand == null) {
          if (part.length >= 4) {
            yield* searchList.values.matchPrefix(input.last);
          }
          return;
        }
        last = currentCommand;
        continue;
      }

      final option = currentCommand.options.match(part);
      if (option != null) {
        last = option;
        continue;
      }

      final subCommand = currentCommand.subCommands.match(part);
      if (subCommand != null) {
        currentCommand = subCommand;
        last = currentCommand;
        continue;
      }

      last = null;
    }

    if (currentCommand == null) {
      return;
    }

    if (last is FigCommand) {
      if (isComplete) {
        yield* last.subCommands;
        yield* last.options;
      }
    } else if (last is FigOption) {
      if (isComplete) {
        yield* last.args;
        yield* currentCommand.options;
      } else {
        yield* last.args;
      }
    } else {
      yield* currentCommand.subCommands.matchPrefix(input.last);
      yield* currentCommand.options.matchPrefix(input.last);
      yield* currentCommand.args;
    }
  }
}

extension _FigSuggestionSearch<T extends FigSuggestion> on Iterable<T> {
  /// Finds the first suggestion that matches [name].
  T? match(String name) {
    for (final suggestion in this) {
      if (suggestion.names.contains(name)) {
        return suggestion;
      }
    }
    return null;
  }

  /// Finds all suggestions that start with [name].
  Iterable<T> matchPrefix(String name) sync* {
    for (final suggestion in this) {
      if (suggestion.names.any((e) => e.startsWith(name))) {
        yield suggestion;
      }
    }
  }
}

/// A token of a command.
sealed class FigToken {
  final String? description;

  const FigToken({this.description});
}

/// A token of a command that can be suggested.
sealed class FigSuggestion extends FigToken {
  final List<String> names;

  const FigSuggestion({
    required this.names,
    super.description,
  });
}

class FigCommand extends FigSuggestion {
  final List<FigCommand> subCommands;

  final bool requiresSubCommand;

  final List<FigOption> options;

  final List<FigArgument> args;

  FigCommand({
    required super.names,
    super.description,
    required this.subCommands,
    required this.requiresSubCommand,
    required this.options,
    required this.args,
  });

  factory FigCommand.fromJson(Map<String, dynamic> json) {
    return FigCommand(
      names: singleOrList<String>(json['name']),
      description: json['description'],
      subCommands: singleOrList(json['subcommands'])
          .map<FigCommand>((e) => FigCommand.fromJson(e))
          .toList(),
      requiresSubCommand: json['requiresSubCommand'] ?? false,
      options: singleOrList(json['options'])
          .map<FigOption>((e) => FigOption.fromJson(e))
          .toList(),
      args: singleOrList(json['args'])
          .map<FigArgument>((e) => FigArgument.fromJson(e))
          .toList(),
    );
  }

  @override
  String toString() {
    return 'FigSubCommand($names)';
  }
}

class FigOption extends FigSuggestion {
  final List<FigArgument> args;

  final bool isPersistent;

  final bool isRequired;

  final String? separator;

  final int? repeat;

  final List<String> exclusiveOn;

  final List<String> dependsOn;

  FigOption({
    required super.names,
    super.description,
    required this.args,
    required this.isPersistent,
    required this.isRequired,
    this.separator,
    this.repeat,
    required this.exclusiveOn,
    required this.dependsOn,
  });

  factory FigOption.fromJson(Map<String, dynamic> json) {
    return FigOption(
      names: singleOrList(json['name']).cast<String>(),
      description: json['description'],
      args: singleOrList(json['args'])
          .map<FigArgument>((e) => FigArgument.fromJson(e))
          .toList(),
      isPersistent: json['isPersistent'] ?? false,
      isRequired: json['isRequired'] ?? false,
      separator: json['separator'],
      // ignore: prefer-trailing-comma
      repeat: switch (json['isRepeatable']) {
        true => 0xFFFF,
        int count => count,
        _ => 0,
      },
      exclusiveOn: singleOrList<String>(json['exclusiveOn']),
      dependsOn: singleOrList<String>(json['dependsOn']),
    );
  }

  @override
  String toString() {
    return 'FigOption($names)';
  }
}

class FigArgument extends FigToken {
  final String? name;

  final bool isDangerous;

  final bool isOptional;

  final bool isCommand;

  final String? defaultValue;

  FigArgument({
    required this.name,
    super.description,
    required this.isDangerous,
    required this.isOptional,
    required this.isCommand,
    this.defaultValue,
  });

  factory FigArgument.fromJson(Map<String, dynamic> json) {
    return FigArgument(
      name: json['name'],
      description: json['description'],
      isDangerous: json['isDangerous'] ?? false,
      isOptional: json['isOptional'] ?? false,
      isCommand: json['isCommand'] ?? false,
      defaultValue: json['defaultValue'],
    );
  }

  @override
  String toString() {
    return 'FigArgument($name)';
  }
}

List<T> singleOrList<T>(item) {
  if (item == null) return <T>[];
  return item is List ? item.cast<T>() : <T>[item as T];
}
