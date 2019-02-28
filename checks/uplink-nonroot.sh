#! /usr/bin/env bash

# Set path to a save default
PATH="$(dirname "$0")/..:/usr/lib/gatemon:/usr/lib/nagios/plugins:/usr/lib/monitoring-plugins:/bin:/usr/bin:/sbin:/usr/sbin"

MIN_PORT="$[ 32768 - 20 ]"

. "$(dirname "$0")/../check-all-vpn-exits.cfg"

export TIMEFORMAT="%0R"

NETWORK_DEVICE="$1"
SERVER_IP4="$2"
SERVER_IP6="$3"
GATE="$4"

if [[ -z "$NETWORK_DEVICE" ]] || [[ -z "$SERVER_IP4" ]] || [[ -z "$SERVER_IP6" ]] || [[ -z "$GATE" ]]; then
  echo "$0 <device> <ipv4> <ipv6> <gatenum>" >&2
  exit 1
fi

cat <<EOF
    uplink:
      '0':
EOF

# IPv4
ELAPSED_TIME=0
STATUS_CODE=0

exec 3>&1 4>&2
ELAPSED_TIME="$( { time curl -4 --local-port $[ $MIN_PORT + $GATE ] --max-time 5 --silent --output /dev/null "http://${HOST_TO_FETCH}/" 1>&3 2>&4; } 2>&1)"
exec 3>&- 4>&-

if [[ "$?" = 0 ]]; then
  STATUS_CODE=1
fi

cat <<EOF
        ipv4: ${STATUS_CODE}
EOF

# IPv6
ELAPSED_TIME=0
STATUS_CODE=0

exec 3>&1 4>&2
ELAPSED_TIME="$( { time curl -6 --local-port $[ $MIN_PORT + $GATE ] --max-time 5 --silent --output /dev/null "http://${HOST_TO_FETCH}/" 1>&3 2>&4; } 2>&1)"
exec 3>&- 4>&-

if [[ "$?" = 0 ]]; then
  STATUS_CODE=1
fi

cat <<EOF
        ipv6: ${STATUS_CODE}
EOF
