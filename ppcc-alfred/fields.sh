#!/bin/bash

# Alfred script filter for ppcc - shows fields for a selected item
# Usage: fields.sh ITEM_ID|VAULT|TYPE|EMAIL|USERNAME|PASSWORD|URL

set +euo pipefail

# Parse the argument (format: ITEM_ID|VAULT|TYPE|EMAIL|USERNAME|PASSWORD|URL)
if [ -z "${1:-}" ]; then
    echo '{"items": [{"title": "Error", "subtitle": "No item data provided", "valid": false}]}'
    exit 0
fi

IFS='|' read -r ITEM_ID VAULT TYPE EMAIL USERNAME PASSWORD URL <<< "$1"

# Build Alfred items for each available field
ITEMS="[]"

if [ -n "$EMAIL" ] && [ "$EMAIL" != "null" ] && [ "$EMAIL" != "" ]; then
    ITEMS=$(echo "$ITEMS" | jq --arg email "$EMAIL" '. += [{
      title: "Email: " + $email,
      subtitle: "Press Enter to copy email to clipboard",
      arg: $email,
      valid: true,
      icon: { type: "fileicon", path: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/Mail.icns" }
    }]' 2>/dev/null || echo "$ITEMS")
fi

if [ -n "$USERNAME" ] && [ "$USERNAME" != "null" ] && [ "$USERNAME" != "" ]; then
    ITEMS=$(echo "$ITEMS" | jq --arg username "$USERNAME" '. += [{
      title: "Username: " + $username,
      subtitle: "Press Enter to copy username to clipboard",
      arg: $username,
      valid: true,
      icon: { type: "fileicon", path: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/UserIcon.icns" }
    }]' 2>/dev/null || echo "$ITEMS")
fi

if [ -n "$PASSWORD" ] && [ "$PASSWORD" != "null" ] && [ "$PASSWORD" != "" ]; then
    ITEMS=$(echo "$ITEMS" | jq --arg password "$PASSWORD" '. += [{
      title: "Password: [hidden]",
      subtitle: "Press Enter to copy password to clipboard",
      arg: $password,
      valid: true,
      icon: { type: "fileicon", path: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/LockedIcon.icns" }
    }]' 2>/dev/null || echo "$ITEMS")
fi

if [ -n "$URL" ] && [ "$URL" != "null" ] && [ "$URL" != "" ]; then
    ITEMS=$(echo "$ITEMS" | jq --arg url "$URL" '. += [{
      title: "URL: " + $url,
      subtitle: "Press Enter to copy URL to clipboard",
      arg: $url,
      valid: true,
      icon: { type: "fileicon", path: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/BookmarkIcon.icns" }
    }]' 2>/dev/null || echo "$ITEMS")
fi

# If no fields available
FIELD_COUNT=$(echo "$ITEMS" | jq -r 'length // 0' 2>/dev/null || echo "0")
if [ "$FIELD_COUNT" -eq 0 ]; then
    ITEMS='[{"title": "No fields available", "subtitle": "This item has no available fields", "valid": false}]'
fi

echo "{\"items\": $ITEMS}"
