import 'package:commander_ui/commander_ui.dart';
import 'package:masoneer/modules/config/domain/config.dart';
import 'package:masoneer/modules/github/github_repository.dart';
import 'package:masoneer/modules/mason/data/mason_repository.dart';
import 'package:masoneer/routing/custom_router.dart';
import 'package:masoneer/utils/spinner.dart';

class MasonScreen extends TuiScreen {
  final Commander commander;
  final GitHubRepoConfig repoConfig;

  MasonScreen(this.commander, this.repoConfig) : super('Mason');

  @override
  Future<ScreenAction> run() async {
    final gitRepo = GithubClientRepository();

    final bricksList = await showSpinner(
      message: 'Loading bricks from ${repoConfig.name}...',
      operation: () => gitRepo.listRepoContents(
        repoConfig.githubUrl,
        token: repoConfig.authToken,
      ),
    );

    if (bricksList.isNotEmpty) {
      final options = [...bricksList, 'Back'];

      final value = await commander.select(
        'Select a brick',
        onDisplay: (value) => value,
        placeholder: 'Type to search',
        defaultValue: bricksList[0],
        options: options,
      );

      if (value == 'Back') {
        // POP: Go back to the previous screen
        return ScreenAction.pop();
      } else {
        // Exit TUI completely to free stdout for interactive prompts
        // Run generateBrick after exiting the TUI context
        final brickName = value;
        final gitUrl = repoConfig.githubUrl;
        return ScreenAction.exit(() async {
          // Run generateBrick outside TUI context - stdout is now free
          final masonRepo = MasonClientRepository();
          try {
            await masonRepo.generateBrick(brickName: brickName, gitUrl: gitUrl);
            print('✅ Brick "$brickName" generated successfully!');
          } catch (e) {
            print('❌ Error generating brick: $e');
          }
        });
      }
    } else {
      print('No bricks found in ${repoConfig.name}.');
      // Show a menu with just Back option if no bricks found
      final value = await commander.select(
        'No bricks available',
        onDisplay: (value) => value,
        options: ['Back'],
      );

      if (value == 'Back') {
        return ScreenAction.pop();
      }
      return ScreenAction.pop();
    }
  }
}
