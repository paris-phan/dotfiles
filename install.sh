#!/bin/bash
# Set up a Mac from this repo. Safe to re-run.
#
#   ./install.sh                         core only
#   ./install.sh work mobile             core plus opt-in groups
#   ./install.sh work --force-dotfiles   flags are passed to `mise bootstrap`
#
# Order: Xcode Command Line Tools, Homebrew, Brewfiles, then `mise bootstrap`
# for config files, macOS settings and the login shell.
set -euo pipefail

cd "$(dirname "$0")"

step() { printf '\n==> %s\n' "$1"; }
warn() { printf '  ! %s\n' "$1" >&2; }

groups=()
mise_args=()
for arg in "$@"; do
  case "$arg" in
    -*) mise_args+=("$arg") ;;
    *)
      if [ ! -f "Brewfile.$arg" ]; then
        available=$(find . -maxdepth 1 -name 'Brewfile.*' | sed 's|^\./Brewfile\.||' | sort | tr '\n' ' ')
        echo "Unknown group '$arg'. Available: $available" >&2
        exit 2
      fi
      groups+=("$arg")
      ;;
  esac
done

step "Xcode Command Line Tools"
if xcode-select -p >/dev/null 2>&1; then
  echo "  Already installed."
else
  xcode-select --install
  echo "  Finish the installer that just opened, then run this script again."
  exit 1
fi

step "Homebrew"
if [ -x /opt/homebrew/bin/brew ]; then
  echo "  Already installed."
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# Homebrew will not load a formula or cask from a third-party tap until it is
# trusted. Listing one in a Brewfile is the decision to trust it, so trust
# exactly those entries (not the whole tap).
trust_tap_entries() {
  local kind name flag
  while read -r kind name; do
    [ -n "$name" ] || continue
    if [ "$kind" = cask ]; then flag=--cask; else flag=--formula; fi
    brew tap "${name%/*}"
    brew trust "$flag" "$name"
  done < <(sed -nE 's|^(brew\|cask) "([^"/]+/[^"/]+/[^"]+)".*|\1 \2|p' "$1")
}

# One failed package should not block the rest of the setup.
failed=()
bundle() {
  step "Packages: $1"
  if ! trust_tap_entries "$1"; then
    warn "Could not trust a tap entry in $1; brew bundle may skip it."
  fi
  if ! brew bundle --file "$1"; then
    failed+=("$1")
    warn "brew bundle reported failures for $1; continuing."
  fi
}

bundle Brewfile
for group in ${groups[@]+"${groups[@]}"}; do
  bundle "Brewfile.$group"
done

step "Config files, macOS settings and login shell"
if ! command -v mise >/dev/null 2>&1; then
  echo "mise is not installed; fix the Brewfile failure above and re-run." >&2
  exit 1
fi
mise trust --quiet mise.toml
mise bootstrap ${mise_args[@]+"${mise_args[@]}"}

echo
if [ ${#failed[@]} -eq 0 ]; then
  echo "Done."
else
  echo "Done, with package failures in: ${failed[*]}"
  echo "Fix the errors above and re-run this script."
fi
echo "Log out and back in so the login shell and macOS settings take effect."
echo "Then work through the checklist in README.md."
