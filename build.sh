#!bin/bash

set -e -u -o pipefail

# First argument: the landing-zone-accelerator-on-aws release tag to build
# against, in the form 'vX.Y.Z'.
release="${1:-}"

if [ -z "$release" ]; then
  echo "Usage: $0 vX.Y.Z" >&2
  echo "A landing-zone-accelerator-on-aws release tag must be provided." >&2
  exit 1
fi

if ! echo "$release" | grep -Eq '^v[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo "Invalid release tag '$release'. Expected format: vX.Y.Z" >&2
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
