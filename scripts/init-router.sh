#!/bin/bash

set -Eeu -o pipefail


function ping_router() {
   if mongosh 'mongodb://router:27017/' --quiet --eval 'quit(db.runCommand("ping").ok == 1 ? 0 : 1)' > /dev/null 2>&1; then
      return 0
   else
      return 1
   fi
}


function add_shard01() {
  if mongosh 'mongodb://router:27017/' --quiet --eval 'quit(sh.addShard("shard01/shard01a:27018,shard01b:27018,shard01c:27018").ok == 1 ? 0 : 1)' > /dev/null 2>&1; then
      return 0
   else
      return 1
   fi
}


function add_shard02() {
  if mongosh 'mongodb://router:27017/' --quiet --eval 'quit(sh.addShard("shard02/shard02a:27018,shard02b:27018,shard02c:27018").ok == 1 ? 0 : 1)' > /dev/null 2>&1; then
      return 0
   else
      return 1
   fi
}


if ! ping_router; then
   echo "MongoS on router does not respond, aborting" >&2
   exit 1
fi


if ! add_shard01; then
   echo "Could not add shard01 to router, aborting" >&2
   exit 1
fi

if ! add_shard02; then
   echo "Could not add shard02 to router, aborting" >&2
   exit 1
fi


echo "All shards added to router" >&2
exit 0
