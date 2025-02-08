/**
* @author Marco Lazzaroni - mlazzaroni@pic-informatica.it
* @date Creation 07/06/2021
* @description TAM_TR_CDCAssetEvent – Trigger on AssetChangeEvent for TAM backend sync
*/

trigger TAM_TR_CDCAssetEvent on AssetChangeEvent (after insert) {

    for(AssetChangeEvent cEvent : Trigger.new) {
        EventBus.ChangeEventHeader header = cEvent.ChangeEventHeader;
        Map<String, Object> serializedHeader = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(header));

        switch on header.changeType {
            when 'CREATE', 'UPDATE', 'UNDELETE' {
                Map<String, Set<Id>> EligibleAssetIdsByType = TAM_CDCObjectEventHelper.getEligibleAssetIdsByType(new Set<Id>((List<Id>)header.recordIds));
                for(String AssetType : EligibleAssetIdsByType.keySet()) {
                    System.enqueueJob(new TAM_AsyncPublishCDE('assets', AssetType, EligibleAssetIdsByType.get(AssetType), serializedHeader));
                }
            }
            when else {
            }
        }
    }

}