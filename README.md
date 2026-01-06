# PPCC - Proton Pass Clipboard CLI

A command-line tool to search and copy password manager items from Proton Pass via `pass-cli`.

## Installation

1. Ensure `pass-cli` is installed and configured
2. Ensure `jq` is installed (`brew install jq` or `apt install jq`)
3. Make `ppcc` executable: `chmod +x ppcc`
4. Add to PATH or use directly: `./ppcc`

## Usage

### Basic Search

Search for items by URL pattern:

```bash
ppcc github
ppcc github.com
ppcc kraken
```

### Advanced Options

```bash
# Search in a specific vault
ppcc --vault Personal github

# Search for specific item type
ppcc --type note meeting
ppcc --type credit-card

# Combine options
ppcc --vault Work --type login github
```

### Supported Types

- `login` (default)
- `note`
- `alias`
- `credit-card`
- `identity`
- `ssh-key`
- `wifi`
- `custom`

### Workflow

1. Enter search phrase (searches in item URLs)
2. Select matching item from list
3. Choose field to copy:
   - `e` - Email
   - `n` - Username
   - `p` - Password
   - `u` - URL
4. Selected field is copied to clipboard

## Example

```bash
$ ppcc github
Found 1 matching item(s):

1) github.com | URLs: https://github.com/session

Only one match found, selecting automatically...

Selected: github.com

Available fields:
  e) Email: user@example.com
  n) Username: dfosterj
  p) Password: [hidden]
  u) URL: https://github.com/session

Copy to clipboard (e/n/p/u): p
✓ Password copied to clipboard
```

## Alfred Workflow (ppcc-alfred)

**Status: ⚠️ In Development - Not Currently Working**

### Concept

The Alfred workflow aims to provide the same functionality as the CLI directly from Alfred's search interface.

### Current Implementation

- **`search.sh`** - Searches Proton Pass items and outputs Alfred JSON format
- **`fields.sh`** - Displays available fields (email, username, password, URL) for selected items
- **`info.plist`** - Alfred workflow configuration

### Planned Workflow

1. Type `ppcc` in Alfred
2. Enter search phrase (e.g., `ppcc github`)
3. Results appear in Alfred
4. Press `Cmd+Enter` on an item to view fields
5. Select field to copy to clipboard

### Roadmap

- [x] Basic CLI functionality
- [x] Alfred workflow structure
- [x] Search script with Alfred JSON output
- [x] Fields display script
- [ ] Fix argument passing in Alfred workflow
- [ ] Test and validate workflow
- [ ] Add support for modifier keys (quick copy email/password)
- [ ] Add fuzzy search/filtering in Alfred results

### Known Issues

- Alfred workflow does not currently accept search arguments correctly
- Workflow structure follows authy pattern but needs debugging

## Requirements

- macOS or Linux
- `pass-cli` (Proton Pass CLI)
- `jq` (JSON processor)
- `bash` 4.0+
- Clipboard utility: `pbcopy` (macOS) or `xclip`/`xsel` (Linux)

## License

See repository license file.
