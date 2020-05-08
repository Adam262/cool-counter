# Cool Counter

#### A simple Sinatra app that teaches you about Docker, Docker Compose and Kubernetes

![Cool Counter](https://github.com/Adam262/cool-counter/blob/master/landing-image.png?raw=true)

### Overview
Cool Counter is a simple Sinatra web app. What it does is pretty inconsequential - you increment or decrement a counter, with the count persisted to a Redis database. 
The real purpose of this repo is to show how to run a simple service-oriented application in 4 ways:

* locally on a Mac
* as Docker containers
* via Docker-Compose
* via Kubernetes, running on a local cluster

This README shows the quick and dirty on installing and running Cool Counter. For a lot more detail on the project, consult [LESSONS_LEARNED](https://github.com/Adam262/cool-counter/blob/master/LESSONS_LEARNED.md).

### Getting Started
Please set up the following dependencies before attempting to use Cool Counter.

Git clone this repo 
```
git@github.com:Adam262/cool-counter.git cool-counter && cd $_

```

Docker Desktop for Mac (development environment for working with containers):

* install [Docker Desktop for Mac](https://hub.docker.com/editions/community/docker-ce-desktop-mac/)

ASDF (system wide version and dependency manager):

* install [asdf version manager](https://github.com/asdf-vm/asdf)
* run `asdf install`

Bundler (package managment for Ruby apps):

* install `bundler` via `gem install bundler`
* run `bundle install`

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
# Build the Docker image (only if not built in another step)
./init.sh build

# Start the app
./init.sh docker

# Stop the app
./init.sh docker down

```
#### Via Docker compose
The app runs on localhost:4567

Commands
```
# Build the Docker image (only if not built in another step)
./init.sh build

# Start the app
./init.sh docker-compose

# Stop the app 
./init.sh docker-compose down

```

#### Via Kubernetes on a local cluster
The app runs on localhost

Commands
```
# Build the Docker image (only if not built in another step)
./init.sh build

# Start the app
./init.sh k8s

# Stop the app (by deleting namespace and all K8s resources)
./init.sh k8s down-namespace

# Stop the app (by additionally deleting cluster)
./init.sh k8s down-cluster

```

#### Debugging
Any init script command can be prefaced with `DEBUG=true`. This is will cause bash to log commands before executing them, including expanded arguments. For example:

```
DEBUG=true ./init.sh k8s up
```

### Next Steps
There are a ton of technologies I could apply here. All are used at my job, although I haven't nececessarily gotten in the weeds of implementing them at work. So could learn a lot.

Some examples:

* [Buildpacks](https://buildpacks.io/). A higher-level abstraction over a Dockerfile
* [Prometheus](https://prometheus.io/). Monitoring tool. I have an open PR to add monitoring at all steps via Prometheus. 
* [Helm](https://helm.sh/). Package manager for Kubenetes. For example, I would install Prometheus to my cluster via Helm. 
* [Horizontal Pod Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/). This is a native K8s feature that would allow the app to scale the number of
web containers based on the value of a metric (ingested from Prometheus). 
