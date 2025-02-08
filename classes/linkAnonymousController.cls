/**
 * Created by FMARCHEGIA00 on 19/04/2021.
 */

public without sharing class linkAnonymousController {

    @AuraEnabled
    public static String getAnonymousIdFromCustomSetting() {
        OrgManagement__c orgManagement = [SELECT AnonymuosID_del__c FROM OrgManagement__c LIMIT 1];
        system.debug('orgManagement.AnonymuosID_del__c -> '+ orgManagement.AnonymuosID_del__c);
        return orgManagement.AnonymuosID_del__c;
    }

}