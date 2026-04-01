#!/bin/bash
# =============================================================================
# macOS System Defaults
# Run: source ~/Github/dotfiles/defaults.sh
# =============================================================================

echo "Applying macOS defaults..."
osascript -e 'tell application "System Preferences" to quit' 2>/dev/null
osascript -e 'tell application "System Settings" to quit' 2>/dev/null

# --- Appearance --------------------------------------------------------------
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
defaults write NSGlobalDomain AppleMiniaturizeOnDoubleClick -bool false

# --- Keyboard ----------------------------------------------------------------
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# --- Mouse -------------------------------------------------------------------
defaults write NSGlobalDomain com.apple.mouse.linear -bool true

# --- Dock --------------------------------------------------------------------
defaults write com.apple.dock tilesize -int 41
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.3
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock minimize-to-application -bool true
defaults write com.apple.dock mru-spaces -bool false

# Hot corners: bottom-right = Quick Note (14)
defaults write com.apple.dock wvous-br-corner -int 14
defaults write com.apple.dock wvous-br-modifier -int 0

# --- Finder ------------------------------------------------------------------
defaults write com.apple.finder FXPreferredViewStyle -string "icnv"
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
defaults write com.apple.finder NewWindowTarget -string "PfHm"

# --- Screenshots -------------------------------------------------------------
mkdir -p "${HOME}/Screenshots"
defaults write com.apple.screencapture location -string "${HOME}/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

# --- Menu Bar Clock ----------------------------------------------------------
defaults write com.apple.menuextra.clock ShowSeconds -bool true
defaults write com.apple.menuextra.clock ShowAMPM -bool true
defaults write com.apple.menuextra.clock ShowDate -int 0
defaults write com.apple.menuextra.clock ShowDayOfWeek -bool true

# --- Misc --------------------------------------------------------------------
# Expand save/open dialogs by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Don't warn when opening downloaded files
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Don't save to iCloud by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Prevent .DS_Store on network and USB drives
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Safari: enable developer menu
defaults write com.apple.Safari IncludeDevelopMenu -bool true

# TextEdit: plain text by default
defaults write com.apple.TextEdit RichText -int 0

# Print: quit when finished
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# --- Power Management (Mac Mini) --------------------------------------------
# These require sudo; skip if not available
if sudo -n true 2>/dev/null; then
  sudo pmset -a displaysleep 10
  sudo pmset -a sleep 1
  sudo pmset -a disksleep 10
  sudo pmset -a womp 1          # Wake on LAN
  sudo pmset -a powernap 1
  echo "  Applied power management settings."
else
  echo "  Skipping power settings (requires sudo)."
fi

# --- Apply -------------------------------------------------------------------
for app in "Dock" "Finder" "SystemUIServer"; do
  killall "${app}" &>/dev/null
done
echo "Done. Some changes require logout/restart."
