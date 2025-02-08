/**
* @author Marco Lazzaroni - mlazzaroni@pic-informatica.it
* @date Creation 05/10/2021
* @description TAM_TR_CDCLocationEvent – Trigger on LocationChangeEvent for TAM Location (geolocation) backend sync
*/

trigger TAM_TR_CDCLocationEvent on LocationChangeEvent (after insert) {

    for(LocationChangeEvent cEvent : Trigger.new) {
        EventBus.ChangeEventHeader header = cEvent.ChangeEventHeader;
        Map<String, Object> serializedHeader = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(header));

        switch on header.changeType {
            when 'CREATE', 'UPDATE' {
                Map<String, Set<Id>> EligibleAssetIdsByType = TAM_CDCObjectEventHelper.getEligibleLocAssets(new Set<Id>((List<Id>)header.recordIds));
                for(String AssetType : EligibleAssetIdsByType.keySet()) {
                    System.enqueueJob(new TAM_AsyncPublishCDE('assets', AssetType, EligibleAssetIdsByType.get(AssetType), serializedHeader));
                }
            }
            when else {
            }
        }
    }

}