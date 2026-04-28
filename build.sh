#!bin/bash

set -e -u -o pipefail

if [ ! -d landing-zone-accelerator-on-aws ]; then
  git clone https://github.com/awslabs/landing-zone-accelerator-on-aws.git
fi
cd landing-zone-accelerator-on-aws
git checkout main
git pull
release=$(git describe --tags --abbrev=0)
git -c advice.detachedHead=false checkout $release
cd ..
echo $release
image_name=cc-lza-validator
image_id=ghcr.io/home-office-digital/$image_name
image_id=$(echo $image_id | tr '[A-Z]' '[a-z]')

docker build --platform linux/amd64 --tag $image_id:$release .
docker tag $image_id:$release $image_id:latest