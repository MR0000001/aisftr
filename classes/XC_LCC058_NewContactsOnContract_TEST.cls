/**
* @author Chiara Turco cturco@deloitte.it
* @date Creation  16/05/2019 
* @description XC_LCC058_NewContactsOnContract_TEST – Test class for XC_LCC058_NewContactsOnContract
*/
@isTest
public class XC_LCC058_NewContactsOnContract_TEST { 
    
   
    static testMethod void callStockAvailability(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();     
        
        
        List<Contract> lstc = XC_DF_Contract.createContracts(1);
        contract c = lstc[0];
        insert c;        
        XC_ContractLineItem__c cli = new XC_ContractLineItem__c();
		cli.XC_Contract__c= c.Id;
        insert cli;
        update c; 
        string st = XC_LCC058_NewContactsOnContract.retriveData(cli.Id);    
        
        
        System.assertEquals(true, st!=null);
        Test.stopTest();
        
    }
    
    
     //Test Method retriveContractData
    static testMethod void retriveContractData(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();       
        
        List <contact> lct = XC_DF_Contact.createResidentialContacts(2);
        List <account> lac = XC_DF_Account.createResidentialAccounts(2);
        contact co = lct[0];
        account a =lac[0];
        insert a;
        co.AccountId= a.Id;
        insert co;
        
        List<Contract> lstc = XC_DF_Contract.createContracts(1);
        contract c = lstc[0];
        c.AccountId=a.Id;
        insert c;        
        XC_ContractLineItem__c cli = new XC_ContractLineItem__c();
		cli.XC_Contract__c= c.Id;
        insert cli;
        update c;
        
        string st = XC_LCC058_NewContactsOnContract.retriveContractData(c.Id, cli.Id);    
        
        
        System.assertEquals(true, st!=null);
        Test.stopTest();
        
    }
    
    //Test Method createContactsOnContract
    static testMethod void createContactsOnContract(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();       
        
        
        List <contact> lct = XC_DF_Contact.createResidentialContacts(2);
        List <account> lac = XC_DF_Account.createResidentialAccounts(2);
        contact c = lct[0];
        account a =lac[0];
        insert a;
        c.AccountId= a.Id;
        insert c;
        Map<String,Object> mp = new Map<String,Object>();
        mp.put('startDate', date.today());
        mp.put('contactValue', c.Id);        
        String st = JSON.serialize(mp);
 
        XC_UTIL_ResultWrapper rw = XC_LCC058_NewContactsOnContract.createContactsOnContract(st);         
        
        System.assertEquals(true, rw!=null);  
        Test.stopTest();
        
    }

}