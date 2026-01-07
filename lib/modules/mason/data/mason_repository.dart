import 'dart:io';
import 'package:masoneer/modules/mason/data/mason_def_repository.dart';
import 'package:path/path.dart' as path;

/// Repository for handling Mason brick operations.
///
/// This class manages the lifecycle of Mason commands:
/// 1. Initializes mason.yaml
/// 2. Adds the brick from the configured git repository
/// 3. Generates the brick using mason make
/// 4. Cleans up all Mason-related files and folders
class MasonClientRepository implements MasonRepository {
  /// Generates a Mason brick and cleans up all Mason artifacts.
  ///
  /// [brickName] The name of the brick to generate
  /// [gitUrl] The GitHub URL where the bricks repository is located
  /// [onProgress] Optional callback to update progress messages
  ///
  /// Returns true if successful, false otherwise.
  /// Throws [MasonException] if any step fails.
  @override
  Future<bool> generateBrick({
    required String brickName,
    required String gitUrl,
    void Function(String)? onProgress,
  }) async {
    try {
      // Step 1: Initialize mason.yaml
      onProgress?.call('Initializing mason...');
      await _runMasonCommand(['init']);

      // Step 2: Add the brick from the git repository
      onProgress?.call('Adding brick from remote...');
      await _runMasonCommand([
        'add',
        brickName,
        '--git-url',
        gitUrl,
        '--git-path',
        'bricks/$brickName',
      ]);

      // Step 3: Generate the brick
      onProgress?.call('Generating brick...');
      await _runMasonCommand(['make', brickName]);

      // Step 4: Clean up Mason artifacts
      onProgress?.call('Cleaning up...');
      await _cleanupMasonArtifacts();

      return true;
    } catch (e) {
      // Attempt cleanup even if there was an error
      onProgress?.call('Cleaning up after error...');
      await _cleanupMasonArtifacts();
      rethrow;
    }
  }

  /// Runs a Mason command using Process.run.
  ///
  /// [args] The arguments to pass to the mason command
  ///
  /// Throws [MasonException] if the command fails.
  Future<void> _runMasonCommand(List<String> args) async {
    final result = await Process.run('mason', args, runInShell: true);

    if (result.exitCode != 0) {
      throw MasonException(
        'Mason command failed: mason ${args.join(' ')}\n'
        'Exit code: ${result.exitCode}\n'
        'Stderr: ${result.stderr}',
      );
    }
  }

  /// Removes all Mason-related files and folders.
  ///
  /// Deletes:
  /// - mason.yaml file
  /// - .mason directory
  Future<void> _cleanupMasonArtifacts() async {
    final currentDir = Directory.current;
    final masonYaml = File(path.join(currentDir.path, 'mason.yaml'));
    final masonDir = Directory(path.join(currentDir.path, '.mason'));
    final masonLock = File(path.join(currentDir.path, 'mason-lock.json'));

    try {
      if (await masonYaml.exists()) {
        await masonYaml.delete();
      }
      if (await masonLock.exists()) {
        await masonLock.delete();
      }
      if (await masonDir.exists()) {
        await masonDir.delete(recursive: true);
      }
    } catch (e) {
      print('Warning: Failed to clean up some Mason artifacts: $e');
    }
  }
}

/// Exception thrown when Mason operations fail.
class MasonException implements Exception {
  final String message;

  MasonException(this.message);

  @override
  String toString() => 'MasonException: $message';
}
