#!/usr/bin/env bash
set -euo pipefail

# Debian/GNOME desktop setup for react-carplay.
#
# This script intentionally does NOT create an autostart entry.
# It installs a local AppImage into ~/Applications and creates a normal
# desktop launcher so the app can be started manually from GNOME.
#
# Usage:
#   ./setup-pi.sh [path/to/react-carplay.AppImage]
#
# If no AppImage path is supplied, the script searches ./dist/*.AppImage.

APP_NAME="React CarPlay"
APP_ID="react-carplay"
INSTALL_DIR="${HOME}/Applications"
INSTALL_PATH="${INSTALL_DIR}/ReactCarPlay.AppImage"
DESKTOP_FILE="${HOME}/.local/share/applications/${APP_ID}.desktop"
ICON_SOURCE="$(pwd)/build/icon.png"
ICON_DIR="${HOME}/.local/share/icons/hicolor/512x512/apps"
ICON_PATH="${ICON_DIR}/${APP_ID}.png"
UDEV_RULE="/etc/udev/rules.d/52-nodecarplay.rules"

info() {
  echo "==> $*"
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

detect_appimage() {
  if [[ $# -gt 0 && -n "${1:-}" ]]; then
    [[ -f "$1" ]] || fail "AppImage not found: $1"
    echo "$1"
    return
  fi

  local detected
  detected="$(find ./dist -maxdepth 1 -type f -name '*.AppImage' 2>/dev/null | sort | tail -n 1 || true)"
  [[ -n "$detected" ]] || fail "No AppImage found. Build one first with: npm install && npm run build:linux"
  echo "$detected"
}

install_package_if_available() {
  local package="$1"

  if dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q "install ok installed"; then
    return
  fi

  if apt-cache show "$package" >/dev/null 2>&1; then
    info "Installing package: $package"
    sudo apt-get install --yes "$package"
  fi
}

ensure_runtime_packages() {
  info "Installing desktop/AppImage runtime packages when available"
  sudo apt-get update
  install_package_if_available "desktop-file-utils"
  install_package_if_available "libnss3"
  install_package_if_available "libxss1"
  install_package_if_available "libatk-bridge2.0-0"
  install_package_if_available "libgtk-3-0"

  # Electron AppImage needs FUSE 2. Debian releases vary between libfuse2 and
  # libfuse2t64, so try both package names.
  install_package_if_available "libfuse2"
  install_package_if_available "libfuse2t64"
}

install_udev_rules() {
  info "Creating udev rules for CPC200-CCPA / Carlinkit dongle"
  sudo tee "$UDEV_RULE" >/dev/null <<'EOF'
# CPC200-CCPA / Carlinkit dongle. Allows the active desktop user to access it.
SUBSYSTEM=="usb", ATTR{idVendor}=="1314", ATTR{idProduct}=="1520", MODE="0660", GROUP="plugdev", TAG+="uaccess"
SUBSYSTEM=="usb", ATTR{idVendor}=="1314", ATTR{idProduct}=="1521", MODE="0660", GROUP="plugdev", TAG+="uaccess"
EOF

  sudo udevadm control --reload-rules
  sudo udevadm trigger
}

install_appimage() {
  local source_appimage="$1"

  info "Installing AppImage"
  mkdir -p "$INSTALL_DIR"
  cp "$source_appimage" "$INSTALL_PATH"
  chmod +x "$INSTALL_PATH"
}

install_icon() {
  if [[ -f "$ICON_SOURCE" ]]; then
    info "Installing desktop icon"
    mkdir -p "$ICON_DIR"
    cp "$ICON_SOURCE" "$ICON_PATH"
  else
    info "No icon found at $ICON_SOURCE; launcher will use the default app icon"
    ICON_PATH="$APP_ID"
  fi
}

install_desktop_launcher() {
  info "Creating GNOME desktop launcher"
  mkdir -p "$(dirname "$DESKTOP_FILE")"

  cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=${APP_NAME}
Comment=CarPlay for CPC200-CCPA
Exec=${INSTALL_PATH}
Icon=${ICON_PATH}
Terminal=false
Categories=AudioVideo;Utility;
StartupNotify=true
EOF

  chmod +x "$DESKTOP_FILE"

  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "${HOME}/.local/share/applications" || true
  fi
}

main() {
  local source_appimage
  source_appimage="$(detect_appimage "${1:-}")"

  ensure_runtime_packages
  install_udev_rules
  install_appimage "$source_appimage"
  install_icon
  install_desktop_launcher

  info "Done"
  echo
  echo "Installed app: ${INSTALL_PATH}"
  echo "Launcher:      ${DESKTOP_FILE}"
  echo
  echo "Unplug and replug the CPC200-CCPA dongle before launching the app."
  echo "Start it from GNOME as: ${APP_NAME}"
}

main "$@"
