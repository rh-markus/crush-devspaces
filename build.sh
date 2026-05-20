#!/bin/bash
set -euo pipefail

QUAY_USERNAME="${1:-}"

if [ -z "$QUAY_USERNAME" ]; then
  echo "Usage: $0 <quay-username>"
  echo ""
  echo "Example:"
  echo "  $0 myusername"
  exit 1
fi

IMAGE_NAME="quay.io/${QUAY_USERNAME}/crush-devspaces:latest"

echo "Building container image..."
podman build -t "$IMAGE_NAME" -f Containerfile .

echo ""
echo "Image built successfully: $IMAGE_NAME"
echo ""
read -p "Push to Quay.io now? (y/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "Pushing to Quay.io..."
  podman push "$IMAGE_NAME"
  echo ""
  echo "✓ Image pushed successfully!"
  echo ""
  echo "Next steps:"
  echo "1. Update devfile.yaml with: image: $IMAGE_NAME"
  echo "2. Push this repo to Git"
  echo "3. Import into OpenShift DevSpaces"
else
  echo "Skipped push. Run manually with:"
  echo "  podman push $IMAGE_NAME"
fi
