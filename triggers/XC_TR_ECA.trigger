/**
* @author Antonio D'Onofrio - andonofrio@deloitte.it
* @date Creation 05/12/2020
* @description B2WExtCat__External_Catalog_Association__c – Trigger on B2WExtCat__External_Catalog_Association__c
*/ 

trigger XC_TR_ECA on B2WExtCat__External_Catalog_Association__c (before insert, before update, before delete, after insert, after update, after delete) {

    XC_TR_Dispatcher.init(new XC_TR_ECA_Handler(), Trigger.operationType,Constants.MDT_SKIP_LEAD);
    
}