#!/usr/bin/env bash

cat <<EOF
###############
Local Utilities
###############
EOF

usage() {
    cat <<EOF
Usage: server [params]
Params:
-s     | --start: start docker-compose
-wasn  | --webapp-sync: sync webapp content
-n     | --stop: stop docker
-k     | --kill: reset image with image name param
EOF
}

killImage() {
    docker images --format="{{.Repository}} {{.ID}}" | 
    grep "^$1 " | 
    cut -d' ' -f2 | 
    xargs docker rmi
}

while [ "$1" != "" ]; do
  case $1 in
  -s | --start)
    # sync the solidity contract abi into the webapp
    rsync $(pwd)/src/solidity/artifacts/contracts/WavePortal.sol/WavePortal.json $(pwd)/src/web-app/src/utils
    rsync -r $(pwd)/src/web-app/ $(pwd)/docker/web-app/app
    cd $(pwd)/docker &&
    docker-compose up --remove-orphans -d
    ;;
  -sn | --sync)
    rsync $(pwd)/src/solidity/artifacts/contracts/WavePortal.sol/WavePortal.json $(pwd)/src/web-app/src/utils
    rsync -r $(pwd)/src/web-app/ $(pwd)/docker/web-app/app
    ;;
  -n | --stop)
    rm -rf $(pwd)/docker/web-app/app/
    cd $(pwd)/docker &&
    docker-compose down
    ;;
  -rmd | --remove-dangling)
    docker rmi $(docker images -f "dangling=true" -q)
    ;;
  -k | --kill)
    shift
    killImage $1
    ;;
  -cip | --container-ip)
    shift
    docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $1
    ;;
  -w | --webapp)
    shift
    cd $(pwd)/docker ; docker-compose exec node /bin/bash -c 'yarn dev; bash'
    ;;
  -h | --help)
    usage
    exit
    ;;
  esac
  shift
done
