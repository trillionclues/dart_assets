import 'package:mason_logger/mason_logger.dart';

class AppLogger {
  final Logger _logger;

  AppLogger({Logger? logger}) : _logger = logger ?? Logger();

  void info(String message) => _logger.info(message);
  void warn(String message) => _logger.warn(message);
  void err(String message) => _logger.err(message);
  void detail(String message) => _logger.detail(message);
  void success(String message) => _logger.success(message);

  Progress progress(String message) => _logger.progress(message);
}
