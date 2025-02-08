/**
 * The Class XC_TR_Case_U_CancellationManagement_TEST
 * @author Luisana Rocco lrocco@deloitte.it
 * @date Creation 21/08/2019
 * @description Test class - XC_TR_Case_U_CancellationManagement/_D
**/ 

@isTest
public without sharing class XC_TR_Case_U_CancellationManagement_TEST { 

    @TestSetup
	static void setup(){ 
        Test.startTest();
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Case> caseList = new List<Case>();
        for (Integer i=0; i<2; i++){
			Case caso = new Case();
            caso.Status = 'ESTA001';
            caso.Reason = 'XCMOT004';
            caso.SubCause__c = 'ATCL066';
            caso.XC_LegalEntity__c = 'EndesaX';
            caseList.add(caso);
        }
        List<Account> listAccount = XC_DF_Account.createResidentialAccounts(1);
        insert listAccount;
        List<Contact> listContact = XC_DF_Contact.createResidentialContacts(listAccount);
        insert listContact;
        List<Account> accList = [SELECT Id, Name, (SELECT Id, AccountId, Email, XC_Preferredlanguageofcontact__c FROM Contacts) FROM Account];
        caseList[1].ContactId = accList[0].Contacts[0].Id;
        caseList[1].AccountId = accList[0].Id;
        caseList[0].ContactId = accList[0].Contacts[0].Id;
        caseList[0].AccountId = accList[0].Id;
        insert caseList;
        List<NE__Order__c> orderList = XC_DF_Order.createOrders(1, 'InOrder');
        orderList[0].XC_CaseId__c = caseList[0].Id;
        insert orderList;
        caseList[1].ParentId = caseList[0].Id;
        update caseList;
        List<XC_Address__c> addressForAccount =  XC_DF_Address.createAddress(accList);
        insert addressForAccount;
        List<Opportunity> oppList =  XC_DF_Opportunity.createOpportunityWithoutVisit(accList[0].Contacts, addressForAccount[0]);
        oppList[0].XC_CaseId__c = caseList[0].Id;
        insert oppList;
        Test.stopTest();
        List<Opportunity> oppListQuote =  XC_DF_Opportunity.createOpportunityWithoutVisit(accList[0].Contacts, addressForAccount[0]);
        insert oppListQuote;
        List<XC_Address__c> address2 =  XC_DF_Address.createAddress(1);
        insert address2;    
        NE__Order__c ordClone = orderList[0].clone(false, false, false, false);
        ordClone.RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByName().get('Quote').getRecordTypeId();
        ordClone.XC_CaseId__c = caseList[0].Id;
        ordClone.NE__OptyId__c = oppListQuote[0].Id;
        ordClone.XC_DeliveryAddress__c = addressForAccount[0].id; //address2[0].Id;

        ordClone.NE__AccountId__c = accList[0].Id;
        insert ordClone;
        List<ServiceResource> serviceRes  = XC_DF_ServiceResource.createServiceResources(1);
        serviceRes[0].Name = 'No Candidate Found';
        update serviceRes;
    }
    
    /*
	    *@ Description Case Cancelled.
	*/
    @isTest
    static void caseCancellation() {        
        Case parentCase = [SELECT Id FROM Case WHERE ContactId !=null][0];
        // create work order
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders (1, 'Delivery & Installation');
        woList[0].CaseId = parentCase.Id;
        woList[0].Status = 'Assigned';
        woList[0].XC_DeliveryDate__c = Date.newInstance(2020, 1, 1);
        woList[0].XC_WorkTypeLabel__c = 'Delivery & Installation';
        insert woList;
        Test.startTest();
        parentCase.Status = 'ESTA008';
        parentCase.CaseRemarks__c  = 'Cancellation';
        parentCase.XC_Result__c = 'RS011';
        parentCase.XC_Resolution__c = 'R017';
        update parentCase;
        Test.stopTest();
        System.assert(parentCase!=null);
    }

    /*
	    *@ Description Cannot cancel the case. The opportunity has child record related
	*/
    @isTest
    static void caseCancellationOpportunityError() {
        Opportunity opp = [SELECT Id FROM opportunity][0];
        NE__Order__c ord = [SELECT Id FROM NE__Order__c][0];
        ord.NE__OptyId__c = opp.Id;
        update ord; 
        Test.startTest();
        Case parentCase = [SELECT Id FROM Case][0];
        parentCase.Status = 'ESTA008';
        parentCase.CaseRemarks__c  = 'Cancellation';
        parentCase.XC_Result__c = 'RS011';
        parentCase.XC_Resolution__c = 'R017';
        try{
            update parentCase;
        }catch(Exception ex){
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' ,ex.getDmlStatusCode(0));
        }
        Test.stopTest();
    }

    /*
	    *@ Description Cannot cancel the case. Exception.
	*/
    @isTest
    static void caseCancellationError() {
        Test.startTest();
        Case parentCase = [SELECT Id FROM Case][0];
        parentCase.Status = 'ESTA008';
        try{
            update parentCase;
        }catch(Exception ex){
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' ,ex.getDmlStatusCode(0));
        }
        Test.stopTest();
    }

}