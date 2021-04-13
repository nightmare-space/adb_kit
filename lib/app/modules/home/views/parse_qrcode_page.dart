import 'package:adb_tool/config/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ConnectEntity {
  ConnectEntity(this.address);

  final String address;
  bool success = false;
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
    execPostMsg();
  }

  void execPostMsg() {
    widget.addressList.forEach((element) {
      entitys.add(ConnectEntity(element));
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];
    entitys.forEach((element) {
      children.add(
        SizedBox(
          height: Dimens.gap_dp48,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimens.gap_dp24,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    element.address,
                  ),
                  SizedBox(
                    width: Dimens.gap_dp8,
                  ),
                  if (!element.success)
                    SpinKitThreeBounce(
                      color: Theme.of(context).accentColor,
                      size: Dimens.gap_dp12,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
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
