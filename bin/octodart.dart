import 'package:commander_ui/commander_ui.dart';
import 'package:octodart/modules/config/data/config_repository.dart';
import 'package:octodart/modules/config/domain/config.dart';
import 'package:octodart/views/home/home.dart';

Future<void> main() async {
  // 1. Initialize Commander in main
  final commander = Commander(level: Level.verbose);
  final AppConfig config = await loadConfig();

  // Your application logic can now use these typed fields:
  // SomeGitHubClient client = SomeGitHubClient(token: config.github.authToken);
  // await client.fetchRepo(config.github.bricksUrl);
  await getUserSelection(commander, config);
}
