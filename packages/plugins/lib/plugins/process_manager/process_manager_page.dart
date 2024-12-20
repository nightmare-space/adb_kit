import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:plugins/plugins/process_manager/menu.dart';
import 'android_process_page.dart';
import 'foundation/process_line.dart';
import 'package:android_api_server_client/android_api_server_client.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:adb_util/adb_util_flutter.dart';
import 'package:global_repository/global_repository.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ProcessManagerPage extends StatefulWidget {
  const ProcessManagerPage({super.key, required this.serial});
  final String serial;

  @override
  State<ProcessManagerPage> createState() => _ProcessManagerPageState();
}

class _ProcessManagerPageState extends State<ProcessManagerPage> {
  bool breaking = false;
  List<ProcessLine> processLines = [];
  AASClient? aas;
  String filter = '';
  FocusNode focusNode = FocusNode();

  Debouncer debouncer = Debouncer(delay: const Duration(milliseconds: 100));
  @override
  void initState() {
    super.initState();
    poll();
  }

  Process? process;

  var index = 0;
  Future<void> poll() async {
    aas = await AndroidAPIServerStarter.startServer(widget.serial);
    String psCmd = 'ps -A -o pid,ppid,name,etime,rss -k -cpu';
    // final result = await execWSAA('adb -s ${widget!.serial} shell $cmd');
    String topCMD = 'top -m 500 -b -d 3 -q -o PID,USER,PR,NI,VIRT,RES,SHR,S,%CPU,%MEM,TIME+,CMDLINE,NAME,CMD';
    process = await Process.start(
      'adb',
      ['-s', widget.serial, 'shell', topCMD],
      environment: adbEnvir(),
      includeParentEnvironment: true,
      runInShell: false,
    );
    String out = '';
    process?.stdout.transform(const Utf8Decoder()).listen((event) {
      out += event;
      debouncer.call(() {
        final lines = out.trim().split('\n');
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
    });
  }

  @override
  void dispose() {
    super.dispose();
    breaking = true;
    process?.kill();
  }

  @override
  Widget build(BuildContext context) {
    if (aas == null) {
      return SpinKitPulse(
        color: Theme.of(context).colorScheme.primary,
      );
    }
    List<double> widths = [120.w, 120.w, 60.w];
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        SizedBox(height: 8.w),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    fillColor: colorScheme.surfaceContainer,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 8.w,
                    ),
                  ),
                  onChanged: (value) {
                    filter = value;
                    setState(() {});
                  },
                ),
              ),
              SizedBox(width: 8.w),
              Builder(builder: (context) {
                return IconButton(
                  onPressed: () {
                    RenderBox renderBox = context.findRenderObject() as RenderBox;
                    Offset offset = renderBox.localToGlobal(Offset.zero);
                    offset += Offset(renderBox.size.width, 0);
                    focusNode.unfocus();
                    Get.dialog(
                      Menu(offset: offset),
                      barrierColor: Colors.transparent,
                      useSafeArea: false,
                    );
                  },
                  icon: const Icon(Icons.more_vert),
                );
              }),
            ],
          ),
        ),
        SizedBox(height: 8.w),
        [
          Expanded(
            child: Column(
              children: [
                buildHeader(widths),
                buildProcessList(widths),
              ],
            ),
          ),
          AndroidProcessPage(
            aas: aas!,
          ),
        ][index]
      ],
    );
  }

  String getProcessName(ProcessLine processLine) {
    if (processLine.name.contains('[')) {
      return processLine.name;
    }
    return processLine.name.replaceAll(RegExp('.*/'), '');
  }

  bool canLoadAppIcon(ProcessLine processLine) {
    if (processLine.name.contains('/')) {
      return false;
    }
    return processLine.user.startsWith('u0') || processLine.cmdline.contains('.');
  }

  Expanded buildProcessList(List<double> widths) {
    if (filter.isNotEmpty) {
      processLines = processLines.where((element) => element.name.contains(filter)).toList();
    }
    return Expanded(
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
              onTap: () {
                showToast('暂不支持更多信息查看');
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.w, horizontal: 10.w),
                    child: Row(
                      children: [
                        Builder(builder: (_) {
                          // Log.i('processLine -> $processLine');
                          if (canLoadAppIcon(processLine)) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8.w),
                              child: Image.network(
                                aas!.iconUrl(processLine.cmdline),
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
                              ),
                            );
                          }
                          return SvgPicture.asset('assets/linux.svg', width: 40.w, height: 40.w);
                        }),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(getProcessName(processLine), maxLines: 1),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: widths[0],
                                    child: Text(processLine.pid),
                                  ),
                                  SizedBox(
                                    width: widths[1],
                                    child: Text(processLine.res),
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
                  if (canLoadAppIcon(processLine))
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () {
                          // execWSA('adb -s ${widget.serial} shell kill -9 ${processLine.pid}');
                          aas?.stopActivity(package: processLine.cmdline);
                          showToast('执行成功');
                        },
                        icon: const Icon(Icons.clear),
                      ),
                    ),
                ],
              ),
            );
          },
          itemCount: processLines.length,
        ),
      ),
    );
  }

  Container buildHeader(List<double> widths) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.primary.withOpacity(0.1),
      margin: EdgeInsets.symmetric(horizontal: 10.w),
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
    );
  }
}

// Toybox 0.8.11-android multicall binary (see toybox --help)

// usage: top [-Hhbq] [-k FIELD,] [-o FIELD,] [-s SORT] [-n NUMBER] [-m LINES] [-d SECONDS] [-p PID,] [-u USER,]

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

// Cursor UP/DOWN or LEFT/RIGHT to move list, SHIFT LEFT/RIGHT to change sort,
// space to force update, R to reverse sort, Q to exit.


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
