/// Represents a single GitHub repository configuration for Mason bricks.
class GitHubRepoConfig {
  final String name;
  final String githubUrl;
  final String? authToken;

  GitHubRepoConfig({
    required this.name,
    required this.githubUrl,
    this.authToken,
  });

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

class AppConfig {
  final List<GitHubRepoConfig> repos;

  AppConfig({required this.repos});

  // Factory constructor maps the root TOML document (the full Map)
  // to the top-level objects.
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

  /// Returns true if the config has no valid repositories configured.
  bool get isDefault => repos.isEmpty;
}
