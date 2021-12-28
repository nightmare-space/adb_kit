import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:global_repository/global_repository.dart';

class LogoPage extends StatefulWidget {
  const LogoPage({Key key}) : super(key: key);

  @override
  _LogoPageState createState() => _LogoPageState();
}

class _LogoPageState extends State<LogoPage> {
  @override
  void initState() {
    super.initState();
  }

  final GlobalKey _globalKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // _globalKey为需要图像化的widget的key
          final RenderRepaintBoundary boundary = _globalKey.currentContext
              .findRenderObject() as RenderRepaintBoundary;
          // ui.Image => image.Image
          final dynamic img = await boundary.toImage();
          final ByteData byteData =
              await img.toByteData(format: ImageByteFormat.png) as ByteData;
          final Uint8List pngBytes = byteData.buffer.asUint8List();
          File(RuntimeEnvir.dataPath + '/ic_launcher.png')
              .writeAsBytes(pngBytes);
        },
      ),
      body: Center(
        child: NiCardButton(
          borderRadius: 32,
          child: SingleChildScrollView(
            child: RepaintBoundary(
              key: _globalKey,
              child: SizedBox(
                width: 1024,
                height: 1024,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Builder(
                    builder: (_) {
                      const double size = 1024 - 64.0;
                      const double padding = 16.0 * size / 160;
                      return Material(
                        borderRadius: BorderRadius.circular(32 * size / 160),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: padding,
                            horizontal: padding,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/icon/remote.svg',
                              ),
                              // Icon(
                              //   Icons.share,
                              //   // color: Color(0xff282b3e),
                              //   color: Colors.black,
                              //   size: size - 2 * padding,
                              // ),
                            ],
                          ),
                          // child: Icon(
                          //   Icons.adb_rounded,
                          //   size: 1024,
                          //   color: Color(0xff282b3e),
                          // ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
