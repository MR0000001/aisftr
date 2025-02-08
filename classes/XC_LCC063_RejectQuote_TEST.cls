/**
* @author Emanuela Cacace ecacace@deloitte.it
* @date Creation  16/05/2019 
* @description XC_LCC063_RejectQuote_TEST – Test class for XC_LCC063_RejectQuote
*/ 
@isTest
public with sharing class XC_LCC063_RejectQuote_TEST {
    
    //Test Method retriveCategoryValues
    static testMethod void retriveCategoryValues(){
    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();

    List<XC_LCC063_RejectQuote.PicklistValues> result = XC_LCC063_RejectQuote.retriveCategoryValues();
    System.assert(!result.isEmpty());
    Test.stopTest();
    }

        //Test Method rejectQuote
    static testMethod void rejectQuote(){
    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
    
    NE__Order__c o = new NE__Order__c(); 
    o.XC_LossReason__c = 'Expired';
    o.XC_Status__c=Label.XC_CL_Configuration_QuoteDraft;
    o.RecordTypeId=Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
    insert o;
    
    String recordId = o.Id ; 
    String lossReason = o.XC_LossReason__c;
    XC_UTIL_ResultWrapper rw = XC_LCC063_RejectQuote.rejectQuote(recordId,lossReason );
    delete o;
    //System.assertEquals(true, rw.success);
    Test.stopTest();
    }



 
}