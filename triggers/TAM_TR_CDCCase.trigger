/**
* @author Marco Lazzaroni - mlazzaroni@pic-informatica.it
* @date Creation 07/10/2021
* @description TAM_TR_CDCCase – Trigger on CaseChangeEvent for TAM cases (cases associated to technical assets) backend sync
*/

trigger TAM_TR_CDCCase on CaseChangeEvent (after insert) {

    for(CaseChangeEvent cEvent : Trigger.new) {
        EventBus.ChangeEventHeader header = cEvent.ChangeEventHeader;
        Map<String, Object> serializedHeader = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(header));

        switch on header.changeType {
            when 'CREATE', 'UPDATE' {
                Set<Id> EligibleCaseIds = TAM_CDCObjectEventHelper.getEligibleCaseIds(new Set<Id>((List<Id>)header.recordIds));
                if(EligibleCaseIds != null && !EligibleCaseIds.isEmpty()) {
                    System.enqueueJob(new TAM_AsyncPublishCDE('cases', 'TAM_Case', EligibleCaseIds, serializedHeader));
                }
            }
            when else {
            }
        }
    }

}