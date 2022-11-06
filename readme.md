# Mongo Sharded Cluster with Docker Compose

A simple sharded Mongo Cluster with a replication factor of 3 running in `docker` using `docker compose`.

Designed to be quick and simple to get a local or test environment up and running. Needless to say... DON'T USE THIS IN PRODUCTION!

Heavily inspired by:
- [https://github.com/jfollenfant/mongodb-sharding-docker-compose](https://github.com/jfollenfant/mongodb-sharding-docker-compose)
- [https://github.com/chefsplate/mongo-shard-docker-compose](https://github.com/chefsplate/mongo-shard-docker-compose)

## Components and features

* Config Server (3 member replica set): `config01a`,`config01b`,`config01c`
* 2 Shards (each a 3 member replica set):
  * `shard01a` (preferred primary), `shard01b`, `shard01c`
  * `shard02a`(preferred primary), `shard02b`, `shard02c`
* 1 Router (mongos): `router`
* DB data persistence using docker data volumes
* Automatic setup of config servers, shard servers and router
* Resource limits
* Health checks

## Run

1. Start all of the containers (daemonized):
```
docker compose up -d
```

2. Wait until all init tasks have succeeded:
```
docker compose ps initrouter
```
Expected output:
```
NAME                                      COMMAND                  SERVICE             STATUS              PORTS
mongo-shard-docker-compose-initrouter-1   "docker-entrypoint.s…"   initrouter          exited (0)          
```

3. Verify the status of the sharded cluster:
```
docker compose exec router mongo --eval 'sh.status()'
```
Expected output:
```
MongoDB shell version v4.4.17
connecting to: mongodb://127.0.0.1:27017/?compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("5a8d865e-9efe-4cce-b50e-0009ee82f990") }
MongoDB server version: 4.4.17
--- Sharding Status --- 
  sharding version: {
  	"_id" : 1,
  	"minCompatibleVersion" : 5,
  	"currentVersion" : 6,
  	"clusterId" : ObjectId("63680ded948f01c03c98bf49")
  }
  shards:
        {  "_id" : "shard01",  "host" : "shard01/shard01a:27018,shard01b:27018,shard01c:27018",  "state" : 1 }
        {  "_id" : "shard02",  "host" : "shard02/shard02a:27018,shard02b:27018,shard02c:27018",  "state" : 1 }
  active mongoses:
        "4.4.17" : 1
  autosplit:
        Currently enabled: yes
  balancer:
        Currently enabled:  yes
        Currently running:  no
        Failed balancer rounds in last 5 attempts:  0
        Migration Results for the last 24 hours: 
                No recent migrations
  databases:
        {  "_id" : "config",  "primary" : "config",  "partitioned" : true }
```

## Accessing the Mongo Shell
Is as simple as:
```
docker compose exec router mongo
```

## Resetting the Cluster
To remove all data and re-initialize the cluster, make sure the containers are stopped and remove persisted data:

```
docker compose down
docker volume rm \
   mongo-shard-docker-compose_config01acfg \
   mongo-shard-docker-compose_config01adb \
   mongo-shard-docker-compose_config01bcfg \
   mongo-shard-docker-compose_config01bdb \
   mongo-shard-docker-compose_config01ccfg \
   mongo-shard-docker-compose_config01cdb \
   mongo-shard-docker-compose_shard01acfg \
   mongo-shard-docker-compose_shard01adb \
   mongo-shard-docker-compose_shard01bcfg \
   mongo-shard-docker-compose_shard01bdb \
   mongo-shard-docker-compose_shard01ccfg \
   mongo-shard-docker-compose_shard01cdb \
   mongo-shard-docker-compose_shard02acfg \
   mongo-shard-docker-compose_shard02adb \
   mongo-shard-docker-compose_shard02bcfg \
   mongo-shard-docker-compose_shard02bdb \
   mongo-shard-docker-compose_shard02ccfg \
   mongo-shard-docker-compose_shard02cdb \
   mongo-shard-docker-compose_routercfg \
   mongo-shard-docker-compose_routerdb
```
