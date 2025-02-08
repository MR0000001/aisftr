/**
 * The Class XC_LCC268_GenerateDocument_Test.
 *
 * @author            : Ramayya bulli.bheemanaboyana@accenture.com
 * @date Creation     : 02/18/2022
 * @date Modification : 
 * @description       : TEST Class for XC_LCC268_GenerateDocument
 */

@isTest
public with sharing class XC_LCC268_GenerateDocument_Test {
  @isTest
    public static XC_REST_ContractCallback.ContractCallbackResponse testCallClass(){
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
        contractlist[0].XC_Generate_Contract_Document__c = true;
         wr = XC_UTIL_Sobject.updateRecord(contractlist[0]);
        wcallBackResponse.Error =wr.errorMessage;
       wcallBackResponse.Message =wr.errorMessage;
       
       Test.startTest();
       XC_LCC268_GenerateDocument.getContractRecordMethod(con.id);
        con.XC_EnelEnergyMARI_ExternalIdDOC__c = '';
        update con;
        XC_LCC268_GenerateDocument.getContractRecordMethod(con.id);
       Test.stopTest();
       return wcallBackResponse;
    }
  
}