/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/
@IsTest
private class XC_TR_ConsentDescription_ChkStatus_TEST {
    static testMethod void testBehavior() {
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        Insert org;
        List<XC_ConsentDescription__c> listRecordEx  = new List<XC_ConsentDescription__c>();
        List<XC_ConsentDescription__c> listRecord  = new List<XC_ConsentDescription__c>();
        List<XC_ConsentDescription__c> listRecord2  = new List<XC_ConsentDescription__c>();
        //NA 1902
        Map<Id,XC_ConsentDescription__c> mapNew=new Map<Id,XC_ConsentDescription__c>();
        Map<Id,XC_ConsentDescription__c> mapOld=new Map<Id,XC_ConsentDescription__c>();
        XC_ConsentDescription__c recordNewEx = new XC_ConsentDescription__c(XC_Country__c = 'Spain', XC_LegalEntity__c ='EndesaX',XC_ConsentStatus__c= 'Active',XC_ConsentVersion__c='1.0');
        XC_ConsentDescription__c recordNew = new XC_ConsentDescription__c(XC_Country__c = 'Spain', XC_LegalEntity__c ='EndesaX',XC_ConsentStatus__c= 'Active',XC_ConsentVersion__c='1.0');
        XC_ConsentDescription__c recordNew2 = new XC_ConsentDescription__c(XC_Country__c = 'Spain', XC_LegalEntity__c ='EndesaX',XC_ConsentStatus__c= 'Inactive',XC_ConsentVersion__c='1.0');
        listRecordEx.add(recordNewEx);
        listRecordEx.add(recordNew2);
        listRecord.add(recordNew);
        Database.Insert(listRecordEx,false);
        //NA 1902
       test.startTest();
        XC_TR_ConsentDescription_CheckStatus.existingRecord(listRecordEx);
        Database.Insert(listRecord,false);
        mapOld.put(recordNew2.id,recordNew2);
        recordNew2.XC_ConsentStatus__c = 'Active';
        recordNew2.XC_Country__c = 'United Kingdom';
        recordNew2.XC_LegalEntity__c = 'JuicenetLimited';
        Database.update(recordNew2,false);
        mapNew.put(recordNew2.id,recordNew2);
        System.assertEquals(recordNew2.XC_ConsentStatus__c,recordNewEx.XC_ConsentStatus__c,'Error Message');
        //NA1902
        XC_TR_ConsentDescription_CheckStatus.checkStatusBeforeUpdate(mapNew, mapOld);
        test.stopTest();
    }
}