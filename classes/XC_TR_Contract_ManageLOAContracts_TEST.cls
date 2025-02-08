/* 
* @author Anjana Balu anjana.balu@accenture.com
* @date Creation 22/06/2022
* @description XC_TR_Contract_ManageLOAContracts_TEST – Test class for XC_TR_Contract_ManageLOAContracts
*/ 

@isTest
public class XC_TR_Contract_ManageLOAContracts_TEST {
    
    @isTest
   public static void updateServiceAccountsTest(){
        List<Contract> contractList = XC_DF_Contract.createContracts(1);  
        //insert contractList;
        Account accList = new Account();
            accList.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_Account_Partner').getRecordTypeId();
            accList.Name = 'Test Account n ';
            accList.PrimaryEmail__c = 'test_partner@email.com';
            accList.IdentityType__c='Passport';
            accList.IdentityNumber__c='3526173'+ (Math.random()*Math.random());
        insert accList;
        Map<Id,Contract> mapNew = new Map<Id,Contract>();
        Map<Id,Contract> mapOld = new Map<Id,Contract>();  
         List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1, true); 
        insert oppList;
       // List<Opportunity> oppList = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
        for(Contract c : contractList)
        {
            c.XC_Segment__c = 'B2B';
            c.Opportunity__c = oppList.get(0).id;
            c.AccountId=accList.id;
            c.RecordTypeId=Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('XC_LOA').getRecordTypeId(); 
            c.XC_LOA_Signed__c=true;
            //c.XC_LOA_Start_Date__c=system.today()-90;
            //c.XC_LOA_Validity__c=2.00;
            //c.status ='New';
        }
        insert contractList;
        mapNew.put(contractList.get(0).id,contractList.get(0));
        Service_Account__c sa=new Service_Account__c();
        sa.Name='Test1';
        insert sa;
        XC_Service_Account_LOA__c saloa=new XC_Service_Account_LOA__c();
        saloa.XC_Service_Account__c=sa.Id;
        saloa.XC_Contract__c=contractList.get(0).id;
        insert saloa;
        Test.startTest();
        XC_TR_Contract_ManageLOAContracts.updateServiceAccounts(mapOld,mapNew);
        Test.stopTest();
    }
    
    @isTest
    public static void updateContractLOAStatusTest1(){
        List<Contract> contractList = XC_DF_Contract.createContracts(3);
        Account accountToInsert = new Account();
            accountToInsert.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_Account_Partner').getRecordTypeId();
            accountToInsert.Name = 'Test Account n ';
            accountToInsert.PrimaryEmail__c = 'test_partner@email.com';
            accountToInsert.XC_Status__c = 'Active'; 
            accountToInsert.IdentityType__c='Passport';
            accountToInsert.IdentityNumber__c='3526173'+ (Math.random()*Math.random());
        insert accountToInsert;
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
        insert oppList;
        for(Contract c : contractList)
        {
            c.XC_Segment__c = 'B2B';
            c.Opportunity__c = oppList.get(0).id;
            c.AccountId=accountToInsert.id;
            c.RecordTypeId=Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('XC_LOA').getRecordTypeId(); 
            c.XC_LOA_Signed__c=true;
        }
        insert contractList;
        for(Contract con : contractList)
        {
            con.XC_LOA_Start_Date__c=system.today();
            con.XC_LOA_Validity__c=2.00;
        }
        update contractList;
        Test.startTest();
        XC_TR_Contract_ManageLOAContracts.updateContractLOAStatus(contractList);
        Test.stopTest();
    }
    
    @isTest
    public static void updateContractLOAStatusTest2(){
        List<Contract> contractList = XC_DF_Contract.createContracts(3);      
        List<Account> accList = XC_DF_Account.insertPartnerAccounts(1,'Active');
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
        for(Contract c : contractList)
        {
            c.XC_Segment__c = 'B2B';
            c.Opportunity__c = oppList.get(0).id;
            c.AccountId=accList.get(0).id;
            c.RecordTypeId=Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('XC_LOA').getRecordTypeId(); 
            c.XC_LOA_Signed__c=false;
        }
        insert contractList;
        Test.startTest();
        XC_TR_Contract_ManageLOAContracts.updateContractLOAStatus(contractList);
        Test.stopTest();
    }
    @isTest
    public static void updateContractLOAStatusTest4(){
        List<Contract> contractList = XC_DF_Contract.createContracts(3);
        Account accountToInsert = new Account();
            accountToInsert.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_Account_Partner').getRecordTypeId();
            accountToInsert.Name = 'Test Account n ';
            accountToInsert.PrimaryEmail__c = 'test_partner@email.com';
            accountToInsert.XC_Status__c = 'Active'; 
            accountToInsert.IdentityType__c='Passport';
            accountToInsert.IdentityNumber__c='3526173'+ (Math.random()*Math.random());
        insert accountToInsert;
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
        insert oppList;
        for(Contract c : contractList)
        {
            c.XC_Segment__c = 'B2B';
            c.Opportunity__c = oppList.get(0).id;
            c.AccountId=accountToInsert.id;
            c.RecordTypeId=Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('XC_LOA').getRecordTypeId(); 
            c.XC_LOA_Signed__c=true;
        }
        insert contractList;
        for(Contract con : contractList)
        {
            con.XC_LOA_Start_Date__c=Date.newInstance(2022,02,04);
            con.XC_LOA_Validity__c=2.00;
        }
        update contractList;
        Test.startTest();
        XC_TR_Contract_ManageLOAContracts.updateContractLOAStatus(contractList);
        Test.stopTest();
    }
    
}