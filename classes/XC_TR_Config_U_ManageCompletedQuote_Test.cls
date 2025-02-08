/**
 * The Class XC_TR_Config_U_ManageCompletedQuote_Test.
 *
 * @author Domenico Del Prete domenico.delprete@nttadata.com
 * @date Creation 18/11/2019
 * @date Modification dd/mm/yyyy
 * @description XC_TR_Config_U_ManageCompletedQuote_Test – Class test for XC_TR_Config_U_ManageCompletedQuote
 */
 @isTest
public without sharing class XC_TR_Config_U_ManageCompletedQuote_Test {

    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c(); 
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    }

    @IsTest
    static void succededTest(){  
        List<WorkOrder> listOfWoPlannedMaintenance = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1,Label.XC_CL_WorkTypeLabel_PlannedMaintenance, Label.XC_CL_WorkType_PlannedMaintenance); 
        insert listOfWoPlannedMaintenance;
        XC_DictamenItem__c dicta = new XC_DictamenItem__c();
        dicta.XC_Precintar__c = 'Sealed';
        dicta.XC_WorkOrder__c = listOfWoPlannedMaintenance[0].id;
        insert dicta;
        List<WorkOrder> listOfWORepair = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_Repair); 
        listOfWORepair[0].XC_WorkTypeLabel__c = Label.XC_CL_Repair;
        listOfWORepair[0].ParentWorkOrderId = listOfWoPlannedMaintenance[0].id;
        insert listOfWORepair;
        List<Opportunity> listOfOpp = XC_DF_Opportunity.createOpportunity(1, false);
        listOfOpp[0].XC_WorkOrder__c = listOfWORepair[0].id;
        insert listOfOpp;

        List<XC_Address__c> listOfAddress = XC_DF_Address.createAddress(1);
        NE__Order__c order = new NE__Order__c();
        order.XC_DeliveryAddress__c = listOfAddress[0].id;
        order.XC_InstallationAddress__c = listOfAddress[0].id;
        order.NE__AccountId__c = listOfOpp[0].AccountId;
        order.NE__OptyId__c = listOfOpp[0].Id;
        Id quote = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
        order.RecordTypeId = quote; 
        order.XC_Status__c = 'Draft';
        insert order;
        order.XC_Status__c = 'Rejected';
        update order;        
    }


}