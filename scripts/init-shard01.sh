#!/bin/bash

set -Eeu -o pipefail


function ping_primary() {
   if mongosh 'mongodb://shard01a:27018/' --quiet --eval 'quit(db.runCommand("ping").ok == 1 ? 0 : 1)' > /dev/null 2>&1; then
      return 0
   else
      return 1
   fi
}


function poll_repset() {
   if mongosh 'mongodb://shard01a:27018/' --quiet --eval 'quit(rs.status().ok == 0 ? 1 : 0)' > /dev/null 2>&1; then
      return 0
   else
      return 1
   fi
}


function init_repset() {
  if mongosh 'mongodb://shard01a:27018/' --quiet --eval 'quit(rs.initiate({_id:"shard01",version:1,members:[{_id:0,host:"shard01a:27018",priority:500},{_id:1,host:"shard01b:27018",priority:1},{_id:2,host:"shard01c:27018",priority:1}]}).ok == 1 ? 0 : 1)' > /dev/null 2>&1; then
      return 0
   else
      return 1
   fi
}


if ! ping_primary; then
   echo "MongoD on preferred shard01 replica set primary does not respond, aborting" >&2
   exit 1
fi


if ! poll_repset; then
   echo "shard01 replica set status not okay, initializing" >&2
   init_repset

   for i in 1 2 3 4 5 6; do
      sleep 10
      if poll_repset; then
         echo "shard01 replica set status okay" >&2
         exit 0
      fi
   done
   echo "shard01 replica set status not okay after 60 seconds, failing initialization" >&2
   exit 1
fi

echo "shard01 replica set status okay, not initializing" >&2
exit 0
