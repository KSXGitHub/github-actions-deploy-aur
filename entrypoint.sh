#!/bin/bash

set -o errexit -o pipefail -o nounset

echo "::warning ::inputs.filename = $INPUT_FILENAME"
echo "::warning ::GITHUB_WORKSPACE = $GITHUB_WORKSPACE"

echo "Content of $(pwd)"
ls .

echo "Content of $INPUT_FILENAME"
cat "$INPUT_FILENAME"

echo "Number of lines of inputs.paragraph"
echo "$INPUT_PARAGRAPH" | wc -l

echo "Content of inputs.paragraph"
echo "$INPUT_PARAGRAPH" | while read -r line; do
  echo 'line>' "$line"
done
