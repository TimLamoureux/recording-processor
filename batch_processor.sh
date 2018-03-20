#!/bin/bash

for i in {1..10}
do
   ./recording-processor.sh -d -u 1STMc4lIfTMqL-Z-Ujq1w3ev-jWmi0o72 -e mp3 --days_ago $i -p 'SIMA-173.64-' ../radio-recordings/ ../processed-recordings/
done
