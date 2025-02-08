/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 15/05/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_WorkOrder_U_CheckCommVisit_TEST – Test Class for XC_TR_WorkOrder_U_CheckCommercialVisit
*/ 
@isTest
public class XC_TR_WorkOrder_U_CheckCommVisit_TEST {

    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        /*List<User> usersList = [SELECT Id FROM User WHERE Profile.Name = 'XC_ESP_SalesAgentPartner' AND isActive = true];
        List<Account> accountList = XC_DF_Account.insertPartnerAccounts(1);
        List<ServiceResource> serviceResourcesToInsert = new List<ServiceResource>();
            ServiceResource serviceRes = new ServiceResource();
            serviceRes.Name = 'No Candidate Found';
            serviceRes.XC_Account__c = accountList[0].Id;
            serviceRes.IsActive = true;
            serviceRes.IsCapacityBased = true;
            serviceRes.XC_AutomaticDeactivation__c = true;
            serviceRes.RelatedRecordId = usersList[1].Id; // serviceRes.RelatedRecordId = accnt.Users[0].Id
            serviceResourcesToInsert.add(serviceRes);
        insert serviceResourcesToInsert;*/
    }

    static testMethod void onInsertWithLead() { 
        insert XC_DF_Lead.createResidentialLead();
        Lead leadInserted = [SELECT Id FROM Lead];
        List<WorkOrder> woListPreviousLead = new List<WorkOrder>();
        List<WorkOrder> woListPrevoius = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_CommercialVisit);
        for (WorkOrder wo : woListPrevoius){
            wo.XC_Lead__c = leadInserted.Id; 
            woListPreviousLead.add(wo);
        }
        insert woListPreviousLead;
        List<WorkOrder> woListWithLead = new List<WorkOrder>();
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(100, Label.XC_CL_WorkType_CommercialVisit);
        for (WorkOrder wo : woList){
            wo.XC_Lead__c = leadInserted.Id; 
            woListWithLead.add(wo);
        }
        Test.startTest();
        try{
        insert woListWithLead;
        }
         catch(Exception e) {
             Boolean expectedExceptionThrown =  e.getMessage().contains(Label.XC_CL_WorkOrder_CommercialVisitErrorOnLead) ? true : false;
             System.assertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }

    static testMethod void onInsertWithOpportunity() {
        insert XC_DF_Account.createResidentialAccounts(1);
        List<Account> accList = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'XC_GLO_Account_Residential'];
        insert XC_DF_Address.createAddress(accList);
        List<XC_Address__c> listAddress = [SELECT Id FROM XC_Address__c];
        insert XC_DF_Contact.createResidentialContacts(accList);
        List<Contact> contactList = [SELECT Id, AccountId FROM Contact];
        insert XC_DF_Opportunity.createOpportunityWithVisit(contactList,listAddress[0]);
        List<Opportunity> oppInserted = [SELECT Id FROM Opportunity];
        List<WorkOrder> woListPreviousOpp = new List<WorkOrder>();
        List<WorkOrder> woListPrevoius = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_CommercialVisit);
        for(Opportunity op: oppInserted){
            for (WorkOrder wo : woListPrevoius){
                wo.XC_Opportunity__c = op.Id; 
                woListPreviousOpp.add(wo);
            }
        }
        insert woListPreviousOpp;
        List<WorkOrder> woListWithOpp = new List<WorkOrder>();
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_CommercialVisit);
        for(Opportunity op: oppInserted){
            for (WorkOrder wo : woList){
                wo.XC_Opportunity__c = op.Id; 
                woListWithOpp.add(wo);
            }
        }
        Test.startTest();
        try{
            insert woListWithOpp;
            System.debug(LoggingLevel.WARN,'@@woListWithOpp'+woListWithOpp.size());
            System.debug('woListWithOpp[0].XC_WorkTypeLabel__c-->'+ woListWithOpp[0].XC_WorkTypeLabel__c);
            System.debug(LoggingLevel.FINEST,'woListWithOpp-->' +woListWithOpp);

        }    
        catch(Exception e) {
             Boolean expectedExceptionThrown =  e.getMessage().contains(Label.XC_CL_WorkOrder_CommercialVisitErrorOnOpportunity) ? true : false;
             System.assertEquals(expectedExceptionThrown, true);
        }
       
        Test.stopTest();
    }

}