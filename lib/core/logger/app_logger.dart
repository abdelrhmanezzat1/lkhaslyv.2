import 'package:logger/logger.dart';

/// A global logger instance for the application.
///
/// Provides structured and colored logging for different levels (debug, info, warning, error).
final appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 1, // number of method calls to be displayed
    errorMethodCount: 8, // number of method calls if stacktrace is provided
    lineLength: 120, // width of the output
    colors: true, // Colorful log messages
  ),
);
