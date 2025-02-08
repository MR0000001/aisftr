/**
* @author Massimiliano Avallone - massimiliano.avallone@nttdata.com 
* @date Creation 11/09/2019 
* @description XC_TR_PartnerCoverage_U_FillFields_TEST – Test class 
*/
@isTest
private  class XC_TR_PartnerCoverage_U_FillFields_TEST {
    static testMethod void partnerCoverage(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        
        List<Account> accList = XC_DF_Account.insertPartnerAccounts(1);
        
        String userId = UserInfo.getUserId();
        ServiceResource serviceRes = new ServiceResource();
        serviceRes.Name = accList[0].Name;
        serviceRes.XC_Account__c = accList[0].Id;
        serviceRes.IsActive = true;
        serviceRes.IsCapacityBased = true;
        serviceRes.RelatedRecordId = userId;
        insert serviceRes;
               
        List<ServiceResource> listserRes = [SELECT id, XC_Account__c FROM ServiceResource];
        
        WorkType wt = XC_DF_WorkType.createWorkType('Commercial Visit');
        insert wt;
        
        XC_PartnerCoverage__c pc = new XC_PartnerCoverage__c();
        pc.XC_WorkType__c = wt.Id;
        pc.XC_ZipCode__c = 'B';
        pc.XC_Account__c = listserRes[0].XC_Account__c;
        insert pc;
        
        pc.XC_ZipCode__c = 'c';
        update pc;
        delete pc; 
        
        XC_ZipCodeWorkType__c zcwt = new XC_ZipCodeWorkType__c();
        zcwt.XC_ExternalId__c = wt.Id+'_B' ;
        insert zcwt;
        
        Test.stopTest();
    }
}