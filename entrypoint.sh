#!/bin/bash

set -o errexit -o pipefail -o nounset

echo "::warning ::inputs.filename = $INPUT_FILENAME"
echo "::warning ::GITHUB_WORKSPACE = $GITHUB_WORKSPACE"

echo "Displaying content of $INPUT_FILENAME"
cat /input_file
