#!/bin/bash

available() {
    echo "Available simulations:"
    for d in simulations/*; do
        echo -n `basename $d`": "
        cat $d/description
    done
}

help() {
    echo "Usage: $0 [-h|--help] [-s|--simulation <simulation_name>]"
    available
}
POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"
    
    case $key in
        -h|--help)
            help
            exit 0
        ;;
        -s|--simulation)
            SIMULATION="$2"
            shift # past argument
            shift # past value
        ;;
        *)  # unknown option
            POSITIONAL+=("$1")
            shift # past argument
        ;;
    esac
done

RUNNING_CONTAINERS=`docker ps | grep mqtt | wc -l`
WSPORT=$((9001+$RUNNING_CONTAINERS))
MQTTPORT=$((1883+$RUNNING_CONTAINERS))
DBUSTCPPORT=$((3000+$RUNNING_CONTAINERS))

if test -n "$POSITIONAL"; then
    echo "Positional argument(s) ($POSITIONAL) passed. Did you mean to run with -s?"
    available
    exit 1
elif test -z "$SIMULATION"; then
    docker run -it --rm -p $WSPORT:9001 -p $MQTTPORT:1883 -p $DBUSTCPPORT:3000 mqtt
else
    if test -f simulations/$SIMULATION/setup; then
        docker run -d --rm -p $WSPORT:9001 -p $MQTTPORT:1883 -p $DBUSTCPPORT:3000 mqtt /root/run_with_simulation.sh $SIMULATION
    else
        echo "Simulation ($SIMULATION) does not exist in simulations/"
        available
        exit 1
    fi
fi