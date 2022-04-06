# artemis-test-case-2022-04

## Configurazione broker:


         <address-setting match="SELECTOR">
            <default-last-value-key>MESSAGE_KEY</default-last-value-key>
            <default-non-destructive>true</default-non-destructive>
         </address-setting>

        <address name="TICKERPLAN">
            <multicast>
               <queue name="LVQ" last-value-key="MESSAGE_KEY" non-destructive="true"/>
               <queue name="TICKER" />
            </multicast>
        </address>

        <address name="SELECTOR">
            <multicast>
               <queue name="QUEUE.SEL" />
            </multicast>
       </address>


## TEST CASE LVQ 

### STEP 1
Clean and start broker

Start producer: ./tickerplan-prd-brk_7.9.0.sh

Start CMS consumer: ./tickerplan-cns-TICKERPLAN-LVQ-prefetch-1.sh  -> Messages in the lvq queue no longer update

### STEP2
Clean e start broker 

Start producer: ./tickerplan-prd-brk_7.9.0.sh

Start proton consumer: ./proton-tickerplan-cns.sh -> duplicate receipt of the same key / value (first message)

Start CMS consumer: ./tickerplan-cns-TICKERPLAN-LVQ-prefetch-1.sh -> Messages in the lvq queue no longer update

### STEP3
Clean e start broker 

Start producer:  ./tickerplan-prd-brk_7.9.0.sh

Start proton consumer: proton-tickerplan-cns-prefetch-100.sh -> failure to receive key 0 

### STEP4
Start producer: ./tickerplan-prd-brk_7.9.0.sh no sleep

Stop producer: a 500K messaggi

Start CMS consumer:   ./tickerplan-cns-TICKERPLAN-LVQ-prefetch-1.sh  -> 
instead of receiving the latest image of snapshot message updates, we receive them "in blocks" until the last message sent by the producer is reached.
The same behavior is also observed with the console. Same behavior with the proton consumer.



## TEST CASE FILTERS

### STEP 1
Start producer  ./push-srv-proton-prd.sh

Start first proton consumer:  ./push-srv-proton-cns-filter-key-1.sh -> works as expected: filter messages with key 1

Start second proton consumer: ./push-srv-proton-cns-filter-key-1.sh -> messages are distributed anycast rather than multicast as expected

### STEP 2
Start producer:  ./push-srv-proton-prd.sh

Start proton consumer:  ./push-srv-proton-cns-filter-key-1.sh -> works as expected: filter messages with key 1

Start proton consumer:  ./push-srv-proton-cns-filter-key-2.sh -> no messages are received from either consumer
