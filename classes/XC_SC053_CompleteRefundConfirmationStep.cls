/**
* @author Marina Ciavarra - mciavarra@deloitte.it
* @date Creation 12/05/2021
* @description XC_SC053_CompleteRefundConfirmationStep – Complete the Refoud Confirmation set when the refound is executed
*/

public with sharing class XC_SC053_CompleteRefundConfirmationStep implements Schedulable, Database.Batchable<sObject>  {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC053_CompleteRefundConfirmationStep');
    /**
        * @author Marina Ciavarra - mciavarra@deloitte.it
        * @description start
        * @param bc - BatchableContext 
        * @return Database.getQueryLocator
       */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        if(!Schema.sObjectType.Zuora__Refund__c.isAccessible()){
            return null;
        }
        String query =  'SELECT Id, Zuora__Status__c, XC_Case__c, XC_Order__c, SubscriptionName__c' +
                        ' FROM Zuora__Refund__c ' +
                        ' WHERE SubscriptionName__c != null' +
                        ' AND Value_Date__c != null';
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'query' + query);              
        return Database.getQueryLocator(query);
    }

    /**
    * @description execute method
    * @param sc - SchedulableContext
    */
    public void execute(SchedulableContext sc) { 
        Id batchId = Database.executeBatch(new XC_SC053_CompleteRefundConfirmationStep(), 100);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'batch XC_SC053_CompleteRefundConfirmationStep in execution'); 
    }

    /** 
    * @description execute method
    * @param bc - BatchableContext 
    * @param scope - list to execute logic on
   */
    public void execute(Database.BatchableContext bc, List<Zuora__Refund__c> scope) {
        List<XC_BatchErrorLog__c> errorLog = new List<XC_BatchErrorLog__c>(); 
        List<XC_Provisioning_Step__c> stepListToUpdate = new List<XC_Provisioning_Step__c>(); 
        List<Zuora__Refund__c> refundListToUpdate =  new List<Zuora__Refund__c>();
        List<String> listConfigItem = new List<String>();
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'scope ' + scope); 
        
        Map<String, Zuora__Refund__c> refoundMap = populateRefundMap(scope);
        List<String> listSubscriptionName =  XC_UTIL_Sobject.getListFieldValues(scope, 'SubscriptionName__c');
        
        Map<Id, Asset> mapAsset = new Map<Id, Asset>([SELECT ID, XC_SubscriptionName__c, XC_Configuration_Item__c
                                                        FROM Asset 
                                                        WHERE XC_SubscriptionName__c IN: listSubscriptionName]); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapAsset -> ' + mapAsset);
        listConfigItem = populateListConfItem(mapAsset);

        Map<Id, XC_Provisioning_Step__c> mapSteps = new Map<Id, XC_Provisioning_Step__c>([SELECT ID, XC_Status__c, XC_Configuration_Item__c, 
                                                                                            XC_Configuration_Item__r.NE__OrderId__c, XC_Configuration_Item__r.NE__OrderId__r.XC_CaseId__c
                                                                                            FROM XC_Provisioning_Step__c 
                                                                                            WHERE XC_Configuration_Item__c IN: listConfigItem
                                                                                            AND XC_Status__c = 'In Progress']); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapSteps -> ' + mapSteps);

        Map<Id,Zuora__Refund__c> mapStepRefound = populateMapStepRefound (mapSteps, mapAsset, refoundMap );
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapStepRefund -> ' + mapStepRefound);

        for(Id stepId : mapStepRefound.keySet()){
            XC_Provisioning_Step__c step = mapSteps.get(stepId);
            step.XC_Status__c = Label.XC_CL_Completed_Ok;
            stepListToUpdate.add(step);
            Zuora__Refund__c refund = mapStepRefound.get(stepId);
            refund.XC_Case__c = step.XC_Configuration_Item__r.NE__OrderId__r.XC_CaseId__c;
            refund.XC_Order__c = step.XC_Configuration_Item__r.NE__OrderId__c;
            refundListToUpdate.add(refund);
        }

        List<XC_UTIL_Sobject.WrapperResult> listWrapperResult = XC_UTIL_Sobject.updateListRecords(stepListToUpdate);
        List<XC_UTIL_Sobject.WrapperResult> listWrapperResultRefund = XC_UTIL_Sobject.updateListRecords(refundListToUpdate);
        listWrapperResult.addAll(listWrapperResultRefund);
        for(XC_UTIL_Sobject.WrapperResult wr : listWrapperResult){
            if(!wr.success){
                XC_BatchErrorLog__c bel = new XC_BatchErrorLog__c();
                bel.Name = 'XC_SC053_CompleteRefundConfirmationStep';
                bel.XC_ErrorMessage__c = wr.errorMessage;
                bel.XC_TypeOfOperation__c = 'Complete refund steps batch';
                bel.XC_RecordId__c = wr.errorObjectId;
                                    errorLog.add(bel);
            }
        }
        XC_UTIL_Sobject.insertListRecords(errorLog);
    }

    /** 
    * @description execute method
    * @param bc - BatchableContext 
    */
    public void finish(Database.BatchableContext bc) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'FINISH batch XC_SC053_CheckDocumentationsValidity');
    }

    /**
    * Populate List BPLI.
    * @param mapAsset Map<Id, Asset>
    * @description Method to populate the bpli list
    */
    private static List<String> populateListConfItem(Map<Id, Asset> mapAsset){
        List<String> listConfItem = new List<String>();
        for(Id assetId : mapAsset.keySet()){
            listConfItem.add(mapAsset.get(assetId).XC_Configuration_Item__c);
        }
        return listConfItem;
    }

    /**
    * Populate Map <ConfigurationItemId, asset>.
    * @param mapAsset Map<Id, Asset>
    * @description Method create a map containing as key id of Configuratio Item and as value the Asset
    */
    private static Map<Id, Asset> populateMapCIAsset(Map<Id, Asset> mapAsset){
        Map<Id, Asset> mapCIAsset = new Map<Id, Asset>();
        for(Id assetId : mapAsset.keySet()){
            Id key = mapAsset.get(assetId).XC_Configuration_Item__c;
            Asset value= mapAsset.get(assetId);
            mapCIAsset.put(key, value);
        }
        return mapCIAsset;
    }
    
    /**
    * Populate Map <SubscriptionName, Zuora__Refund__c>.
    * @param refundList List<Zuora__Refund__c>
    * @description Method create a map containing as key the subscriptionName and as value Zuora__Refund__c
    */
    private static Map<String, Zuora__Refund__c> populateRefundMap (List<Zuora__Refund__c> refundList){
        Map<String, Zuora__Refund__c> refoundMap = new Map<String, Zuora__Refund__c>();
        for(Zuora__Refund__c refund : refundList){
            refoundMap.put(refund.SubscriptionName__c, refund);
        }
        return refoundMap;
    }
    
    /**
    * Populate Map <ProvisioningStepId, Zuora__Refund__c>.
    * @param mapStep Map<Id, XC_Provisioning_Step__c>
    * @param mapAsset Map<Id, Asset>
    * @param refoundMap Map<String, Zuora__Refund__c>
    * @description Method create a map containing as key the Provisioning Step id and as value Zuora__Refund__c
    */
    private static Map<Id,Zuora__Refund__c> populateMapStepRefound (Map<Id, XC_Provisioning_Step__c> mapSteps, Map<Id, Asset> mapAsset, Map<String, Zuora__Refund__c> refoundMap ){
        Map<Id,Zuora__Refund__c> mapStepRefound = new Map<Id,Zuora__Refund__c>();
        Map<Id, Asset> mapCIAsset = populateMapCIAsset(mapAsset);
        for(XC_Provisioning_Step__c step :  mapSteps.values()){
            Id key = step.Id; 
            String sName = mapCIAsset.get(step.XC_Configuration_Item__c).XC_SubscriptionName__c;
            Zuora__Refund__c value = refoundMap.get(sName);
            mapStepRefound.put(key, value);
        }
        return mapStepRefound;
    }
}