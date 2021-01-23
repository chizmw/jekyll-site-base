#!/bin/bash

set -euo pipefail

docker build -t $(basename $PWD |tr [:upper:] [:lower:]):local .
docker tag jekyll-site-base:local chizcw/jekyll-site-base:$(git rev-parse --short HEAD)
docker push chizcw/jekyll-site-base:$(git rev-parse --short HEAD)
