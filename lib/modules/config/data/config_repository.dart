import 'dart:io';
import 'package:octodart/modules/config/domain/config.dart';
import 'package:path/path.dart' as p;
import 'package:toml/toml.dart';

/// App-specific name used for the config folder (e.g., ~/.config/octodart/)
const String appName = 'octodart';

/// The name of the TOML configuration file
const String configFileName = 'config.toml';

final AppConfig defaultAppConfig = AppConfig(
  github: GitHubConfig(
    bricksUrl: 'https://github.com/default/bricks',
    authToken: 'none',
  ),
);

String get configDir {
  final env = Platform.environment;

  if (Platform.isLinux || Platform.isMacOS) {
    // Linux: ~/.config/
    // macOS: ~/Library/Application Support/ (though ~/.config is often used for TUIs)
    // We use ~/.config/ for better TUI compatibility on Linux/macOS.
    return env['HOME'] != null ? p.join(env['HOME']!, '.config') : '';
  } else if (Platform.isWindows) {
    // Windows: %APPDATA% (e.g., C:\Users\user\AppData\Roaming)
    return env['APPDATA'] ?? '';
  }
  // Fallback for other or unknown OS
  return env['HOME'] ?? '.';
}

/// Reads the TOML configuration file from the cross-platform user config directory.
Future<AppConfig> loadConfig() async {
  // Note: Return type is now AppConfig (non-nullable)
  try {
    // 1. Determine the Config Directory using the pure Dart helper
    final String baseConfigPath = configDir;

    if (baseConfigPath.isEmpty) {
      throw Exception(
        "Could not determine configuration directory for the current OS.",
      );
    }

    // 2. Locate the File
    // Note: We use baseConfigPath directly, NOT Directory(baseConfigPath)
    final String configPath = p.join(baseConfigPath, appName, configFileName);

    // 3. Read and Parse the TOML
    final TomlDocument document = await TomlDocument.load(configPath);
    final Map<String, dynamic> rootMap = document.toMap();

    // 4. Convert to Strongly-Typed Class
    final AppConfig config = AppConfig.fromMap(rootMap);

    print('✅ Config file loaded and parsed successfully from: $configPath');
    return config;
  } on TomlParserException catch (e) {
    print('❌ ERROR: Failed to parse TOML configuration file. Check syntax.');
    print('Returning default configuration due to parsing error.');
    print(e.message);
    return defaultAppConfig; // Return default on parsing failure
  } on FileSystemException catch (e) {
    print('❌ ERROR: File system error while accessing config file.');
    print('Returning default configuration due to file error.');
    print(e.message);
    return defaultAppConfig; // Return default on file access failure
  } catch (e) {
    print('❌ An unexpected error occurred: $e');
    print('Returning default configuration.');
    return defaultAppConfig; // Return default for any other error
  }
}
