/**
* @author Raffaele Pacchiano
* @date Creation  07/03/2020 
* @description XC_TR_Contract_AccountPartner_TEST
**/
@isTest
public class XC_TR_Contract_AccountPartner_TEST {
   
    static testMethod void afterInsertManageContract (){
        test.startTest();
        List<Contract> contractList = XC_DF_Contract.createContracts(2);
        List<Account> accList = XC_DF_Account.insertPartnerAccounts(1,'Active');
       // accList.get(0).recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_Account_Partner').getRecordTypeId();
       // insert accList;
        
        Map<Id,Contract> mapNew = new Map<Id,Contract>();  
        
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
        for(Opportunity opp : oppList){
            opp.XC_Segment__c ='B2B';
            opp.AccountId = accList.get(0).id;
            opp.StageName = 'Draft'; 
            opp.Name = 'TEST'; 
            opp.CloseDate =System.today(); 
        }
        //insert oppList;
        for(Contract c : contractList){
            c.XC_Segment__c = 'B2B';
            c.Opportunity__c = oppList.get(0).id;  
            c.XC_ContractType__c ='MATERIAL AND SERVICE';
            c.AccountId=accList.get(0).id;
            c.RecordTypeId=Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_Contract').getRecordTypeId(); 
            c.XC_LegalEntity__c ='EnelXItalia';
        }
        insert contractList;
        mapNew.putAll(contractList);
  
        test.stopTest();
        }
		static testMethod void afterInsertManageContract1 (){
        test.startTest();
        List<Contract> contractList = XC_DF_Contract.createContracts(2);
        List<Account> accList = XC_DF_Account.insertPartnerAccounts(1,'Active');
       // accList.get(0).recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_Account_Partner').getRecordTypeId();
       // insert accList;
        
        Map<Id,Contract> mapNew = new Map<Id,Contract>();  
        
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
        for(Opportunity opp : oppList){
            opp.XC_Segment__c ='B2B';
            opp.AccountId = accList.get(0).id;
            opp.StageName = 'Draft'; 
            opp.Name = 'TEST'; 
            opp.CloseDate =System.today(); 
        }
        //insert oppList;
        for(Contract c : contractList){
            c.XC_Segment__c = 'B2B';
            c.Opportunity__c = oppList.get(0).id;  
            c.XC_ContractType__c ='SERVICE';
            c.AccountId=accList.get(0).id;
            c.RecordTypeId=Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_Contract').getRecordTypeId(); 
            c.XC_LegalEntity__c ='EnelXItalia';
        }
        insert contractList;
        mapNew.putAll(contractList);
        XC_TR_Contract_AccountPartner.afterInsertManageContract(mapNew);
        test.stopTest();  
        }
    	static testMethod void afterInsertManageContract2 (){
        test.startTest();
        List<Contract> contractList = XC_DF_Contract.createContracts(2);
        List<Account> accList = XC_DF_Account.insertPartnerAccounts(1,'Active');
       // accList.get(0).recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_Account_Partner').getRecordTypeId();
       // insert accList;
        
        Map<Id,Contract> mapNew = new Map<Id,Contract>();  
        
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
        for(Opportunity opp : oppList){
            opp.XC_Segment__c ='B2B';
            opp.AccountId = accList.get(0).id;
            opp.StageName = 'Draft'; 
            opp.Name = 'TEST'; 
            opp.CloseDate =System.today(); 
        }
        //insert oppList;
        for(Contract c : contractList){
            c.XC_Segment__c = 'B2B';
            c.Opportunity__c = oppList.get(0).id;  
            c.XC_ContractType__c ='MATERIAL';
            c.AccountId=accList.get(0).id;
            c.RecordTypeId=Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_Contract').getRecordTypeId(); 
            c.XC_LegalEntity__c ='EnelXItalia';
        }
        insert contractList;
        mapNew.putAll(contractList);
  		
        test.stopTest();	
        }
        	static testMethod void afterInsertManageContract3 (){
        test.startTest();
        List<Contract> contractList = XC_DF_Contract.createContracts(3);      
        List<Account> accList = XC_DF_Account.insertPartnerAccounts(1,'Active');  
        Map<Id,Contract> mapNew = new Map<Id,Contract>();
        Map<Id,Contract> mapOld = new Map<Id,Contract>();   
     	List<Opportunity> oppList = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
                 for(Contract c : contractList)
                 {
                    c.XC_Segment__c = 'B2B';
                    c.Opportunity__c = oppList.get(0).id;
                    c.AccountId=accList.get(0).id;
                    c.RecordTypeId=Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_Contract').getRecordTypeId(); 
                    c.XC_LegalEntity__c ='EnelXItalia';
                 }
                insert contractList;
                contractList.get(0).XC_ContractType__c= 'SERVICE';
        		contractList.get(1).XC_ContractType__c= 'MATERIAL';
          		contractList.get(2).XC_ContractType__c= 'MATERIAL AND SERVICE';
                mapNew.put(contractList.get(0).id,contractList.get(0));
                mapOld.put(contractList.get(0).id,contractList.get(1));
               // mapNew.put(contractList.get(2).id,contractList.get(2));

        
        XC_TR_Contract_AccountPartner.afterUpdateManageContract(mapNew,mapOld);    
        test.stopTest();	
        }
}