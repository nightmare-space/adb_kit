import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_repository/global_repository.dart';
import 'package:termare_view/termare_view.dart';

class OtgTerminal extends StatefulWidget {
  const OtgTerminal({Key key}) : super(key: key);

  @override
  _OtgTerminalState createState() => _OtgTerminalState();
}

class _OtgTerminalState extends State<OtgTerminal> {
  MethodChannel channel = const MethodChannel('scrcpy');
  final TermareController _controller = TermareController();
  @override
  void initState() {
    super.initState();
    channel.setMethodCallHandler((call) async {
      if (call.method == 'output') {
        Log.w('output -> ${call.arguments}');
        _controller.write(call.arguments.toString());
      }
    });
  }
  Future<void> loop() async {
    while (mounted) {
      Log.w('等待');
      final String data = await channel.invokeMethod('read');
      Log.w('data -> $data');
      _controller.write(data);
      await Future.delayed(const Duration(milliseconds: 600));
    }
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: TermareView(
        keyboardInput: (String data) {
          channel.invokeMethod('write', data);
        },
        controller: _controller,
      ),
    );
  }
}
