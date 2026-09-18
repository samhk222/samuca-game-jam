#!/bin/sh

set -eu

REPO_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
if [ "$(basename "$REPO_ROOT")" = "lib" ]; then
	REPO_ROOT=$(dirname "$REPO_ROOT")
fi

# shellcheck disable=SC1091
. "$REPO_ROOT/tools/versions.env"

TOOLS_DIR="$REPO_ROOT/.tools"
NODE_DIR="$TOOLS_DIR/node"
MCP_DIR="$TOOLS_DIR/godot-mcp"

export PATH="$NODE_DIR/bin:$PATH"

case "$(uname -s)" in
	Darwin)
		GODOT_BIN="$TOOLS_DIR/godot/Godot.app/Contents/MacOS/Godot"
		GODOT_SELF_CONTAINED_DIR="$TOOLS_DIR/godot"
		;;
	Linux)
		GODOT_BIN="$TOOLS_DIR/godot/godot"
		GODOT_SELF_CONTAINED_DIR="$TOOLS_DIR/godot"
		;;
	*)
		echo "Unsupported operating system: $(uname -s)" >&2
		exit 1
		;;
esac

GODOT_EDITOR_DATA="$GODOT_SELF_CONTAINED_DIR/editor_data"
GODOT_TEMPLATE_DIR="$GODOT_EDITOR_DATA/export_templates/$GODOT_VERSION.$GODOT_STATUS"
export GODOT_PATH="$GODOT_BIN"
