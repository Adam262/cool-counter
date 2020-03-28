#!/usr/bin/env bash

init () {
  case "$1" in
  build)
  docker build -t cool-counter .
  ;;

  local)
  brew services start redis
  rackup -p 4567
  ;;

  docker)
  network=sinatra-app-network
  docker run --name=sinatra-app --network=$network -d -p 4567:4567 cool-counter
  docker run --name=redis --hostname=redis --network=$network -d redis
  ;;
  
  docker-compose)
  docker-compose up -d
  docker-compose logs -f
  ;;
  
  k8s)
    kind create cluster --config=k8s/cluster.yaml
    kind load docker-image cool-counter
    kind load docker-image redis
    kubectl apply -f k8s/redis-service.yaml
    kubectl apply -f k8s/redis-deployment.yaml
    kubectl apply -f k8s/web-service.yaml
    kubectl apply -f k8s/web-deployment.yaml
    kubectl apply -f https://projectcontour.io/quickstart/contour.yaml
    kubectl patch daemonsets -n projectcontour envoy -p '{"spec":{"template":{"spec":{"nodeSelector":{"ingress-ready":"true"},"tolerations":[{"key":"node-role.kubernetes.io/master","operator":"Equal","effect":"NoSchedule"}]}}}}'
    kubectl apply -f k8s/ingress.yaml
  ;;
  
  esac
}

init $1
