# Cool Counter

#### A simple Sinatra app that teaches you about Docker, Docker Compose and Kubernetes

### Getting Started
To get up and running, please follow steps in [README](https://github.com/Adam262/cool-counter/blob/master/README.md). Read on for more detail on the project steps and lessons I learned along the way

### Milestone 1 - Run Cool Counter locally
#### Key steps

* run Redis locally
* run Sinatra server

#### Gotchas
This part was pretty straightforward. Most of the work involved doing stuff in Sinatra I take for granted in Rails:

* Making Sinatra run in modular form so you can have private methods
* Getting SASS to work on Sinatra
* Running JS on Sinatra (ES6 Fetch API FTW)

### Milestone 2 - Run on Docker
#### Key steps

* run Docker for Mac
* write Docker image for your Sinatra app
* pull Redis image
* get app to talk to Redis
* optimize Docker image

#### Gotchas
##### You are probably missing a lot of system dependencies for gems, such as gcc 
`bundle install` kept failing. I would shell into a failed build, bundle install again, see error logs and add system libraries one at a time, eg:

I tried:

```
  docker images
  docker run -it <SHA of failed build> bash
  bundle install
```

Finally it worked to add this to Dockerfile `RUN apt-get install -y build-essential`. It contains gcc, libc, make, etc - [see](https://packages.debian.org/sid/build-essential)

You are also likely need to install debugging tools such as `curl` and `telnet`
#
##### Nice to assign --name to docker container, else docker will give a random one, eg:
```
docker run --name=sinatra-app -d -p 4567:4567 adam262/sinatra-app
docker run --name=redis -d -p 6379:6379 redis
``` 

##### Getting one container to talk to another and to your localhost is ... hard (without docker-compose or K8s):

* Step 1. Pulish your sinatra container's port via `docker run -p <host>:<container-port>`. This is so your localhost can talk to sinatra at a deterministic port
* Step 2. Create a docker network and pass `docker run --network=<cool-network-name>` to each container. This is so your sinatra container and redis container expose ports to each other
* Step 3. I really banged my head on giving Redis container a deterministic hostname.  The answer lies in (Docker networking docs)[https://docs.docker.com/config/containers/container-networking/]. So a container's hostname defaults to its container SHA. You can overide this with `docker run --hostname=redis`

```
local network=cool-counter-network
docker network create $network
docker run --name=web --network=$network -p 4567:4567 -d  cool-counter
docker run --name=redis --network=$network --hostname=redis -d redis
```

##### Your image build is slow by default
An easy win is to `bundle install` before you copy the rest of your app code. Else any change to app code will invalidate gem cache

### Milestone 3 - Run on Docker Compose
#### Key steps

* Write docker-compose.yml

#### Gotchas

* Honstly none. Docker compose is almost too easy. 

### Milestone 4 - K8s-ify app
#### Key steps

* Chose a local cluster (Minikube vs Kind vs others)
* Plan architecture of K8s resources. You will need a deployment and a service for each of front-end (web-server) and back-end(redis)
* Set up a single-node K8s cluster locally
* Set up a multiple-node K8s cluster locally
* Create namespace
* Deploy front-end and expose to ingress via service
* Deploy ingress to expose app
* Deploy back-end and expose to front-end via service 
* Consider env var vs DNS for exposing back-end service
* Test via /ping
* Test via /

#### Gotchas

##### I started with Minikube. You need to reuse the local Docker daemon for minikube. It's painful

* Do not attempt to pull images from Docker registry. Well you can if you set secrets
* Thank you [savior](https://stackoverflow.com/questions/42564058/how-to-use-local-docker-images-with-minikube). 

Need to:

* Set the Docker environment variables on your Minikube via `eval $(minikube docker-env)`
* Rebuild image with a tag, eg `docker build -t cool-tag .`
* In Deployment or Pod spec, set `imagePullPolicy: Never`
* Reference image via its tag (not via registry)

**web-deployment.yaml**
```
   spec:
      containers:
      - name: cool-counter
        image: cool-counter
        imagePullPolicy: Never
        ports:
        - containerPort: 4567
```

##### minikube service command is needed to expose your cluster to an external url
Gets the kubernetes URL(s) for the specified service in your local cluster
```
# open a browser to the service's external URL
# This is `minikube ip` + the port that you set in service config yaml 
minikube service sinatra-app

# but EXTERNAL-IP is pending
k get svc -l app=sinatra-app
``` 

##### I switched to kind + ingress
What is kind?

* A K8s cluster that runs in a Docker container (KuberNetes In Docker)
* Easy to use
* Minikube needed its own VM, on top of the VM that Docker for Mac runs on. Kind runs on its own Docker container called `kind-control-plane`
* Can have multiple nodes - more realistic. Minikube is a single master node
* Interesting to see how K8s distributes pods.

```
k get nodes

NAME                         STATUS   ROLES    AGE     VERSION
cool-cluster-control-plane   Ready    master   5m6s    v1.17.0
cool-cluster-worker          Ready    <none>   4m33s   v1.17.0

k describe cool-cluster-control-plane
```

Rememeber to load images from your local Docker to the clusters
```
docker build -t cool-tag .
kind load docker-image cool-tag
kubectl apply -f deployment-for-cool-tag.yaml
```

What is Ingress?

* Ingress is a K8s resouce that exposes HTTP and HTTPS routes from outside the cluster to services within the cluster. Traffic routing is controlled by rules defined on the Ingress resource.

Need two resouces:

* Ingress
* IngressController - via [Nginx](https://kubernetes.github.io/ingress-nginx/)

Follow [kind instructions](https://kind.sigs.k8s.io/docs/user/ingress/)

##### How does the web server talk to Redis?
*Via env var*

* Remember we need to tell our web server the name of the Redis host
* `k exec <some-web-pod-name> -- printenv` will show a system env var called `COOL_COUNTER_REDIS_SERVICE_HOST`
* Then pass this to your `web-deployment`. It will override the `REDIS_HOST` env var set in your Dockerfile  
* This approach works but has quirks, namely order dependency. You need to apply `redis-service` before anything else. 

*Via DNS*

* This approach is nicer then the env var approach because you can refer to the DNS name before the service exists. There is no order dependency in creating your resources
* K8s provides a deterministic DNS convention. Eg, lookup a service hostname by `<service-name>.<namespace>.svc.cluster.local`

* View a pod's DNS entry:
```
k exec -it <some-pod> bash
cat /etc/resolv.conf

nameserver 1.2.3.4
search default.svc.cluster.local svc.cluster.local cluster.local
options ndots:2 edns0
```
