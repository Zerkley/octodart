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
    final masonRepo = MasonClientRepository();

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
        try {
          await showSpinnerWithProgress(
            initialMessage: 'Generating brick: $value...',
            operation: (updateMessage) => masonRepo.generateBrick(
              brickName: value,
              gitUrl: repoConfig.githubUrl,
              onProgress: updateMessage,
            ),
          );
          print('✅ Brick "$value" generated successfully!');
        } catch (e) {
          print('❌ Error generating brick: $e');
        }
        // After generation (success or failure), go back to previous screen
        return ScreenAction.pop();
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
