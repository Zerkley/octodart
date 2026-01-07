# Masoneer

A terminal user interface (TUI) for managing and generating [Mason](https://github.com/felangel/mason) bricks from multiple GitHub repositories.

Masoneer simplifies the process of scaffolding code by providing an interactive menu to browse and apply Mason templates directly from your configured GitHub repositories—without manually running Mason CLI commands.

## Features

- **Multiple Repository Support** — Configure multiple GitHub repositories containing Mason bricks
- **Interactive TUI** — Browse and select bricks through a searchable menu
- **Private Repository Support** — Use GitHub tokens for private repositories
- **Cross-Platform** — Works on macOS and Linux
- **Zero Configuration Start** — Ships with a working example repository out of the box

## Prerequisites

- [Mason CLI](https://github.com/felangel/mason) must be installed and available in your PATH
- Dart SDK ^3.9.0 (only if installing from source)

```bash
# Install Mason CLI
dart pub global activate mason_cli
```

## Installation

### From pub.dev (Recommended)

```bash
dart pub global activate masoneer
```

Make sure you have the Dart SDK's global bin directory in your PATH:

```bash
# Add to ~/.zshrc or ~/.bashrc
export PATH="$PATH:$HOME/.pub-cache/bin"
```

### From Source

```bash
# Clone the repository
git clone https://github.com/Zerkley/masoneer.git
cd masoneer

# Install dependencies
dart pub get

# Option 1: Run directly with Dart
dart run

# Option 2: Compile to native executable
dart compile exe bin/masoneer.dart -o masoneer

# Move to PATH for global access
sudo mv masoneer /usr/local/bin/
# Or for user-only installation:
mkdir -p ~/.local/bin && mv masoneer ~/.local/bin/
```

## Configuration

Masoneer uses a TOML configuration file located at:

- **macOS/Linux:** `~/.config/masoneer/config.toml`
- **Windows:** `%APPDATA%\masoneer\config.toml`

A default configuration is created automatically on first run.

### Configuration Format

```toml
[github]
repos = [
  { name = "My Templates", github_url = "https://github.com/username/my-bricks" },
  { name = "Work Templates", github_url = "https://github.com/company/bricks", auth_token = "ghp_xxxxxxxxxxxx" },
]
```

### Configuration Fields

| Field        | Required | Description                                               |
| ------------ | -------- | --------------------------------------------------------- |
| `name`       | Yes      | Display name shown in the TUI menu                        |
| `github_url` | Yes      | GitHub repository URL containing Mason bricks             |
| `auth_token` | No       | GitHub personal access token (required for private repos) |

### Repository Structure

Your GitHub repository should contain a `mason.yaml` file at the root with your bricks defined:

```yaml
bricks:
  my_brick:
    path: bricks/my_brick
  another_brick:
    path: bricks/another_brick
```

## Usage

Simply run `masoneer` from the directory where you want to generate the brick:

```bash
cd ~/projects/my-app
masoneer
```

Then navigate through the menus:

1. Select **Mason** from the main menu
2. Choose a repository from your configured list
3. Select a brick to generate
4. Follow any Mason prompts for brick variables

The generated files will be placed in your current working directory.

## License

MIT License — see [LICENSE](LICENSE) for details.

---

Made with Dart and [commander_ui](https://pub.dev/packages/commander_ui)
