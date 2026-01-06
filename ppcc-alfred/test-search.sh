#!/bin/bash

# Test script to debug search.sh
# Usage: ./test-search.sh SEARCH_PHRASE

echo "Testing search.sh with query: $*"
echo "---"

# Test basic search
echo "Test 1: Basic search"
./search.sh "$@" 2>&1

echo ""
echo "---"
echo "Test 2: Check if pass-cli works"
pass-cli item list Work --filter-type login --output json 2>&1 | head -20

echo ""
echo "---"
echo "Test 3: Check jq"
which jq
jq --version
