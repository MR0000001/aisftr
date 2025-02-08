/**
 * Created by smaccagno on 02/03/2021.
 */

public with sharing class CTIUtility {
    @AuraEnabled
    public static Boolean getMysterySettings(){
        CTI_Settings__c myst = CTI_Settings__c.getInstance();
        Boolean active = myst.Mystery_Active__c;
        return active;
    }
}