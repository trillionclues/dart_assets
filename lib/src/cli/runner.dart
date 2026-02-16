import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

import 'commands/watch_command.dart';
import 'commands/gen_command.dart';
import 'commands/optimize_command.dart';
import 'commands/unused_command.dart';
import 'commands/clean_command.dart';
import 'commands/doctor_command.dart';
import 'commands/check_command.dart';

// Runs the dart_assets CLI with the given [arguments]
Future<void> run(List<String> arguments) async {
  final logger = Logger();

  final runner = CommandRunner<void>(
    'dart_assets',
    'Professional asset management for Flutter projects.',
  )
    ..addCommand(WatchCommand(logger: logger))
    ..addCommand(GenCommand(logger: logger))
    ..addCommand(OptimizeCommand(logger: logger))
    ..addCommand(UnusedCommand(logger: logger))
    ..addCommand(CleanCommand(logger: logger))
    ..addCommand(DoctorCommand(logger: logger))
    ..addCommand(CheckCommand(logger: logger));

  try {
    await runner.run(arguments);
  } on UsageException catch (e) {
    logger.err(e.message);
    logger.info(e.usage);
  } catch (e) {
    logger.err('$e');
  }
}
