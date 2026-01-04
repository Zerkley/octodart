import 'package:commander_ui/commander_ui.dart';
import 'package:masoneer/modules/config/domain/config.dart';
import 'package:masoneer/routing/custom_router.dart';
import 'package:masoneer/views/mason/mason.dart';
import 'package:masoneer/views/android_sign/android_sign.dart';

class HomeScreen extends TuiScreen {
  final Commander commander;
  final AppConfig config;

  HomeScreen(this.commander, this.config) : super('Main Menu');

  @override
  Future<ScreenAction> run() async {
    final isMasonConfigured = !config.isDefault;
    final masonOption = isMasonConfigured
        ? 'Mason'
        : 'Mason (Not configured in config file)';
    final value = await commander.select(
      'Select a menu',
      onDisplay: (value) => value,
      defaultValue: 'Mason',
      options: [masonOption, 'Android sign', 'Exit'],
    );

    switch (value) {
      case 'Mason':
        // Check if mason is configured before allowing access
        if (!isMasonConfigured) {
          print(
            '❌ Mason is not configured. Please configure it in your config file first.',
          );
          // Stay on the current screen (run again)
          return ScreenAction.push(this);
        }
        // PUSH: Go to the Mason screen and keep HomeScreen on the stack
        return ScreenAction.push(MasonScreen(commander, config));
      case 'Mason (Not configured in config file)':
        // Block access if mason is not configured
        print(
          '❌ Mason is not configured. Please configure it in your config file first.',
        );
        // Stay on the current screen (run again)
        return ScreenAction.push(this);
      case 'Android sign':
        // PUSH: Go to the Android Sign screen and keep HomeScreen on the stack
        return ScreenAction.push(AndroidSignScreen(commander, config));
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
