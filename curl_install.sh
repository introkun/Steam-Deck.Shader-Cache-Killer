#!/bin/bash
#Steam Deck Shader Cache Killer by scawp and rewamped by introkun
#License: DBAD: https://raw.githubusercontent.com/introkun/Steam-Deck.Shader-Cache-Killer-Rewamped/main/LICENSE.md
#Source: https://github.com/introkun/Steam-Deck-Shader.Cache-Killer-Rewamped (original source is here https://github.com/scawp/Steam-Deck-Shader.Cache-Killer)

#stop running script if anything returns an error (non-zero exit)
set -e

repo_url="https://raw.githubusercontent.com/introkun/Steam-Deck.Shader-Cache-Killer/main"

tmp_dir="/tmp/introkun.SDSCK.install"

script_install_dir="/home/deck/.local/share/introkun/SDSCK"

device_name="$(uname --nodename)"
user="$(id -u deck)"

if [ "$device_name" !='' "steamdeck" ] || [ "$user" != "1000" ]; then
  zenity --question --width=400 \
  --text="This code has been written specifically for the Steam Deck with user Deck \
  \nIt appears you are running on a different system/non-standard configuration. \
  \nAre you sure you want to continue?"
  if [ "$?" != 0 ]; then
    #NOTE: This code will never be reached due to "set -e", the system will already exit for us but just incase keep this
    echo "bye then! xxx"
    exit 1;
  fi
fi

function create_desktop_icon () {
  app_name="$1"
  app_description="$2"
  script_name="$3"
  icon_path="$HOME"/Desktop/"$app_name".desktop
  rm -rf "$icon_path" 2>/dev/null

  echo "#!/usr/bin/env xdg-open
  [Desktop Entry]
  Name=$app_description
  Exec=curl $repo_url/$script_name | bash -s --
  Icon=delete
  Terminal=false
  Type=Application
  StartupNotify=false" > "$icon_path"
  chmod +x "$icon_path"
}

function install_zShaderCacheKiller () {
  zenity --question --width=400 \
    --text="Read $repo_url/README.md before proceeding. \
    \nWould you like to add Shader Cache Killer to your Steam Library?"
  if [ "$?" != 0 ]; then
    #NOTE: This code will never be reached due to "set -e", the system will already exit for us but just incase keep this
    echo "bye then! xxx"
    exit 0;
  fi

  killerScriptName="zShaderCacheKiller"
  moverScriptName="zShaderCacheMover"
  killerScriptInstallPath="$script_install_dir/${killerScriptName}Rewamped.sh"
  moverScriptInstallPath="$script_install_dir/${moverScriptName}Rewamped.sh"

  echo "Making tmp folder $tmp_dir"
  mkdir -p "$tmp_dir"

  echo "Making install folder $script_install_dir"
  mkdir -p "$script_install_dir"

  echo "Downloading Required Files"
  curl -o "$tmp_dir/$killerScriptName.sh" "$repo_url/$killerScriptName.sh"
  curl -o "$tmp_dir/$moverScriptName.sh" "$repo_url/$moverScriptName.sh"

  echo "Adding Write Permissions if needed"
  if [ -e "$killerScriptInstallPath" ]; then
    chmod 777 "$killerScriptInstallPath"
  fi
  if [ -e "$moverScriptInstallPath" ]; then
    chmod 777 "$moverScriptInstallPath"
  fi

  echo "Copying $tmp_dir/$killerScriptName.sh to $killerScriptInstallPath"
  cp "$tmp_dir/$killerScriptName.sh" "$killerScriptInstallPath"

  echo "Copying $tmp_dir/$moverScriptName.sh to $moverScriptInstallPath"
  cp "$tmp_dir/$moverScriptName.sh" "$moverScriptInstallPath"

  echo "Adding Execute and Removing Write Permissions"
  chmod 555 "$killerScriptInstallPath"
  chmod 555 "$moverScriptInstallPath"

  echo "Creating Desktop Icons..."
  create_desktop_icon "UninstallZShaderCacheUtilities" "Uninstall zShaderCacheUtilities" "uninstall.sh"

  update-desktop-database ~/.local/share/applications

  echo "Adding to Steam Library..."
  set +e
  zenity --info --width=400 --text="Adding cache killer script to Steam" --timeout=1
  add_killer="$(steamos-add-to-steam "$killerScriptInstallPath")"
  zenity --info --width=400 --text="Adding cache mover script to Steam (5 sec delay)" --timeout=5
  add_mover="$(steamos-add-to-steam "$moverScriptInstallPath")"
}

install_zShaderCacheKiller

echo "Done."
