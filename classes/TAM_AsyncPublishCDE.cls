/**
* @author Marco Lazzaroni - mlazzaroni@pic-informatica.it
* @date Creation 10/01/2021
* @description TAM_AsyncPublishCDE – Async queuable class for change data event integration
*/

public class TAM_AsyncPublishCDE implements Queueable, Database.AllowsCallouts {
    private String topic;
    private String topicType = '';
    private Set<Id> recordIds;
    private Map<String, Object> header;

    public class AsyncPublishCDEException extends Exception {}

    public TAM_AsyncPublishCDE(String topic, String topicType, Set<Id> recordIds, Map<String, Object> header) {
        this.topic = topic;
        this.topicType = topicType;
        this.recordIds = recordIds;
        this.header = header;
    }

    public void execute(QueueableContext context) {
        switch on topic {
            when 'assets', 'cases' {
                List<String> payloads = TAM_CDCObjectEventHelper.getJSONPayload(topic, topicType, recordIds, header);
                if(payloads != null && !payloads.isEmpty()) {
                    TAM_CDCObjectEventHelper.publishCDEPayload(topic, payloads, header);
                }
            }
            when else {
                // DO NOTHING
            }
        }
    }
}