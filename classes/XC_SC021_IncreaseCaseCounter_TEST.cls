/**
* @author Dario Tramontin - dtramontin@deloitte.it 
* @date Creation 05/08/2019
* @date Modification dd/mm/yyyy
* @description XC_SC021_IncreaseCaseCounter_TEST – Test of XC_SC021_IncreaseCaseCounter
*/

@isTest
public without sharing class XC_SC021_IncreaseCaseCounter_TEST {

    static testMethod void testMethod1() {      

        List<Case> c = XC_DF_Case.createCases(5);
        for(Case cas : c){
            cas.Status = 'ESTA001';
        }
        insert c;  
        String recordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('XC_ESP_Complaint_Case').getRecordTypeId();

        c[0].Status = XC_AT_Constants.TRIGGER_STATUS_ESTA001;
        c[0].recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('XC_ESP_Complaint_Case').getRecordTypeId();
        c[1].Status = XC_AT_Constants.TRIGGER_STATUS_ESTA002;
        c[1].XC_SubStatus__c = XC_AT_Constants.CASE_SUBSTATUS_SUB006;
        c[1].recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('XC_ESP_Complaint_Case').getRecordTypeId();

        c[2].Status = XC_AT_Constants.TRIGGER_STATUS_ESTA002;
        c[2].XC_SubStatus__c = XC_AT_Constants.CASE_SUBSTATUS_SUB003;
        c[2].recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('XC_ESP_Complaint_Case').getRecordTypeId();

        c[3].Status = XC_AT_Constants.TRIGGER_STATUS_ESTA004;
        c[3].XC_SubStatus__c = XC_AT_Constants.CASE_SUBSTATUS_SUB002;
        c[3].recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('XC_ESP_Complaint_Case').getRecordTypeId();

        update c; 

        Test.startTest();
            SchedulableContext sc = null;
            XC_SC021_IncreaseCaseCounter tsc = new XC_SC021_IncreaseCaseCounter();
            tsc.execute(sc);
            XC_SC021_IncreaseCaseCounter bat = new XC_SC021_IncreaseCaseCounter();
            DataBase.executeBatch(bat);

            System.assertEquals(true, c!=null, 'Wrong Assert Equals');
            
        Test.stopTest();
    }

        static testMethod void testMethod2() {

        List<Case> c = XC_DF_Case.createCases(1);
        c[0].Status = 'ESTA001';
        insert c;
        XC_UTIL_Sobject.WrapperResult wr = new XC_UTIL_Sobject.WrapperResult();
        wr.errorMessage = 'test error';
        wr.errorObjectId = c[0].id;
        
        Test.startTest();

            XC_BatchErrorLog__c error = XC_SC021_IncreaseCaseCounter.createBatchError(wr, 'name_test', 'operation_test');
            System.assertEquals(true, error!=null, 'Wrong Assert Equals');
            
        Test.stopTest();
    }
}