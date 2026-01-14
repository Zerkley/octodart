import 'package:masoneer/modules/config/data/config_repository.dart';
import 'package:masoneer/modules/config/domain/config.dart';
import 'package:masoneer/modules/github/github_repository.dart';
import 'package:masoneer/modules/mason/data/mason_repository.dart';

/// Example demonstrating how to use masoneer programmatically.
///
/// This example shows how to:
/// 1. Load configuration from the default config file
/// 2. List bricks from a GitHub repository
/// 3. Generate a brick (commented out to avoid side effects)
Future<void> main() async {
  // Load configuration from the default config file
  // (~/.config/masoneer/config.toml on Linux/macOS)
  print('Loading configuration...');
  final config = await loadConfig();
  print('Found ${config.repos.length} configured repository(ies)\n');

  if (config.repos.isEmpty) {
    print('No repositories configured. Please add repositories to your config file.');
    return;
  }

  // Use the first configured repository
  final repo = config.repos.first;
  print('Using repository: ${repo.name}');
  print('URL: ${repo.githubUrl}\n');

  // List available bricks from the repository
  print('Fetching available bricks...');
  final githubRepo = GithubClientRepository();
  try {
    final bricks = await githubRepo.listRepoContents(
      repo.githubUrl,
      token: repo.authToken,
    );

    if (bricks.isEmpty) {
      print('No bricks found in this repository.');
      return;
    }

    print('Found ${bricks.length} brick(s):');
    for (final brick in bricks) {
      print('  - $brick');
    }

    // Example: Generate a brick (commented out to avoid side effects)
    // Uncomment the following lines to actually generate a brick:
    /*
    print('\nGenerating brick: ${bricks.first}');
    final masonRepo = MasonClientRepository();
    await masonRepo.generateBrick(
      brickName: bricks.first,
      gitUrl: repo.githubUrl,
      onProgress: (message) => print('  $message'),
    );
    print('✅ Brick generated successfully!');
    */
  } catch (e) {
    print('❌ Error: $e');
  }
}

