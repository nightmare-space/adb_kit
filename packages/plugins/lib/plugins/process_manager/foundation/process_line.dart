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
