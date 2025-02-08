/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 31/01/2020
* @description XC_TR_ZipCodeWorkType_Handler_TEST – Test class 
*/
@isTest
public class XC_TR_ZipCodeWorkType_Handler_TEST {
    
    static testMethod void insertZipCodeWt(){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        WorkType wt = new WorkType();
        wt.name = 'Commercial Visit - Boiler';
        wt.EstimatedDuration = 3;
        wt.XC_LegalEntity__c = 'EndesaX';
        insert wt;
        List<Account> accList = XC_DF_Account.insertPartnerAccounts(1);
        String userId = UserInfo.getUserId();
        ServiceResource serviceRes = new ServiceResource();
        serviceRes.Name = accList[0].Name;
        serviceRes.XC_Account__c = accList[0].Id;
        serviceRes.IsActive = true;
        serviceRes.IsCapacityBased = true;
        serviceRes.RelatedRecordId = userId;
    insert serviceRes;
        Test.startTest();
        XC_PartnerCoverage__c pc = new XC_PartnerCoverage__c();
        pc.XC_WorkType__c = wt.Id;
        pc.XC_ZipCode__c = 'B';
        pc.XC_Account__c = serviceRes.XC_Account__c;
        insert pc;
        
        pc.XC_ZipCode__c = 'c';
        XC_ZipCodeWorkType__c zcwt = new XC_ZipCodeWorkType__c();
        zcwt.XC_ExternalId__c = wt.Id+'_B' ;
        insert zcwt;
        zcwt.XC_ExternalId__c = wt.Id+'c' ;
        update zcwt;
        delete zcwt;
        test.stopTest();
        System.assertEquals(pc != null, true);
    }
}