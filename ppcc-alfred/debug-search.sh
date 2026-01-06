#!/bin/bash

# Debug version of search.sh that logs to a file
# This helps debug what Alfred is passing

DEBUG_FILE="$HOME/ppcc-alfred-debug.log"

echo "=== $(date) ===" >> "$DEBUG_FILE"
echo "Args received: $*" >> "$DEBUG_FILE"
echo "Arg count: $#" >> "$DEBUG_FILE"
for i in "$@"; do
    echo "  Arg: '$i'" >> "$DEBUG_FILE"
done

# Call the actual search script and capture output
OUTPUT=$("$(dirname "$0")/search.sh" "$@" 2>&1)
EXIT_CODE=$?

echo "Exit code: $EXIT_CODE" >> "$DEBUG_FILE"
echo "Output length: ${#OUTPUT}" >> "$DEBUG_FILE"
echo "Output (first 500 chars): ${OUTPUT:0:500}" >> "$DEBUG_FILE"
echo "" >> "$DEBUG_FILE"

# Output the result to Alfred
echo "$OUTPUT"
exit $EXIT_CODE
