# Jenkins HA Tool

[![wercker status](https://app.wercker.com/status/3a296a6449fba419c04992b250f1d062/s/master "wercker status")](https://app.wercker.com/project/byKey/3a296a6449fba419c04992b250f1d062)

## Description
利用etcd、haproxy实现Jenkins自动选主切换

## Language
bash >= 4.1

## Prerequest
- jq
- etcd cluster
- jenkins
- rsync service
- haproxy/elb
