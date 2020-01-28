# Journey from running an app on local server to Docker to K8s

## Stage 1 - Sinatra + Redis on MacOS
### Key steps
* bundle init
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

### Gotchas
* bundle install kept failing. 
* I tried: ```
  docker images
  docker run -it <SHA of failed build> bash
  bundle install
  ```
* Finally it worked to add this to Dockerfile `RUN apt-get install -y build-essential`
* It contains gcc, libc, make, etc - see https://packages.debian.org/sid/build-essential
* Struggle to expose Sinatra port
* curl is not by default on Debian. Need to install it. 
* nice to assign --name to docker container, else docker will give a random one, eg:
```
docker run --name=sinatra-app -d -p 4567:4567 adam262/sinatra-app
docker run --name=redis -d -p 6379:6379 redis
``` 
* concept of linking containers. --link is legacy concept, now should create network (or use docker compose, or use K8S)
* need to pass in hostname, else it defaults to container sha!

```
docker network create sinatra-app-network
docker run --name=sinatra-app --network=sinatra-app-network -d -p 4567:4567 adam262/sinatra-app
docker run --name=redis --hostname=redis --network=sinatra-app-network -d -p 6379:6379 redis
```
TO DO
* optimize doccker build. right now any change in app code invalidates cache and causes all gems to be re fetched
* apt-get telnet so I can `telnet redis 6379`