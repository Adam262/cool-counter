# Journey from running an app on local server to Docker to K8s

## Stage 1 - Sinatra + Redis on MacOS
### Key steps
* run Redis locally
* run Sinatra server

### Gotchas
* making Sinatra run in modular form so you can have private methods
* getting SASS to work on Sinatra
* running JS on Sinatra (ES^ Fetch API FTW)

## Stage 2 - Dockerize app
### Key steps
* run Docker for Mac
* write Docker image for your Sinatra app
* pull Redis image
* get app to talk to Redis
* optimize Docker image

## Stage 3 - Docker Compose app
### Key steps
* Write docker-compose.yml

### Gotchas
#### You are probably missing a lot of system dependencies for gems, such as gcc 
`bundle install` kept failing. I would shell into a failed build, bundle install again, see error logs and add
system libraries one at a time, eg:

I tried: 
```
  docker images
  docker run -it <SHA of failed build> bash
  bundle install
  ```
Finally it worked to add this to Dockerfile `RUN apt-get install -y build-essential`. It contains gcc, libc, make, etc - [see](https://packages.debian.org/sid/build-essential)

#### You are also missing debugging tools such as `curl` and `telnet`
* curl is not by default on Debian. Need to install it. Same for telnet

#### Nice to assign --name to docker container, else docker will give a random one, eg:
```
docker run --name=sinatra-app -d -p 4567:4567 adam262/sinatra-app
docker run --name=redis -d -p 6379:6379 redis
``` 

#### Getting one container to talk to another and to your localhost is ... hard (without docker-compose or K8s)
* Step 1. Pulish your sinatra container's port via `docker run -p <host>:<container-port>`. This is so your localhost can talk to sinatra at a deterministic port
* Step 2. Create a docker network and pass `docker run --network=<cool-network-name>` to each container. This is so your sinatra container and redis container expose ports to each other
* Step 3. I really banged my head on giving Redis container a deterministic hostname.  The answer lies in (Docker networking docs) [https://docs.docker.com/config/containers/container-networking/]. So a container's hostname defaults to its container SHA. You can overide this with `docker run --hostname=redis`


```
docker network create sinatra-app-network
docker run --name=sinatra-app --network=sinatra-app-network -d -p 4567:4567 adam262/sinatra-app
docker run --name=redis --hostname=redis --network=sinatra-app-network -d redis
```

#### Your image build is slow by default
An easy win is to `bundle install` before you copy the rest of your app code. Else any change to app code will invalidate gem cache


## Stage 4 - K8s-ify the app
### Need to reuse local Docker daemon minikube
* Do not attempt to pull images from Docker registry. Well you can if you set secrets
* Thank you [savior](https://stackoverflow.com/questions/42564058/how-to-use-local-docker-images-with-minikube). Need to:
- Set the Docker environment variables on your Minikube via `eval $(minikube docker-env)`
- rebuild image with a tag, eg `docker build -t cool-tag .`
- in Deployment or Pod spec, set `imagePullPolicy: Never`
- reference image via its tag (not via registry)

**web-deployment.yaml**
```
   spec:
      containers:
      - name: sinatra-app
        image: sinatra-app
        imagePullPolicy: Never
        ports:
        - containerPort: 4567
```


