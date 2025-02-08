/**
* @author dpalamides
* @date 01/10/2020
* @description classes.XC_TR_Contract_U_PopulateFromOpp
*/


public without sharing class XC_TR_Contract_U_PopulateFromOpp {

    public static void populatefields(List<Contract> listNew){
        Map<Id,Opportunity> mapOpp = new Map<Id,Opportunity>([Select Id, XC_ContractType__c, XC_InvoiceType__c FROM Opportunity where id in :XC_UTIL_Sobject.getListFieldValues(listNew,'Opportunity__c') and XC_Segment__c in ('B2B','B2G')]);

        if(mapOpp.values().isEmpty() ){
            return;
        }

        for(Contract c : listNew){
            if(mapOpp.containsKey(c.Opportunity__c)) {
                c.Contract_Type__c = mapOpp.get(c.Opportunity__c).XC_ContractType__c;
                c.XC_InvoiceType__c = mapOpp.get(c.Opportunity__c).XC_InvoiceType__c;
            }
        }
    }
}