#!/bin/bash
URL="//127.0.0.1:61616"
ADDRESS="TICKERPLAN::LVQ?consumer.prefetchSize=100"

../proton-tickerplan-cns/bin/x64/Debug/proton-tickerplan-cns.out $URL  $ADDRESS 
