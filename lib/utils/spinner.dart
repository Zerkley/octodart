import 'dart:async';
import 'dart:io';

/// Shows an ASCII spinner animation while an async operation is running.
///
/// Usage:
/// ```dart
/// final result = await showSpinner(
///   message: 'Loading...',
///   operation: () => someAsyncOperation(),
/// );
/// ```
Future<T> showSpinner<T>({
  required String message,
  required Future<T> Function() operation,
}) async {
  final spinnerFrames = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];
  int frameIndex = 0;

  // Start the spinner animation
  // Use stderr to avoid conflicts with commander_ui which uses stdout
  final spinnerTimer = Timer.periodic(const Duration(milliseconds: 100), (
    timer,
  ) {
    stderr.write('\r${spinnerFrames[frameIndex]} $message');
    stderr.flush();
    frameIndex = (frameIndex + 1) % spinnerFrames.length;
  });

  try {
    // Run the actual operation
    final result = await operation();
    // Stop the spinner
    spinnerTimer.cancel();
    // Clear the spinner line from stderr
    stderr.write('\r${' ' * (message.length + spinnerFrames[0].length + 1)}\r');
    stderr.flush();
    // Add a small delay to ensure stdout is ready for commander_ui
    await Future.delayed(const Duration(milliseconds: 50));
    return result;
  } catch (e) {
    // Stop the spinner on error
    spinnerTimer.cancel();
    // Clear the spinner line from stderr
    stderr.write('\r${' ' * (message.length + spinnerFrames[0].length + 1)}\r');
    stderr.flush();
    // Add a small delay to ensure stdout is ready
    await Future.delayed(const Duration(milliseconds: 50));
    rethrow;
  }
}

/// Shows an ASCII spinner animation with dynamic message updates.
///
/// Usage:
/// ```dart
/// final result = await showSpinnerWithProgress(
///   initialMessage: 'Starting...',
///   operation: (updateMessage) async {
///     updateMessage('Step 1...');
///     await step1();
///     updateMessage('Step 2...');
///     await step2();
///   },
/// );
/// ```
Future<T> showSpinnerWithProgress<T>({
  required String initialMessage,
  required Future<T> Function(void Function(String) updateMessage) operation,
}) async {
  final spinnerFrames = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];
  int frameIndex = 0;
  String currentMessage = initialMessage;
  int maxMessageLength = initialMessage.length;

  // Start the spinner animation
  // Use stderr to avoid conflicts with commander_ui which uses stdout
  final spinnerTimer = Timer.periodic(const Duration(milliseconds: 100), (
    timer,
  ) {
    stderr.write('\r${spinnerFrames[frameIndex]} $currentMessage');
    stderr.flush();
    frameIndex = (frameIndex + 1) % spinnerFrames.length;
  });

  // Function to update the message
  void updateMessage(String newMessage) {
    currentMessage = newMessage;
    if (newMessage.length > maxMessageLength) {
      maxMessageLength = newMessage.length;
    }
  }

  try {
    // Run the actual operation with the update function
    final result = await operation(updateMessage);
    // Stop the spinner
    spinnerTimer.cancel();
    // Clear the spinner line from stderr
    stderr.write(
      '\r${' ' * (maxMessageLength + spinnerFrames[0].length + 1)}\r',
    );
    stderr.flush();
    // Add a small delay to ensure stdout is ready for commander_ui
    await Future.delayed(const Duration(milliseconds: 50));
    return result;
  } catch (e) {
    // Stop the spinner on error
    spinnerTimer.cancel();
    // Clear the spinner line from stderr
    stderr.write(
      '\r${' ' * (maxMessageLength + spinnerFrames[0].length + 1)}\r',
    );
    stderr.flush();
    // Add a small delay to ensure stdout is ready
    await Future.delayed(const Duration(milliseconds: 50));
    rethrow;
  }
}
