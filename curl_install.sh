#!/bin/bash
#Steam Deck Shader Cache Killer by scawp and rewamped by introkun
#License: DBAD: https://github.com/intokun/Steam-Deck.Shader-Cache-Killer/blob/main/LICENSE.md
#Source: https://github.com/introkun/Steam-Deck-Shader.Cache-Killer (original source is here https://github.com/scawp/Steam-Deck-Shader.Cache-Killer)

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

function install_zShaderCacheKiller () {
  zenity --question --width=400 \
    --text="Read $repo_url/README.md before proceeding. \
    \nWould you like to add Shader Cache Killer to your Steam Library?"
  if [ "$?" != 0 ]; then
    #NOTE: This code will never be reached due to "set -e", the system will already exit for us but just incase keep this
    echo "bye then! xxx"
    exit 0;
  fi

  killerScriptName="zShaderCacheKillerRewamped.sh"
  moverScriptName="zShaderCacheMoverRewamped.sh"
  killerScriptInstallPath="$script_install_dir/$killerScriptName"
  moverScriptInstallPath="$script_install_dir/$moverScriptName"

  echo "Making tmp folder $tmp_dir"
  mkdir -p "$tmp_dir"

  echo "Making install folder $script_install_dir"
  mkdir -p "$script_install_dir"

  echo "Downloading Required Files"
  curl -o "$tmp_dir/$killerScriptName" "$repo_url/$killerScriptName"
  curl -o "$tmp_dir/$moverScriptName" "$repo_url/$moverScriptName"

  echo "Copying $tmp_dir/$killerScriptName to $killerScriptInstallPath"
  cp "$tmp_dir/$killerScriptName" "$killerScriptInstallPath"

  echo "Copying $tmp_dir/$moverScriptName to $moverScriptInstallPath"
  cp "$tmp_dir/$moverScriptName" "$moverScriptInstallPath"

  echo "Adding Execute and Removing Write Permissions"
  chmod 555 "$killerScriptInstallPath"
  chmod 555 "$moverScriptInstallPath"

  add_killer="$(steamos-add-to-steam "$killerScriptInstallPath")"
  sleep 2;
  add_mover="$(steamos-add-to-steam "$moverScriptInstallPath")"

}

install_zShaderCacheKiller

echo "Done."
