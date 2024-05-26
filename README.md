### Run dev environment with docker

#### Build docker image

```
docker build -t my-dev-environment .
```

#### Start docker container

```
docker run --privileged -it -p 2375:2375 --name dev-container my-dev-environment
```

#### Reconnect to docker container

```
docker restart dev-container && docker attach dev-container
```
