abstract class MasonRepository {
  Future<bool> generateBrick({
    required String brickName,
    required String gitUrl,
    void Function(String)? onProgress,
  });
}
