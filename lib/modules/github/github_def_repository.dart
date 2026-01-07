abstract class GithubRepository {
  Future<List<String>> listRepoContents(String repo, {String? token});
}
