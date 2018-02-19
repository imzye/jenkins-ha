#!/bin/bash
ETCD_IP_LIST="etcd1.ip etcd2.ip etcd3.ip"
ETCD_PORT="2379"
EP=$(hostname)
KEY_NAME="j_master"
TTL=10
HBT=2
MASTER_IP=""
## startup
function rand_ip() {
  min=1
  max=$(echo $ETCD_IP_LIST|awk '{print NF}')
  num=$(($RANDOM+1000000000))
  rand=$(($num%$max+$min))
  echo $ETCD_IP_LIST |cut -d" " -f$rand
}

function self_reg() {
  rc=$(curl -s $ETCD_IP:$ETCD_PORT/v2/keys/$KEY_NAME -XPUT -d value="$EP" -d prevExist="false" -d ttl=$TTL|jq '.["errorCode"]')
}

function get_master_ip() {
  MASTER_IP=$(curl -s $ETCD_IP:$ETCD_PORT/v2/keys/$KEY_NAME |jq '.["node"]["value"]')
}

function refresh_ttl() {
  x=$(curl -s $ETCD_IP:$ETCD_PORT/v2/keys/$KEY_NAME -XPUT -d ttl=$TTL -d refresh=true -d prevExist=true)
}

while :;do
ETCD_IP=$(rand_ip)
self_reg
if [[ $rc -eq 105 ]];then
  get_master_ip
  echo "[INFO] `date '+%Y-%m-%d %H:%M:%S'` MASTER_IP: $MASTER_IP"
  if [[ "$MASTER_IP" == "\"$EP\"" ]];then
    echo "[INFO] `date '+%Y-%m-%d %H:%M:%S'` keep jenkins start"
    service jenkins start
    refresh_ttl
  else
    echo "[INFO] `date '+%Y-%m-%d %H:%M:%S'` service jenkins stop"
    service jenkins stop
    echo "[INFO] `date '+%Y-%m-%d %H:%M:%S'` sync data from $MASTER_IP"
    rsync -a ${MASTER_IP//\"/}::jenkins/var/lib/jenkins /var/lib/
    echo "[INFO] `date '+%Y-%m-%d %H:%M:%S'` data sync done"
  fi
elif [[ "$rc" == "null" ]];then
  echo "[INFO] `date '+%Y-%m-%d %H:%M:%S'` register success"
  continue
fi
sleep $HBT
done
