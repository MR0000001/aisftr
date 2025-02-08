/**
* @author Domenico Del Prete - domenico.delprete@nttdata.com
* @date Creation 20/01/2021
* @description XC_SC051_PopulateOwnerExternalOrder – Batch used to populate the correct OwnerId on the Order from External System
*/
public without sharing class XC_SC051_PopulateOwnerExternalOrder implements Schedulable, Database.Batchable<sObject>{

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC051_PopulateOwnerExternalOrder');

    /**
     * @description execute method
     * @param sc - SchedulableContext 
    */
    public void execute(SchedulableContext sc) { 
        Database.executeBatch(new XC_SC051_PopulateOwnerExternalOrder(), 200);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Batch XC_SC051_PopulateOwnerExternalOrder in execution'); 
    }

    /**
     * @description Start method for batch
     * @param bc - BatchableContext 
     * @return Database.QueryLocator  
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In XC_SC051_PopulateOwnerExternalOrder');
        String query = 'SELECT Id, Name, Createddate, XC_SalesChannel__c, XC_SalesSubChannel__c, XC_UserChannelCode__c, XC_UserSubchannelCode__c, XC_CampaignPlatform__c, XC_LegalEntity__c  FROM NE__Order__c WHERE XC_UserSubchannelCode__c != null AND RecordType.name  = \''+'Order'+'\' AND  OwnerId NOT IN (SELECT Id FROM User WHERE XC_SubChannel__c != null)  and CreatedDate = LAST_N_DAYS:30 ORDER BY CreatedDate desc';
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Query for scope --> ' + query);
        System.debug('@@@ Query for scope --> ' + query);
        return Database.getQueryLocator(query);                                         
    }  

    /**
    * @description Execute method for batch
    * @param bc - Database.BatchableContext
    * @param scope - List<WorkOrder>
    */
    public void execute(Database.BatchableContext bc, List<NE__Order__c> scope) {
        List<NE__Order__c> listOfOrder = new List<NE__Order__c>();
        Set<String> setOfLegalEntity = new Set<String>();
        Set<String> setOfSubChannel = new Set<String>();
        for(NE__Order__c ord : scope){
            if(!String.isEmpty(ord.XC_LegalEntity__c)){
                setOfLegalEntity.add(ord.XC_LegalEntity__c);
            }
            if(!String.isEmpty(ord.XC_UserSubchannelCode__c)){
                setOfSubChannel.add(ord.XC_UserSubchannelCode__c);
            }
        }
        List<User> listOfUser = [SELECT Id, XC_SubChannel__c, XC_LegalEntity__c FROM User WHERE XC_SubChannel__c != '' AND XC_SubChannel__c IN: setOfSubChannel AND XC_LegalEntity__c IN :setOfLegalEntity  and IsActive =: true];
        Map<String, List<User>> mapLegalEntityListOfUsers = new Map<String, List<User>>();
        Map<String, User> mapSubChannelUser = new Map<String, User>();
        for(User us : listOfUser){
            if(!String.isEmpty(us.XC_SubChannel__c)){
                mapSubChannelUser.put(us.XC_SubChannel__c, us);
            }
        }
        for(NE__Order__c ord : scope){
            if(!String.isEmpty(ord.XC_UserSubchannelCode__c) && !String.isEmpty(ord.XC_LegalEntity__c)){
                if(mapSubChannelUser.get(ord.XC_UserSubchannelCode__c) != null && mapSubChannelUser.get(ord.XC_UserSubchannelCode__c).XC_LegalEntity__c == ord.XC_LegalEntity__c){
                    ord.OwnerId = mapSubChannelUser.get(ord.XC_UserSubchannelCode__c).Id;
                    listOfOrder.add(ord);
                }
            }
        }
        XC_TR_Configuration_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_Configuration_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        List<XC_UTIL_Sobject.WrapperResult> wrapperResultList = XC_UTIL_Sobject.updateListRecords(listOfOrder);
        XC_TR_Configuration_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_Configuration_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        // Batch Error Log for fail:
        List<XC_BatchErrorLog__c> errorLog = new List<XC_BatchErrorLog__c>();
        for(XC_UTIL_Sobject.WrapperResult wr : wrapperResultList){
            if(!wr.success){
                XC_BatchErrorLog__c bel = new XC_BatchErrorLog__c();
                bel.Name = 'XC_SC051_PopulateOwnerExternalOrder';
                bel.XC_ErrorMessage__c = wr.errorMessage;
                bel.XC_TypeOfOperation__c = 'Populate OwnerId batch';
                bel.XC_RecordId__c = wr.errorObjectId; 
                errorLog.add(bel);
            }
        }
        XC_UTIL_Sobject.insertListRecords(errorLog);
    }

    /**
     * @description Finish method for batch
     * @param bc - BatchableContext 
    */
    public void finish(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Finish Batch SC051');
    }  
}