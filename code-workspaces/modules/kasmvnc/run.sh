#!/usr/bin/env bash

BOLD='\033[0;1m'
CODE='\033[36;40;1m'
RESET='\033[0m'

printf "$${BOLD}Installing kasmvnc!\n"

sudo apt install -y libgbm1 libgl1 libxcursor1 libxfixes3 libxfont2 libxrandr2 libxshmfence1 libxtst6 ssl-cert xauth x11-xkb-utils xkb-data libswitch-perl libyaml-tiny-perl libhash-merge-simple-perl liblist-moreutils-perl libtry-tiny-perl libdatetime-timezone-perl >/dev/null
sudo apt install -y dbus-x11 xvfb xfwm4 libupower-glib3 upower xfce4 xfce4-goodies xfce4-terminal xfce4-panel xfce4-session >/dev/null

sudo apt remove -y xfce4-battery-plugin xfce4-power-manager-plugins xfce4-pulseaudio-plugin light-locker

output=$(sudo curl -L "https://github.com/kasmtech/KasmVNC/releases/download/v1.2.0/kasmvncserver_bookworm_1.2.0_amd64.deb" --output /tmp/kasm.deb && sudo dpkg -i /tmp/kasm.deb && sudo apt-get install -f -y)
if [ $? -ne 0 ]; then
  echo "Failed to install kasmvnc: $output"
  exit 1
fi
printf "🥳 kasmvnc has been installed.\n\n"

KASMVNC_SERVER="kasmvncserver"

# Initialize the Xvfb display
#sudo sed -i 's/^allowed_users=.*/allowed_users=anybody/' /etc/X11/Xwrapper.config
echo "coder:$5$root$5g9u2JOfNYQBraXBdyKxTAxOOLiDy7f0l3ORZsF4Dx/:w" | sudo tee -a /root/.kasmpasswd
sudo vncpasswd -u coder -rwn

echo "👷 Running $KASMVNC_SERVER -disableBasicAuth -select-de xfce in the background..."
echo "Check logs at ${LOG_PATH}!"
sudo $KASMVNC_SERVER -disableBasicAuth -select-de xfce >${LOG_PATH} 2>&1 &
