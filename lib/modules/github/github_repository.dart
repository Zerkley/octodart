import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:core';

typedef RepoIdentifiers = ({String owner, String repo});

class GithubClientRepository {
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

  Future<void> listRepoContents(
    String owner,
    String repo, {
    String? token,
  }) async {
    // TODO: Use the urls from the config file
    final repoInfo = _parseGitHubURL(repo);
    if (repoInfo == null) {
      print('error parsing github url');
      return;
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

    print('Fetching contents from: $url');

    try {
      // 3. Make the GET Request
      final response = await http.get(url, headers: headers);
      //TODO: Adapt this to scan for mason.yaml file and read contents
      if (response.statusCode == 200) {
        // 4. Parse the JSON Response
        final List<dynamic> contents = json.decode(response.body);

        print('\n--- Repository Contents ($owner/$repo) ---');
        for (final item in contents) {
          final String name = item['name'] ?? 'N/A';
          final String type = item['type'] ?? 'N/A'; // 'file' or 'dir'

          // Display path, type, and size (if it's a file)
          if (type == 'file') {
            final int size = item['size'] ?? 0;
            print('📄 FILE: $name (${size} bytes)');
          } else if (type == 'dir') {
            print('📁 DIRECTORY: $name');
          } else {
            print('❓ OTHER: $name ($type)');
          }
        }
        print('-----------------------------------------');
      } else {
        print('Error: Failed to fetch repository contents.');
        print('Status Code: ${response.statusCode}');
        if (response.statusCode == 404) {
          print('Check if the owner and repository names are correct.');
        }
        if (response.statusCode == 403) {
          print('Rate limit exceeded or token permissions insufficient.');
        }
      }
    } catch (e) {
      print('An exception occurred during the API call: $e');
    }
  }
}
