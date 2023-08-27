import 'package:flutter/foundation.dart';

class Logger {
  static bool _enabled = kDebugMode;

  /// 设置是否启用日志打印
  static void setLoggingEnabled(bool enabled) {
    _enabled = enabled;
  }

  static void _log(String level, Object? message) {
    if (_enabled) {
      final time = DateTime.now().toIso8601String();
      final location = _getLogLocation();
      debugPrint('[$time] $level $location: $message');
    }
  }

  /// 获取日志的来源位置，例如类名和方法名
  static String _getLogLocation() {
    final trace = StackTrace.current;
    final frames = trace.toString().split('\n');
    // 假设 Logger 方法是在堆栈的第三帧被调用的（通常是这样的）
    final frame = frames[2].trim();
    return frame.split(' ')[0];
  }

  static void debug(Object? message) => _log('DEBUG', message);
  static void info(Object? message) => _log('INFO', message);
  static void warn(Object? message) => _log('WARNING', message);
  static void error(Object? message) => _log('ERROR', message);
  static void fatal(Object? message) => _log('FATAL', message);
}
