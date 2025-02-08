/**
 * @author Danilo Lombardi - dolombardi@deloitte.it
 * @date Creation 13/10/2021
 * @date Modification 28/10/2021 by Nicola Mariniello nmariniello@deloitte.it
 * @description XC_IN081_ContractAmenment_D – DAO for XC_IN081_ContractAmenment
 */


public with sharing class XC_IN081_ContractAmenment_D {


    public static Map<Id, Asset> getMapContrAmend(List<Id> listContractAmendment) {
        Map<Id, Asset> mapCA = new Map<Id, Asset>([SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__RecurringChargeOv__c, XC_Configuration_Item__r.XC_RecurringDuration__c,
                                                        XC_Contract_Amendment__c, XC_Configuration_Item__r.NE__OrderId__c, XC_Contract_Amendment__r.XC_Contract__r.EndDate
                                                    FROM Asset
                                                    WHERE XC_Contract_Amendment__c IN :listContractAmendment]);
        return mapCA;
    }


    public static Map<Id, Asset> getMapContrAmendByOrderItem(String confItemId) {
        Map<Id, Asset> mapCA = new Map<Id, Asset>([SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__RecurringChargeOv__c, XC_Configuration_Item__r.XC_RecurringDuration__c,
                                                        XC_Contract_Amendment__c, XC_Configuration_Item__r.NE__OrderId__c, XC_Contract_Amendment__r.XC_Contract__r.EndDate
                                                    FROM Asset
                                                    WHERE XC_Configuration_Item__c =: confItemId]);
        return mapCA;
    }

}