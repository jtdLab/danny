#!/bin/bash
# Runs `mason bundle` to generate bundles for all bricks within the top level bricks directory.

if [[ "$1" == "--local" ]]; then
    # Command Brick
    mason bundle bricks/command -t dart -o packages/danny_cli/lib/src/commands/new/templates

    # Command Runner Brick
    mason bundle bricks/command_runner -t dart -o packages/danny_cli/lib/src/commands/build/templates

    # Project Brick
    mason bundle bricks/project -t dart -o packages/danny_cli/lib/src/commands/create/templates
else
    # Command Brick
    mason bundle -s git https://github.com/jtdLab/danny --git-path bricks/command -t dart -o packages/danny_cli/lib/src/commands/new/templates

    # Command Runner Brick
    mason bundle -s git https://github.com/jtdLab/danny --git-path bricks/command_runner -t dart -o packages/danny_cli/lib/src/commands/build/templates

    # Project Brick
    mason bundle -s git https://github.com/jtdLab/danny --git-path bricks/project -t dart -o packages/danny_cli/lib/src/commands/create/templates
fi

dart format ./packages/danny_cli
