@isTest
public with sharing class XC_REST_ContractCallback_Test {
     static testMethod void requestNotActive(){
        XC_REST_ContractCallback.ContractCallbackRequest req = new XC_REST_ContractCallback.ContractCallbackRequest();
        test.startTest();
        XC_REST_ContractCallback.ContractCallbackResponse wr = XC_REST_ContractCallback.callToPostContractFromEE(req, 'serverSystem');
        System.assertNotEquals(String.valueof(200), wr.Error);
        test.stopTest();
    }

     @isTest
    public static XC_REST_ContractCallback.ContractCallbackResponse requestActive(){
        List<Account> accounts = new List<Account>();
        Account testAccount = new Account(Name = 'Test',PrimaryEmail__c='test@gmail.com');
        insert testAccount;
        accounts.add(testAccount);
    Contract con = new Contract();
    con.AccountId = testAccount.id;
    con.XC_EnelEnergyMARI_ExternalIdDOC__c = 'UMAKX0002JRH';
    con.Description = '';
    con.XC_Generate_Contract_Document__c = false;
    insert con;
    List<Contract> contractlist = [SELECT Id, XC_EnelEnergyMARI_ExternalIdDOC__c,XC_CompanyName__c,Description,XC_Generate_Contract_Document__c  FROM Contract limit 1];
    list<user> u= [select id,Country__c from User where id=:UserInfo.getUserId() limit 1];
        
     XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_interfaceName__c = 'CreateContract';
        ic.name = 'CreateContract';
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        insert ic;
    XC_REST_ContractCallback.ContractCallbackResponse wcallBackResponse = new XC_REST_ContractCallback.ContractCallbackResponse();
    XC_REST_ContractCallback.ContractCallbackRequest wReq = new XC_REST_ContractCallback.ContractCallbackRequest();
    wReq.ObjectId = contractlist[0].id;
    wReq.ExternalDocumentId = contractlist[0].XC_EnelEnergyMARI_ExternalIdDOC__c;
    wReq.DocumentCategory = 'SF_CONTRACT_SIGNED';
    wReq.ObjectType = 'Contract';
    wReq.Company = UserInfo.getOrganizationName();
    wReq.FileName = 'Contract signed'+' '+contractlist[0].id;
    wReq.Description = contractlist[0].Description;
    wReq.Country = u[0].Country__c;
    wcallBackResponse = XC_REST_ContractCallback.callToPostContractFromEE(wReq,'XCustomerB2C');
        
    XC_UTIL_Sobject.WrapperResult wr = new XC_UTIL_Sobject.WrapperResult();
       wcallBackResponse.Error =wr.errorMessage;
       wcallBackResponse.Message =wr.errorMessage;
      system.assert(wcallBackResponse!=null);
        return wcallBackResponse;
    }
}