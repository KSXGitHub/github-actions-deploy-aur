#!/bin/bash

set -o errexit -o pipefail -o nounset

echo "::warning ::inputs.filename = $INPUT_FILENAME"
echo "::warning ::GITHUB_WORKSPACE = $GITHUB_WORKSPACE"

echo "Content of $(pwd)"
ls .

echo "Content of $INPUT_FILENAME"
cat "$INPUT_FILENAME"

echo "Content of inputs.paragraph"
echo "$INPUT_PARAGRAPH"
