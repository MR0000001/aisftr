@isTest
public class XC_LCC_CreateOppFromSA_Test {
    
    static testMethod void getServiceApptest(){
        
      List<Account> accounts = XC_DF_Account.createResidentialAccounts(1);
      insert accounts;
      List <Contact> cont = XC_DF_Contact.createResidentialContacts(accounts);
      cont[0].AccountId=accounts.get(0).id; 
      insert cont;
      List<Opportunity> opp = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);     
      insert opp;
      User u=[select id from user where XC_EnabledToSkip__c=true limit 1];
      test.startTest();
      Case caso = new Case();
      caso.Status = 'ESTA001';
      caso.Reason = 'XCMOT002';
      caso.SubCause__c ='ATCL003';
      caso.XC_Opportunity__c= opp[0].id;
      caso.XC_LegalEntity__c = 'EnelXItalia';
      caso.OwnerId=Userinfo.getUserId();
      caso.AccountId = accounts[0].Id;
      caso.ContactId = cont[0].Id;
      caso.XC_Type_Intermediary__c = 'TI001';
      caso.Origin='CAN0008';
      caso.XC_Subtype__c='XC199';
      caso.XC_BusinessLine__c='eCity';
      System.runas(u){
        insert caso;
      }
      WorkOrder ord=new WorkOrder();      
      ord.RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_WorkOrder').getRecordTypeId();
      ord.XC_Segment__c='B2B';
      ord.XC_LegalEntity__c='EnelSole';
      ord.XC_WorkTypeCategory__c='Malfunctioning';
      ord.XC_WorkTypeLabel__c='Census - Juice Box';
      ord.Description='Test Prova';
      ord.BusinessLine__c='eCity';
      ord.XC_Country__c='Italy';
      ord.caseId=caso.id;
      Insert ord;
      List<WorkOrder> listWorder=new List<WorkOrder>();
      listWorder.add(ord);
      List<ServiceAppointment>  servApp = XC_DF_ServiceAppointment.createServiceAppointment(listWorder);
      servApp[0].XC_ReasonforSuspension__c = 'Richiesta Preventivo';
      servApp[0].XC_QuotationRequestOutcome__c='Quotation Request Accepted';
      insert servApp;
      XC_LCC_CreateOppFromServiceAppointment.ResultWrapper rw = XC_LCC_CreateOppFromServiceAppointment.getCurrentServiceAppointment(servApp[0].id);
        
      System.assertEquals(true, rw!=null);
      //System.assertEquals(ord.Id, rw.workOrderId);
      Test.stopTest();
    }
}