#!/bin/bash
#
#[ -z "${CONSUMER_GROUP}" ] && {
#  echo "Must set CONSUMER_GROUP in env." >&2
#  exit 1
#}

BOOTSTRAP_SERVER=${BOOTSTRAP_SERVER:-localhost:9092}
SLEEP=${SLEEP:-30}
PREFIX=${PREFIX:-offsets}

GRAPHITE_HOST=${GRAPHITE_HOST:-localhost}
GRAPHITE_PORT=${GRAPHITE_PORT:-2003}

#CMD="kafka-run-class kafka.admin.ConsumerGroupCommand --bootstrap-server ${BOOTSTRAP_SERVER} --describe --group ${CONSUMER_GROUP}"

echo "logging env:" >&2
env >&2

echo "logging cmd:" >&2
echo "${CMD}" >&2

CONSUMER_GROUPS=`kafka-run-class kafka.admin.ConsumerGroupCommand --bootstrap-server ${BOOTSTRAP_SERVER} --list`

while :; do
  for CON_GROUP in $CONSUMER_GROUPS
    do
    CMD="kafka-run-class kafka.admin.ConsumerGroupCommand --bootstrap-server ${BOOTSTRAP_SERVER} --describe --group ${CON_GROUP}"
      ${CMD} | \
      tail -n+2 | \
      awk -v prefix="${PREFIX}" -v ts="$(date +%s)" -v cg="${CON_GROUP}" '{print prefix "." $1 "." cg "." $2 ".lag", $5, ts}' > \
      /dev/tcp/${GRAPHITE_HOST}/${GRAPHITE_PORT}
  done
  sleep ${SLEEP}
done
