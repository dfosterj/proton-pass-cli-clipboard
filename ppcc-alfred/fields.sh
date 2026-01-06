#!/bin/bash

# Alfred script filter for ppcc - shows fields for a selected item
# Usage: fields.sh ITEM_ID|VAULT|TYPE|EMAIL|USERNAME|PASSWORD|URL

set -euo pipefail

# Parse the argument (format: ITEM_ID|VAULT|TYPE|EMAIL|USERNAME|PASSWORD|URL)
IFS='|' read -r ITEM_ID VAULT TYPE EMAIL USERNAME PASSWORD URL <<< "$1"

# Build Alfred items for each available field
ITEMS="[]"

if [ -n "$EMAIL" ] && [ "$EMAIL" != "null" ]; then
    ITEMS=$(echo "$ITEMS" | jq --arg email "$EMAIL" '. += [{
      title: "Email: " + $email,
      subtitle: "Press Enter to copy email to clipboard",
      arg: $email,
      valid: true,
      icon: { type: "fileicon", path: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/Mail.icns" }
    }]')
fi

if [ -n "$USERNAME" ] && [ "$USERNAME" != "null" ]; then
    ITEMS=$(echo "$ITEMS" | jq --arg username "$USERNAME" '. += [{
      title: "Username: " + $username,
      subtitle: "Press Enter to copy username to clipboard",
      arg: $username,
      valid: true,
      icon: { type: "fileicon", path: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/UserIcon.icns" }
    }]')
fi

if [ -n "$PASSWORD" ] && [ "$PASSWORD" != "null" ]; then
    ITEMS=$(echo "$ITEMS" | jq '. += [{
      title: "Password: [hidden]",
      subtitle: "Press Enter to copy password to clipboard",
      arg: "'"$PASSWORD"'",
      valid: true,
      icon: { type: "fileicon", path: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/LockedIcon.icns" }
    }]')
fi

if [ -n "$URL" ] && [ "$URL" != "null" ]; then
    ITEMS=$(echo "$ITEMS" | jq --arg url "$URL" '. += [{
      title: "URL: " + $url,
      subtitle: "Press Enter to copy URL to clipboard",
      arg: $url,
      valid: true,
      icon: { type: "fileicon", path: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/BookmarkIcon.icns" }
    }]')
fi

# If no fields available
if [ "$(echo "$ITEMS" | jq 'length')" -eq 0 ]; then
    ITEMS='[{"title": "No fields available", "subtitle": "This item has no available fields", "valid": false}]'
fi

echo "{\"items\": $ITEMS}"
