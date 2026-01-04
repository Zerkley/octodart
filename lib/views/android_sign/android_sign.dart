import 'package:commander_ui/commander_ui.dart';
import 'package:masoneer/modules/config/domain/config.dart';
import 'package:masoneer/routing/custom_router.dart';

class AndroidSignScreen extends TuiScreen {
  final Commander commander;
  final AppConfig config;

  AndroidSignScreen(this.commander, this.config) : super('Android sign');

  @override
  Future<ScreenAction> run() async {
    // TODO: Implement Android sign functionality
    print('Android sign screen - functionality to be implemented');

    final value = await commander.select(
      'Select an option',
      onDisplay: (value) => value,
      defaultValue: 'Back',
      options: ['Back'],
    );

    if (value == 'Back') {
      // POP: Go back to the previous screen
      return ScreenAction.pop();
    }

    // Default: go back
    return ScreenAction.pop();
  }
}
