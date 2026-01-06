# PPCC Alfred Workflow

Alfred workflow for Proton Pass Clipboard CLI (ppcc) - Search and copy password manager items.

## Installation

1. Make sure `ppcc` is installed and in your PATH
2. Make sure `pass-cli` is installed and configured
3. Double-click `PPCC.alfredworkflow` to install, or:
   - Open Alfred Preferences
   - Go to Workflows
   - Click the `+` button and select "Import Workflow"
   - Select `PPCC.alfredworkflow`

## Usage

### Basic Search

1. Open Alfred (default: `Cmd+Space`)
2. Type `ppcc` followed by your search phrase
3. Results will show matching items from your default vault (Work)
4. Press `Enter` to copy the item title to clipboard
5. Press `Cmd+Enter` on an item to view its fields (email, username, password, URL)

### Advanced Usage

#### Search with Vault
```
ppcc --vault Personal github
```

#### Search with Type
```
ppcc --type note meeting
```

#### Combined
```
ppcc --vault Work --type login github
```

### Field Selection

When you press `Cmd+Enter` on an item:
- You'll see all available fields (email, username, password, URL)
- Select a field and press `Enter` to copy it to clipboard
- A notification will confirm the copy

## Workflow Structure

- `search.sh` - Searches items and outputs Alfred JSON format
- `fields.sh` - Shows available fields for a selected item
- `info.plist` - Alfred workflow configuration

## Requirements

- macOS with Alfred installed
- `ppcc` script in PATH
- `pass-cli` installed and configured
- `jq` installed (for JSON parsing)
