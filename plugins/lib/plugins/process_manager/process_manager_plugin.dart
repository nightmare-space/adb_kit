import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:adb_kit/app/controller/devices_controller.dart';
import 'package:adb_kit/core/interface/pluggable.dart';
import 'package:adb_kit/generated/l10n.dart';
import 'package:adb_kit/utils/dex_server.dart';
import 'package:adbutil/adbutil.dart';
import 'package:app_manager/app_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:global_repository/global_repository.dart';

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

// TODO 安卓14上挂了, 2024.10.22 测试又是好的
class ProcessPlugin extends ADBKITPlugin {
  @override
  Widget buildWidget(BuildContext context, DevicesEntity? device) {
    return ProcessManagerPage(devicesEntity: device);
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

// def PID,USER,PR,NI,VIRT,RES,SHR,S,%CPU,%MEM,TIME+,CMDLINE
class ProcessLine {
  ProcessLine({
    required this.pid,
    required this.user,
    required this.pr,
    required this.ni,
    required this.virt,
    required this.res,
    required this.shr,
    required this.s,
    required this.cpu,
    required this.mem,
    required this.time,
    required this.cmdline,
    required this.name,
  });

  final String pid;
  final String user;
  final String pr;
  final String ni;
  final String virt;
  final String res;
  final String shr;
  final String s;
  final String cpu;
  final String mem;
  final String time;
  final String cmdline;
  final String name;

  factory ProcessLine.fromLine(String line) {
    final list = line.split(RegExp(r'\s+'));
    return ProcessLine(
      pid: list[0],
      user: list[1],
      pr: list[2],
      ni: list[3],
      virt: list[4],
      res: list[5],
      shr: list[6],
      s: list[7],
      cpu: list[8],
      mem: list[9],
      time: list[10],
      cmdline: list[11],
      name: list[11],
    );
  }

  @override
  String toString() {
    return 'ProcessLine(pid: $pid, user: $user, pr: $pr, ni: $ni, virt: $virt, res: $res, shr: $shr, s: $s, cpu: $cpu, mem: $mem, time: $time, cmdline: $cmdline , name: $name)';
  }
}

class ProcessManagerPage extends StatefulWidget {
  const ProcessManagerPage({super.key, this.devicesEntity});
  final DevicesEntity? devicesEntity;

  @override
  State<ProcessManagerPage> createState() => _ProcessManagerPageState();
}

class _ProcessManagerPageState extends State<ProcessManagerPage> {
  bool breaking = false;
  List<ProcessLine> processLines = [];
  AppChannel? channel;

  Debouncer debouncer = Debouncer(delay: const Duration(milliseconds: 100));
  @override
  void initState() {
    super.initState();
    poll();
  }

  Process? process;
  Future<void> poll() async {
    await DexServer.startServer(widget.devicesEntity!.serial).then((value) {
      channel = value;
    });
    final result = await asyncExec('$adb -s ${widget.devicesEntity!.serial} shell ps -A -o pid,ppid,name,etime,rss -k -cpu');
    // Log.i('result -> $result');
    // final result2 = await execCmd('$adb -s ${widget.devicesEntity!.serial} shell top -m 100 -b -d 10');
    // Log.i('result -> $result2');
    process = await Process.start(
      adb,
      ['-s', widget.devicesEntity!.serial, 'shell', 'top', '-m', '500', '-b', '-d', '3', '-q', '-o', ' PID,USER,PR,NI,VIRT,RES,SHR,S,%CPU,%MEM,TIME+,CMDLINE,NAME,CMD'],
      environment: adbEnvir() as Map<String, String>?,
      includeParentEnvironment: true,
      runInShell: false,
    );
    // 30795 root         20   0    0    0    0 I  1.6   0.0   0:19.78 [kworker/u16:14-memlat_wq]
    // final result = await execCmd('$adb -s ${widget.devicesEntity!.serial} shell top -m100 -b -d10');
    // Log.i(result);
    DateTime? dateTime;
    String out = '';
    process?.stdout.transform(const Utf8Decoder()).listen((event) {
      // DateTime now = DateTime.now();
      // if (dateTime != null && now.difference(dateTime!).inSeconds > 2) {}
      // dateTime = now;
      out += event;
      debouncer.call(() {
        final lines = out.trim().split('\n');
        // Log.i(out);
        // File('/Users/nightmare/Desktop/nightmare-space/GitHub/adb_kit/top.txt').writeAsStringSync(out.trim());
        out = '';
        processLines.clear();
        for (String line in lines) {
          if (line.contains('PID')) {
            continue;
          }
          try {
            processLines.add(ProcessLine.fromLine(line.trim()));
          } catch (e) {}
        }
        setState(() {});
      });

      // Log.w(processLines);
    });
    Timer.periodic(Duration(), (timer) {});
    // while (!breaking) {
    //   final result =await execCmd('$adb -s ${widget.devicesEntity!.serial} shell ps -A -o pid,ppid,name,etime,rss,cpu --sort CPU');
    //   Log.i(result);
    //   await Future<void>.delayed(const Duration(seconds: 2));
    // }
  }

  @override
  void dispose() {
    super.dispose();
    breaking = true;
    process?.kill();
  }

  @override
  Widget build(BuildContext context) {
    List<double> widths = [120.w, 120.w, 60.w];
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        SizedBox(height: 8.w),
        Container(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 56.w),
                child: SizedBox(
                  width: widths[0],
                  child: Text(
                    'PID',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 14.w,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: widths[1],
                child: Text(
                  'RES',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 14.w,
                  ),
                ),
              ),
              SizedBox(
                width: widths[2],
                child: Text(
                  'CPU',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 14.w,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Scrollbar(
            interactive: true,
            thumbVisibility: true,
            trackVisibility: true,
            radius: Radius.circular(12.w),
            thickness: 10.w,
            child: ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                final ProcessLine processLine = processLines[index];
                return InkWell(
                  onTap: () {},
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.w, horizontal: 16.w),
                    child: Row(
                      children: [
                        Builder(builder: (_) {
                          if (channel != null && processLine.user.startsWith('u0')) {
                            return Image.network(
                              channel!.iconUrl(processLine.cmdline),
                              width: 40.w,
                              height: 40.w,
                              gaplessPlayback: true,
                              errorBuilder: (_, __, ___) {
                                return Image.asset(
                                  'packages/app_manager/assets/placeholder.png',
                                  gaplessPlayback: true,
                                  width: 40.w,
                                  height: 40.w,
                                );
                              },
                            );
                          }
                          return SvgPicture.asset('assets/linux.svg', width: 40.w, height: 40.w);
                        }),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(processLine.name, maxLines: 1),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: widths[0],
                                    child: Text('${processLine.pid}'),
                                  ),
                                  SizedBox(
                                    width: widths[1],
                                    child: Text('${processLine.res}'),
                                  ),
                                  SizedBox(
                                    width: widths[2],
                                    child: Text('${processLine.cpu}%'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              itemCount: processLines.length,
            ),
          ),
        ),
      ],
    );
  }
}

// Show process activity in real time.

// -H	Show threads
// -h	Usage graphs instead of text
// -k	Fallback sort FIELDS (default -S,-%CPU,-ETIME,-PID)
// -o	Show FIELDS (def PID,USER,PR,NI,VIRT,RES,SHR,S,%CPU,%MEM,TIME+,CMDLINE)
// -O	Add FIELDS (replacing PR,NI,VIRT,RES,SHR,S from default)
// -s	Sort by field number (1-X, default 9)
// -b	Batch mode (no tty)
// -d	Delay SECONDS between each cycle (default 3)
// -m	Maximum number of tasks to show
// -n	Exit after NUMBER iterations
// -p	Show these PIDs
// -u	Show these USERs
// -q	Quiet (no header lines)


// flutter: [I/] Command line field types
// flutter: [I/] 
// flutter: [I/]   ARGS    CMDLINE minus initial path     CMD     Thread name (/proc/TID/stat:2)
// flutter: [I/]   CMDLINE Command line (argv[])          COMM    EXE filename (/proc/PID/exe)
// flutter: [I/]   COMMAND EXE path (/proc/PID/exe)       NAME    Process name (PID's argv[0])
// flutter: [I/] 
// flutter: [I/] Process attribute field types
// flutter: [I/] 
// flutter: [I/]   S       Process state
// flutter: [I/] 	  R (running) S (sleeping) D (device I/O) T (stopped)  t (trace stop)
// flutter: [I/] 	  X (dead)    Z (zombie)   P (parked)     I (idle)
// flutter: [I/] 	  Also between Linux 2.6.33 and 3.13
// flutter: [I/] 	  x (dead)    K (wakekill) W (waking)
// flutter: [I/] 
// flutter: [I/]   SCH     Scheduling policy (0=other, 1=fifo, 2=rr, 3=batch, 4=iso, 5=idle)
// flutter: [I/]   STAT    Process state (S) plus
// flutter: [I/] 	  < high priority          N low priority L locked memory
// flutter: [I/] 	  s session leader         + foreground   l multithreaded
// flutter: [I/]   %CPU    Percentage of CPU time used    %MEM    RSS as % of physical memory
// flutter: [I/]   %VSZ    VSZ as % of physical memory    ADDR    Instruction pointer
// flutter: [I/]   BIT     32 or 64                       C       Total %CPU used since start
// flutter: [I/]   CPU     Which processor running on     DIO     Disk I/O
// flutter: [I/]   DREAD   Data read from disk            DWRITE  Data written to disk
// flutter: [I/]   ELAPSED Elapsed time since PID start   F       Flags 1=FORKNOEXEC 4=SUPERPRIV
// flutter: [I/]   GID     Group ID                       GROUP   Group name
// flutter: [I/]   IO      Data I/O                       LABEL   Security label
// flutter: [I/]   MAJFL   Major page faults              MINFL   Minor page faults
// flutter: [I/]   NI      Niceness (static 19 to -20)    PCY     Android scheduling policy
// flutter: [I/]   PGID    Process Group ID               PID     Process ID
// flutter: [I/]   PPID    Parent Process ID              PR      Prio Reversed (dyn 39-0, RT)
// flutter: [I/]   PRI     Priority (dynamic 0 to 139)    PSR     Processor last executed on
// flutter: [I/]   READ    Data read                      RES     Short RSS
// flutter: [I/]   RGID    Real (before sgid) Group ID    RGROUP  Real (before sgid) group name
// flutter: [I/]   RSS     Resident Set Size (DRAM pages) RTPRIO  Realtime priority
// flutter: [I/]   RUID    Real (before suid) user ID     RUSER   Real (before suid) user name
// flutter: [I/]   SHR     Shared memory                  STIME   Start time (ISO 8601)
// flutter: [I/]   SWAP    Swap I/O                       SZ      4k pages to swap out
// flutter: [I/]   TCNT    Thread count                   TID     Thread ID
// flutter: [I/]   TIME    CPU time consumed              TIME+   CPU time (high precision)
// flutter: [I/]   TTY     Controlling terminal           UID     User id
// flutter: [I/]   USER    User name                      VIRT    Virtual memory size
// flutter: [I/]   VSZ     Virtual memory size (1k units) WCHAN   Wait location in kernel
// flutter: [I/]   WRITE   Data written                   
// flutter: [I/] 
