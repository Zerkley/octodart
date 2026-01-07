import 'package:commander_ui/commander_ui.dart';
import 'package:masoneer/modules/config/domain/config.dart';
import 'package:masoneer/routing/custom_router.dart';
import 'package:masoneer/views/mason/mason.dart';

class RepoSelectorScreen extends TuiScreen {
  final Commander commander;
  final List<GitHubRepoConfig> repos;

  RepoSelectorScreen(this.commander, this.repos) : super('Select Repository');

  @override
  Future<ScreenAction> run() async {
    // Build options list with repo names + Back option
    final repoNames = repos.map((r) => r.name).toList();
    final options = [...repoNames, 'Back'];

    final value = await commander.select(
      'Select a repository',
      onDisplay: (value) => value,
      placeholder: 'Type to search',
      defaultValue: repoNames.isNotEmpty ? repoNames[0] : 'Back',
      options: options,
    );

    if (value == 'Back') {
      return ScreenAction.pop();
    }

    // Find the selected repo config
    final selectedRepo = repos.firstWhere(
      (r) => r.name == value,
      orElse: () => repos.first,
    );

    // Push the Mason screen with the selected repo
    return ScreenAction.push(MasonScreen(commander, selectedRepo));
  }
}
