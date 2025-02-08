/**
* @author Emanuela Cacace ecacace@deloitte.it
* @date Creation  13/05/2019 
* @description XC_LCC051_CloneLead_TEST – Test class for XC_LCC051_CloneLead
*/
@isTest 
public class XC_LCC051_CloneLead_TEST {
    
     //Test Method cloneNewLead
    static testMethod void cloneNewLead(){ 
    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
        XC_ProductCategoryOfInterest__c productCategoryOfInterest = XC_DF_ProductCategoryOfInterest.prodCatWithVisitRecord();
        insert productCategoryOfInterest;
        List<Lead> listLead = XC_DF_Lead.createResidentialLeads(1);
        insert listLead; 
        String prodId = productCategoryOfInterest.id;
        XC_UTIL_ResultWrapper rw = XC_LCC051_CloneLead.cloneNewLead(listLead[0].Id, prodId, true);
        System.assertEquals(false, rw.success);
    Test.stopTest(); 
    }
    
     //Test Method isSystemAdmin
    static testMethod void isSystemAdmin(){
    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
        Boolean result= XC_LCC051_CloneLead.isSystemAdmin();
        System.assertEquals(true, result);
    Test.stopTest();
    }
    
    static testMethod void createAndCloneLead(){
        XC_ProductCategoryOfInterest__c productCategoryOfInterest = XC_DF_ProductCategoryOfInterest.prodCatWithVisitRecord();
        insert productCategoryOfInterest;
        insert XC_DF_ProductCategoryOfInterest.prodCatWithVisitRecord();
        
        List<Lead> listLead = XC_DF_Lead.createResidentialLeads(1);
        listLead[0].XC_DocumentCountry__c = 'Spain';
        insert listLead; 
        
        List<XC_Address__c> addreass = XC_DF_Address.createAddress(1); 
        insert addreass;
        
        listLead[0].XC_LeadAddress__c = addreass[0].Id;
        update listLead;
        
        /*XC_LegalEntityConsent__c le = new XC_LegalEntityConsent__c();
        le.XC_Individual__c = lead.IndividualId;
        le.XC_LegalEntity__c = 'EndesaX';
        le.XC_GiveDataToNew__c = 'Yes';
        le.XC_UpdateAboutProducts__c = 'Yes';
        le.XC_ConsentToDataProcessing__c = 'Yes';
        le.XC_LeCountry__c = 'Spain';
        insert le;*/
        
        Test.startTest();
        XC_UTIL_ResultWrapper rw = XC_LCC051_CloneLead.cloneNewLead(listLead[0].id, productCategoryOfInterest.Name, true);
      	System.debug('@@@@@ Clone rw='+rw);
        System.assertEquals(true, rw.success); 
        Test.stopTest(); 
    }
    
    static testMethod void createAndCloneLeadDuplicated(){
        //Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Residential').getRecordTypeId();
        
        insert XC_DF_Lead.createResidentialLeads(1);
        Lead lead = [SELECT Id, IndividualId FROM LEAD LIMIT 1];
        insert XC_DF_Address.createAddress(1); 
        XC_Address__c addreass = [SELECT Id FROM XC_Address__c LIMIT 1]; 
        lead.XC_LeadAddress__c = addreass.Id;
        lead.XC_ProductCategoryOfInterest__c = '';
        update lead;
        
        Test.startTest();
        XC_UTIL_ResultWrapper rw = XC_LCC051_CloneLead.cloneNewLead(lead.id, '', true);
      	System.debug('@@@@@ Clone rw='+rw);
        System.assertEquals(true, rw.success); 
        Test.stopTest(); 
    }

}