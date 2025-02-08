/**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com 
* @date Creation 05/09/2019
* @date Modification 
* @description XC_LCC139_QuoteDetails_TEST 
*/  
@isTest
public class XC_LCC139_QuoteDetails_TEST {  
    
    /**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com 
* @description  Method to test retrieveQuoteId
*/
static testMethod void retrieveQuoteIdTest(){

     OneOrg__c org = new OneOrg__c(); 
     org.Name = 'OneOrg (User)';
     //org.XC_Spain_Triggers__c = true;
     insert org;
   
     List<User> usersList = [SELECT Id FROM User WHERE Profile.Name = 'XC_ESP_SalesAgentPartner' AND isActive = true];
     List<Account> accountList = XC_DF_Account.insertPartnerAccounts(1);
     List<Contact> ctList = XC_DF_Contact.createPartnerContacts(accountList);
     insert ctList;
     List<XC_Address__c> add = XC_DF_Address.createAddress(accountList);
     insert add;
     /*List<ServiceResource> serviceResourcesToInsert = new List<ServiceResource>();  
            ServiceResource serviceRes = new ServiceResource();
            serviceRes.Name = 'No Candidate Found';
            serviceRes.XC_Account__c = accountList[0].Id;
            serviceRes.IsActive = true;
            serviceRes.IsCapacityBased = true;
            serviceRes.XC_AutomaticDeactivation__c = true;
            serviceRes.RelatedRecordId = usersList[1].Id; // serviceRes.RelatedRecordId = accnt.Users[0].Id
            serviceResourcesToInsert.add(serviceRes);
    insert serviceResourcesToInsert;*/
    List<Opportunity> opps = XC_DF_Opportunity.createOpportunity(1,false);   
    insert opps;
    List<WorkOrder> wos = XC_DF_WorkOrder.createWorkOrders(1,'General');    
    wos[0].XC_Opportunity__c = opps[0].id; 
    wos[0].AccountId = accountList[0].Id;
    wos[0].Status = 'Assigned';
    System.debug('Acc Name = '+accountList[0].Name);
    
    insert wos;
    WorkOrder wo1 = [SELECT Id, Status FROM WorkOrder LIMIT 1];
    wo1.Status = 'In Progress';
    update wo1;
     WorkOrder wo2 = [SELECT Id, Status FROM WorkOrder LIMIT 1];
    wo2.Status = 'Completed';
    update wo2;
    Test.startTest();
    WorkOrder wo = [SELECT Id, Status FROM WorkOrder LIMIT 1];
    opps[0].XC_WorkOrder__c = wo.Id;
    update opps;
    List<Case> cases = XC_DF_Case.createCasesForWo(1);    
    cases[0].RecordTypeId =  Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_ESP_Case').getRecordTypeId();

    NE__Order__c ord = XC_DF_Order.createOrder('In Order');
    ord.NE__OptyId__c = opps[0].Id;
    ord.NE__One_Time_Fee_Total__c = 0;
    ord.NE__Recurring_Charge_Total__c = 100;
    ord.XC_Status__c = 'In provisioning';
    update ord;
    cases[0].Reason = 'XCMOT004';
    cases[0].Status = 'ESTA001';
    cases[0].ContactId = ctList[0].Id;
    cases[0].AccountId = accountList[0].Id;
    cases[0].XC_WorkOrder__c = wo.id; 
    insert cases;
    Case c = [SELECT Id, AccountId, ContactId, XC_WorkOrder__c, XC_WorkOrder__r.Status, XC_WorkOrder__r.AccountId, XC_WorkOrder__r.ContactId, RecordType.Name from Case limit 1];
    System.debug('@@@Cases-->'+cases[0].XC_WorkOrder__c);
    c.RecordTypeId =  Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_ESP_Case').getRecordTypeId();
    update c;
    XC_LCC139_QuoteDetails.retrieveQuoteId(c.Id);
    Test.stopTest();

	}
}