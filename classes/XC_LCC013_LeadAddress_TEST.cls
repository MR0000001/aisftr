/**
* @author Emanuela Cacace ecacace@deloitte.it
* @date Creation  15/05/2019 
* @description XC_LCC013_LeadAddress_TEST – Test class for XC_LCC013_LeadAddress
*/ 
@isTest
public with sharing class XC_LCC013_LeadAddress_TEST { 
    //Test Method getFieldSet
    static testMethod void getFieldSet(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
            String result = XC_LCC013_LeadAddress.getFieldSet();
            System.assertEquals('XC_ESP_Lead_New_Address', result);
        Test.stopTest();
    } 
        
    static testMethod void getAddressFields(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        List<Lead> lstLead = XC_DF_Lead.createResidentialLeads(1);
        
        XC_Address__c add = new XC_Address__c();
        add.XC_Lead__c = lstLead[0].id;
        insert add;
        
        Test.startTest();
            String result = XC_LCC013_LeadAddress.getAddressFields(lstLead[0].id);
            System.assert(result!=null);
        Test.stopTest();
    }


}