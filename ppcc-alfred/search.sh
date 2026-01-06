#!/bin/bash

# Alfred script filter for ppcc - searches items and outputs Alfred JSON
# Usage: search.sh [--vault VAULT] [--type TYPE] SEARCH_PHRASE
# Or: search.sh FIELD_QUERY (format: ITEM_ID|VAULT|TYPE|EMAIL|USERNAME|PASSWORD|URL)

set -euo pipefail

# Check if this is a field query (contains pipe separators)
if [[ "${1:-}" == *"|"* ]]; then
    # This is a field selection query, delegate to fields.sh
    "$(dirname "$0")/fields.sh" "$1"
    exit 0
fi

# Parse arguments for search
VAULT="Work"
TYPE="login"
SEARCH_PHRASE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --vault)
            VAULT="$2"
            shift 2
            ;;
        --type)
            TYPE="$2"
            shift 2
            ;;
        *)
            if [ -z "$SEARCH_PHRASE" ]; then
                SEARCH_PHRASE="$1"
            else
                SEARCH_PHRASE="$SEARCH_PHRASE $1"
            fi
            shift
            ;;
    esac
done

# If no search phrase, show empty result
if [ -z "$SEARCH_PHRASE" ]; then
    echo '{"items": []}'
    exit 0
fi

# Get items from pass-cli
ITEMS_JSON=$(pass-cli item list "$VAULT" --filter-type "$TYPE" --output json 2>/dev/null || echo '{"items":[]}')

# Convert type to JSON key format
case "$TYPE" in
    login) TYPE_KEY="Login" ;;
    note) TYPE_KEY="Note" ;;
    alias) TYPE_KEY="Alias" ;;
    credit-card) TYPE_KEY="CreditCard" ;;
    identity) TYPE_KEY="Identity" ;;
    ssh-key) TYPE_KEY="SSHKey" ;;
    wifi) TYPE_KEY="WiFi" ;;
    custom) TYPE_KEY="Custom" ;;
    *) TYPE_KEY=$(echo "$TYPE" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}') ;;
esac

# Search for items matching the search phrase in URLs
MATCHING_ITEMS=$(echo "$ITEMS_JSON" | jq -r --arg search "$SEARCH_PHRASE" --arg type "$TYPE_KEY" '
  .items[] | 
  select(
    (.content.content[$type].urls // [])[]? | 
    test($search; "i")
  ) | 
  {
    id: .id,
    title: .content.title,
    urls: (.content.content[$type].urls // []),
    email: (.content.content[$type].email // ""),
    username: (.content.content[$type].username // ""),
    password: (.content.content[$type].password // ""),
    vault: "'"$VAULT"'",
    type: "'"$TYPE"'"
  }
' | jq -s '.')

# Check if any matches found
MATCH_COUNT=$(echo "$MATCHING_ITEMS" | jq 'length')

if [ "$MATCH_COUNT" -eq 0 ]; then
    echo '{"items": [{"title": "No items found", "subtitle": "No items matching \"'"$SEARCH_PHRASE"'\" in vault \"'"$VAULT"'\"", "valid": false}]}'
    exit 0
fi

# Output Alfred JSON format with Cmd modifier to show fields
echo "$MATCHING_ITEMS" | jq -r '
  {
    items: [
      .[] | {
        title: .title,
        subtitle: (.urls | join(", ")) + " • Press Cmd to view fields",
        arg: (.id + "|" + .vault + "|" + .type + "|" + .email + "|" + .username + "|" + .password + "|" + (.urls[0] // "")),
        valid: true,
        text: {
          copy: .title
        },
        mods: {
          cmd: {
            arg: (.id + "|" + .vault + "|" + .type + "|" + .email + "|" + .username + "|" + .password + "|" + (.urls[0] // "")),
            subtitle: "View fields for: " + .title,
            valid: true
          }
        }
      }
    ]
  }
'
