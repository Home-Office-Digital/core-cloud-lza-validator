#!bin/bash

set -e -u -o pipefail

# The landing-zone-accelerator-on-aws release tag to build against is pinned in
# the RELEASE file (form 'vX.Y.Z'). Changing the release is a source change, so
# the build output depends only on the repository contents.
release_file="$(dirname "$0")/RELEASE"

if [ ! -f "$release_file" ]; then
  echo "RELEASE file not found at '$release_file'." >&2
  exit 1
fi

release="$(tr -d '[:space:]' < "$release_file")"

if [ -z "$release" ]; then
  echo "RELEASE file is empty. It must contain a release tag in the form vX.Y.Z." >&2
  exit 1
fi

if ! echo "$release" | grep -Eq '^v[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo "Invalid release tag '$release' in RELEASE file. Expected format: vX.Y.Z" >&2
  exit 1
fi

if [ ! -d landing-zone-accelerator-on-aws ]; then
  git clone https://github.com/awslabs/landing-zone-accelerator-on-aws.git
fi
cd landing-zone-accelerator-on-aws
git fetch --all --tags --prune
git -c advice.detachedHead=false checkout "$release"
cd ..
echo "$release"
image_name=cc-lza-validator
image_id=ghcr.io/home-office-digital/$image_name
image_id=$(echo $image_id | tr '[A-Z]' '[a-z]')

docker build --platform linux/amd64 --tag $image_id:$release .
