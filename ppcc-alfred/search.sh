#!/bin/bash

# Alfred script filter for ppcc - searches items and outputs Alfred JSON
# Usage: search.sh [--vault VAULT] [--type TYPE] SEARCH_PHRASE
# Or: search.sh FIELD_QUERY (format: ITEM_ID|VAULT|TYPE|EMAIL|USERNAME|PASSWORD|URL)

set +euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if this is a field query (contains pipe separators)
if [[ "${1:-}" == *"|"* ]]; then
    "$SCRIPT_DIR/fields.sh" "$1"
    exit 0
fi

# Parse arguments
VAULT="Work"
TYPE="login"
SEARCH_PHRASE=""

# Alfred with scriptargtype=1 passes arguments split by spaces
# So "ppcc github" becomes: search.sh "github"
# And "ppcc --vault Personal github" becomes: search.sh "--vault" "Personal" "github"

# Collect all non-flag arguments as search phrase
ARGS=("$@")
i=0
while [ $i -lt ${#ARGS[@]} ]; do
    case "${ARGS[$i]}" in
        --vault)
            if [ $((i + 1)) -lt ${#ARGS[@]} ]; then
                VAULT="${ARGS[$((i + 1))]}"
                i=$((i + 2))
            else
                i=$((i + 1))
            fi
            ;;
        --type)
            if [ $((i + 1)) -lt ${#ARGS[@]} ]; then
                TYPE="${ARGS[$((i + 1))]}"
                i=$((i + 2))
            else
                i=$((i + 1))
            fi
            ;;
        *)
            # Everything else is part of the search phrase
            if [ -z "$SEARCH_PHRASE" ]; then
                SEARCH_PHRASE="${ARGS[$i]}"
            else
                SEARCH_PHRASE="$SEARCH_PHRASE ${ARGS[$i]}"
            fi
            i=$((i + 1))
            ;;
    esac
done

# Trim whitespace
SEARCH_PHRASE=$(printf '%s' "$SEARCH_PHRASE" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

# If no search phrase, show empty result
if [ -z "$SEARCH_PHRASE" ]; then
    echo '{"items": []}'
    exit 0
fi

# Get items from pass-cli
ITEMS_JSON=$(pass-cli item list "$VAULT" --filter-type "$TYPE" --output json 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$ITEMS_JSON" ]; then
    echo "{\"items\": [{\"title\": \"Error\", \"subtitle\": \"Failed to retrieve items from vault '$VAULT'\", \"valid\": false}]}"
    exit 0
fi

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

# Search for items matching the search phrase in URLs - EXACT same as ppcc script
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
    password: (.content.content[$type].password // "")
  }
' | jq -s '.')

MATCH_COUNT=$(echo "$MATCHING_ITEMS" | jq 'length')

if [ "$MATCH_COUNT" -eq 0 ]; then
    echo "{\"items\": [{\"title\": \"No items found\", \"subtitle\": \"No items matching \\\"$SEARCH_PHRASE\\\" in vault \\\"$VAULT\\\"\", \"valid\": false}]}"
    exit 0
fi

# Format for Alfred - simplified jq query
echo "$MATCHING_ITEMS" | jq -r --arg vault "$VAULT" --arg type "$TYPE" '
  {
    items: [
      .[] |
      {
        title: .title,
        subtitle: (if (.urls | length) > 0 then ((.urls | join(", ")) + " • Press Cmd to view fields") else ("No URLs" + " • Press Cmd to view fields") end),
        arg: (.id + "|" + $vault + "|" + $type + "|" + (.email // "") + "|" + (.username // "") + "|" + (.password // "") + "|" + (if (.urls | length) > 0 then (.urls[0] // "") else "" end)),
        valid: true,
        text: { copy: .title },
        mods: {
          cmd: {
            arg: (.id + "|" + $vault + "|" + $type + "|" + (.email // "") + "|" + (.username // "") + "|" + (.password // "") + "|" + (if (.urls | length) > 0 then (.urls[0] // "") else "" end)),
            subtitle: ("View fields for: " + .title),
            valid: true
          }
        }
      }
    ]
  }
'
