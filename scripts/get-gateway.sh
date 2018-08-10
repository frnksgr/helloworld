#!/bin/bash

# usage: get-gateway.sh <namespace> <service>
#  return ip or hostname of external LB

gw=$(kubectl -n "$1" get svc "$2" \
    -o jsonpath="{.status.loadBalancer.ingress[0].ip}")

if [ -z $gw ]; then
    gw=$(kubectl -n "$1" get svc "$2" \
        -o jsonpath="{.status.loadBalancer.ingress[0].hostname}")
fi

echo $gw