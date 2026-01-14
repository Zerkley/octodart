/// Abstract interface for Mason brick generation operations.
abstract class MasonRepository {
  /// Generates a Mason brick from a GitHub repository.
  ///
  /// [brickName] The name of the brick to generate.
  /// [gitUrl] The GitHub URL where the bricks repository is located.
  /// [onProgress] Optional callback to receive progress updates.
  ///
  /// Returns `true` if the brick was generated successfully.
  Future<bool> generateBrick({
    required String brickName,
    required String gitUrl,
    void Function(String)? onProgress,
  });
}
