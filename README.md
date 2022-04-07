# artemis-test-case-2022-04

## Broker configuration:


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
In this test case the producer sends a single message with key 0 and n messages with key 1 to the address TICKERPLAN.
A consumer on the LVQ queue will reads the messages produced

### STEP 1
- Clean and start broker

- Start producer: ./tickerplan-prd-brk_7.9.0.sh -> as expected, only one message with key 0 is written on queue lvq and the messages with key 1 are updated

- Start CMS consumer: ./tickerplan-cns-TICKERPLAN-LVQ-prefetch-1.sh  -> it's expected to read only one message with key 0 and the updates of the messages with key 1. What is obvserved is: the updates of the messages with key 1 are not received and messages in the lvq queue no longer update.

### STEP2
- Clean e start broker 

- Start producer: ./tickerplan-prd-brk_7.9.0.sh

- Start proton consumer: ./proton-tickerplan-cns.sh -> it's expected to read only one message with key 0 and the updates of the messages with key 1. What is obvserved is: the consumer reads twice the message with key 0.

- Start CMS consumer: ./tickerplan-cns-TICKERPLAN-LVQ-prefetch-1.sh -> it's expected to read only one message with key 0 and the updates of the messages with key 1. What is obvserved is: the updates of the messages with key 1 are not received and messages in the lvq queue no longer update

### STEP3
- Clean e start broker 

- Start producer:  ./tickerplan-prd-brk_7.9.0.sh

- Start proton consumer: proton-tickerplan-cns-prefetch-100.sh -> it's expected to read only one message with key 0 and the updates of the messages with key 1. What is obvserved is: the consumer don't reads the message with key 0 

### STEP4
- Start producer: ./tickerplan-prd-brk_7.0-nosleep.sh

- Stop producer at about 500K messages

- Start CMS consumer:   ./tickerplan-cns-TICKERPLAN-LVQ-prefetch-1.sh  -> it's expected to read the last two messagees witk key 0 and 1 sent by producer. What is obvserved is: the consumer reads messages "in blocks" until the last message sent by the producer is reached.
The same behavior is also observed with the console. Same behavior with the proton consumer.



## TEST CASE FILTERS
In this test case the producer sends n messages updating three keys 0,1 and 3 to the address SELECTOR.
Each message is sent with a property named SUBJECT containing values of the type:
"bv.quote.n%3.id" where n%3 is the result of operation n modulo 3.
A consumer on queue name "QUEUE.SEL" will read messages with a filter on property SUBJECT set to "bv.#.FILTER.id" where FILTER is a numeric param of consumer.


### STEP 1
- Start producer  ./push-srv-proton-prd-selector.sh

- Start first proton consumer:  ./push-srv-proton-cns-filter-key-1.sh -> works as expected: only messages with SUBJECT "bv.quote.1.id" are received

- Start second proton consumer: ./push-srv-proton-cns-filter-key-1.sh -> don't works as expected: messages are distributed anycast rather than multicast

### STEP 2
- Start producer:  ./push-srv-proton-prd-selector.sh

- Start proton consumer:  ./push-srv-proton-cns-filter-key-1.sh -> works as expected: filter messages with key 1 are received

- Start proton consumer:  ./push-srv-proton-cns-filter-key-2.sh -> don't works as expected: no messages are received from either consumer

## Versions
- amq-broker-7.9.0
- active-mq-cms-3.9.5
- amq-clients-2.9.0
