import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:adb_kit/app/controller/devices_controller.dart';
import 'package:adb_kit/core/interface/pluggable.dart';
import 'package:adb_kit/generated/l10n.dart';
import 'package:adb_kit/utils/dex_server.dart';
import 'package:adb_kit/utils/utils.dart';
import 'package:app_manager/app_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:global_repository/global_repository.dart';
import 'package:android_api_server_client/android_api_server_client.dart';

import 'process_manager_page.dart';

// TODO 测试多个安卓版本兼容性
String testOut = '''
18852 shell        20   0 2.1G 5.0M 3.9M R 13.7   0.0   0:00.07 top -m 20 -b -d 10 -q
24347 root          0 -20    0    0    0 I  3.4   0.0   0:05.07 [kworker/u17:10-hal_register_write_wq]
16376 root         20   0    0    0    0 I  3.4   0.0   0:05.60 [kworker/u16:0-memlat_wq]
 9989 system       20   0 7.4G  74M  50M S  3.4   0.6   0:02.09 com.xiaomi.mi_connect_service
 5610 bluetooth    20   0 7.2G  67M  45M S  3.4   0.6   0:08.97 com.android.bluetooth
   36 root         20   0    0    0    0 R  3.4   0.0   0:03.15 [rcuop/2]
   14 root         20   0    0    0    0 S  3.4   0.0   0:18.77 [rcuog/0]
18796 root         20   0    0    0    0 I  0.0   0.0   0:00.00 [kworker/4:0]
18717 root         20   0    0    0    0 I  0.0   0.0   0:00.00 [kworker/2:0-events]
18501 root         20   0    0    0    0 I  0.0   0.0   0:00.00 [kworker/5:0-events]
18251 shell        20   0 5.1G 149M 111M S  0.0   1.3   0:00.35 app_process /data/local/tmp com.nightmare.applib.AppServer
18249 shell        20   0 2.0G 2.8M 2.3M S  0.0   0.0   0:00.00 sh -c CLASSPATH=/data/local/tmp/app_server app_process /data/local/tmp com.nightmare.applib.AppServer
18142 root         20   0    0    0    0 I  0.0   0.0   0:00.01 [kworker/7:0-mm_percpu_wq]
16368 root         20   0    0    0    0 I  0.0   0.0   0:00.00 [kworker/6:2]
15273 root         20   0    0    0    0 I  0.0   0.0   0:01.25 [kworker/0:0-events]
15260 root         20   0    0    0    0 I  0.0   0.0   0:00.13 [kworker/1:0-mm_percpu_wq]
15141 u0_a121      20   0 6.4G  97M  73M S  0.0   0.8   0:00.46 com.android.quicksearchbox:widgetProvider
14909 root         20   0    0    0    0 I  0.0   0.0   0:00.39 [kworker/u16:14-events_unbound]
13107 root          0 -20    0    0    0 I  0.0   0.0   0:01.83 [kworker/u17:3-qmi_msg_handler]
13008 root         20   0    0    0    0 I  0.0   0.0   0:00.23 [kworker/u16:13-events_unbound]
13007 root         20   0    0    0    0 I  0.0   0.0   0:01.06 [kworker/u16:12-ipa_pm_activate]
13006 root         20   0    0    0    0 I  0.0   0.0   0:00.38 [kworker/u16:10-events_unbound]
13005 root         20   0    0    0    0 I  0.0   0.0   0:00.35 [kworker/u16:7-ipa_interrupt_wq]
13004 root         20   0    0    0    0 I  0.0   0.0   0:00.25 [kworker/u16:6-events_unbound]
13003 root         20   0    0    0    0 I  0.0   0.0   0:01.78 [kworker/u16:5-memlat_wq]''';

class ProcessPlugin extends ADBKITPlugin {
  @override
  Widget buildWidget(BuildContext context, DevicesEntity? device) {
    return ProcessManagerPage(serial: device!.serial);
  }

  @override
  ImageProvider<Object> get iconImageProvider => throw UnimplementedError();

  @override
  String get name => S.current.processManager;

  @override
  void onTrigger() {}
  @override
  String get id => '$this';
}
