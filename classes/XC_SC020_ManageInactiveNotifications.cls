/**
 * The Class XC_SC020_ManageInactiveNotifications.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 24/07/2019
 * @date Modification : dd/mm/yyyy
 * @description       : XC_SC020_ManageInactiveNotifications – Batch for manage inactive notifications
 **/


public without sharing class XC_SC020_ManageInactiveNotifications implements Schedulable, Database.Batchable<sObject> {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC020_ManageInactiveNotifications');
    

    /**
	* @description execute method
	* @param sc - SchedulableContext 
	*/ 
    public void execute(SchedulableContext sc) { 
        Id batchId = Database.executeBatch(new XC_SC020_ManageInactiveNotifications());
    }
    

    /**
    * @description start method
    * @param bc - BatchableContext 
    * @return Database.QueryLocator  
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Start batch XC_SC020_ManageInactiveNotifications');

        String recordType = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByName().get('Order').getRecordTypeId();

        String query = 'SELECT Id, XC_Country__c, NE__OptyId__c, NE__OptyId__r.XC_LegalEntity__c, NE__OptyId__r.XC_Contact__c, NE__OptyId__r.XC_Contact__r.AccountId, NE__OptyId__r.XC_Contact__r.Name, NE__OptyId__r.XC_Contact__r.Email, NE__OptyId__r.XC_Contact__r.XC_Preferredlanguageofcontact__c FROM NE__Order__c';
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Query ---> ' + query);
					
		if(!Test.isRunningTest()) {
			query += ' WHERE RecordTypeId =: recordType AND XC_OrderToInactiveNotification__c = true AND NE__OptyId__r.XC_Contact__r.Email != null';
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Final query ---> ' + query);
		}

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'End start method for batch XC_SC020_ManageInactiveNotifications'); 
        return Database.getQueryLocator(query);
    }
    

    /**
    * @description execute method
    * @param bc - BatchableContext 
    * @param scope - list to execute logic on
    */
    public void execute(Database.BatchableContext bc, List<NE__Order__c> scope) {   
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Enter in execute method');

        List<XC_BatchErrorLog__c> errorLog = new List<XC_BatchErrorLog__c>();

        List<NE__Order__c> listOrderToProcess = new List<NE__Order__c>();
        List<Map<String,Object>> mapOrderForCustomInteraction = new List<Map<String,Object>>();
        for(NE__Order__c order : scope) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For Order ---> ' + order); 
            order.XC_InactiveNotificationDate__c = Date.Today();
            listOrderToProcess.add(order);

            Map<String,Object> data = new Map<String,Object>();
            data.put('customerType', 'Reminder_Order_Inactive');
            data.put('skipComunication', false);
            data.put('orderId', order.Id);
            data.put('opportunityId', order.NE__OptyId__c);
            data.put('legalEntity', order.NE__OptyId__r.XC_LegalEntity__c);
            data.put('contactId', order.NE__OptyId__r.XC_Contact__c);
            data.put('accountId', order.NE__OptyId__r.XC_Contact__r.AccountId);
            data.put('fullName', order.NE__OptyId__r.XC_Contact__r.Name);
            data.put('email', order.NE__OptyId__r.XC_Contact__r.Email);
            data.put('preferredlanguage', order.NE__OptyId__r.XC_Contact__r.XC_Preferredlanguageofcontact__c);
            mapOrderForCustomInteraction.add(data);
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listOrderToProcess ---> ' + listOrderToProcess); 
        List<XC_UTIL_Sobject.WrapperResult> resultList = XC_UTIL_Sobject.updateListRecords(listOrderToProcess, false);
        for(XC_UTIL_Sobject.WrapperResult wr : resultList){
            if(!wr.success){
                errorLog.add(createBatchError(wr, 'XC_SC020_ManageInactiveNotifications', 'Update InactiveNotificationDate on Order based on LastModifyDate'));
            }
        }

        if(!mapOrderForCustomInteraction.isEmpty()){
            List<XC_UTIL_Sobject.WrapperResult> results = XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromOrders(mapOrderForCustomInteraction);
            for(XC_UTIL_Sobject.WrapperResult wr : results){
                if(!wr.success){
                    errorLog.add(createBatchError(wr, 'XC_SC020_ManageInactiveNotifications', 'Creation of Customer Interaction'));
                }
            }
        }

        XC_UTIL_Sobject.insertListRecords(errorLog);       
    }
    

    /**
    * @description finish method
    * @param bc - BatchableContext 
    */
    public void finish(Database.batchablecontext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Finish XC_SC020_ManageInactiveNotifications');
    }


    /**
    * @description finish method
    * @param bc - BatchableContext 
    */
    public static XC_BatchErrorLog__c createBatchError(XC_UTIL_Sobject.WrapperResult wr, String name, String operation) {

        XC_BatchErrorLog__c bel = new XC_BatchErrorLog__c();
        bel.Name = name;
        bel.XC_ErrorMessage__c = wr.errorMessage;
        bel.XC_TypeOfOperation__c = operation;
        bel.XC_RecordId__c = wr.errorObjectId;

        return bel;
    }
}