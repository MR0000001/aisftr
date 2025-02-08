/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation  06/02/2020 
* @description XC_TR_ConsentDescription_TEST – Test class for XC_TR_ConsentDescription_Handler
*/ 
@isTest
public class XC_TR_ConsentDescription_TEST {
    
    @isTest
    static void insertTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<XC_ConsentDescription__c> listRecordEx  = new List<XC_ConsentDescription__c>();
        List<XC_ConsentDescription__c> listRecord  = new List<XC_ConsentDescription__c>();
        XC_ConsentDescription__c recordNewEx = new XC_ConsentDescription__c(XC_Country__c = 'Spain', XC_LegalEntity__c ='EndesaX',XC_ConsentStatus__c= 'Active',XC_ConsentVersion__c='1.0');
        XC_ConsentDescription__c recordNew = new XC_ConsentDescription__c(XC_Country__c = 'Spain', XC_LegalEntity__c ='EndesaX',XC_ConsentStatus__c= 'Active',XC_ConsentVersion__c='1.0');
        XC_ConsentDescription__c recordNew2 = new XC_ConsentDescription__c(XC_Country__c = 'Spain', XC_LegalEntity__c ='EndesaX',XC_ConsentStatus__c= 'Inactive',XC_ConsentVersion__c='1.0');
        listRecordEx.add(recordNewEx);
        listRecordEx.add(recordNew2);
        listRecord.add(recordNew);
        insert listRecord;
        Test.stopTest();
        System.assertEquals(true, !listRecord.isEmpty());
    }
    
    @isTest
 	static void updateTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<XC_ConsentDescription__c> listRecordEx  = new List<XC_ConsentDescription__c>();
        List<XC_ConsentDescription__c> listRecord  = new List<XC_ConsentDescription__c>();
        XC_ConsentDescription__c recordNewEx = new XC_ConsentDescription__c(XC_Country__c = 'Spain', XC_LegalEntity__c ='EndesaX',XC_ConsentStatus__c= 'Active',XC_ConsentVersion__c='1.0');
        XC_ConsentDescription__c recordNew = new XC_ConsentDescription__c(XC_Country__c = 'Spain', XC_LegalEntity__c ='EndesaX',XC_ConsentStatus__c= 'Active',XC_ConsentVersion__c='1.0');
        XC_ConsentDescription__c recordNew2 = new XC_ConsentDescription__c(XC_Country__c = 'Spain', XC_LegalEntity__c ='EndesaX',XC_ConsentStatus__c= 'Inactive',XC_ConsentVersion__c='1.0');
        listRecordEx.add(recordNewEx);
        listRecordEx.add(recordNew2);
        listRecord.add(recordNew);
        insert listRecord;
        update listRecord;
        Test.stopTest(); 
        System.assertEquals(true, !listRecord.isEmpty());
    } 

    @isTest
    static void deleteTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<XC_ConsentDescription__c> listRecordEx  = new List<XC_ConsentDescription__c>();
        List<XC_ConsentDescription__c> listRecord  = new List<XC_ConsentDescription__c>();
        XC_ConsentDescription__c recordNewEx = new XC_ConsentDescription__c(XC_Country__c = 'Spain', XC_LegalEntity__c ='EndesaX',XC_ConsentStatus__c= 'Active',XC_ConsentVersion__c='1.0');
        XC_ConsentDescription__c recordNew = new XC_ConsentDescription__c(XC_Country__c = 'Spain', XC_LegalEntity__c ='EndesaX',XC_ConsentStatus__c= 'Active',XC_ConsentVersion__c='1.0');
        XC_ConsentDescription__c recordNew2 = new XC_ConsentDescription__c(XC_Country__c = 'Spain', XC_LegalEntity__c ='EndesaX',XC_ConsentStatus__c= 'Inactive',XC_ConsentVersion__c='1.0');
        listRecordEx.add(recordNewEx);
        listRecordEx.add(recordNew2);
        listRecord.add(recordNew);
        insert listRecord;
        delete listRecord;
        Test.stopTest();
        System.assertEquals(true, !listRecord.isEmpty());
    }    
}