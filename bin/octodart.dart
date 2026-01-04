import 'package:commander_ui/commander_ui.dart';
import 'package:masoneer/modules/config/data/config_repository.dart';
import 'package:masoneer/modules/config/domain/config.dart';
import 'package:masoneer/routing/custom_router.dart';
import 'package:masoneer/utils/console_clear.dart';
import 'package:masoneer/views/home/home.dart';

Future<void> main() async {
  // 1. Initialize Commander in main
  final commander = Commander(level: Level.verbose);
  final AppConfig config = await loadConfig();

  // Clear screen when TUI starts
  clearScreen();

  // Start the application with the Home Screen
  final app = TuiApp(HomeScreen(commander, config));
  await app.run();
}
