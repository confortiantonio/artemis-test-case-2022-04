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

### STEP5

By using a Proton producer, the broker behaves differently but not correctly.
We have experienced two different bugs:

1st bug:
Follow these steps:

1.	Start the producer (./bin/tickerplan-proton-prd.sh) : let it generate a bunch of messages …


msgNumber 147 msgKey 1000  
msgNumber 148 msgKey 1000  
msgNumber 149 msgKey 1000  
msgNumber 150 msgKey 1000  
msgNumber 151 msgKey 1000  
msgNumber 152 msgKey 1000  
msgNumber 153 msgKey 1000  
msgNumber 154 msgKey 1000  
msgNumber 155 msgKey 1000  
msgNumber 156 msgKey 1000  
msgNumber 157 msgKey 1000  

2.	Start the consumer (./bin/proton-tickerplan-cns.sh)

RECEIVE: Opened receiver for source address 'TICKERPLAN::LVQ'

Message #1 Received: body<sent at 27-04-2022 10:17:19> key<0> messageNumber<0>  
Message #2 Received: body<sent at 27-04-2022 10:17:30> key<1000> messageNumber<107>  
Message #3 Received: body<sent at 27-04-2022 10:17:30> key<1000> messageNumber<108>  
Message #4 Received: body<sent at 27-04-2022 10:17:30> key<1000> messageNumber<109>  
Message #5 Received: body<sent at 27-04-2022 10:17:31> key<1000> messageNumber<110>  
….

3.	Stop the consumer
4.	Stop the producer
5.	Start the consumer

RECEIVE: Opened receiver for source address 'TICKERPLAN::LVQ'  
Message #1 Received: body<sent at 27-04-2022 10:18:48> key<1000> messageNumber<157>  
Message #2 Received: body<sent at 27-04-2022 10:18:32> key<0> messageNumber<0>  
Message #3 Received: body<sent at 27-04-2022 10:18:48> key<1000> messageNumber<157>   <- Duplicate Message  

6.	Stop the consumer

2nd  bug:
Follow these steps:

1.	Start the producer : let it generate a bunch of messages 

…
msgNumber 27 msgKey 1000  
msgNumber 28 msgKey 1000  
msgNumber 29 msgKey 1000  
msgNumber 30 msgKey 1000  
msgNumber 31 msgKey 1000  
msgNumber 32 msgKey 1000  
msgNumber 33 msgKey 1000  
msgNumber 34 msgKey 1000  
msgNumber 35 msgKey 1000  
msgNumber 36 msgKey 1000  

2.	Stop the producer
3.	Start the consumer

RECEIVE: Opened receiver for source address 'TICKERPLAN::LVQ'  
Message #1 Received: body<sent at 27-04-2022 10:27:35> key<0> messageNumber<0>  
Message #2 Received: body<sent at 27-04-2022 10:27:44> key<1000> messageNumber<84>  

4.	Stop the consumer
5.	Start the producer
6.	Stop the producer
7.	Start the consumer

RECEIVE: Opened receiver for source address 'TICKERPLAN::LVQ'  
Message #1 Received: body<sent at 27-04-2022 10:27:59> key<0> messageNumber<0>  
Message #2 Received: body<sent at 27-04-2022 10:28:02> key<1000> messageNumber<36>  
Message #3 Received: body<sent at 27-04-2022 10:27:59> key<0> messageNumber<0>                  <- Duplicate Message  
Message #4 Received: body<sent at 27-04-2022 10:28:02> key<1000> messageNumber<36>              <- Duplicate Message  

### STEP 6 (case RH 03202592)

1.	Start the producer (./tickerplan-proton-prd-nodelay.sh in https://github.com/confortiantonio/artemis-test-case-2022-04/tree/main/test-case-lvq/step5/bin)
2.	Stop the producer

…
msgNumber 77665 msgKey 1000  
msgNumber 77666 msgKey 1000  
msgNumber 77667 msgKey 1000  
msgNumber 77668 msgKey 1000  
msgNumber 77669 msgKey 1000  
msgNumber 77670 msgKey 1000  
msgNumber 77671 msgKey 1000  
msgNumber 77672 msgKey 1000  
msgNumber 77673 msgKey 1000  
msgNumber 77674 msgKey 1000  
msgNumber 77675 msgKey 1000  
msgNumber 77676 msgKey 1000  

3.	Start the consumer (proton-tickerplan-cns.sh in https://github.com/confortiantonio/artemis-test-case-2022-04/tree/main/test-case-lvq/step5/bin)

RECEIVE: Opened receiver for source address 'TICKERPLAN::LVQ'  
Message #1 Received: body<sent at 27-04-2022 12:11:11> key<0> messageNumber<0>  
Message #2 Received: body<sent at 27-04-2022 12:11:21> key<1000> messageNumber<77676>  


4.	Start the producer
5.	The consumer receives

…
Message #3 Received: body<sent at 27-04-2022 12:01:18> key<0> messageNumber<0>  
Message #4 Received: body<sent at 27-04-2022 12:01:18> key<1000> messageNumber<28>  

6.	Stop the producer
7.	Stop the consumer
8.	Start the producer
…
msgNumber 156349 msgKey 1000  
msgNumber 156350 msgKey 1000  
msgNumber 156351 msgKey 1000  
msgNumber 156352 msgKey 1000  
msgNumber 156353 msgKey 1000  
msgNumber 156354 msgKey 1000  
msgNumber 156355 msgKey 1000  
msgNumber 156356 msgKey 1000  
msgNumber 156357 msgKey 1000  
msgNumber 156358 msgKey 1000  
msgNumber 156359 msgKey 1000  

9.	Start the consumer

Message #1 Received: body<sent at 27-04-2022 12:17:02> key<0> messageNumber<0>  
Message #2 Received: body<sent at 27-04-2022 12:17:16> key<1000> messageNumber<111624>  
Message #3 Received: body<sent at 27-04-2022 12:17:16> key<1000> messageNumber<111626>  
Message #4 Received: body<sent at 27-04-2022 12:17:02> key<0> messageNumber<0>                   <- Duplicate message (same as Step 5 ??)  
Message #5 Received: body<sent at 27-04-2022 12:17:17> key<1000> messageNumber<112375>  
Message #6 Received: body<sent at 27-04-2022 12:17:17> key<1000> messageNumber<112375> <- Duplicate message  
Message #7 Received: body<sent at 27-04-2022 12:17:17> key<1000> messageNumber<112684>  


## TEST CASE FILTERS
In this test case the producer sends n messages updating three keys 0,1 and 2 to the address SELECTOR.

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

### STEP 3

Follow these steps:

1.	Start the producer (push-srv-proton-prd-selector.sh in https://github.com/confortiantonio/artemis-test-case-2022-04/tree/main/test-case-filters/step3/bin)
2.	Start a 1st  consumer without filter (proton-consumer-nofilter.sh)
3.	Start a 2nd consumer without filter (proton-consumer-nofilter.sh)

Messages are round-robined to both consumers 

4.	Stop the 2nd consumer without filter
5.	Start a 2nd consumer with filter (proton-consumer-filter.sh)

Filtered messages are round-robined to both consumers 

6.	Stop the 2nd consumer with filter

The 1st consumer continues to receive filtered messages

7.	Stop the 1st consumer without filter
8.	Start the 1st consumer without filter (proton-consumer-nofilter.sh)

The 1st consumer receives all messages

## Versions
- amq-broker-7.9.0
- active-mq-cms-3.9.5
- amq-clients-2.9.0
