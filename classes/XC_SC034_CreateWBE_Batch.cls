global class XC_SC034_CreateWBE_Batch implements Database.Batchable<sObject> {


    global Database.QueryLocator start(Database.BatchableContext BC) { 
        //List<NE__OrderItem__c> oiList = [select id,NE__OrerId__c from NE__ORderItem__c where XC_Wbe__c = null and NE__OrderId__r.XC_LegalEntity__c in ('EnelXItalia','EnelSole','Cogenio','EnelXMobility','EnelXSrl','YouSaveSpA','ESCoComuniSrl') and NE__OrderId__r.XC_Segment__c in ('B2B','B2G')];
        String query = 'SELECT Id FROM NE__Order__c where XC_LegalEntity__c in (\'EnelXItalia\',\'EnelXMobilityItalia\',\'EnelSole\',\'Cogenio\',\'EnelXMobility\',\'EnelXMobilityHolding\',\'EnelXSrl\',\'YouSaveSpA\',\'ESCoComuniSrl\',\'EnelXMSP\') and XC_Segment__c in (\'B2B\',\'B2G\') and XC_update_WBE_from_Batch__c = false and RecordType.DeveloperName = \'Order\' and (CreatedBy.Username = \'migrationitab2bg@exprod.com\' OR CreatedBy.Username = \'Digrationitab2bg@exprod.com\' )';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<NE__Order__c> orderList) {
        XC_TR_WbeTracking_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_INSERT, true);
        for (NE__Order__c ord : orderList) {
            try{
            	XC_LCC_056_CalculateWBS.submit(ord.Id);
                ord.XC_update_WBE_from_Batch__c = true;
            }catch(Exception e){
                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());
            }
        }
        update orderList;
    }
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}