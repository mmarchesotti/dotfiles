# ==============================================================================
# 1. OH-MY-ZSH CONFIGURATION
# ==============================================================================
export ZSH="$HOME/.oh-my-zsh"

# Theme: We use Starship later, so keep this simple or empty
ZSH_THEME="robbyrussell"

# Plugins: The "Holy Trinity" + git
plugins=(
    git
    zsh-syntax-highlighting
    zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# ==============================================================================
# 2. ENVIRONMENT & EXPORTS (Ported from Omarchy)
# ==============================================================================
export EDITOR="nvim"
export VISUAL="nvim"
export SUDO_EDITOR="$EDITOR"
export BAT_THEME="ansi"

# ==============================================================================
# 3. ALIASES (Ported from Omarchy)
# ==============================================================================
# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# File System (eza replacement for ls)
if (( $+commands[eza] )); then
  alias ls='eza -lh --group-directories-first --icons=auto'
  alias lsa='ls -a'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
fi

# Tools
alias d='docker'
alias r='rails'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
alias v="nvim"

# Git
alias g='git'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'

# Dotfiles (Your custom ones)
alias dotfiles='/usr/bin/git --git-dir=$HOME/dev/.dotfiles/ --work-tree=$HOME'
alias lazydot='lazygit --git-dir=$HOME/dev/.dotfiles --work-tree=$HOME'

# Nvim wrapper
n() { if [ "$#" -eq 0 ]; then nvim .; else nvim "$@"; fi; }

# Open wrapper (xdg-open)
open() { xdg-open "$@" >/dev/null 2>&1 & }

# ==============================================================================
# 4. CUSTOM FUNCTIONS (Ported from Omarchy)
# ==============================================================================
# Compression
compress() { tar -czf "${1%/}.tar.gz" "${1%/}"; }
alias decompress="tar -xzf"

# ISO to SD Card
iso2sd() {
  if [ $# -ne 2 ]; then
    echo "Usage: iso2sd <input_file> <output_device>"
    echo "Example: iso2sd ~/Downloads/ubuntu.iso /dev/sda"
    echo -e "\nAvailable SD cards:"
    lsblk -d -o NAME | grep -E '^sd[a-z]' | awk '{print "/dev/"$1}'
  else
    sudo dd bs=4M status=progress oflag=sync if="$1" of="$2"
    sudo eject $2
  fi
}

# Format Drive (Standardized function for Zsh)
format-drive() {
  if [ $# -ne 2 ]; then
    echo "Usage: format-drive <device> <name>"
    echo "Example: format-drive /dev/sda 'My Stuff'"
    echo -e "\nAvailable drives:"
    lsblk -d -o NAME -n | awk '{print "/dev/"$1}'
  else
    echo "WARNING: This will completely erase all data on $1 and label it '$2'."
    read -q "confirm?Are you sure you want to continue? (y/N): "
    echo "" # Newline after read -q

    if [[ "$confirm" == "y" ]]; then
      sudo wipefs -a "$1"
      sudo dd if=/dev/zero of="$1" bs=1M count=100 status=progress
      sudo parted -s "$1" mklabel gpt
      sudo parted -s "$1" mkpart primary 1MiB 100%

      local partition="$([[ $1 == *"nvme"* ]] && echo "${1}p1" || echo "${1}1")"
      sudo partprobe "$1" || true
      sudo udevadm settle || true
      sudo mkfs.exfat -n "$2" "$partition"
      echo "Drive $1 formatted as exFAT and labeled '$2'."
    fi
  fi
}

# Media Conversion (FFmpeg & ImageMagick)
transcode-video-1080p() {
  ffmpeg -i $1 -vf scale=1920:1080 -c:v libx264 -preset fast -crf 23 -c:a copy ${1%.*}-1080p.mp4
}

transcode-video-4K() {
  ffmpeg -i $1 -c:v libx265 -preset slow -crf 24 -c:a aac -b:a 192k ${1%.*}-optimized.mp4
}

img2jpg() {
  magick "$1" "${@:2}" -quality 95 -strip ${1%.*}-optimized.jpg
}

img2jpg-small() {
  magick "$1" "${@:2}" -resize 1080x\> -quality 95 -strip ${1%.*}-optimized.jpg
}

img2png() {
  magick "$1" "${@:2}" -strip -define png:compression-filter=5 \
    -define png:compression-level=9 \
    -define png:compression-strategy=1 \
    -define png:exclude-chunk=all \
    "${1%.*}-optimized.png"
}

# ==============================================================================
# 5. TOOL INITIALIZATIONS (Zsh Specific)
# ==============================================================================

# Mise (replaces asdf/nvm)
if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
fi

# Zoxide (Better cd)
# Note: Zoxide's zsh init handles the 'cd' alias automatically!
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh --cmd cd)"
fi

# Try
if (( $+commands[try] )); then
  eval "$(try init zsh)"
fi

# FZF
if [ -f /usr/share/fzf/key-bindings.zsh ]; then
    source /usr/share/fzf/key-bindings.zsh
fi
if [ -f /usr/share/fzf/completion.zsh ]; then
    source /usr/share/fzf/completion.zsh
fi

# Starship Prompt (Must be near the end)
if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
fi

# Atuin History (Must be the very last thing)
if (( $+commands[atuin] )); then
    eval "$(atuin init zsh)"
fi

. "$HOME/.local/share/../bin/env"
