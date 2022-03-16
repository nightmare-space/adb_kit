import 'dart:convert';

T asT<T>(dynamic value) {
  if (value is T) {
    return value;
  }
  return null;
}

class Task {
  Task({
    this.taskName,
    this.taskId,
    this.package,
    this.activity,
    this.displayId,
    this.icon,
  });

  factory Task.fromJson(Map<String, dynamic> jsonRes) {
    if (jsonRes == null) {
      return null;
    }

    final List<int> icon = jsonRes['icon'] is List ? <int>[] : null;
    if (icon != null) {
      for (final dynamic item in jsonRes['icon']) {
        if (item != null) {
          icon.add(asT<int>(item));
        }
      }
    }
    return Task(
      taskName: asT<String>(jsonRes['taskName']),
      taskId: asT<String>(jsonRes['taskId']),
      package: asT<String>(jsonRes['package']),
      activity: asT<String>(jsonRes['activity']),
      displayId: asT<String>(jsonRes['displayId']),
      icon: icon,
    );
  }

  String taskName;
  String taskId;
  String package;
  String activity;
  String displayId;
  List<int> icon;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'taskName': taskName,
        'taskId': taskId,
        'package': package,
        'activity': activity,
        'displayId': displayId,
        'icon': icon,
      };

  Task clone() =>
      Task.fromJson(asT<Map<String, dynamic>>(jsonDecode(jsonEncode(this))));
}
