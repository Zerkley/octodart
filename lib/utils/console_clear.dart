import 'dart:io';

void clearScreen() {
  stdout.write('\x1B[2J\x1B[0;0H');
}
