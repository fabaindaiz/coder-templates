#!/usr/bin/env bash

EXTENSIONS=("${EXTENSIONS}")
BOLD='\033[0;1m'
CODE='\033[36;40;1m'
RESET='\033[0m'

# Create install directory if it doesn't exist
mkdir -p ${INSTALL_DIR}

printf "$${BOLD}Installing vscode-cli!\n"

# Download and extract code-cli tarball
output=$(curl -L 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' --output /tmp/code.deb && sudo dpkg -i /tmp/code.deb && sudo apt-get install -f -y)
if [ $? -ne 0 ]; then
  echo "Failed to install vscode-cli: $output"
  exit 1
fi
printf "🥳 vscode-web has been installed.\n\n"

CODE_SERVER="${INSTALL_DIR}/code"

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

echo "👷 Running ${INSTALL_DIR}/bin/code serve-web --port ${PORT} --without-connection-token --accept-server-license-terms in the background..."
echo "Check logs at ${LOG_PATH}!"
$CODE_SERVER serve-web --disable-telemetry --port ${PORT} --without-connection-token --accept-server-license-terms >${LOG_PATH} 2>&1 &
