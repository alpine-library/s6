#!/bin/bash
set -e

name='s6'
namespace='alpinelib'


declare -A aliases
aliases=(
	["1.18"]='latest'
)
fullVersion="$(grep -m1 'ENV S6_OVERLAY_VERSION ' "Dockerfile" | cut -d' ' -f3)"
majorVersion= ${fullVersion%[.-]*}
#
versionAliases=()
versionAliases+=( $fullVersion ${aliases[$MainVersion]} )


echo "build docker image $fullVersion"
ID=$(docker build .  | tail -1 | sed 's/.*Successfully built \(.*\)$/\1/')

for va in "${versionAliases[@]}"; do
  echo "TAG image $ID -> $namespace/$name:$va"
  docker tag -f $ID $namespace/$name:$va
  if [ $DOCKER_PUSH ]; then
  echo "PUSH image $ID -> $namespace/$name:$va"
  docker push $namespace/$name:$va
  fi
done
