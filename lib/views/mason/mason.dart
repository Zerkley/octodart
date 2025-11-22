import 'package:commander_ui/commander_ui.dart';

Future<void> getMasonSelection(Commander commander) async {
  final value = await commander.select(
    'What is your name ?',
    onDisplay: (value) => value,
    placeholder: 'Type to search',
    defaultValue: 'Charlie',
    options: ['Alice', 'Bob', 'Charlie', 'David', 'Eve', 'Frank', 'John'],
  );

  print(value);
}
