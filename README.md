### Run dev environment with docker

#### Build docker image

```
docker build -t my-dev-environment .
```

#### Start docker container

```
docker run -it --name dev-container my-dev-environment
```

#### Reconnect to docker container

```
docker restart dev-container && docker attach dev-container
```
