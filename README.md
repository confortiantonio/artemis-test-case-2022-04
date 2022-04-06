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
Clean e start broker

Avvio produttore  ./tickerplan-prd-brk_7.9.0.sh

Avvio consumatore CMS ./tickerplan-cns-TICKERPLAN-LVQ-prefetch-1.sh  -> I messagi presenti in coda lvq non si refreshano piu

### STEP2
Clean e start broker 

Avvio produttore  ./tickerplan-prd-brk_7.9.0.sh

Avvio consumatore proton ./proton-tickerplan-cns.sh -> ricezione duplicata della medesima chiave/valore (primo messaggio)

Avvio consumatore CMS ./tickerplan-cns-TICKERPLAN-LVQ-prefetch-1.sh -> I messagi presenti in coda lvq non si refreshano più

### STEP3
Clean e start broker 

Avvio produttore  ./tickerplan-prd-brk_7.9.0.sh

Avvio consumatore proton proton-tickerplan-cns-prefetch-100.sh -> mancata ricezione della chiave 0 (messaggio con chiave inserito ma non editato)

### STEP4
Avvio produttore  ./tickerplan-prd-brk_7.9.0.sh senza sleep

Stop produttore   a 500K messaggi

Avvio consumatore CMS  ./tickerplan-cns-TICKERPLAN-LVQ-prefetch-1.sh  -> invece di ricevere l ultima immagine snapshot ne riceviamo enne “a blocchi” fino al raggiungimento dell’ultimo messaggio inviato dal producer.
Lo stesso comportamento si osserva anche con la console. Stesso comportamento con il consumatore di tipo proton.



## TEST CASE FILTERS

### STEP 1
Avvio produttore  ./push-srv-proton-prd.sh

Avvio consumatore proton ./push-srv-proton-cns-filter-key-1.sh -> funziona come atteso: filtra i messaggi con chiave 1

Avvio secondo consumatore proton ./push-srv-proton-cns-filter-key-1.sh -> i messaggi vengono distribuiti in modalità anycast anziché multicast come atteso

### STEP 2
Avvio produttore  ./push-srv-proton-prd.sh

Avvio consumatore proton ./push-srv-proton-cns-filter-key-1.sh -> funziona come atteso: filtra i messaggi con chiave 1

Avvio consumatore proton ./push-srv-proton-cns-filter-key-2.sh -> non si riceve alcun messaggio da entrambi i consumatori
