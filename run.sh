#!/bin/bash
set -eux -o pipefail

docker network create -d bridge workshop

docker run -d --name cb-server --network workshop -p 8091-8096:8091-8096 -p 11207:11207 -p 11210:11210 -p 11211:11211 -p 18091-18094:18091-18094 couchbase:community
#docker run -d --name cb-server -p 8091-8096:8091-8096 -p 11207:11207 -p 11210:11210 -p 11211:11211 -p 18091-18094:18091-18094 couchbase:community

curl --retry-all-errors --connect-timeout 5 --max-time 10 --retry 20 --retry-delay 0 --retry-max-time 120 'http://127.0.0.1:8091'

curl -u Administrator:password http://127.0.0.1:8091/nodes/self/controller/settings -d 'path=%2Fopt%2Fcouchbase%2Fvar%2Flib%2Fcouchbase%2Fdata&' -d 'index_path=%2Fopt%2Fcouchbase%2Fvar%2Flib%2Fcouchbase%2Fdata&' -d 'cbas_path=%2Fopt%2Fcouchbase%2Fvar%2Flib%2Fcouchbase%2Fdata&' -d 'eventing_path=%2Fopt%2Fcouchbase%2Fvar%2Flib%2Fcouchbase%2Fdata&'
curl -u Administrator:password -v -X POST http://127.0.0.1:8091/node/controller/setupServices -d 'services=kv%2Cn1ql%2Cindex'
curl -u Administrator:password -v -X POST http://127.0.0.1:8091/settings/web -d 'password=password&username=Administrator&port=SAME'

CB_SERVER_IP_ADDR=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' cb-server)

#curl -u Administrator:password http://127.0.0.1:8091/node/controller/rename -d "hostname=$CB_SERVER_IP_ADDR"

docker run -p 4984-4986:4984-4986 --network workshop --name sync-gateway -d -v $(pwd)/sync-gateway-config.json:/etc/sync_gateway/sync_gateway.json couchbase/sync-gateway:community /etc/sync_gateway/sync_gateway.json
#docker run -p 4984-4986:4984-4986 --name sync-gateway -d -v $(pwd)/sync-gateway-config.json:/etc/sync_gateway/sync_gateway.json couchbase/sync-gateway:community /etc/sync_gateway/sync_gateway.json
