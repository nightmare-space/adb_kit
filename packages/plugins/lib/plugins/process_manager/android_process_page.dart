import 'package:flutter/material.dart';
import 'package:android_api_server_client/android_api_server_client.dart';
import 'package:signale/signale.dart';

class AndroidProcessPage extends StatefulWidget {
  const AndroidProcessPage({super.key, required this.aas});
  final AASClient aas;

  @override
  State<AndroidProcessPage> createState() => _AndroidProcessPageState();
}

class _AndroidProcessPageState extends State<AndroidProcessPage> {
  late AASClient aas = widget.aas;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    AndroidProcesses androidProcesses = await aas.api.getAndroidProcess(key: 'aas');
    Log.i('androidProcesses: $androidProcesses');
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
