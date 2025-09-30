// lib/core/utils/app_logger.dart
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: (DateTime dateTime) =>
          '${dateTime.year.toString().padLeft(4, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}',
    ),
  );

  static void info(dynamic message) => _logger.i(message);
  static void warning(dynamic message) => _logger.w(message);
  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.e(message);
  static void debug(dynamic message) => _logger.d(message);
  static void verbose(dynamic message) => _logger.t(message);
}
