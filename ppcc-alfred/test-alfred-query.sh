#!/bin/bash

# Test what happens when Alfred passes a query
# Simulate: user types "ppcc github" in Alfred
# Alfred should pass "github" as $1

echo "Testing with query: 'github'"
echo "---"
cd "$(dirname "$0")"
./search.sh github

echo ""
echo "---"
echo "Testing with query: '--vault Work github'"
./search.sh --vault Work github

echo ""
echo "---"
echo "Testing with empty query (what Alfred might pass initially)"
./search.sh ""
