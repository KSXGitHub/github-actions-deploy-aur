#!/bin/bash

set -o errexit -o pipefail -o nounset

echo "::warning ::inputs.filename = $INPUT_FILENAME"
echo "::warning ::GITHUB_WORKSPACE = $GITHUB_WORKSPACE"

echo "Content of $(pwd)"
ls -AR .

echo "Content of $INPUT_FILENAME"
cat the_input_file/input-file.txt
