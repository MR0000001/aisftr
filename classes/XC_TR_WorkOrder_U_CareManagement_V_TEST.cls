@isTest
public class XC_TR_WorkOrder_U_CareManagement_V_TEST {
    
    @TestSetup
    static void setupData(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        NE__Order__c order = XC_DF_Order.createOrder(Label.XC_CL_Configuration_TypeInOrder); //'InOrder'
    }
	
    @isTest
	static void careManagementToScheduleAppointment(){
        Test.startTest();
		List<Account> acc = [SELECT Id FROM Account];
        List<Contact> cont = [SELECT Id FROM Contact];
        
        NE__Order__c orderQueried = [SELECT Id, RecordType.DeveloperName, XC_Status__c FROM NE__Order__c];
        orderQueried.XC_Status__c = Label.XC_CL_Configuration_OrderInProvisioning;
        orderQueried.RecordType.DeveloperName = Label.XC_CL_Configuration_Order;
        orderQueried.XC_Compliance_Approval__c = Label.XC_CL_ComplianceVerificationStatus_StatusOK;
        orderQueried.XC_Channel__c = null;
        update orderQueried;
        
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        woList[0].AccountId = acc[0].Id;
        woList[0].ContactId = cont[0].Id;
        woList[0].XC_Configuration__c = orderQueried.Id; //order
        insert woList;
        
        System.assertEquals(true, woList[0].Id!=null);
        Test.stopTest();
    }
	
    @isTest
	static void careManagementToScheduleAppointmetFromMarket(){
		List<Account> acc = [SELECT Id FROM Account];
        List<Contact> cont = [SELECT Id FROM Contact];
        
        Test.startTest();
        NE__Order__c orderQueried = [SELECT Id, RecordType.DeveloperName, XC_Status__c FROM NE__Order__c];
        orderQueried.XC_Status__c = Label.XC_CL_Configuration_OrderInProvisioning;
        orderQueried.XC_Channel__c = Label.XC_CL_Order_ChannelValue_Market;
        update orderQueried;
        
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        woList[0].AccountId = acc[0].Id;
        woList[0].ContactId = cont[0].Id;
        woList[0].XC_Configuration__c = orderQueried.Id;
        insert woList;
        
        System.assertEquals(true, woList[0].Id!=null);
        Test.stopTest();
    }
    
    /*@isTest
	static void manageCaseClosureForScheduleAppointment(){
		List<Account> acc = [SELECT Id FROM Account];
        List<Contact> cont = [SELECT Id FROM Contact];
        
        NE__Order__c orderQueried = [SELECT Id, RecordType.DeveloperName, XC_Status__c FROM NE__Order__c];
        orderQueried.XC_Status__c = Label.XC_CL_Configuration_OrderInProvisioning;
        orderQueried.RecordType.DeveloperName = Label.XC_CL_Configuration_Order;
        orderQueried.XC_Channel__c = Label.XC_CL_Order_ChannelValue_Market;
        update orderQueried;
        
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        woList[0].AccountId = acc[0].Id;
        woList[0].ContactId = cont[0].Id;
        woList[0].XC_Configuration__c = orderQueried.Id;
        
        insert woList;
        
        Test.startTest();
        woList[0].Status = Label.XC_CL_WorkOrder_Assigned;
        update woList;

        System.assertEquals(true, woList[0].Status == Label.XC_CL_WorkOrder_Assigned);
        Test.stopTest();
    }
    
    @isTest
	static void careManagementToScheduleAppointmet_skeepCreation(){
		List<Account> acc = [SELECT Id FROM Account];
        List<Contact> cont = [SELECT Id FROM Contact];
        
        NE__Order__c orderQueried = [SELECT Id, RecordType.DeveloperName, XC_Status__c FROM NE__Order__c];
        orderQueried.XC_Status__c = Label.XC_CL_Configuration_OrderInProvisioning;
        orderQueried.RecordType.DeveloperName = Label.XC_CL_Configuration_Order;
        orderQueried.XC_Channel__c = Label.XC_CL_Order_ChannelValue_Market;
        update orderQueried;
        
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        woList[0].AccountId = acc[0].Id;
        woList[0].ContactId = cont[0].Id;
        insert woList;
        
        Map<String, XC_CM_Case_Type_Setting__mdt> caseMDT = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_CaseToScheduleAppointment});
        Case caso = XC_UTIL_Case.initCaseFromCaseSettings(caseMDT.get(Label.XC_CL_CaseToScheduleAppointment));
        caso.AccountId = woList[0].AccountId;
        caso.ContactId = woList[0].ContactId;
        caso.Status = 'ESTA003';
        caso.XC_WorkOrder__c = woList[0].Id;
        caso.XC_Order__c = orderQueried.Id;
        caso.XC_LegalEntity__c = woList[0].XC_LegalEntity__c;
        caso.Country__c = woList[0].XC_Country__c;
        caso.Origin = Label.XC_CL_CaseOriginCAN002;
        insert caso;
        
        Test.startTest();
        	woList[0].XC_Configuration__c = orderQueried.Id;
            update woList;
            System.assert(true);
        Test.stopTest();
    }*/
}