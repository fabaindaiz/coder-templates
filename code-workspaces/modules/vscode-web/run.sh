#!/usr/bin/env bash

EXTENSIONS=("${EXTENSIONS}")
BOLD='\033[0;1m'
CODE='\033[36;40;1m'
RESET='\033[0m'

printf "$${BOLD}Installing vscode-cli!\n"

sudo apt install -y libasound2 libatk-bridge2.0-0 libatk1.0-0 libatspi2.0-0 libcairo2 libdrm2 libgbm1 libgtk-3-0 libnspr4 libnss3 libpango-1.0-0 libsecret-1-0 libxcomposite1 libxdamage1 libxfixes3 libxkbcommon0 libxkbfile1 libxrandr2 xdg-utils
output=$(curl -L 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' --output /tmp/code.deb && sudo dpkg -i /tmp/code.deb && sudo apt-get install -f -y)
if [ $? -ne 0 ]; then
  echo "Failed to install vscode-cli: $output"
  exit 1
fi
printf "🥳 vscode-web has been installed.\n\n"

CODE_SERVER="code"

# Install each extension...
IFS=',' read -r -a EXTENSIONLIST <<< "$${EXTENSIONS}"
for extension in "$${EXTENSIONLIST[@]}"; do
  if [ -z "$extension" ]; then
    continue
  fi
  printf "🧩 Installing extension $${CODE}$extension$${RESET}...\n"
  output=$($CODE_SERVER --extensions-dir=$HOME/.vscode-server/extensions --install-extension "$extension")
  if [ $? -ne 0 ]; then
    echo "Failed to install extension: $extension: $output"
    exit 1
  fi
done

echo "👷 Running $CODE_SERVER serve-web --disable-telemetry --port ${PORT} --without-connection-token --accept-server-license-terms in the background..."
echo "Check logs at ${LOG_PATH}!"
$CODE_SERVER serve-web --disable-telemetry --port ${PORT} --without-connection-token --accept-server-license-terms >${LOG_PATH} 2>&1 &
