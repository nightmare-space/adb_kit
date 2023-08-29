import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:adb_kit/global/widget/xterm_wrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:xterm/xterm.dart';
import 'package:xterm/suggestion.dart';

import 'src/platform_menu.dart';
import 'src/suggestion_engine.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

final engine = SuggestionEngine();
bool isLoad = false;

// Future<Map<String, dynamic>> loadSuggestion() async {
//   final data = await rootBundle.load('assets/specs_v1.json.gz');
//   return await Stream.value(data.buffer.asUint8List()).cast<List<int>>().transform(gzip.decoder).transform(utf8.decoder).transform(json.decoder).first as Map<String, dynamic>;
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // engine.load(await loadSuggestion());
  // runApp(MyApp());
}

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'xterm.dart demo',
//       debugShowCheckedModeBanner: false,
//       home: AppPlatformMenu(child: Home()),
//     );
//   }
// }

class Home extends StatefulWidget {
  const Home({
    Key? key,
    required this.pty,
    required this.terminal,
  }) : super(key: key);
  final Pty pty;
  final Terminal terminal;

  @override
  // ignore: library_private_types_in_public_api
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // late final terminal = Terminal(
  //   maxLines: 10000,
  //   onPrivateOSC: _handlePrivateOSC,
  // );

  late Terminal terminal = widget.terminal..onPrivateOSC = _handlePrivateOSC;

  final terminalController = TerminalController();

  final terminalKey = GlobalKey<TerminalViewState>();

  final suggestionOverlay = SuggestionPortalController();

  late final Pty pty;

  @override
  void initState() {
    super.initState();
    terminal.addListener(_handleTerminalChanged);
    pty = widget.pty;

    WidgetsBinding.instance.endOfFrame.then(
      (_) {
        if (mounted) _startPty();
      },
    );
    loadSuggestions();
  }

  void loadSuggestions() async {
    if (isLoad) return;
    Stopwatch stopwatch = Stopwatch()..start();
    ByteData data = await rootBundle.load('assets/specs_v1.json.gz');
    Log.i('rootBundle.load time: ${stopwatch.elapsedMilliseconds}ms');
    Uint8List buffer = data.buffer.asUint8List();
    // 将buffer使用gzip解压
    List<int> decompressedBytes = await compute(GZipDecoder().decodeBytes, buffer);
    Log.i('GZipDecoder time: ${stopwatch.elapsedMilliseconds}ms');

    String jsonStr = await compute(utf8.decode, decompressedBytes);
    Log.i('utf8.decode time: ${stopwatch.elapsedMilliseconds}ms');

    final specs = await compute(json.decode, jsonStr);
    Log.i('json.decode: ${stopwatch.elapsedMilliseconds}ms');
    engine.load(specs);
    isLoad = true;
  }

  @override
  void dispose() {
    super.dispose();
    terminal.removeListener(_handleTerminalChanged);
  }

  void _startPty() {
    // pty = Pty.start(
    //   shell,
    //   columns: terminal.viewWidth,
    //   rows: terminal.viewHeight,
    // );

    // pty.output.cast<List<int>>().transform(Utf8Decoder()).listen(terminal.write);

    pty.exitCode.then((code) {
      terminal.write('the process exited with exit code $code');
    });

    terminal.onOutput = (data) {
      pty.write(const Utf8Encoder().convert(data));
    };

    terminal.onResize = (w, h, pw, ph) {
      pty.resize(h, w);
    };
  }

  /// Where the current shell prompt starts
  CellAnchor? _promptStart;

  /// Where the current user input starts
  CellAnchor? _commandStart;

  /// Where the current user input ends and the command starts to execute
  CellAnchor? _commandEnd;

  /// Where the command finishes
  CellAnchor? _commandFinished;

  void _handlePrivateOSC(String code, List<String> args) {
    switch (code) {
      case '133':
        _handleFinalTermOSC(args);
    }
  }

  void _handleFinalTermOSC(List<String> args) {
    switch (args) {
      case ['A']:
        _promptStart?.dispose();
        _promptStart = terminal.buffer.createAnchorFromCursor();
        _commandStart?.dispose();
        _commandStart = null;
        _commandEnd?.dispose();
        _commandEnd = null;
        _commandFinished?.dispose();
        _commandFinished = null;
        break;
      case ['B']:
        _commandStart?.dispose();
        _commandStart = terminal.buffer.createAnchorFromCursor();
        break;
      case ['C', ..._]:
        _commandEnd?.dispose();
        _commandEnd = terminal.buffer.createAnchorFromCursor();
        _handleCommandEnd();
        break;
      case ['D', String exitCode]:
        _commandFinished?.dispose();
        _commandFinished = terminal.buffer.createAnchorFromCursor();
        _handleCommandFinished(int.tryParse(exitCode));
        break;
    }
  }

  void _handleCommandEnd() {
    if (_commandStart == null || _commandEnd == null) return;
    final command = terminal.buffer.getText(BufferRangeLine(_commandStart!.offset, _commandEnd!.offset)).trim();
    print('command: $command');
  }

  void _handleCommandFinished(int? exitCode) {
    if (_commandEnd == null || _commandFinished == null) return;
    final result = terminal.buffer.getText(BufferRangeLine(_commandEnd!.offset, _commandFinished!.offset)).trim();
    print('result: $result');
    print('exitCode: $exitCode');
  }

  final suggestionView = SuggestionViewController();

  String? get commandBuffer {
    final commandStart = _commandStart;
    if (commandStart == null || _commandEnd != null) {
      return null;
    }

    var commandRange = BufferRangeLine(
      commandStart.offset,
      CellOffset(
        terminal.buffer.cursorX,
        terminal.buffer.absoluteCursorY,
      ),
    );
    return terminal.buffer.getText(commandRange).trimRightNewline();
  }

  void _handleTerminalChanged() {
    final command = commandBuffer;

    if (command == null || command.isEmpty) {
      suggestionOverlay.hide();
      return;
    }

    final suggestions = engine.getSuggestions(command).toList();
    suggestionView.update(suggestions);

    print('suggestions: $suggestions');

    if (suggestions.isNotEmpty) {
      suggestionOverlay.update(terminalKey.currentState!.globalCursorRect);
    } else {
      suggestionOverlay.hide();
    }
  }

  void _handleSuggestionSelected(FigToken suggestion) {
    final command = commandBuffer;
    if (command == null) {
      return;
    }

    final incompleteCommand = command.endsWith(' ') ? null : command.split(' ').last;

    switch (suggestion) {
      case FigCommand(:var names):
        if (incompleteCommand == null) {
          _emitSuggestion(names.first);
        } else {
          for (final name in names) {
            if (name.startsWith(incompleteCommand)) {
              _emitSuggestion(name.substring(incompleteCommand.length));
              break;
            }
          }
        }
      case FigOption(:var names):
        if (incompleteCommand == null) {
          _emitSuggestion(names.first);
        } else {
          for (final name in names) {
            if (name.startsWith(incompleteCommand)) {
              _emitSuggestion(name.substring(incompleteCommand.length));
              break;
            }
          }
        }
        break;
      default:
    }
  }

  void _emitSuggestion(String text) {
    pty.write(const Utf8Encoder().convert(text));
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SuggestionPortal(
        controller: suggestionOverlay,
        overlayBuilder: (context) {
          return SuggestionView(
            suggestionView,
            onSuggestionSelected: _handleSuggestionSelected,
          );
        },
        child: TerminalView(
          terminal,
          key: terminalKey,
          controller: terminalController,
          autofocus: true,
          backgroundOpacity: 0,
          keyboardType: TextInputType.multiline,
          onKey: (node, event) {
            if (event is! RawKeyDownEvent) {
              return KeyEventResult.ignored;
            }

            if (suggestionOverlay.isShowing) {
              switch (event.logicalKey) {
                case LogicalKeyboardKey.escape:
                  suggestionOverlay.hide();
                  return KeyEventResult.handled;
                case LogicalKeyboardKey.tab:
                  final suggestion = suggestionView.currentSuggestion;
                  if (suggestion != null) {
                    _handleSuggestionSelected(suggestion);
                    return KeyEventResult.handled;
                  }
                case LogicalKeyboardKey.arrowUp:
                  suggestionView.selectPrevious();
                  return KeyEventResult.handled;
                case LogicalKeyboardKey.arrowDown:
                  suggestionView.selectNext();
                  return KeyEventResult.handled;
                default:
              }
            }

            return KeyEventResult.ignored;
          },
          theme: (isDark ? TerminalThemes.whiteOnBlack : theme),
        ),
      ),
    );
  }
}

/// The state of the suggestion overlay.
class SuggestionViewController extends ChangeNotifier {
  final scrollController = ScrollController();

  List<FigToken> get suggestions => _suggestions;
  List<FigToken> _suggestions = [];

  var _selected = 0;
  set selected(int index) {
    _selected = max(0, min(index, suggestions.length - 1));
    notifyListeners();
  }

  double get itemExtent => _itemExtent;
  double _itemExtent = 20;
  set itemExtent(double value) {
    if (value == _itemExtent) return;
    _itemExtent = value;
    notifyListeners();
  }

  FigToken? get currentSuggestion {
    if (_suggestions.isEmpty) return null;
    return _suggestions[_selected];
  }

  void update(List<FigToken> suggestions) {
    _suggestions = suggestions;
    _selected = 0;
    notifyListeners();
  }

  void selectNext() {
    _selected = (_selected + 1) % _suggestions.length;
    ensureVisible(_selected);
    notifyListeners();
  }

  void selectPrevious() {
    _selected = (_selected - 1) % _suggestions.length;
    ensureVisible(_selected);
    notifyListeners();
  }

  void ensureVisible(int index) {
    if (!scrollController.hasClients) {
      return;
    }
    final position = scrollController.position;

    final targetOffset = itemExtent * index;
    final viewportBottomOffset = position.pixels + position.viewportDimension;

    if (targetOffset < position.pixels) {
      position.jumpTo(targetOffset);
    } else if (targetOffset + itemExtent > viewportBottomOffset) {
      position.jumpTo(
        max(0, targetOffset + itemExtent - position.viewportDimension),
      );
    }
  }
}

/// The suggestion popup shown above the terminal when user is typing a command.
class SuggestionView extends StatelessWidget {
  const SuggestionView(
    this.controller, {
    super.key,
    this.onSuggestionSelected,
  });

  final SuggestionViewController controller;

  final void Function(FigToken)? onSuggestionSelected;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return _build(context);
      },
    );
  }

  Widget _build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 300,
          maxHeight: 200,
        ),
        decoration: BoxDecoration(
          color: Colors.grey[800],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                controller: controller.scrollController,
                itemExtent: controller.itemExtent,
                itemCount: controller._suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = controller._suggestions[index];
                  return GestureDetector(
                    onTapDown: (_) => controller.selected = index,
                    onDoubleTapDown: (_) => onSuggestionSelected?.call(suggestion),
                    child: ClipRect(
                      child: SuggestionTile(
                        selected: index == controller._selected,
                        suggestion: suggestion,
                      ),
                    ),
                  );
                },
              ),
            ),
            if (controller.currentSuggestion != null) ...[
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey[700],
              ),
              SuggestionDescriptionView(controller.currentSuggestion!),
            ],
          ],
        ),
      ),
    );
  }
}

/// The area at the bottom of [SuggestionView] that shows the description of
/// the currently selected suggestion.
class SuggestionDescriptionView extends StatefulWidget {
  const SuggestionDescriptionView(
    this.suggestion, {
    super.key,
  });

  final FigToken suggestion;

  @override
  State<SuggestionDescriptionView> createState() => _SuggestionDescriptionViewState();
}

class _SuggestionDescriptionViewState extends State<SuggestionDescriptionView> {
  var isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        setState(() {
          isHovering = true;
        });
      },
      onExit: (event) {
        setState(() {
          isHovering = false;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(
          widget.suggestion.description ?? '',
          maxLines: isHovering ? null : 1,
          overflow: isHovering ? null : TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
      ),
    );
  }
}

/// An item in [SuggestionView].
class SuggestionTile extends StatelessWidget {
  const SuggestionTile({
    super.key,
    required this.selected,
    required this.suggestion,
  });

  final bool selected;

  final FigToken suggestion;

  static final primaryStyle = TerminalStyle().toTextStyle().copyWith(
        leadingDistribution: TextLeadingDistribution.even,
      );

  static final argumentStyle = TerminalStyle().toTextStyle().copyWith(
        leadingDistribution: TextLeadingDistribution.even,
        color: Colors.grey[500],
        fontSize: 12,
      );

  @override
  Widget build(BuildContext context) {
    final (icon, iconColor) = _getIcon(suggestion);
    final canSelect = suggestion is! FigArgument;

    return Container(
      color: selected ? Colors.blue[800] : Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 4),
          Icon(icon, size: 14, color: iconColor),
          SizedBox(width: 4),
          Expanded(
            child: RichText(
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              text: TextSpan(
                text: _getContent(suggestion) ?? '',
                children: [...buildArgs()],
                style: canSelect ? primaryStyle : primaryStyle.copyWith(fontStyle: FontStyle.italic),
              ),
            ),
          ),
          if (selected && canSelect) ...[
            Icon(Icons.keyboard_tab_rounded, size: 16, color: Colors.grey[400]),
            SizedBox(width: 4),
          ],
        ],
      ),
    );
  }

  Iterable<InlineSpan> buildArgs() sync* {
    final args = switch (suggestion) {
      FigCommand(:var args) => args,
      FigOption(:var args) => args,
      _ => <FigArgument>[],
    };

    const indent = ' ';

    for (final arg in args) {
      yield TextSpan(
        text: arg.isOptional ? '$indent[${arg.name}]' : '$indent<${arg.name}>',
        style: argumentStyle,
      );
    }
  }

  static (IconData, Color) _getIcon(FigToken suggestion) {
    return switch (suggestion) {
      FigCommand() => (Icons.subdirectory_arrow_right, Colors.blue),
      FigOption() => (Icons.settings, Colors.green),
      FigArgument() => (Icons.text_fields, Colors.yellow),
    };
  }

  static String? _getContent(FigToken suggestion) {
    return switch (suggestion) {
      FigCommand(:final names) => names.join(', '),
      FigOption(names: final name) => name.join(', '),
      FigArgument(:final name) => name,
    };
  }
}

String get shell {
  if (Platform.isMacOS || Platform.isLinux) {
    return Platform.environment['SHELL'] ?? 'bash';
  }

  if (Platform.isWindows) {
    return 'cmd.exe';
  }

  return 'sh';
}

extension on String {
  String trimRightNewline() {
    return endsWith('\n') ? substring(0, length - 1) : this;
  }
}
