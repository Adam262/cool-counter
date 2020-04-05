#!/usr/bin/env bash

init() {
  local nginx_url="https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.30.0/deploy/static"

  case $1 in

  build)
    docker build -t cool-counter .
    ;;

  local)
    brew services start redis
    rackup -p 4567
    ;;

  docker)
    network=cool-counter-network
    docker run --name=web --network=$network -d -p 4567:4567 cool-counter
    docker run --name=redis --hostname=redis --network=$network -d redis
    ;;
  
  docker-compose)
    if [[ $2 == "down" ]]; then
      docker-compose down
      exit 0
    fi  

    docker-compose up -d
    docker-compose logs -f

    ;;
  
  k8s)
    if [[ $2 == "down" ]]; then
      kind delete cluster --name=cool-cluster
      exit 0
    fi 

    kind create cluster --config=k8s/cluster.yaml --name=cool-cluster

    kind --name=cool-cluster load docker-image cool-counter
    kind --name=cool-cluster load docker-image redis
    
    kubectl apply -f k8s/namespace.yaml
    
    kubectl apply -f k8s/web-deployment.yaml
    kubectl apply -f k8s/web-service.yaml
    kubectl apply -f k8s/redis-deployment.yaml
    kubectl apply -f k8s/redis-service.yaml
    
    kubectl apply -f "${nginx_url}/mandatory.yaml"
    kubectl apply -f "${nginx_url}/provider/baremetal/service-nodeport.yaml"
    kubectl patch deployments -n ingress-nginx nginx-ingress-controller -p "$(cat k8s/nginx-patch.json)"
    kubectl apply -f k8s/ingress.yaml
    ;;
  
  esac
}

init "$@"
