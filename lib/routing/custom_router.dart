import 'package:masoneer/utils/console_clear.dart';

abstract class TuiScreen {
  final String screenName;

  TuiScreen(this.screenName);

  /// The main logic for displaying the menu/screen and handling input.
  /// It should return the next screen to navigate to, or null/ExitCommand
  /// to indicate termination or a return.
  Future<ScreenAction> run();
}

/// A class to encapsulate the result of a screen's `run()` method.
class ScreenAction {
  final String actionType;
  final TuiScreen? nextScreen;
  final Future<void> Function()? onExit;

  ScreenAction.push(TuiScreen screen)
    : actionType = 'PUSH',
      nextScreen = screen,
      onExit = null;
  ScreenAction.pop() : actionType = 'POP', nextScreen = null, onExit = null;
  ScreenAction.exit([this.onExit]) : actionType = 'EXIT', nextScreen = null;
}

/// Main application router that manages the screen stack and navigation.
class TuiApp {
  // A Stack (LIFO - Last In, First Out) to manage screen history
  final List<TuiScreen> _screenStack = [];

  TuiApp(TuiScreen initialScreen) {
    _screenStack.add(initialScreen);
  }

  Future<void> run() async {
    // This is the continuous application loop.
    bool isRunning = true;
    while (isRunning) {
      if (_screenStack.isEmpty) {
        // Should only happen if the initial screen immediately POPs or the logic is flawed.
        print('Application stack is empty. Exiting.');
        break;
      }

      // Get the current screen (the one on top of the stack)
      TuiScreen currentScreen = _screenStack.last;

      // Run the screen's logic and get the intended action
      ScreenAction action = await currentScreen.run();

      // Handle the returned action
      switch (action.actionType) {
        case 'PUSH':
          // A new screen is being launched.
          // Check if it's the same screen (for re-display) or a new one.
          if (action.nextScreen != currentScreen) {
            clearScreen();
            _screenStack.add(action.nextScreen!);
          } else {
            // If it's the same screen, no change to the stack, loop continues.
            // This is how you implement "re-running" the current menu.
          }
          break;
        case 'POP':
          // Go back to the previous screen by removing the current one.
          // Note: The POP action should not be performed on the very first screen.
          clearScreen();
          if (_screenStack.length > 1) {
            _screenStack.removeLast();
          } else {
            // Treat POP on the initial screen as an application exit.
            clearScreen();
            isRunning = false;
          }
          break;
        case 'EXIT':
          // Application shutdown.
          clearScreen();
          isRunning = false;
          // Run any post-exit callback (e.g., generateBrick outside TUI context)
          if (action.onExit != null) {
            await action.onExit!();
          }
          break;
      }
    }
    print('Application closed.');
  }
}
