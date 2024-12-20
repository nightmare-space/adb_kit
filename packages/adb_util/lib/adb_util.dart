import '';
import 'package:signale/signale.dart';
export 'src/adb_foundation.dart';
export 'src/adb.dart';
export 'src/adb_command.dart';

String shortHash(Object? object) {
  return object.hashCode.toUnsigned(20).toRadixString(16).padLeft(5, '0');
}

Map<String, String> modelCache = {};
Map<String, String> deviceIDCache = {};
Future<String?> getDeviceID(
  String serial, {
  String? password,
}) async {
  if (deviceIDCache.containsKey(serial)) {
    return deviceIDCache[serial];
  }
  String nidPath = '/data/local/tmp/nid';
  String cmd = '$adb -s $serial shell cat $nidPath';
  String? id;
  try {
    id = await exec(cmd, password: password);
  } catch (e) {
    await writeKey(serial, password!);
    id = await exec(cmd, password: password);
  }
  // if (id.contains('No such file')) {
  // }
  deviceIDCache[serial] = id;
  return id;
}

Future<void> writeKey(String serial, String password) async {
  String nidPath = '/data/local/tmp/nid';
  String id = shortHash(() {}).toString();
  await exec('$adb -s $serial shell echo $id > $nidPath', password: password);
}

Future<String?> getDeviceProductModel(
  String serial, {
  String? password,
}) async {
  if (modelCache.containsKey(serial)) {
    // Log.i('get model from cache');
    return modelCache[serial]!;
  }
  String getPropPrefix = '$adb -s $serial shell getprop';
  String? model;
  // Some device like xiaomi can't get model name by `ro.product.marketname`
  try {
    model = await exec('$getPropPrefix ro.product.marketname', password: password);
    if (model.trim().isEmpty) {
      model = await exec('$getPropPrefix ro.product.model', password: password);
    }
    modelCache[serial] = model;
  } catch (e) {
    Log.e('get model error : $e');
  }
  return model;
}
