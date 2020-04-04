#!/usr/bin/env bash

init() {
  local nginx_url="https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.30.0/deploy/static"
  
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
    
    kubectl apply -f "${nginx_url}/mandatory.yaml"
    kubectl apply -f "${nginx_url}/provider/baremetal/service-nodeport.yaml"
    kubectl patch deployments -n ingress-nginx nginx-ingress-controller -p "$(cat k8s/nginx-patch.json)"
    kubectl apply -f k8s/ingress.yaml
  ;;
  
  esac
}

init $1
