#!/usr/bin/env bash

init () {
  case "$1" in
  local)
  brew services start redis
  rackup -p 4567
  ;;

  docker)
  network=sinatra-app-network
  docker run --name=sinatra-app --network=$network -d -p 4567:4567 adam262/sinatra-app
  docker run --name=redis --hostname=redis --network=$network -d redis
  ;;
  
  docker-compose)
  docker-compose up -d
  docker-compose logs -f
  ;;
  
  k8s)
  Message="I'm drowning here!  There's a partition at $space %!"
  ;;
  
  esac
}

init $1
