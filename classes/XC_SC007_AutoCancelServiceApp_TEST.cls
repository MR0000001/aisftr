/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 31/05/2019
* @description XC_SC007_AutoCancelServiceApp_TEST – Test class for XC_SC007_AutoCancelServiceAppointment
*/ 

@isTest
private class XC_SC007_AutoCancelServiceApp_TEST {
    @TestSetup
    static void testSetup (){
        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(1);
        insert listOrderItem;  
       /* List<User> usersList = [SELECT Id FROM User WHERE Profile.Name = 'XC_ESP_SalesAgentPartner' AND isActive = true];
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
        WorkType workType = new WorkType();
        workType.Name = 'Delivery & Installation';
        workType.XC_WorkTypeCategory__c = 'Delivery & Installation';
        workType.DurationType = Label.XC_CL_WorkType_Hours;
        worktype.XC_LegalEntity__c = 'EndesaX';
        worktype.XC_Country__c = 'SPAIN';
        workType.EstimatedDuration = 1;
        insert workType;
    } 
    @isTest 
    static void onExecuteBatch() {
        Test.startTest();
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        List<NE__OrderItem__c> listOrderItem = new List<NE__OrderItem__c>([SELECT ID FROM NE__OrderItem__c limit 1]);
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, 'Delivery & Installation');
        woList[0].XC_DeliveryDate__c = Date.newInstance(2020, 1, 1);
        woList[0].XC_WorkTypeLabel__c = 'Delivery & Installation';
        insert woList;

        woList[0].XC_Configuration_Item__c = listOrderItem[0].Id; 
        update woList;
        
        WorkOrder wo = [SELECT Id, ContactId, AccountId,  WorkTypeId FROM WorkOrder WHERE Id = : woList[0].Id LIMIT 1];
        List<Contact> listContact = XC_DF_Contact.createResidentialContacts(1);
        insert listContact;
		wo.ContactId = listContact[0].Id;
        update wo;

        Opportunity opportunity = XC_DF_Opportunity.createOpportunity(1, false)[0];
        insert opportunity; 

        List<NE__OrderItem__c> listOrderItemQuery = [SELECT Id, NE__OrderId__r.NE__OptyId__c, NE__OrderId__c FROM NE__OrderItem__c WHERE Id = :listOrderItem[0].Id];
        NE__Order__c order = new NE__Order__c(Id = listOrderItemQuery[0].NE__OrderId__c);
        order.NE__OptyId__c = opportunity.Id;
        update order;


        insert XC_DF_OperatingHours.createOperatingHours('Gold Appointment Calendar');
        
        List<ServiceAppointment> listServiceAppointment = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        listServiceAppointment[0].XC_WorkTypeLabel__c = 'Delivery & Installation';
        listServiceAppointment[0].XC_Country__c = 'Spain';
        listServiceAppointment[0].SchedStartTime = (Datetime) Date.today();
        listServiceAppointment[0].SchedEndTime = (Datetime) Date.today();
        listServiceAppointment[0].Status = 'Scheduled';
        listServiceAppointment[0].ActualDuration = 1.0;
        listServiceAppointment[0].XC_LegalEntity__c = 'EndesaX';
        insert listServiceAppointment;
        
        
        listServiceAppointment[0].SchedStartTime = (Datetime) Date.today().addDays(1);
        listServiceAppointment[0].SchedEndTime = (Datetime) Date.today().addDays(2);
        
        
        List<XC_UTIL_ZipCodeWorkType.ZipCodeWorkTypeWrapper> zipCodeWtWrapper = new List<XC_UTIL_ZipCodeWorkType.ZipCodeWorkTypeWrapper>(); 
        XC_UTIL_ZipCodeWorkType.ZipCodeWorkTypeWrapper wrap = new XC_UTIL_ZipCodeWorkType.ZipCodeWorkTypeWrapper();
        wrap.workType = 'Delivery & Installation';
        wrap.zipCode = '12233';
        zipCodeWtWrapper.add(wrap);
        
        
        XC_ZipCodeWorkType__c zip = new XC_ZipCodeWorkType__c();
        zip.XC_ExternalId__c = wrap.zipCode+'_'+wrap.workType;
        zip.XC_ZipCode__c ='12233';
        zip.XC_WorkType__c = wo.WorkTypeId;
        insert zip;
        
        listServiceAppointment[0].XC_Payment_Type__c = Label.XC_CL_BankTransfer;
        listServiceAppointment[0].ContactId = listContact[0].Id;
        update listServiceAppointment;

        System.assert(listServiceAppointment!=null);
        String query = ' SELECT Id, SchedStartTime, ParentRecordId, XC_WorkTypeLabel__c, XC_Payment_Type__c ' + 
                       ' FROM ServiceAppointment '; 
        List<ServiceAppointment> temp = Database.query(query);
        System.debug('@@@ query1 ---> ' + temp);
        Database.executeBatch(new XC_SC007_AutoCancelServiceAppointment(), 50); 
        Test.stopTest();
    }
}