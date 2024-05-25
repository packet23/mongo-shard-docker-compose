#!/bin/bash

set -Eeu -o pipefail


function ping_primary() {
   if mongosh 'mongodb://config01a:27019/' --quiet --eval 'quit(db.runCommand("ping").ok == 1 ? 0 : 1)' > /dev/null 2>&1; then
      return 0
   else
      return 1
   fi
}


function poll_repset() {
   if mongosh 'mongodb://config01a:27019/' --quiet --eval 'quit(rs.status().ok == 0 ? 1 : 0)' > /dev/null 2>&1; then
      return 0
   else
      return 1
   fi
}


function init_repset() {
  if mongosh 'mongodb://config01a:27019/' --quiet --eval 'quit(rs.initiate({_id:"config",configsvr:true,version:1,members:[{_id:0,host:"config01a:27019",priority:500},{_id:1,host:"config01b:27019",priority:1},{_id:2,host:"config01c:27019",priority:1}]}).ok == 1 ? 0 : 1)' > /dev/null 2>&1; then
      return 0
   else
      return 1
   fi
}


if ! ping_primary; then
   echo "MongoD on preferred config replica set primary does not respond, aborting" >&2
   exit 1
fi


if ! poll_repset; then
   echo "config replica set status not okay, initializing" >&2
   init_repset

   for i in 1 2 3 4 5 6; do
      sleep 10
      if poll_repset; then
         echo "config replica set status okay" >&2
         exit 0
      fi
   done
   echo "config replica set status not okay after 60 seconds, failing initialization" >&2
   exit 1
fi

echo "config replica set status okay, not initializing" >&2
exit 0
