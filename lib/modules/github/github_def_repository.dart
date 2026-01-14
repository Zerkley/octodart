/// Abstract interface for GitHub repository operations.
abstract class GithubRepository {
  /// Lists the available Mason bricks in a GitHub repository.
  ///
  /// [repo] The GitHub repository URL or identifier.
  /// [token] Optional authentication token for private repositories.
  ///
  /// Returns a list of brick names found in the repository.
  Future<List<String>> listRepoContents(String repo, {String? token});
}
