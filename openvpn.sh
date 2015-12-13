#!/bin/sh

SCRIPTS_DIR='/usr/local/openvpn_as/scripts'

HOST="${COLLECTD_HOSTNAME:-`hostname -f`}"
PAUSE="${COLLECTD_INTERVAL:-10}"
RX=0
TX=0

while sleep $PAUSE
do

  NOW="$(date +%s)"
  CLIENTS_CONNECTED=`sudo $SCRIPTS_DIR/sacli VPNSummary | grep clients | awk '{print $2}'`
  CLIENTS_LICENSED=`sudo $SCRIPTS_DIR/liman info | grep -o  "[0-9]*"`
  echo "PUTVAL $HOST/openvpn/gauge-clients-connected interval=$PAUSE N:$CLIENTS_CONNECTED"
  echo "PUTVAL $HOST/openvpn/gauge-clients-licensed interval=$PAUSE N:$CLIENTS_LICENSED"
  RX_LIST=`sudo $SCRIPTS_DIR/sacli VPNStatus | tr '/' - |  jsonpipe  | grep "/openvpn_[0-9]/client_list/[0-9]/4" | tr -d '"'  | awk '{print $2}'`
  for i in $RX_LIST; do
    RX=`expr $RX + $i`
  done
  echo "PUTVAL $HOST/openvpn/derive-clients-rx interval=$PAUSE N:$RX"

  TX_LIST=`sudo $SCRIPTS_DIR/sacli VPNStatus | tr '/' - |  jsonpipe  | grep "/openvpn_[0-9]/client_list/[0-9]/5" | tr -d '"'  | awk '{print $2}'`
  for i in $TX_LIST; do
    TX=`expr $TX + $i`
  done
  echo "PUTVAL $HOST/openvpn/derive-clients-tx interval=$PAUSE N:$TX"
done

