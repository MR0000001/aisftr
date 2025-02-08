/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 15/05/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_Opportunity_U_SetStatus_TEST – Test Class for XC_TR_Opportunity_U_SetStatus
*/ 

@isTest
public class XC_TR_Opportunity_U_SetStatus_TEST {
    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    }

    static testMethod void onUpdateOpportunity() {
        insert XC_DF_Account.createResidentialAccounts(1);
        List<Account> accList = [SELECT Id FROM Account];
        insert XC_DF_Address.createAddress(accList);
        List<XC_Address__c> listAddress = [SELECT Id FROM XC_Address__c];
        insert XC_DF_Contact.createResidentialContacts(accList);
        List<Contact> contactList = [SELECT Id, AccountId FROM Contact];
        Test.startTest();
        XC_DF_Order.createOrder('Opty');
        List<Opportunity> oppinserted = [SELECT Id FROM Opportunity];
        System.assertEquals(oppinserted.size() , 1);
        Test.stopTest();
    }
    
     static testMethod void setStageInProgress() {
     	XC_DF_Order.createOrder('Opty');
        List<Opportunity> oppinserted = [SELECT Id FROM Opportunity];
        oppinserted[0].XC_Segment__c = 'B2B';
        oppinserted[0].XC_IndustrialKPI__c = 'Total Assets';
         oppinserted[0].XC_LegalEntity__c = 'test';
         oppinserted[0].XC_Invited_Checkbox__c = false;
         oppinserted[0].StageName = 'asd';
        
        
         Test.startTest();
        XC_TR_Opportunity_U_SetStatus.setStageInProgress(oppinserted, null, null);
         oppinserted[0].XC_LegalEntity__c = 'EnelX';
         XC_TR_Opportunity_U_SetStatus.setStageInProgress(oppinserted, null, null);
                  
         map<id,opportunity> n = new map<id,opportunity>();
         n.put(oppinserted[0].id, oppinserted[0]);
                  map<id,opportunity> o = new map<id,opportunity>();
         o.put(oppinserted[0].id, oppinserted[0]);
         oppinserted[0].XC_Invited_Checkbox__c = true;
          oppinserted[0].XC_LegalEntity__c = 'EnelXX';
         XC_TR_Opportunity_U_SetStatus.setStageInProgress(oppinserted, n, o);
         
         Test.stopTest(); 
        
     }
    
    static testMethod void setStageInProgress1() {
     	XC_DF_Order.createOrder('Opty');
        List<Opportunity> oppinserted = [SELECT Id FROM Opportunity];
        oppinserted[0].XC_Segment__c = 'B2B';
        oppinserted[0].XC_IndustrialKPI__c = 'Total Assets';
         oppinserted[0].XC_LegalEntity__c = 'test';
         oppinserted[0].XC_Invited_Checkbox__c = true;
         oppinserted[0].StageName = 'asd';
        
        
         Test.startTest();
                  
         map<id,opportunity> n = new map<id,opportunity>();
         n.put(oppinserted[0].id, new opportunity());
                  map<id,opportunity> o = new map<id,opportunity>();
         o.put(oppinserted[0].id, new opportunity());
         XC_TR_Opportunity_U_SetStatus.setStageInProgress(oppinserted, n, o);
         
         Test.stopTest(); 
        
     }
    
        static testMethod void setStageInProgress2() {
     	XC_DF_Order.createOrder('Opty');
        List<Opportunity> oppinserted = [SELECT Id FROM Opportunity];
        oppinserted[0].XC_Segment__c = 'B2B';
        oppinserted[0].XC_IndustrialKPI__c = 'Total Assets';
         oppinserted[0].XC_LegalEntity__c = 'test';
         oppinserted[0].XC_Invited_Checkbox__c = false;
         oppinserted[0].StageName = 'Qualified Potential Opportunity';
        
        
         Test.startTest();
                  
         map<id,opportunity> n = new map<id,opportunity>();
         n.put(oppinserted[0].id, oppinserted[0]);
                  map<id,opportunity> o = new map<id,opportunity>();
         o.put(oppinserted[0].id, new opportunity());
         XC_TR_Opportunity_U_SetStatus.setStageInProgress(oppinserted, n, o);
            XC_TR_Opportunity_U_SetStatus.setClosingUser(oppinserted, n, o);
         
         Test.stopTest(); 
        
     }
            
    static testMethod void setClosingUser() {
     	XC_DF_Order.createOrder('Opty');
        List<Opportunity> oppinserted = [SELECT Id FROM Opportunity];

         oppinserted[0].StageName = 'Qualified Potential Opportunity';
        oppinserted[0].XC_NumberOfConfiguration__c = 2;
        
        
         Test.startTest();
                  
		update oppinserted[0];
         
         Test.stopTest(); 
        
     }

    
    static testMethod void createNotification(){
        List<Opportunity> oppinserted = XC_DF_Opportunity.createOpportunity(1, false);
        List<Opportunity> oppinserted2 = XC_DF_Opportunity.createOpportunity(1, false);
        insert oppinserted;
        //XC_DF_Order.createOrder('Opty');
        //List<Opportunity> oppinserted = [SELECT Id FROM Opportunity];
        oppinserted[0].XC_Segment__c = 'B2G';
        oppinserted[0].XC_IndustrialKPI__c = 'Work Contract';
        oppinserted[0].XC_LegalEntity__c = 'EnelXItalia';
        oppinserted[0].XC_Invited_Checkbox__c = false;
        oppinserted[0].StageName = 'Abandoned';    
        oppinserted[0].XC_BusinessLine__c = 'eCity';
        oppinserted[0].RecordTypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2G_Opportunity_Italy').getRecordTypeId();
        oppinserted[0].XC_ProductCategory__c = 'Optimize';
        oppinserted[0].XC_ProductCategoryOfInterest__c = 'Architectural Lighting';
        oppinserted[0].XC_CustomerRequestDate__c =Date.newInstance(2022, 12, 30);
        update oppinserted;
         oppinserted2[0].XC_Segment__c = 'B2G';
        oppinserted2[0].XC_IndustrialKPI__c = 'Total Assets';
        oppinserted2[0].XC_LegalEntity__c = 'test';
        oppinserted2[0].XC_Invited_Checkbox__c = false;
        //oppinserted2[0].StageName = 'Abandoned';    
        oppinserted2[0].XC_BusinessLine__c = 'eCity';
        Test.startTest();               
        map<id,opportunity> n = new map<id,opportunity>();
        n.put(oppinserted[0].id, oppinserted[0]);
        map<id,opportunity> o = new map<id,opportunity>();
        o.put(oppinserted[0].id, oppinserted2[0]);
        XC_TR_Opportunity_U_SetStatus.createNotification(oppinserted, n, o);
        Test.stopTest(); 
    }
}