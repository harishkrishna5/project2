#!/bin/bash

usage() {
    echo 'Usage: monitor.sh "result_folder" "check_1 params" "check_2" ...'
}

if [ "$#" -lt 2 ]; then
    usage
    exit 1
fi
PROMETHEUS_COLLECTOR_FOLDER=/var/lib/node_exporter/textfile_collector
FOLDER=$1
# create result folder if not exist
if [ ! -d "$FOLDER" ]; then
  mkdir -p "$FOLDER"
fi

shift
CHECKS=("$@")

for c in "${CHECKS[@]}"
do
        # Run the check
        RES=`/local/armdata/scripts/check_mk/arm_monitor_wrapper.sh $c`
        CODE=$?

        # Strip the new line into one
        RES=`echo "$RES" | tr '\n' ' - '`

        # Extract output of the check
        CHECK_CMD=`echo "$c"|cut -d' ' -f1`
        CMD_TXT=`echo "$RES" |cut -d'|' -f1`
        PERF=`echo "$RES" |cut -d'|' -f2`

        if [[ "$PERF" == "$CMD_TXT" ]]; then
            # If no perf data
            echo "$CODE $CHECK_CMD - $RES" > $FOLDER/${CHECK_CMD}_result.txt
            echo "#$CHECK_CMD gauge" > $PROMETHEUS_COLLECTOR_FOLDER/${CHECK_CMD}_result.prom
            echo "$CHECK_CMD $CODE" >> $PROMETHEUS_COLLECTOR_FOLDER/${CHECK_CMD}_result.prom
        else
            # With perf data, change the delimiter of perf from space to pipe
            PERF_F=`echo "$PERF" | xargs | sed 's/ /|/g' `

            echo "$CODE $CHECK_CMD $PERF_F $CMD_TXT" > $FOLDER/${CHECK_CMD}_result.txt
            METRIC=`echo $PERF_F | awk -F '=' '{print $2}' | awk -F ';' '{print $1}' | sed 's/[A-Za-z]*//g'`
            echo "#$CHECK_CMD gauge" > $PROMETHEUS_COLLECTOR_FOLDER/${CHECK_CMD}_result.prom
            echo "$CHECK_CMD $CODE" >> $PROMETHEUS_COLLECTOR_FOLDER/${CHECK_CMD}_result.prom
            echo "#${CHECK_CMD}_perf gauge" > $PROMETHEUS_COLLECTOR_FOLDER/${CHECK_CMD}_perf_result.prom
            echo "${CHECK_CMD}_perf $METRIC" >> $PROMETHEUS_COLLECTOR_FOLDER/${CHECK_CMD}_perf_result.prom

        fi
done
