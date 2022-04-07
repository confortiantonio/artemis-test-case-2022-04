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
In this test case the producer sends a single message with key 0 and n messages with key 1000 to the address TICKERPLAN.
A consumer on the LVQ queue reads the messages produced

### STEP 1
A CMS consumer does not receive LVQ updates and blocks the broker.

- Clean and start broker

- Start producer: ./tickerplan-prd-brk_7.9.0.sh -> as expected, only one message with key 0 is written on queue lvq and the messages with key 1000 are updated

- Start CMS consumer: ./tickerplan-cns-TICKERPLAN-LVQ-prefetch-1.sh  -> it's expected to read only one message with key 0 and the updates of messages with key 1000. What is obvserved is: the updates of messages with key 1000 are not received and messages in the lvq queue are no longer updated.

### STEP2
A PROTON consumer receives twice the same message; when a CMS consumer is started, the CMS consumer behaves as in STEP1 and the broker is blocked also for the PROTON consumer.

- Clean e start broker 

- Start producer: ./tickerplan-prd-brk_7.9.0.sh

- Start proton consumer: ./proton-tickerplan-cns.sh -> it's expected to read only one message with key 0 and the updates of the messages with key 1000. What is obvserved is: the consumer reads twice the message with key 0.

- Start CMS consumer: ./tickerplan-cns-TICKERPLAN-LVQ-prefetch-1.sh -> it's expected to read only one message with key 0 and the updates of messages with key 1000. What is obvserved is: the updates of messages with key 1000 are not received and messages in the lvq queue are no longer updated

### STEP3
A PROTON consumer with prefetch size set to 100, does not receive all messages.

- Clean e start broker 

- Start producer:  ./tickerplan-prd-brk_7.9.0.sh

- Start proton consumer: proton-tickerplan-cns-prefetch-100.sh -> it's expected to read only one message with key 0 and the updates of the messages with key 1000. What is obvserved is: the consumer doesn't read the message with key 0 

### STEP4
When a large number of messages are sent to a LVQ queue, the consumer (CMS or PROTON) does not only receive the last image of the message but also a number of intermediate images. 

- Start producer: ./tickerplan-prd-brk_7.0-nosleep.sh

- Stop producer at about 500K messages

- Start CMS consumer:   ./tickerplan-cns-TICKERPLAN-LVQ-prefetch-1.sh  -> it's expected to read the last two messages witk key 0 and 1 sent by producer. What is obvserved is: the consumer reads messages "in blocks" until the last message sent by the producer is reached.
The same behavior is also observed with the console. 
Same behavior with the proton consumer.



## TEST CASE FILTERS
In this test case the producer sends n messages updating three keys 0,1 and 3 to the address SELECTOR.

Each message is sent with a property named SUBJECT containing values of the type:
"bv.quote.n%3.id" where n%3 is the result of operation n modulo 3.

A consumer on queue name "QUEUE.SEL" reads messages with a filter on property SUBJECT set to "bv.#.FILTER.id" where FILTER is a numeric parameter of the consumer.


### STEP 1
Two consumers with the same filter ("bv.quote.1.id") :
When only one consumer is active, it works as expected.
Two different consumers instead don't receive all the expected messages; it seems that each consumer receives only one half of the expected messages.
 
- Start producer  ./push-srv-proton-prd-selector.sh

- Start first proton consumer:  ./push-srv-proton-cns-filter-key-1.sh -> works as expected: only messages with SUBJECT "bv.quote.1.id" are received

- Start second proton consumer: ./push-srv-proton-cns-filter-key-1.sh -> when the consumer with SUBJECT "bv.quote.1.id" is started, both consumer don't work as expected: messages are distributed evenly between the 2 consumers

### STEP 2
Two consumers with different filters("bv.quote.1.id" and "bv.quote.2.id"):
When only one consumer is active, it works as expected.
Two different consumers instead don't receive messages.

- Start producer:  ./push-srv-proton-prd-selector.sh

- Start proton consumer:  ./push-srv-proton-cns-filter-key-1.sh -> works as expected: only messages with SUBJECT "bv.quote.1.id" are received

- Start proton consumer:  ./push-srv-proton-cns-filter-key-2.sh -> when the consumer with SUBJECT "bv.quote.2.id" is started, both consumer don't receive messages

## Versions
- amq-broker-7.9.0
- active-mq-cms-3.9.5
- amq-clients-2.9.0
