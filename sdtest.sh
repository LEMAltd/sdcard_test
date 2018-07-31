#!/bin/bash

DEVICE=sdc

SIZE=$(cat /sys/block/$DEVICE/size)
COUNT=100

MIN=1000
MAX=0
AVG=0
SM=0.0

echo "0 0 0 0" > res.txt

gnuplot plot.gnu &

for((i=1; i < $SIZE; i++)); do

        MAX=0
        MIN=1000
        SM=0.0
        for ((a=0; a < $COUNT; a++)); do
                TIME=$(dd if=/dev/$DEVICE of=/dev/null bs=512 skip=$i count=1 2>&1 | awk '/скопировано/ {print $4}')
                TIME=$(echo "${TIME//,/$'.'}")
                if (( $(echo "$TIME > $MAX" | bc -l) )); then
                        MAX=$TIME
                fi
                if (( $(echo "$TIME < $MIN" | bc -l) )); then
                        MIN=$TIME
                fi
                SM=$(echo "$SM + $TIME"| bc -l)
        done
        AVG=$(echo "$SM / $COUNT" | bc -l)
        echo "Block=$i FROM=$SIZE MAX=$MAX MIN=$MIN AVG=$AVG"
        echo "$i $MAX $MIN $AVG" >> res.txt
done
