This will kill all docker containers on your local network, but I test with:

```
docker kill $(docker ps -qa) ; docker rm $(docker ps -qa) ; docker network rm workshop ; ./run.sh && docker logs -f sync-gateway
```
