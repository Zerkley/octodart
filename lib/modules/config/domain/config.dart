class GitHubConfig {
  final String bricksUrl;
  final String authToken;

  GitHubConfig({required this.bricksUrl, required this.authToken});

  factory GitHubConfig.fromMap(Map<String, dynamic> map) {
    return GitHubConfig(
      bricksUrl: map['bricks_url'] as String? ?? '',
      authToken: map['auth_token'] as String? ?? '',
    );
  }
}

class AppConfig {
  final GitHubConfig github;

  AppConfig({required this.github});

  // Factory constructor maps the root TOML document (the full Map)
  // to the top-level objects.
  factory AppConfig.fromMap(Map<String, dynamic> map) {
    // Safely retrieves the 'github' key, which is expected to be a Map.
    // If 'github' is missing, it passes an empty map {} to the GitHubConfig.fromMap
    // so the default values (e.g., '') are used instead of crashing.
    return AppConfig(
      github: GitHubConfig.fromMap(
        map['github'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
