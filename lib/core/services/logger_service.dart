import 'package:logger/logger.dart';

class LoggerService {

  static final Logger logger =
      Logger(
    printer: PrettyPrinter(),
  );

  static void info(String message) {

    logger.i(message);
  }

  static void error(String message) {

    logger.e(message);
  }
  
  static void debug(
    String message,
  ) {
    logger.d(message);
  }
}