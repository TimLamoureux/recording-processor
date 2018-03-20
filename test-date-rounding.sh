#!/bin/bash

# Need to round to nearest hour. Epoch is seconds

date="2018-03-17 1:59:50"
date_epoch=$(date -d "$date" +%s)
echo "date: $date ; epoch: $date_epoch"


date_out=$(date -d "@ $(( (($date_epoch + 1800) / 3600 ) * 3600 ))")
echo "Out: $date_out"



#eval $(date +Y=%Y\;m=%m\;d=%d\;H=%H\;M=%M -d "${date}")
if [[ "$M" -gt "0" && "$M" -le "30" ]]; then
    M=00;
elif [[ "$M" -gt "30" && "$M" -le "59" ]]; then
    M=00
    ((H++))
#elif [[ "$M" < "30" ]] ; then M=15
#elif [[ "$M" < "45" ]] ; then M=30
#else M=45
fi
#echo $Y.$m.$d $H:$M
