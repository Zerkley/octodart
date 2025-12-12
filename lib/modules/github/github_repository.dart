import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:core';
import 'package:yaml/yaml.dart';

import 'package:octodart/modules/github/github_def_repository.dart';

typedef RepoIdentifiers = ({String owner, String repo});

class GithubClientRepository implements GithubRepository {
  GithubClientRepository();

  /// A record representing the owner and repository names extracted from a GitHub URL.

  /// Parses a GitHub URL or string (e.g., 'https://github.com/owner/repo',
  /// 'git@github.com:owner/repo.git', or 'owner/repo')
  /// and extracts the owner and repository names.
  ///
  /// Returns a [RepoIdentifiers] record with 'owner' and 'repo' if successful,
  /// otherwise returns null.
  RepoIdentifiers? _parseGitHubURL(String githubURL) {
    String input = githubURL.trim();

    // 1. Remove .git suffix if present (handles SSH format: git@github.com:owner/repo.git)
    if (input.endsWith('.git')) {
      input = input.substring(0, input.length - 4);
    }

    // 2. Handle full HTTP/HTTPS URLs
    if (input.startsWith('http://') || input.startsWith('https://')) {
      try {
        final uri = Uri.parse(input);

        // Get the path segment and remove the leading slash: "/owner/repo" -> "owner/repo"
        final path = uri.path.trim();

        // Check if the path starts with a slash (which it should) and remove it
        final String cleanPath = path.startsWith('/')
            ? path.substring(1)
            : path;

        final parts = cleanPath.split('/');

        // We expect at least two parts: [owner, repo, ...]
        if (parts.length < 2 || parts[0].isEmpty || parts[1].isEmpty) {
          print(
            'Error: Invalid GitHub URL path structure: expected owner/repo',
          );
          return null;
        }

        // Return the first two parts: owner and repo
        return (owner: parts[0], repo: parts[1]);
      } on FormatException catch (e) {
        print('Error: Failed to parse URL: $e');
        return null;
      }
    }

    // 3. Handle simple owner/repo or SSH-like string formats (e.g., 'owner/repo' or 'git@github.com:owner/repo')

    // Clean up potential SSH prefixes before splitting
    if (input.contains(':') && input.contains('@')) {
      // Attempt to clean SSH format like "git@github.com:owner/repo"
      input = input.split(':').last;
    }

    final parts = input.split('/');

    if (parts.length < 2 || parts[0].isEmpty || parts[1].isEmpty) {
      print('Error: Invalid GitHub string format: expected owner/repo');
      return null;
    }

    // Return the first two parts
    return (owner: parts[0], repo: parts[1]);
  }

  @override
  Future<List<String>> listRepoContents(String repo, {String? token}) async {
    // TODO: Use the urls from the config file
    final repoInfo = _parseGitHubURL(repo);
    if (repoInfo == null) {
      print('error parsing github url');
      return [];
    }
    final url = Uri.parse(
      'https://api.github.com/repos/${repoInfo.owner}/${repoInfo.repo}/contents',
    );

    // 2. Define Request Headers
    final headers = {
      'Accept':
          'application/vnd.github.v3+json', // Recommended GitHub API version
      'User-Agent': 'Dart-GitHub-Client', // Required by GitHub API
      if (token != null)
        'Authorization':
            'Bearer $token', // For private repos or higher rate limits
    };

    try {
      // 3. Make the GET Request
      final response = await http.get(url, headers: headers);
      //TODO: Adapt this to scan for mason.yaml file and read contents
      if (response.statusCode == 200) {
        // 4. Parse the JSON Response
        final List<dynamic> contents = json.decode(response.body);

        // 1. Find the 'mason.yaml' file object
        final masonYamlItem = contents.firstWhere(
          (item) => item['name'] == 'mason.yaml' && item['type'] == 'file',
          orElse: () => null, // Returns null if not found
        );

        if (masonYamlItem != null) {
          final String? downloadUrl = masonYamlItem['download_url'];

          if (downloadUrl != null) {
            // 2. Fetch the raw content from the download URL
            final http.Response response = await http.get(
              Uri.parse(downloadUrl),
            );

            if (response.statusCode == 200) {
              final String yamlContent = response.body;

              // 3. Format/Parse the YAML content for use in Dart
              try {
                // Use loadYaml to parse the string into a Dart object (YamlMap)
                final YamlMap yamlMap = loadYaml(yamlContent) as YamlMap;

                // Convert the YamlMap to a standard Dart Map<String, dynamic>
                // for easier use in the rest of your Dart application.
                final Map<String, dynamic> dartMap = json.decode(
                  json.encode(yamlMap),
                );

                if (dartMap.containsKey('bricks') && dartMap['bricks'] is Map) {
                  // Cast the 'bricks' value to a Map<String, dynamic>
                  final Map<String, dynamic> bricksMap =
                      dartMap['bricks'] as Map<String, dynamic>;

                  // Get the keys (the brick names) and convert them to a list
                  final List<String> brickNamesList = bricksMap.keys.toList();

                  return brickNamesList;
                } else {
                  print(
                    '❌ Error: The parsed map does not contain the expected "bricks" map.',
                  );
                  return [];
                }
              } catch (e) {
                print('❌ Error parsing YAML: $e');
                return [];
              }
            } else {
              print(
                '❌ Failed to download mason.yaml. Status code: ${response.statusCode}',
              );
              return [];
            }
          } else {
            print('❌ mason.yaml item did not contain a download_url.');
            return [];
          }
        } else {
          print(
            '❌ The file mason.yaml was not found in the repository contents.',
          );
          return [];
        }
      } else {
        print('Error: Failed to fetch repository contents.');
        print('Status Code: ${response.statusCode}');
        if (response.statusCode == 404) {
          print('Check if the owner and repository names are correct.');
        }
        if (response.statusCode == 403) {
          print('Rate limit exceeded or token permissions insufficient.');
        }
        return [];
      }
    } catch (e) {
      print('An exception occurred during the API call: $e');
      return [];
    }
  }
}
