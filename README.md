# t3-directory-jumper

A smart directory navigation plugin for Zsh that provides instant shortcuts to your frequently used directories and intelligent project-based navigation.

## Features

- 🚀 **Path Shortcuts**: Create instant aliases to jump to any directory
- 🔍 **Jump Functions**: Smart search for directories within your project tree
- 📝 **Easy Management**: Add, remove, edit, and list all your shortcuts
- ⬆️ **Quick Navigation**: Navigate up multiple directory levels with a single command
- 💾 **Persistent Storage**: All shortcuts saved in `~/.t3-shortcuts`
- 🎯 **No Conflicts**: All shortcuts use the `3` prefix to avoid naming conflicts
- ✨ **Auto-list**: Automatically runs `ls -l` after navigation

## Installation

### oh-my-zsh

1. Clone this repository into oh-my-zsh's plugins directory:

```bash
git clone https://github.com/yourusername/t3-directory-jumper ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/t3-directory-jumper
```

2. Add the plugin to your `~/.zshrc`:

```bash
plugins=(
    # ... other plugins
    t3-directory-jumper
)
```

3. Reload your shell:

```bash
source ~/.zshrc
```

### Manual Installation

1. Clone the repository:

```bash
git clone https://github.com/yourusername/t3-directory-jumper ~/.t3-directory-jumper
```

2. Add to your `~/.zshrc`:

```bash
source ~/.t3-directory-jumper/t3-directory-jumper.plugin.zsh
```

3. Reload your shell:

```bash
source ~/.zshrc
```

### Other Plugin Managers

**Using [zinit](https://github.com/zdharma-continuum/zinit):**
```bash
zinit light yourusername/t3-directory-jumper
```

**Using [antigen](https://github.com/zsh-users/antigen):**
```bash
antigen bundle yourusername/t3-directory-jumper
```

**Using [zplug](https://github.com/zplug/zplug):**
```bash
zplug "yourusername/t3-directory-jumper"
```

## Usage

### Path Shortcuts

Create shortcuts to specific directories that you can access from anywhere.

#### Add a Path Shortcut

```bash
$ cd ~/dev/my-awesome-project
$ t3 add -path
Your current directory is: /Users/username/dev/my-awesome-project
Would you like to add a path shortcut for this directory? (Y/N) Y
Enter your alias for this directory: project
Are you sure to assign the alias '3project'? (Y/N) Y
The "3project" path shortcut has been assigned to "/Users/username/dev/my-awesome-project" directory!
```

Now you can jump to that directory from anywhere:

```bash
$ 3project
# Navigates to ~/dev/my-awesome-project and runs ls -l
```

#### Remove a Path Shortcut

```bash
$ t3 remove -path
Enter the path shortcut to delete: 3project
Are you sure to delete "3project" path shortcut to "/Users/username/dev/my-awesome-project"? (Y/N) Y
The "3project" path shortcut has been removed!
```

#### Edit a Path Shortcut

```bash
$ t3 edit -path 3project
Current path: /Users/username/dev/my-awesome-project
Enter new path (or press Enter to keep current): /Users/username/dev/my-new-project
Update '3project' to point to '/Users/username/dev/my-new-project'? (Y/N) Y
The "3project" path shortcut has been updated!
```

### Jump Functions

Create smart shortcuts that search for specific directories within your project tree.

#### Add a Jump Function

```bash
$ t3 add -jump
Would you like to add a jump function? (Y/N) Y
Enter the shortcut name: src
Enter the directory for "3src" shortcut: src
Directory: src
Is this correct? (Y/N) Y
Are you sure to create the jump function '3src' for 'src'? (Y/N) Y
The "3src" jump function has been created!
You can now use '3src' to navigate to 'src' from anywhere in your project tree.
```

How it works:

```bash
$ pwd
/Users/username/projects/my-app/tests/unit

$ 3src
# Searches upward for a 'src' directory and navigates to:
# /Users/username/projects/my-app/src
# Then runs ls -l
```

#### Remove a Jump Function

```bash
$ t3 remove -jump
Enter the jump function to delete: 3src
Are you sure to delete "3src" jump function for "src"? (Y/N) Y
The "3src" jump function has been removed!
```

#### Edit a Jump Function

```bash
$ t3 edit -jump 3src
Current target directory: src
Enter new target directory (or press Enter to keep current): source
Update '3src' to search for 'source'? (Y/N) Y
The "3src" jump function has been updated!
```

### List Shortcuts

View all your shortcuts or filter by type:

```bash
# List everything
$ t3 list
All shortcuts:
==============

Path Shortcuts:
---------------
3project -> /Users/username/dev/my-awesome-project
3docs -> /Users/username/Documents

Jump Functions:
---------------
3src -> searches for 'src' in project tree
3tests -> searches for 'tests' in project tree
```

```bash
# List only path shortcuts
$ t3 list -path
Path Shortcuts:
---------------
3project -> /Users/username/dev/my-awesome-project
3docs -> /Users/username/Documents
```

```bash
# List only jump functions
$ t3 list -jump
Jump Functions:
---------------
3src -> searches for 'src' in project tree
3tests -> searches for 'tests' in project tree
```

### Navigate Up Directories

Quickly move up multiple directory levels:

```bash
$ pwd
/Users/username/dev/project/src/components/forms/inputs

$ up 3
$ pwd
/Users/username/dev/project/src/components

$ up 5
$ pwd
/Users/username/dev
```

## Command Reference

### Main Commands

```bash
t3 add -path           # Add path shortcut for current directory
t3 add -jump           # Add jump function to search in project tree
t3 remove -path        # Remove an existing path shortcut
t3 remove -jump        # Remove an existing jump function
t3 edit -path <name>   # Edit an existing path shortcut
t3 edit -jump <name>   # Edit an existing jump function
t3 list                # List all shortcuts (paths and jumps)
t3 list -path          # List only path shortcuts
t3 list -jump          # List only jump functions
up <number>            # Navigate up N directories
```

### Examples

```bash
# Create shortcuts
cd ~/projects && t3 add -path
t3 add -jump

# Use shortcuts
3myproject    # Jump to saved path
3src          # Search upward for 'src' directory
up 2          # Go up 2 levels

# Manage shortcuts
t3 list
t3 edit -path 3myproject
t3 remove -jump 3src
```

## Storage

All shortcuts are stored in `~/.t3-shortcuts` with the following structure:

```bash
### PATH SHORTCUTS ###
alias 3project='cd "/Users/username/dev/my-project" && ls -l'
alias 3docs='cd "/Users/username/Documents" && ls -l'

### JUMP FUNCTIONS ###
function 3src() {
    local current_dir=$(pwd)
    while [[ "$current_dir" != "/" && "$current_dir" != "$HOME" ]]; do
        if [[ -d "$current_dir/src" ]]; then
            cd "$current_dir/src" && ls -l
            return
        fi
        current_dir=$(dirname "$current_dir")
    done
    echo "Not in a project directory or 'src' not found"
}
```

## How It Works

### Path Shortcuts
- Creates shell aliases that point to specific directories
- Automatically adds the `3` prefix to avoid conflicts
- Runs `ls -l` after changing directory to show contents

### Jump Functions
- Searches upward from your current location through parent directories
- Stops at the first matching directory or at root/home
- Perfect for navigating within project structures
- Also runs `ls -l` after successful navigation

### Name Uniqueness
- All shortcut names are unique across both paths and jumps
- The plugin prevents you from creating duplicate names
- Only shortcuts starting with `3` can be removed (safety feature)

## Tips & Best Practices

1. **Use short, memorable names**: `3mp` instead of `3my-projects`
2. **Path shortcuts for frequently visited directories**: Your main projects, documents, downloads
3. **Jump functions for project structure**: Common subdirectories like `src`, `tests`, `docs`
4. **Use `t3 list` regularly**: Keep track of your shortcuts
5. **Combine with `up`**: Navigate complex directory structures efficiently
6. **Press Ctrl+C anytime**: Cancel any operation safely

## Troubleshooting

### Shortcuts not loading
Make sure you've sourced your `.zshrc` after installation:
```bash
source ~/.zshrc
```

### Can't find the shortcuts file
The file is created automatically at `~/.t3-shortcuts` on first use of any `t3` command.

### Shortcut conflicts
All shortcuts use the `3` prefix to minimize conflicts. If you still have conflicts, you can manually edit `~/.t3-shortcuts`.

### Jump function not finding directory
Jump functions search upward from your current location. Make sure you're somewhere within the project tree that contains the target directory.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Author

Created by [Your Name]

## Acknowledgments

Inspired by the need for efficient directory navigation in complex project structures.
