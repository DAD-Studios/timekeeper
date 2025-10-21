#!/bin/bash
cd /home/joshua/projects/timekeeper

# Set base PATH
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:$PATH"

# Load Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Load asdf
. /home/linuxbrew/.linuxbrew/opt/asdf/libexec/asdf.sh

# Prefer system binaries first
export PATH="/usr/bin:/usr/local/bin:/bin:/usr/sbin:/usr/local/sbin:/sbin:$PATH"

# Check if tmux session already exists
if tmux has-session -t timekeeper 2>/dev/null; then
    echo "Timekeeper session already exists"
    exit 0
fi

# Start tmux session with the same environment setup
tmux new-session -d -s timekeeper "
export PATH=\"/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:\$PATH\" && \
eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\" && \
. /home/linuxbrew/.linuxbrew/opt/asdf/libexec/asdf.sh && \
export PATH=\"/usr/bin:/usr/local/bin:/bin:/usr/sbin:/usr/local/sbin:/sbin:\$PATH\" && \
cd /home/joshua/projects/timekeeper && \
bin/rails s -b 0.0.0.0
"

echo "Timekeeper Rails server started in tmux session 'timekeeper'"
echo "Attach with: tmux attach -s timekeeper"