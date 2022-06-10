import 'package:adb_tool/config/font.dart';
import 'package:adb_tool/utils/http/http.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:global_repository/global_repository.dart';

enum ConnectState {
  connecting,
  wait,
  success,
  failed,
}

class ConnectEntity {
  ConnectEntity(this.address);

  final String address;
  ConnectState state = ConnectState.wait;
}

class ParseQrcodePage extends StatefulWidget {
  const ParseQrcodePage({Key key, this.addressList}) : super(key: key);

  final List<String> addressList;

  @override
  _ParseQrcodePageState createState() => _ParseQrcodePageState();
}

class _ParseQrcodePageState extends State<ParseQrcodePage> {
  List<ConnectEntity> entitys = [];
  @override
  void initState() {
    super.initState();
    for (var element in widget.addressList) {
      entitys.add(ConnectEntity(element));
    }
    execPostMsg();
  }

  Future<void> execPostMsg() async {
    for (int i = 0; i < entitys.length; i++) {
      entitys[i].state = ConnectState.connecting;
      setState(() {});
      try {
        await httpInstance.post('http://${entitys[i].address}');
        entitys[i].state = ConnectState.success;
        setState(() {});
        Future.delayed(const Duration(milliseconds: 600), () {
          showToast('已经成功发送连接消息');
          Navigator.pop(context);
        });
        break;
      } on DioError catch (e) {
        entitys[i].state = ConnectState.failed;
        setState(() {});
        Log.e('e->$e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];
    for (var element in entitys) {
      children.add(
        SizedBox(
          height: Dimens.gap_dp48,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimens.gap_dp12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    element.address,
                    style:  TextStyle(
                      fontWeight: bold,
                    ),
                  ),
                  SizedBox(
                    width: Dimens.gap_dp8,
                  ),
                  SizedBox(
                    width: Dimens.setWidth(100),
                    child: Center(
                      child: Builder(
                        builder: (_) {
                          if (element.state == ConnectState.connecting) {
                            return SpinKitThreeBounce(
                              color: Theme.of(context).colorScheme.secondary,
                              size: Dimens.gap_dp12,
                            );
                          }
                          if (element.state == ConnectState.success) {
                            return Icon(
                              Icons.check,
                              color: Theme.of(context).colorScheme.secondary,
                            );
                          }
                          if (element.state == ConnectState.wait) {
                            return const Text('等待');
                          }
                          if (element.state == ConnectState.failed) {
                            return Text(
                              '连接失败',
                              style: TextStyle(
                                color: Theme.of(context).errorColor,
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return Center(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimens.gap_dp12),
        child: SizedBox(
          width: Dimens.setWidth(300),
          height: Dimens.gap_dp48 * children.length,
          child: Column(
            children: children,
          ),
        ),
      ),
    );
  }
}
