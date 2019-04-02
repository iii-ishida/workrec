#! /bin/sh

BASEDIR=$(cd $(dirname $(dirname "$0")) && pwd)

gcloud beta emulators datastore start --quiet --no-store-on-disk --consistency=1.0 &
DS_EMU_PID=$!

gcloud beta emulators pubsub start --quiet &
PS_EMU_PID=$!
trap 'pgrep -P $PS_EMU_PID | xargs pgrep -P | xargs kill && pgrep -P $DS_EMU_PID | xargs pgrep -P | xargs kill' 0 1 2 3 15

sleep 3; $(gcloud beta emulators datastore env-init) && $(gcloud beta emulators pubsub env-init)
go run ${BASEDIR}/scripts/create_topic.go && CLIENT_ORIGIN=http://localhost:3000 go run ${BASEDIR}/web
