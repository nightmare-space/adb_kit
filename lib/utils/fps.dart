import 'dart:collection';
import 'dart:ui';

import 'package:flutter/scheduler.dart';

typedef FpsCallback = void Function(double fps, double dropCount);

///
/// fps 获取
/// 官方推荐的方式 SchedulerBinding.instance.addTimingsCallback
/// 注意不能和window.onReportTimings一起用，会冲突
/// 其帧率计算方式为 FPS=实际绘制帧数*fpsHz(一般是60hz,也有90，120的)/(实际绘制帧数+丢帧数)
/// 参考文章 https://yrom.net/blog/2019/08/01/how-to-get-fps-in-flutter-app-codes/
class Fps {
  /// 单例
  static Fps? get instance {
    _instance ??= Fps._();
    return _instance;
  }

  static Fps? _instance;

  static const _maxFrames = 120; // 最大保存帧数据，100 帧足够了，对于 60 fps 来说
  final lastFrames =
      ListQueue<FrameTiming>(_maxFrames); //保存帧数据的队列，约定队头为最后一帧，队尾为开始一帧
  TimingsCallback? _timingsCallback;
  List<FpsCallback> _callBackList = [];

  Fps._() {
    _timingsCallback = (List<FrameTiming> timings) {
      //异步计算fps
      _computeFps(timings);
    };
    SchedulerBinding.instance.addTimingsCallback(_timingsCallback!);
  }

  registerCallBack(FpsCallback back) {
    _callBackList?.add(back);
  }

  unregisterCallBack(FpsCallback back) {
    _callBackList?.remove(back);
  }

  cancel() {
    if (_timingsCallback == null) {
      return;
    }
    SchedulerBinding.instance.removeTimingsCallback(_timingsCallback!);
  }

  /// 一般手机为60帧
  double _fpsHz = 90;

  /// 60帧，那就是16.67ms*1000 微秒
  Duration? _frameInterval;

  /// 计算fps
  Future<void> _computeFps(List<FrameTiming> timings) async {
    // 假设到达的帧数为1 2 3 4
    // 那在lastFrames里就是 4 3 2 1，队尾帧在队头
    for (FrameTiming timing in timings) {
      lastFrames.addFirst(timing);
    }

    // 只保留 maxFrames，超出则移除最早的帧
    while (lastFrames.length > _maxFrames) {
      lastFrames.removeLast();
    }

    var lastFramesSet = <FrameTiming>[];

    // 获取当前手机的fps
    _fpsHz ??= 90;

    //每帧消耗的时间，单位微秒
    _frameInterval ??=
        Duration(microseconds: Duration.microsecondsPerSecond ~/ _fpsHz);

    for (FrameTiming timing in lastFrames) {
      //lastFrames 队头是最后的帧，所以第一次取出来的是队尾帧
      if (lastFramesSet.isEmpty) {
        lastFramesSet.add(timing);
      } else {
        // 帧排序如下
        // frame4 frame3 frame2 frame1
        var lastStart = //frame4的build开始，即frame3的rasterFinish，但中间是会有间隔的
            lastFramesSet.last.timestampInMicroseconds(FramePhase.buildStart);
        // 上面提到的间隔时间
        var interval =
            lastStart - timing.timestampInMicroseconds(FramePhase.rasterFinish);
        //相邻两帧如果开始结束相差时间过大，比如大于 frameInterval * 2，认为是不同绘制时间段产生的
        if (interval > (_frameInterval!.inMicroseconds * 2)) {
          break; //注意这里是break，这次循环结束了，虽然在同一个队列里，但有可能相邻的两帧不在一个时间段，所以不能放一起计算，有个开源的就是没处理这里
        }
        lastFramesSet.add(timing);
      }
    }

    var drawFramesCount = lastFramesSet.length;

    //公式，假设当前手机的FPS = 60帧，1秒渲染了60次
    // FPS / 60 = drawCount / (drawFramesCount + droppedCount)
    // costCount = (drawFramesCount + droppedCount)
    // FPS ≈  60 * drawFramesCount / costCount
    int? droppedCount = 0; //丢帧数

    // 计算总的帧数
    var costCount = lastFramesSet.map((frame) {
      // 耗时超过 frameInterval 认为是丢帧，以60hz为例
      // 15ms ~/ 16ms = 0
      // 16ms ~/ 16ms = 0
      // 17ms ~/ 16ms = 1
      // 所以只要droppedCount大于0 ，认为当前帧是丢帧的
      int droppedCount =
          (frame.totalSpan.inMicroseconds ~/ _frameInterval!.inMicroseconds);
      return droppedCount +
          1; //自己本身绘制的一帧，这里加一是因为认为丢帧了，加1变成2或3，主要看实际消耗的时长，如果是正常帧，那就是0+1=1
    }) //这里返回的其实是个list<int>
        .fold(
            0, //计算的初始值
            (dynamic a, b) =>
                a + b); //计算总的帧数，fold就是list[0]+list[1]+....list[list.len-1]

    //丢帧数=总帧数-绘制帧数
    droppedCount = costCount - drawFramesCount;
    double fps = drawFramesCount * _fpsHz / costCount; //参考上面那四行公式
//    DebugLog.instance.log(
//        "computerFps _fpsHz is $_fpsHz drawFrame is $fps,dropFrameCount is $droppedCount");
    lastFrames.clear();
    _callBackList?.forEach((callBack) {
      callBack(fps, droppedCount!.toDouble());
    });
  }
}
