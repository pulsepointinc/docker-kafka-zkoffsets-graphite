#!/bin/bash

[ -z "${CONSUMER_GROUP}" ] && {
  echo "Must set CONSUMER_GROUP in env." >&2
  exit 1
}

ZK=${ZK:-localhost:2181}
SLEEP=${SLEEP:-60}
PREFIX=${PREFIX:-offsets}

GRAPHITE_HOST=${GRAPHITE_HOST:-localhost}
GRAPHITE_PORT=${GRAPHITE_PORT:-2003}

CMD="kafka-run-class kafka.tools.ConsumerOffsetChecker --group ${CONSUMER_GROUP} --zookeeper ${ZK}"

[ -z "${TOPIC}" ] || {
  CMD="${CMD} --topic ${TOPIC}"
}

echo "logging env:" >&2
env >&2

echo "logging cmd:" >&2
echo "${CMD}" >&2

while :; do
  ${CMD} | \
  tail -n+2 | \
  awk -v prefix="${PREFIX}" -v ts="$(date +%s)" '{print prefix "." $2 "." $1 "." $3 ".lag", $6, ts}' > \
  /dev/tcp/${GRAPHITE_HOST}/${GRAPHITE_PORT}
  sleep ${SLEEP}
done
