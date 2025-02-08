public with sharing class WSO2KeysSelector {
    public static WSO2Keys__c getWSO2Keys() {
        WSO2Keys__c wso2k = [SELECT Consumer_Key__c, Consumer_Secret__c FROM WSO2Keys__c LIMIT 1];
        return wso2k;
    }
}