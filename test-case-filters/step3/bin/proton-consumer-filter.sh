#!/bin/bash
export LD_LIBRARY_PATH=/sviluppo/repo-git/prometheus-cpp/_build/deploy/usr/local/lib64:/sviluppo/repo-git/qpid-proton-0.33.0/build/cpp

#FILTER="bv.%.%.id"
FILTER="bv.%.1.id"
URL="//127.0.0.1:61616"
ADDRESS="SELECTOR::QUEUE.SEL"

../proton-consumer/bin/x64/Debug/proton-consumer.out $URL  $ADDRESS "SUBJECT LIKE '$FILTER'"
