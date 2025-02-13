public class Batch_Call_Out_API_Example implements Database.Batchable<String>, Database.Stateful, Database.AllowsCallouts {
    private static final String API_ENDPOINT = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    private static final Integer MAX_CALLOUTS_PER_TRANSACTION = 100; // Limite governor Salesforce
    private static final Integer MAX_RETRIES = 3; // Massimo numero di riaccodamenti

    private List<String> addressQueue; // Coda dinamica degli indirizzi da processare
    private List<ProcessingResult> results = new List<ProcessingResult>(); // Risultati
    private String apiKey; // Chiave API
    private Integer retryCount = 0; // Contatore di riaccodamenti

    // Costruttore
    public Batch_Call_Out_API_Example(List<String> addresses, String apiKey) {
        this.addressQueue = addresses != null ? addresses : new List<String>();
        this.apiKey = apiKey;
    }

    // Metodo start: restituisce la coda degli indirizzi
    public Iterable<String> start(Database.BatchableContext bc) {
        return addressQueue;
    }

    // Metodo execute: processa un batch di indirizzi
    public void execute(Database.BatchableContext bc, List<String> currentBatch) {
        List<String> unprocessed = new List<String>(); // Indirizzi non processati
        Integer calloutCount = 0;

        for (String address : currentBatch) {
            if (calloutCount >= MAX_CALLOUTS_PER_TRANSACTION || Limits.getCallouts() >= Limits.getLimitCallouts()) {
                unprocessed.add(address); // Salva gli indirizzi non processati
                continue;
            }

            try {
                // Costruzione endpoint
                Map<String, String> params = new Map<String, String>{
                    'input' => EncodingUtil.urlEncode(address, 'UTF-8'),
                    'key' => apiKey,
                    'components' => 'country:it'
                };
                String endpoint = API_ENDPOINT + '?' + serializeParams(params);

                // Esecuzione chiamata API
                HttpRequest request = new HttpRequest();
                request.setEndpoint(endpoint);
                request.setMethod('GET');
                request.setTimeout(12000);

                HttpResponse response = new Http().send(request);

                // Elaborazione risposta
                ProcessingResult result = new ProcessingResult(address);
                if (response.getStatusCode() == 200) {
                    result.responseData = JSON.deserializeUntyped(response.getBody());
                } else {
                    result.error = 'HTTP Error: ' + response.getStatusCode();
                }
                results.add(result);
                calloutCount++;
            } catch (Exception e) {
                ProcessingResult result = new ProcessingResult(address);
                result.error = 'Exception: ' + e.getMessage();
                results.add(result);
            }
        }

        // Riaccoda gli indirizzi non processati
        if (!unprocessed.isEmpty() && retryCount < MAX_RETRIES) {
            this.addressQueue.addAll(unprocessed);
            retryCount++;
            Database.executeBatch(this, 1); // Riaccoda con batch size 1
        }
    }

    // Metodo finish: gestisce il completamento del batch
    public void finish(Database.BatchableContext bc) {
		// Se ci sono ancora indirizzi non processati e non abbiamo superato il numero massimo di tentativi
		if (!addressQueue.isEmpty() && retryCount < MAX_RETRIES) {
			Database.executeBatch(new Batch_Call_Out_API_Example(addressQueue, apiKey), 1);
		} else {
			// Logica di persistenza risultati (esempio)
			List<Log__c> logs = new List<Log__c>();
			for (ProcessingResult res : results) {
				logs.add(new Log__c(
					Details__c = res.toJson()
				));
			}
			insert logs;

			// Invia email di riepilogo
			sendSummaryEmail();
		}
	}

	// Metodo per inviare l'email di riepilogo
	private void sendSummaryEmail() {
		// Configurazione email
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		email.setToAddresses(new String[] { 'admin@example.com' }); // Imposta l'indirizzo email del destinatario
		email.setSubject('Riepilogo Batch_Call_Out_API_Example - ' + System.now());

		// Costruzione corpo email
		Integer successCount = 0;
		Integer errorCount = 0;
		StringBuilder emailBody = new StringBuilder();
		emailBody.append('Riepilogo esecuzione Batch_Call_Out_API_Example:\n\n');
		emailBody.append('Totale indirizzi processati: ' + results.size() + '\n');

		for (ProcessingResult res : results) {
			if (res.error == null) {
				successCount++;
			} else {
				errorCount++;
			}
		}

		emailBody.append('Indirizzi elaborati con successo: ' + successCount + '\n');
		emailBody.append('Indirizzi con errori: ' + errorCount + '\n\n');

		if (errorCount > 0) {
			emailBody.append('Dettagli errori:\n');
			for (ProcessingResult res : results) {
				if (res.error != null) {
					emailBody.append('Indirizzo: ' + res.inputAddress + '\n');
					emailBody.append('Errore: ' + res.error + '\n\n');
				}
			}
		}

		email.setPlainTextBody(emailBody.toString());

		// Invia l'email
		try {
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
		} catch (Exception e) {
			System.debug('Errore durante l\'invio dell\'email: ' + e.getMessage());
		}
	}

    // Metodo per serializzare i parametri dell'endpoint
    private String serializeParams(Map<String, String> params) {
        List<String> pairs = new List<String>();
        for (String key : params.keySet()) {
            pairs.add(EncodingUtil.urlEncode(key, 'UTF-8') + '=' + EncodingUtil.urlEncode(params.get(key), 'UTF-8'));
        }
        return String.join(pairs, '&');
    }

    // Classe wrapper per i risultati
    public class ProcessingResult {
        public String inputAddress;
        public String error;
        public Object responseData;

        public ProcessingResult(String address) {
            this.inputAddress = address;
        }

        public String toJson() {
            return JSON.serialize(this);
        }
    }
}