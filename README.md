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
docker compose exec router mongosh --eval 'sh.status()'
```
Expected output:
```
shardingVersion
{ _id: 1, clusterId: ObjectId('665232c297ddc0c9ddc98c50') }
---
shards
[
  {
    _id: 'shard01',
    host: 'shard01/shard01a:27018,shard01b:27018,shard01c:27018',
    state: 1,
    topologyTime: Timestamp({ t: 1716663010, i: 2 })
  },
  {
    _id: 'shard02',
    host: 'shard02/shard02a:27018,shard02b:27018,shard02c:27018',
    state: 1,
    topologyTime: Timestamp({ t: 1716663011, i: 2 })
  }
]
---
active mongoses
[ { '7.0.9': 1 } ]
---
autosplit
{ 'Currently enabled': 'yes' }
---
balancer
{
  'Currently enabled': 'yes',
  'Failed balancer rounds in last 5 attempts': 0,
  'Currently running': 'no',
  'Migration Results for the last 24 hours': 'No recent migrations'
}
---
databases
[
  {
    database: { _id: 'config', primary: 'config', partitioned: true },
    collections: {
      'config.system.sessions': {
        shardKey: { _id: 1 },
        unique: false,
        balancing: true,
        chunkMetadata: [ { shard: 'shard01', nChunks: 1 } ],
        chunks: [
          { min: { _id: MinKey() }, max: { _id: MaxKey() }, 'on shard': 'shard01', 'last modified': Timestamp({ t: 1, i: 0 }) }
        ],
        tags: []
      }
    }
  }
]
```

## Accessing the Mongo Shell
Is as simple as:
```
docker compose exec router mongosh
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
