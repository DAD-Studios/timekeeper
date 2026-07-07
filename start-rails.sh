#!/bin/bash
set -euo pipefail

APP_DIR="/home/joshua/projects/timekeeper"
SESSION_NAME="timekeeper"
BREW_BIN="/home/linuxbrew/.linuxbrew/bin/brew"
ASDF_BREW_SH="/home/linuxbrew/.linuxbrew/opt/asdf/libexec/asdf.sh"
ASDF_HOME_SH="$HOME/.asdf/asdf.sh"
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"

setup_env() {
    export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:$PATH"

    if [ -x "$BREW_BIN" ]; then
        eval "$("$BREW_BIN" shellenv)"
    fi

    if [ -f "$ASDF_BREW_SH" ]; then
        . "$ASDF_BREW_SH"
    elif [ -f "$ASDF_HOME_SH" ]; then
        . "$ASDF_HOME_SH"
    else
        export ASDF_DATA_DIR="${ASDF_DATA_DIR:-$HOME/.asdf}"
        export PATH="$ASDF_DATA_DIR/shims:$PATH"
    fi
}

remove_stale_pid() {
    local pid_file="$APP_DIR/tmp/pids/server.pid"
    local pid
    local command

    [ -f "$pid_file" ] || return 0

    pid="$(cat "$pid_file")"
    if [ -n "$pid" ] && command="$(ps -p "$pid" -o args= 2>/dev/null)" && [[ "$command" =~ (puma|rails[[:space:]]+s|rails[[:space:]]+server) ]]; then
        return 0
    fi

    rm -f "$pid_file"
}

if [ "${1:-}" = "--server" ]; then
    setup_env
    cd "$APP_DIR"
    remove_stale_pid
    exec bin/rails s -b 0.0.0.0
fi

setup_env
cd "$APP_DIR"

if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Timekeeper session already exists"
    echo "Attach with: tmux attach -s $SESSION_NAME"
    exit 0
fi

tmux new-session -d -s "$SESSION_NAME" "$SCRIPT_PATH --server"

sleep 1
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Timekeeper Rails server failed to start"
    exit 1
fi

echo "Timekeeper Rails server started in tmux session '$SESSION_NAME'"
echo "Attach with: tmux attach -s $SESSION_NAME"
