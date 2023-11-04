#!/usr/bin/env bash

BOLD='\033[0;1m'
CODE='\033[36;40;1m'
RESET='\033[0m'

printf "$${BOLD}Installing kasmvnc!\n"

sudo apt install -y libgbm1 libgl1 libxcursor1 libxfixes3 libxfont2 libxrandr2 libxshmfence1 libxtst6 xauth x11-xkb-utils xkb-data libswitch-perl libyaml-tiny-perl libhash-merge-simple-perl liblist-moreutils-perl libtry-tiny-perl libdatetime-timezone-perl >/dev/null 2>&1
sudo apt install -y dbus-x11 xvfb xfwm4 libupower-glib3 upower xfce4 xfce4-goodies xfce4-terminal xfce4-panel xfce4-session >/dev/null 2>&1
sudo apt remove -y xfce4-battery-plugin xfce4-power-manager-plugins xfce4-pulseaudio-plugin light-locker >/dev/null 2>&1

output=$(sudo curl -L "https://github.com/kasmtech/KasmVNC/releases/download/v1.2.0/kasmvncserver_bookworm_1.2.0_amd64.deb" --output /tmp/kasm.deb && sudo dpkg -i /tmp/kasm.deb && sudo apt-get install -f -y)
if [ $? -ne 0 ]; then
  echo "Failed to install kasmvnc: $output"
  exit 1
fi
printf "🥳 kasmvnc has been installed.\n\n"

KASMVNC_SERVER="kasmvncserver"

# Configure browser
sudo apt install -y chromium >/dev/null 2>&1
sudo sed -i 's|Exec=exo-open --launch WebBrowser %u|Exec=exo-open --launch WebBrowser %u --no-sandbox|' /usr/share/applications/xfce4-web-browser.desktop

# Configure kasmvnc
echo "kasm:$5$kasm$IotFVKEV2Tyazr618kdcy3zjlgJWc3A55pGDwVwRZL6:w" > .kasmpasswd
vncpasswd -u kasm -rwn

echo "👷 Running $KASMVNC_SERVER -disableBasicAuth -select-de xfce in the background..."
echo "Check logs at ${LOG_PATH}!"
$KASMVNC_SERVER -disableBasicAuth -select-de xfce >${LOG_PATH} 2>&1 &
