#!/bin/bash
set -euo pipefail

# Lista obrazów do zbudowania
IMAGES=("critos")  # Dodaj tu swoje obrazy

# Katalogi lokalne
WORKSPACE=$(pwd)
OUTPUT_DIR="${WORKSPACE}/output"
TEMPLATE_DIR="${WORKSPACE}/installer/lorax_templates"

wget -O ${WORKSPACE}/critos.repo https://raw.githubusercontent.com/CritOS-Linux/critos/refs/heads/main/files/rpm-ostree/critos.repo

# Tworzymy katalogi jeśli nie istnieją
mkdir -p "$OUTPUT_DIR"

for IMAGE in "${IMAGES[@]}"; do
  echo "🔧 Budowanie ISO dla: $IMAGE"

  sudo podman run --rm --privileged \
    --volume "$OUTPUT_DIR":/build-container-installer/build \
    --volume "$WORKSPACE":"$WORKSPACE" \
    ghcr.io/jasonn3/build-container-installer \
    ARCH="x86_64" \
    ENABLE_CACHE_DNF="false" \
    ENABLE_CACHE_SKOPEO="false" \
    ENABLE_FLATPAK_DEPENDENCIES="false" \
    ENROLLMENT_PASSWORD="universalblue" \
    IMAGE_NAME="$IMAGE" \
    IMAGE_REPO="ghcr.io/critos-linux" \
    IMAGE_TAG="latest" \
    ISO_NAME="build/${IMAGE}.iso" \
    VARIANT="Kinoite" \
    VERSION="41" \
    REPOS="${WORKSPACE}/critos.repo /etc/yum.repos.d/fedora.repo /etc/yum.repos.d/fedora-updates.repo"

done

cd "${OUTPUT_DIR}"
sudo chmod 644 *
sudo chown $USER:$USER *

echo "✅ Wszystkie ISO zostały zbudowane i zapisane w $OUTPUT_DIR"
