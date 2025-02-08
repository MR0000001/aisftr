/**
 * @description       : XC_SC062_ContractAmendmentManagment to check if the payment is done
 * @author            : Donato Lombardi
 * @created date      : 28-10-2021
 * @last modified on  : 28-10-2021
 * @last modified by  : Nicola Mariniello - nmariniello@deloitte.it
 **/


public without sharing class XC_SC062_ContractAmendmentManagment implements Database.Batchable<Sobject>,Schedulable,  Database.AllowsCallouts {


    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC062_ContractAmendmentManagment');


    public void execute(SchedulableContext sc) {
        Id batchId = Database.executeBatch(new XC_SC062_ContractAmendmentManagment(), 1);
    }
    
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Contract_Amendment_Parent__c ,CreatedDate, XC_Contract__r.ContractNumber, XC_EndDateBeforeExtension__c, XC_EndDateAfterLastExtension__c, XC_Asset__r.Name, ' +
                            'XC_Asset__r.XC_Particle__c, XC_Asset__r.XC_Segment__c, XC_Status__c, XC_Asset__r.XC_LegalEntity__c, XC_Asset__r.XC_SubscriptionName__c, XC_Asset__r.XC_Configuration_Item__c, XC_CostAfterLastRevaluation__c, ' +
                            'XC_Asset__r.XC_Configuration_Item__r.NE__RecurringChargeOv__c, XC_Asset__r.XC_Configuration_Item__r.XC_CA_UpdatePrice__c, XC_Asset__r.XC_Configuration_Item__r.NE__OrderId__c, XC_Asset__r.NE__RecurringChargeFrequency__c,XC_Contract__r.EndDate, XC_Percentage__c, ' +
                            'XC_Asset__r.XC_Original_Configuration_Item__r.XC_ZQuoteId__c, XC_Asset__r.XC_Configuration_Item__r.XC_ZQuoteId__c, ' + 
                            '(SELECT Id, XC_Asset__r.XC_Particle__c, Contract_Amendment_Parent__c, XC_Asset__r.XC_SubscriptionName__c, XC_Asset__r.XC_Configuration_Item__c, XC_CostAfterLastRevaluation__c, XC_EndDateAfterLastExtension__c ,XC_CostBeforeLastRevaluation__c, XC_EndDateBeforeExtension__c, ' +
                            'XC_Asset__r.XC_Configuration_Item__r.XC_CA_UpdatePrice__c, XC_Percentage__c, XC_Asset__r.NE__RecurringChargeFrequency__c, XC_Contract__r.EndDate, XC_Asset__r.XC_Original_Configuration_Item__r.XC_ZQuoteId__c, XC_Asset__r.XC_Configuration_Item__r.XC_ZQuoteId__c FROM XC_ContractAmendmentsChilds__r ) ' +
                        'FROM XC_ContractAmendment__c ' +
                        'WHERE XC_Status__c = \'New\' AND XC_Asset__c != null AND Contract_Amendment_Parent__c = null  order by CreatedDate desc'; // AND XC_Asset__r.XC_Particle__c = \'false\' -> removed the filter as the price change does not create the CA
        return Database.getQueryLocator(query);
    }
    
    
	public void execute(Database.BatchableContext BC, List<XC_ContractAmendment__c> contractAmendList) {
        List<XC_ContractAmendment__c> parents = new List<XC_ContractAmendment__c>();
        List<XC_ContractAmendment__c> childs = new List<XC_ContractAmendment__c>();
    	XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN XC_SC062_ContractAmendmentManagment.execute');
        for(XC_ContractAmendment__c c : contractAmendList) {
            c.XC_Status__c = 'In Progress';
            if (c.Contract_Amendment_Parent__c == null) {
                 parents.add(c);
                for (XC_ContractAmendment__c child : c.XC_ContractAmendmentsChilds__r) {
                    childs.add(child);
                }
            }
        }
        //update contractAmendList;
        
        XC_REST_ContractAmendment.retrieveSubscription(parents,childs);
    }

    
 	public void finish(Database.BatchableContext bc){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN XC_SC062_ContractAmendmentManagment.finish');
    }

}