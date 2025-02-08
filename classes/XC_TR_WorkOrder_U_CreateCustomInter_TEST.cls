/**
 * @author Roberta Porrega - roberta.porrega@nttdata.com
 * @date Creation 23/05/2019
 * @description XC_TR_WorkOrder_U_CreateCustomInter_TEST – Test class
 */
@isTest
private class XC_TR_WorkOrder_U_CreateCustomInter_TEST {

    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        insert XC_DF_OneOrg.createOneOrg('Spain');
    }

    static testMethod void afterWorkOrderUpdate() {
        Test.startTest();
        List<XC_Address__c> addressList =  XC_DF_Address.createAddress(1);
        insert addressList;
        List<NE__Order__c> neOrder =  XC_DF_Order.createOrders(1,'InOrder');
        neOrder[0].NE__AccountId__c = addressList[0].XC_Account__c;
        neOrder[0].XC_InstallationAddress__c = addressList[0].id;
        insert neOrder;
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1, true);
        insert oppList;
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1,  Label.XC_CL_WorkType_Installation);
        for(WorkOrder wo : woList) {
            wo.XC_Configuration__c = neOrder[0].Id;
            wo.XC_Opportunity__c = oppList[0].Id;
            wo.ContactId = oppList[0].XC_Contact__c;
            wo.Status = 'In Progress';
            wo.XC_ToBeManuallyDigitalized__c = true;
            wo.XC_Digitized__c = true;
        }
        insert woList;
        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        saList[0].status = 'Scheduled';
        insert saList;
        for(WorkOrder wo : woList) {
            wo.Status = Label.XC_CL_WorkOrder_Completed;
            wo.XC_MissingQuoteReason__c = 'TEST';
            wo.ContactId = null;
        }
        update woList;


        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(1, listInsertedWorkOrders.size());
        Test.stopTest();
    }

    static testMethod void afterWorkOrderUpdate1() {

        Test.startTest();
        List<XC_Address__c> addressList =  XC_DF_Address.createAddress(1);
        insert addressList;
        List<NE__Order__c> neOrder =  XC_DF_Order.createOrders(1,'InOrder');
        neOrder[0].NE__AccountId__c = addressList[0].XC_Account__c;
        neOrder[0].XC_InstallationAddress__c = addressList[0].id;
        neOrder[0].XC_LegalEntity__c = 'EndesaX';
        insert neOrder;
        List<Contact> contactList = XC_DF_Contact.createResidentialContacts(1);
        insert contactList;
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1,  Label.XC_CL_WorkType_Installation);
        for(WorkOrder wo : woList) {
            wo.XC_WorkTypeLabel__c = 'Installation';
            wo.XC_Configuration__c = neOrder[0].Id;
            wo.ContactId = contactList[0].Id;
            wo.Status = 'In Progress';
            wo.XC_ToBeManuallyDigitalized__c = true;
            wo.XC_Digitized__c = true;
        }
        insert woList;
        for(WorkOrder wo : woList) {
            wo.Status = Label.XC_CL_WorkOrder_Completed;
            wo.ContactId = null;
        }
        update woList;

        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(1, listInsertedWorkOrders.size());
        Test.stopTest();
    }

    static testMethod void afterWorkOrderUpdate2() {
        Test.startTest();
        List<XC_Address__c> addressList =  XC_DF_Address.createAddress(1);
        insert addressList;
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1, true);
        insert oppList;

        List<NE__Order__c> neOrder =  XC_DF_Order.createOrders(1,'InOrder');
        neOrder[0].NE__AccountId__c = addressList[0].XC_Account__c;
        neOrder[0].XC_InstallationAddress__c = addressList[0].id;
        neOrder[0].XC_DeliveryAddress__c = addressList[0].id;
        neOrder[0].NE__OptyId__c = oppList[0].Id;
        insert neOrder;

        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(10,  Label.XC_CL_WorkType_Installation);
        for(WorkOrder wo : woList) {
            wo.XC_Configuration__c = neOrder[0].Id;
            wo.Status = 'In Progress';
            wo.XC_ToBeManuallyDigitalized__c = true;
            wo.XC_Digitized__c = true;

        }
        insert woList;
        for(WorkOrder wo : woList) {
            wo.Status = Label.XC_CL_WorkOrder_Completed;
        }
        update woList;

        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(10, listInsertedWorkOrders.size());
        Test.stopTest();
    }

    @IsTest
    static void createCutomerInteractionUnreachableTEST(){
        
        Test.startTest();
        List<XC_Address__c> addressList =  XC_DF_Address.createAddress(1);
        insert addressList;
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1, true);
        insert oppList;

        List<NE__Order__c> neOrder =  XC_DF_Order.createOrders(1,'InOrder');
        neOrder[0].NE__AccountId__c = addressList[0].XC_Account__c;
        neOrder[0].XC_InstallationAddress__c = addressList[0].id;
        neOrder[0].XC_DeliveryAddress__c = addressList[0].id;
        neOrder[0].NE__OptyId__c = oppList[0].Id;
        neOrder[0].RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
        neOrder[0].XC_Status__c = 'Accepted';
        insert neOrder;

        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, Label.XC_CL_WorkType_PlannedMaintenance + ' - Gas', Label.XC_CL_WorkType_PlannedMaintenance);
        for(WorkOrder wo : woList) {
            wo.XC_Opportunity__c = oppList[0].Id;
            wo.XC_Configuration__c = neOrder[0].Id;
            wo.XC_StatusReason__c = Label.XC_CL_StatusReason_Customernotlocated;
            wo.XC_forSATO__c = true;
        }

        insert woList;
        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        saList[0].status = 'Scheduled';
        insert saList;
        for(WorkOrder wo : woList) {
            //wo.XC_CongaDynamicAPI__c = 'testAPI';
            wo.Status = Label.XC_CL_CustomerInteraction_Assigned;
            wo.XC_ToBeManuallyDigitalized__c = true;
            wo.XC_Digitized__c = true;
        }
        update woList;

        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(1, listInsertedWorkOrders.size());
        Test.stopTest();
    }
    
    @IsTest
    static void createCutomerInteractionCustomerActivityReportTEST(){
        
        Test.startTest();
        List<XC_Address__c> addressList =  XC_DF_Address.createAddress(1);
        insert addressList;
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1, true);
        insert oppList;

        List<NE__Order__c> neOrder =  XC_DF_Order.createOrders(1,'InOrder');
        neOrder[0].NE__AccountId__c = addressList[0].XC_Account__c;
        neOrder[0].XC_InstallationAddress__c = addressList[0].id;
        neOrder[0].XC_DeliveryAddress__c = addressList[0].id;
        neOrder[0].NE__OptyId__c = oppList[0].Id;
        neOrder[0].RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
        neOrder[0].XC_Status__c = 'Accepted';
        insert neOrder;

        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, Label.XC_CL_WorkType_DeliveryInstallation, Label.XC_CL_WorkType_DeliveryInstallation);
        for(WorkOrder wo : woList) {
            wo.XC_Opportunity__c = oppList[0].Id;
            wo.XC_Configuration__c = neOrder[0].Id;
            wo.Status = 'In Progress';
        } 
        
        
        insert woList;
        for(WorkOrder wo : woList) {
            wo.Status = Label.XC_CL_WorkOrder_Completed;
            wo.XC_ToBeManuallyDigitalized__c = true;
            wo.XC_Digitized__c = true;
        }
        update woList;



        List<WorkOrder> listInsertedWorkOrders = [SELECT Id, XC_Check_Final_Status__c, XC_CongaDynamicAPI__c FROM WorkOrder];
        Map<Id,WorkOrder> mapOfWo = XC_TR_WorkOrder_U_CreateCustomInter.getWoMap(woList);
        mapOfWo.values()[0].XC_CongaDynamicAPI__c = 'TestAPI';
        XC_TR_WorkOrder_U_CreateCustomInter.createCutomerInteractionCustomerActivityReport(listInsertedWorkOrders, mapOfWo, null);
        System.assertEquals(1, listInsertedWorkOrders.size());
        Test.stopTest();
    }

    @isTest
    static void createCutomerInteractionCommercialVisitTEST(){
        
        Test.startTest();
        List<XC_Address__c> addressList =  XC_DF_Address.createAddress(1);
        insert addressList;
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1, true);
        insert oppList;

        List<NE__Order__c> neOrder =  XC_DF_Order.createOrders(1,'InOrder');
        neOrder[0].NE__AccountId__c = addressList[0].XC_Account__c;
        neOrder[0].XC_InstallationAddress__c = addressList[0].id;
        neOrder[0].XC_DeliveryAddress__c = addressList[0].id;
        neOrder[0].NE__OptyId__c = oppList[0].Id;
        neOrder[0].RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
        neOrder[0].XC_Status__c = 'Accepted';
        insert neOrder;

        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Commercial Visit - Boiler', Label.XC_CL_CommercialVisit);
        for(WorkOrder wo : woList) {
            wo.XC_Opportunity__c = oppList[0].Id;
            wo.XC_Configuration__c = neOrder[0].Id;
            wo.Status = 'In Progress';
        }
        
        
        insert woList;
        for(WorkOrder wo : woList) {
            wo.Status = Label.XC_CL_WorkOrder_Completed;
            wo.XC_CongaDynamicAPI__c = 'TEST Api';
            wo.XC_ToBeManuallyDigitalized__c = true;
            wo.XC_Digitized__c = true; 
        }
        update woList;

        List<WorkOrder> listInsertedWorkOrders = [SELECT Id, XC_Check_Final_Status__c, XC_CongaDynamicAPI__c FROM WorkOrder];
        System.assertEquals(1, listInsertedWorkOrders.size());
        Test.stopTest();
    }
    @IsTest
    static void methodName(){
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Commercial Visit - Boiler', Label.XC_CL_CommercialVisit);
        insert woList; 
        Test.startTest();
        XC_TR_WorkOrder_U_CreateCustomInter.checkPrimaryPhone(woList[0]);
        XC_TR_WorkOrder_U_CreateCustomInter.checkSecondaryPhone(woList[0]);
        System.assertEquals(1, woList.size());
        Test.stopTest();
        
    }

    @isTest
    static void createCutomerInteractionCustomerActivityReportRejectedQT(){
        Test.startTest();
        List<XC_Address__c> addressList =  XC_DF_Address.createAddress(1);
        insert addressList;
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1, true);
        insert oppList;

        List<NE__Order__c> neOrder =  XC_DF_Order.createOrders(1,'InOrder');
        neOrder[0].NE__AccountId__c = addressList[0].XC_Account__c;
        neOrder[0].XC_InstallationAddress__c = addressList[0].id;
        neOrder[0].XC_DeliveryAddress__c = addressList[0].id;
        neOrder[0].NE__OptyId__c = oppList[0].Id;
        neOrder[0].RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
        neOrder[0].XC_Status__c = 'Rejected';
        insert neOrder;

        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 
                                  'Commercial Visit - Boiler', Label.XC_CL_CommercialVisit);
        for(WorkOrder wo : woList) {
            wo.XC_Opportunity__c = oppList[0].Id;
            wo.XC_Configuration__c = neOrder[0].Id;
            wo.Status = 'In Progress';
            wo.XC_ToBeManuallyDigitalized__c = true;
            wo.XC_Digitized__c = true;
        }
        
        insert woList;

        List<ServiceAppointment> listOfSA = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        insert listOfSA;
        for(WorkOrder wo : woList) {
            wo.Status = Label.XC_CL_WorkOrder_Completed;
            wo.XC_CongaDynamicAPI__c = 'TEST Api';
        }
        update woList;

        List<WorkOrder> listInsertedWorkOrders = [SELECT Id, XC_Check_Final_Status__c, XC_CongaDynamicAPI__c FROM WorkOrder];
        System.assertEquals(1, listInsertedWorkOrders.size());
    }
}