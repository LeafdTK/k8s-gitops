#!/bin/bash
# macOS Cluster Tools Installer Script
# This script installs various utilities for configuring and accessing a Kubernetes cluster.

set -e  # Exit immediately if a command exits with a non-zero status

# Print with colors for better visibility
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}==== Installing Cluster Management Tools for macOS ====${NC}"
echo "These utilities are used for configuring and accessing the cluster."
echo "They are intended to be installed on a workstation, not a node in the cluster."
echo

# Helper function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Helper function to install tools
install_tool() {
  local name="$1"
  local install_cmd="$2"
  local check_cmd="$3"
  
  echo -e "${BLUE}Installing $name...${NC}"
  
  if command_exists "$check_cmd"; then
    echo -e "${GREEN}$name is already installed.${NC}"
  else
    echo "Installing $name..."
    eval "$install_cmd"
    if command_exists "$check_cmd"; then
      echo -e "${GREEN}$name installed successfully.${NC}"
    else
      echo -e "${RED}Failed to install $name.${NC}"
      exit 1
    fi
  fi
  echo
}

# Ensure homebrew is installed
if ! command_exists brew; then
  echo -e "${RED}Homebrew is not installed. Installing it now...${NC}"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install age
install_tool "age" "brew install age" "age"

# Install flux CLI
install_tool "flux" "HOMEBREW_NO_AUTO_UPDATE=1 bash -c 'curl -s https://fluxcd.io/install.sh | bash'" "flux"

# Install kubectl
install_tool "kubectl" "brew install kubectl" "kubectl"

# Install kustomize
install_tool "kustomize" "brew install kustomize" "kustomize"

# Install SOPS
install_tool "sops" "brew install sops" "sops"

# Configure sops-differ for git
echo -e "${BLUE}Configuring sops-differ for git...${NC}"
if grep -A 1 sopsdiffer .git/config >/dev/null 2>&1; then
  echo -e "${GREEN}sops-differ is already configured in git.${NC}"
else
  git config diff.sopsdiffer.textconv "sops -d"
  echo -e "${GREEN}sops-differ configured successfully.${NC}"
fi
echo

# Install talosctl
install_tool "talosctl" "curl -sL https://talos.dev/install | sh" "talosctl"

# Install talhelper
install_tool "talhelper" "curl https://i.jpillora.com/budimanjojo/talhelper! | bash" "talhelper"

echo -e "${GREEN}==== All tools have been installed successfully! ====${NC}"
echo "You are now ready to configure and access your cluster."