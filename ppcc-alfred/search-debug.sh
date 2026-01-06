#!/bin/bash

# Debug version - logs to file
DEBUG_LOG="$HOME/ppcc-debug.log"

echo "=== $(date) ===" >> "$DEBUG_LOG"
echo "All args: $*" >> "$DEBUG_LOG"
echo "Arg count: $#" >> "$DEBUG_LOG"
for i in "$@"; do
    echo "  Arg[$i]: '$i'" >> "$DEBUG_LOG"
done

# Call the real script
"$(dirname "$0")/search.sh" "$@" 2>&1 | tee -a "$DEBUG_LOG"
