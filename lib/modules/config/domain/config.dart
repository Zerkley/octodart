/// Represents a single GitHub repository configuration for Mason bricks.
class GitHubRepoConfig {
  /// The display name for this repository.
  final String name;

  /// The GitHub URL of the repository containing Mason bricks.
  final String githubUrl;

  /// Optional authentication token for private repositories.
  final String? authToken;

  /// Creates a new [GitHubRepoConfig] instance.
  ///
  /// [name] is the display name for the repository.
  /// [githubUrl] is the GitHub URL where the bricks are located.
  /// [authToken] is optional and only needed for private repositories.
  GitHubRepoConfig({
    required this.name,
    required this.githubUrl,
    this.authToken,
  });

  /// Creates a [GitHubRepoConfig] from a map (typically from TOML config).
  ///
  /// Expected map keys:
  /// - `name`: The repository display name
  /// - `github_url`: The GitHub repository URL
  /// - `auth_token`: Optional authentication token (for private repos)
  factory GitHubRepoConfig.fromMap(Map<String, dynamic> map) {
    return GitHubRepoConfig(
      name: map['name'] as String? ?? '',
      githubUrl: map['github_url'] as String? ?? '',
      authToken: map['auth_token'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'github_url': githubUrl,
      if (authToken != null) 'auth_token': authToken,
    };
  }

  /// Returns true if this repo config has valid required fields.
  bool get isValid => name.isNotEmpty && githubUrl.isNotEmpty;
}

/// Main application configuration containing all GitHub repository configurations.
///
/// This class holds the list of GitHub repositories that contain Mason bricks
/// and can be loaded from a TOML configuration file.
class AppConfig {
  /// List of configured GitHub repositories containing Mason bricks.
  final List<GitHubRepoConfig> repos;

  /// Creates a new [AppConfig] instance.
  ///
  /// [repos] is the list of GitHub repository configurations.
  AppConfig({required this.repos});

  /// Creates an [AppConfig] from a map (typically from a TOML document).
  ///
  /// The map should have a `github` section with a `repos` array:
  /// ```toml
  /// [github]
  /// repos = [
  ///   { name = "Repo Name", github_url = "https://github.com/owner/repo" }
  /// ]
  /// ```
  ///
  /// Only valid repository configurations (with non-empty name and URL) are included.
  factory AppConfig.fromMap(Map<String, dynamic> map) {
    final githubSection = map['github'] as Map<String, dynamic>? ?? {};
    final reposList = githubSection['repos'] as List<dynamic>? ?? [];

    final repos = reposList
        .map((item) => GitHubRepoConfig.fromMap(item as Map<String, dynamic>))
        .where((repo) => repo.isValid)
        .toList();

    return AppConfig(repos: repos);
  }

  Map<String, dynamic> toMap() {
    return {
      'github': {'repos': repos.map((r) => r.toMap()).toList()},
    };
  }
}
