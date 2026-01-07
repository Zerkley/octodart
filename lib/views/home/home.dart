import 'package:commander_ui/commander_ui.dart';
import 'package:masoneer/modules/config/domain/config.dart';
import 'package:masoneer/routing/custom_router.dart';
import 'package:masoneer/views/mason/repo_selector.dart';

class HomeScreen extends TuiScreen {
  final Commander commander;
  final AppConfig config;

  HomeScreen(this.commander, this.config) : super('Main Menu');

  @override
  Future<ScreenAction> run() async {
    final value = await commander.select(
      'Select a menu',
      onDisplay: (value) => value,
      defaultValue: 'Mason',
      options: ['Mason', 'Exit'],
    );

    switch (value) {
      case 'Mason':
        // PUSH: Go to the Repo Selector screen
        return ScreenAction.push(RepoSelectorScreen(commander, config.repos));
      case 'Exit':
        // EXIT: Terminate the entire application
        return ScreenAction.exit();
      default:
        print('Invalid option selected.');
        // Stay on the current screen (run again)
        return ScreenAction.push(this);
    }
  }
}
