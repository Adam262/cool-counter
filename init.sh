#!/usr/bin/env bash
set -euo pipefail

[[ -n "${DEBUG-}" ]] && set -x

init() {
  local action=$1
  local option=${2:-""}
  local redis_version="redis:latest"

  case $action in

  build)
    docker build -t cool-counter .
    ;;

  local)
    if [[ $option == "down" ]]; then
      kill $(pgrep rackup)
      brew services stop redis

      exit 0
    fi

    brew_check_or_install redis
    brew services start redis

    bundle exec rackup -p 4567
    ;;

  docker)
    local network=cool-counter-network
    
    if [[ $option == "down" ]]; then
      docker stop redis
      docker rm redis

      docker stop web
      docker rm web

      docker network rm $network

      exit 0
    fi

    docker_check_or_build cool-counter
    docker_check_or_pull $redis_version
    docker_check_or_create_network $network
    
    docker run --name=web --network=$network -p 4567:4567 -d  cool-counter
    docker run --name=redis --network=$network --hostname=redis -d redis

    docker logs -f web
    ;;
  
  docker-compose)
    if [[ $option == "down" ]]; then
      docker-compose down
      
      exit 0
    fi

    docker_check_or_build cool-counter
    docker_check_or_pull $redis_version

    docker-compose up -d
    docker-compose logs -f
    ;;
  
  k8s)
    local cluster_name="cool-cluster"
    local namespace="cool-namespace"
    local kind_nginx_config="https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml"

    if [[ $option == "down" ]]; then
      kubectl delete namespace $namespace
      exit 0
    fi    

    if [[ $option == "down-cluster" ]]; then
      kind delete cluster --name=$cluster_name
      exit 0
    fi

    docker_check_or_build cool-counter
    docker_check_or_pull $redis_version
    
    # Create cluster + load images
    local cluster=$(kind get clusters | grep $cluster_name)

    if [[ $cluster ]]; then
      echo "using cluster $cluster_name ..."
    else
      kind create cluster --config=k8s/cluster.yaml --name=$cluster_name
    fi
    
    kind --name=$cluster_name load docker-image cool-counter
    kind --name=$cluster_name load docker-image redis    

    kubectl apply -f k8s/namespace.yaml
    
    # Deploy web app
    kubectl apply -f k8s/web-deployment.yaml
    kubectl apply -f k8s/web-service.yaml
    kubectl apply -f k8s/redis-deployment.yaml
    kubectl apply -f k8s/redis-service.yaml
    
    # Expose web app via ingress
    if [[ $option == "kind" ]]; then
      echo "Applying Nginx ingress controller for Kind"
      kubectl apply -f "$kind_nginx_config"
      kubectl apply -f k8s/ingress.yaml
    else 
      echo "Applying Nginx ingress controller"
      helm upgrade --install ingress-nginx ingress-nginx \
        --repo https://kubernetes.github.io/ingress-nginx \
        --namespace "$namespace"
      kubectl apply -f k8s/ingress-class.yaml  
      kubectl apply -f k8s/ingress.yaml
    fi
    ;;

  esac
}

brew_check_or_install() {
  local package=$1

  if brew ls --versions $package > /dev/null; then 
    echo "$package is installed"
  else
    echo "Installing $package..."
    brew install $package
  fi
}

docker_check_or_pull() {
  local redis_version=$1

  if docker inspect $redis_version > /dev/null; then
    echo "Image $redis_version is installed"
  else 
    docker pull $redis_version 
  fi
}

docker_check_or_build() {
  local tag=$1

  if docker inspect $tag > /dev/null; then
    echo "Image $tag is installed"
  else 
    docker build -t $tag .
    echo "Building image $tag..."
  fi
}

docker_check_or_create_network() {
  local network=$1

  if docker network inspect $network > /dev/null; then
    echo "Network $network exists"
  else 
    echo "Creating network $network..."
    docker network create $network
  fi
}

init "$@"
