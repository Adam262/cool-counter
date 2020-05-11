# Cool Counter

#### A simple Sinatra app that teaches you about Docker, Docker Compose and Kubernetes

![Cool Counter](https://github.com/Adam262/cool-counter/blob/master/landing-image.png?raw=true)

### Overview
Cool Counter is a simple Sinatra web app. What it does is pretty inconsequential - you increment or decrement a counter, with the count persisted to a Redis database. 
The real purpose of this repo is to show how to run a simple service-oriented application in 4 ways:

* locally on a Mac
* as [Docker](https://docs.docker.com/) containers
* via [Docker-Compose](https://docs.docker.com/compose/)
* via [Kubernetes (K8s)](https://kubernetes.io/docs/home/), running on a local multi-node cluster.

This README shows the quick and dirty on installing and running Cool Counter. For a lot more detail on the project, consult [LESSONS_LEARNED](https://github.com/Adam262/cool-counter/blob/master/LESSONS_LEARNED.md).

### Getting Started
Please set up the following dependencies before attempting to use Cool Counter:

* Git clone this repo (run subsequent commands from within repo)

```
git clone git@github.com:Adam262/cool-counter.git cool-counter && cd $_

```

* install [Docker Desktop for Mac](https://hub.docker.com/editions/community/docker-ce-desktop-mac/), a local environment for working with Docker containers

* install [ASDF](https://github.com/asdf-vm/asdf), a system wide version and dependency manager

* install ASDF plugins and packages needed for this app
```
asdf plugin add kind
asdf plugin add kubectl
asdf plugin add ruby

asdf install
``` 

* install Bundler, a package manager for Ruby apps and the gems needed to run this app locally

```
gem install bundler
bundle install 
```

#### Build the app Docker image
Most steps of this app expect the `cool-counter` Docker image to exist in your local Docker. Build it via below command:

```
./init.sh build
```

You will also need to keep rebuilding image if you check out this repo and do work locally. If there are any issues building, it's very helpful to run a Bash shell into a container at the point that the image build failed. You can do this because it is likely the prior images on which image is based succeeded.

```
# Imagine this step fails
docker build -t cool-counter .

# Find recent image builds (including your build failure)
docker images | head -n 5 

# Exec into bash container for image
docker run -it <your-image-sha> bash
```

### Running Cool Counter

#### Locally
The app runs on localhost:4567

Commands
```
# Start the app
./init.sh local

# Stop the app
./init.sh local down

```
#### Via pure Docker containers
The app runs on localhost:4567

Commands
```
# Start the app
./init.sh docker

# Stop the app
./init.sh docker down

```
#### Via Docker compose
The app runs on localhost:4567

Commands
```
# Start the app
./init.sh docker-compose

# Stop the app 
./init.sh docker-compose down

```

#### Via Kubernetes on a local cluster
The app runs on localhost

Commands
```
# Start the app
./init.sh k8s

# Stop the app (by deleting namespace and all K8s resources)
./init.sh k8s down

# Stop the app (by additionally deleting cluster)
./init.sh k8s down-cluster

```

#### Debugging
Any init script command can be prefaced with `DEBUG=true`. This is will cause bash to log commands before executing them, including expanded arguments. For example:

```
DEBUG=true ./init.sh k8s up
```

### Next Steps
There are a ton of technologies I could apply here. We use them at work, although I haven't necessarily gotten in the weeds for all of them. So could learn a lot.

Some examples:

* [Buildpacks](https://buildpacks.io/). A higher-level abstraction over a Dockerfile
* [Prometheus](https://prometheus.io/). A monitoring tool. I have an open PR to add monitoring at all steps via Prometheus. 
* [Helm](https://helm.sh/). The standard chart (package) manager for Kubenetes. For example, there are stable helm charts you can use to install Prometheus to a K8s cluster. The charts follow a common vendor pattern of creating custom K8s resources that work alongside core K8s resources and respond to common K8s commands
* [Horizontal Pod Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/). A native K8s feature that would allow the app to scale the number of
web containers up and down - automatically - based on the value of a metric (ingested from Prometheus). 
