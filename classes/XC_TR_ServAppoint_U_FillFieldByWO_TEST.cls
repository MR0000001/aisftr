/**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 17/05/2019
* @description XC_TR_ServAppoint_U_FillFieldByWO_TEST –Test Class
*/

@isTest
private class XC_TR_ServAppoint_U_FillFieldByWO_TEST {
     //    TEST INSERT 
    @isTest
    static void checkInsertServiceAppointment() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
         List<Account> acct = XC_DF_Account.createResidentialAccounts(2);
        acct[0].PrimaryEmail__c = 'test@te.it';
        acct[0].IdentityType__c = 'NIF';
        acct[0].IdentityNumber__c='50692632B';
        insert acct;  
        List<Contact> cont = XC_DF_Contact.createResidentialContacts(acct);
        cont[0].FirstName = 'Mario';
        cont[0].LastName='Rossi';
        cont[0].Email = 'test1@contact.it';        
        insert cont;
        String contactId = cont[0].Id;
        String accountId = acct[0].Id; 
        
        
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Delivery', 'Delivery');
        woList[0].XC_DeliveryDate__c = System.today();
        insert woList;
        Test.startTest();
        insert XC_DF_ServiceAppointment.createServiceAppointment(woList);
        List<ServiceAppointment> servAppoInsert = [SELECT Id FROM ServiceAppointment];
        //system.assertEquals(1, servAppoInsert.size());
        Test.stopTest();
    }
      @isTest
      static void checkInsertServiceAppointment1() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
       // List<User> usersList = [SELECT Id FROM User WHERE Profile.Name = 'XC_ESP_SalesAgentPartner' AND isActive = true];
       /*List<Account> acct = XC_DF_Account.createResidentialAccounts(2);
        acct[0].PrimaryEmail__c = 'test@te.it';
        acct[0].IdentityType__c = 'NIF';
        acct[0].IdentityNumber__c='50692632B';
        insert acct;  
        List<Contact> cont = XC_DF_Contact.createResidentialContacts(acct);
        cont[0].FirstName = 'Mario';
        cont[0].LastName='Rossi';
        cont[0].Email = 'test1@contact.it';        
        insert cont;
       
         User user = new User(); 
        user.Username = 'pablo123@gmail.com';  
        user.FirstName ='TestUser';
        user.LastName ='testUserProva';
        user.Email = 'pablo@test.com';
        user.Alias = 'TestTry'; 
        user.ProfileId = [SELECT Id, UserLicenseId FROM Profile WHERE Name = 'XC_ESP_SalesAgentPartner' LIMIT 1][0].Id;
        user.LocaleSidKey = 'it_IT';
        user.TimeZoneSidKey = 'GMT';
        user.LanguageLocaleKey = 'en_US';
        user.EmailEncodingKey = 'ISO-8859-1'; 
        user.IsActive = true;
        user.Country__c = 'SPAIN';
        user.CompanyP__c = 'SPAIN';
        user.ContactId = cont[0].Id;  
        insert user;  
        List<Account> accountList = XC_DF_Account.insertPartnerAccounts(1);
        List<ServiceResource> serviceResourcesToInsert = new List<ServiceResource>();
            ServiceResource serviceRes = new ServiceResource();
            serviceRes.Name = 'No Candidate Found';
            serviceRes.XC_Account__c = accountList[0].Id;
            serviceRes.IsActive = true;
            serviceRes.IsCapacityBased = true;
            serviceRes.XC_AutomaticDeactivation__c = true;
            serviceRes.RelatedRecordId = user.Id; // serviceRes.RelatedRecordId = accnt.Users[0].Id
            serviceResourcesToInsert.add(serviceRes);
        insert serviceResourcesToInsert;*/
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(10,Label.XC_CL_WorkType_Repair);
          for(WorkOrder currentWo : woList){
              currentWo.XC_Urgent_Repair__c= false;
          }
        insert woList;
        Test.startTest();
        insert XC_DF_ServiceAppointment.createServiceAppointment(woList);
        List<ServiceAppointment> servAppoInsert = [SELECT Id FROM ServiceAppointment];
        //system.assertEquals(10, servAppoInsert.size());
        Test.stopTest();
    }
    
    @isTest
      static void checkInsertServiceAppointment5() {
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1,Label.XC_CL_WorkType_Repair);
          for(WorkOrder currentWo : woList){
              currentWo.XC_Urgent_Repair__c= true;
          }
        insert woList;
        Test.startTest();
        insert XC_DF_ServiceAppointment.createServiceAppointment(woList);
        List<ServiceAppointment> servAppoInsert = [SELECT Id FROM ServiceAppointment];
        //system.assertEquals(1, servAppoInsert.size());
        Test.stopTest();
    }
    @isTest
     static void checkInsertServiceAppointment2() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(10,Label.XC_CL_WorkType_Delivery);
         for (WorkOrder wo : woList){
             wo.XC_DeliveryDate__c = Date.newInstance(2030, 12, 31);
         }
         
        insert woList;
        Test.startTest();
        List<ServiceAppointment> servAppList = XC_DF_ServiceAppointment.createServiceAppointment(woList);
          for (ServiceAppointment sa : servAppList){
             sa.XC_Country__c = 'SPAIN';
         }
         insert servAppList;
        List<ServiceAppointment> servAppoInsert = [SELECT Id FROM ServiceAppointment];
        //system.assertEquals(10, servAppoInsert.size());
        Test.stopTest();
    }
    @isTest
    static void checkInsertServiceAppointment3() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Lead> leadList = XC_DF_Lead.createResidentialLeads(1);
        insert leadList;
        
        WorkType workType = new WorkType();
        workType.Name = 'Delivery';
        workType.XC_WorkTypeCategory__c = 'Delivery';
        workType.DurationType = Label.XC_CL_WorkType_Hours;
        workType.XC_LegalEntity__c = 'EndesaX';
        workType.EstimatedDuration = 1;
        insert workType;
        
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, 'Delivery');
        woList[0].XC_DeliveryDate__c = Date.newInstance(2030, 12, 31);
        woList[0].XC_WorkTypeLabel__c = 'Delivery';
        woList[0].XC_AvailabilityDate__c = Date.newInstance(2020, 12, 30);
        woList[0].XC_LegalEntity__c = 'EndesaX';
        //woList[0].XC_Lead__c = leadList[0].Id;
        insert woList;
        
        WorkOrder wo = [SELECT Id, ContactId, AccountId, XC_WorkTypeLabel__c,  WorkTypeId FROM WorkOrder WHERE Id = : woList[0].Id LIMIT 1];
        
          
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
        
        woList[0].XC_WorkTypeLabel__c = 'Delivery';
        update woList;

        Test.startTest();
        List<ServiceAppointment> listSa = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        listSa[0].XC_Country__c = 'Spain';
        listSa[0].SchedStartTime = (Datetime) Date.today();
        listSa[0].SchedEndTime = (Datetime) Date.today();
        listSa[0].XC_WorkTypeLabel__c = 'Delivery';
        listSa[0].ParentRecordId = woList[0].Id;
        insert listSa;
        List<ServiceAppointment> servAppoInsert = [SELECT Id FROM ServiceAppointment];
        //system.assertEquals(1, servAppoInsert.size());
        Test.stopTest();
    }
    
    @isTest    
    static void checkInsertServiceAppointment4() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        WorkType workType = new WorkType();
        workType.Name = 'Delivery & Installation';
        workType.XC_WorkTypeCategory__c = 'Delivery & Installation';
        workType.DurationType = Label.XC_CL_WorkType_Hours;
        workType.EstimatedDuration = 1;
        insert workType;
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, 'Delivery & Installation');
        woList[0].XC_DeliveryDate__c = Date.newInstance(2030, 12, 31);
        woList[0].XC_AvailabilityDate__c = Date.newInstance(2030, 12, 31);
        woList[0].XC_WorkTypeLabel__c = 'Delivery & Installation';
        insert woList;
        Test.startTest();
        insert XC_DF_ServiceAppointment.createServiceAppointment(woList);
        List<ServiceAppointment> servAppoInsert = [SELECT Id FROM ServiceAppointment];
        //system.assertEquals(1, servAppoInsert.size());
        Test.stopTest();
    }
    
        
    @isTest    
    static void checkInsertServiceAppointment6() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_TR_ServiceAppointment_U_FillFieldByWO.PopulateFieldsWrapper wrapp = new XC_TR_ServiceAppointment_U_FillFieldByWO.PopulateFieldsWrapper();
        Map<String,Integer> mapCountryDays = new Map<String,Integer>(); 
        mapCountryDays.put('Spain', 2);
        wrapp.mapCountryDaysForRepairDueDate = mapCountryDays;
        WorkType workType = new WorkType();
        workType.Name = 'Planned Maintenance - Gas';
        workType.XC_WorkTypeCategory__c = 'Planned Maintenance';
        workType.DurationType = Label.XC_CL_WorkType_Hours;
        workType.XC_LegalEntity__c = 'EndesaX';
        workType.EstimatedDuration = 1;
        insert workType;
        List<NE__Order__c> listOfOrder = XC_DF_Order.createOrders(1, 'InOrder');
        listOfOrder[0].XC_LegalEntity__c = 'EndesaX';
        insert listOfOrder;
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        assetList[0].Status = 'Active';
        assetList[0].XC_LegalEntity__c = 'EndesaX';
        assetList[0].NE__Order_Config__c = listOfOrder[0].Id;
        //assetList[0].XC_Product_Subtype__c = 'Boiler';
        //assetList[0].NE__Catalog__c = catalog.Id;
        assetList[0].XC_ActivationDate__c = System.now();
        insert assetList;
        List<XC_Address__c> listOfAddress = XC_DF_Address.createAddress(1);
        insert listOfAddress;
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Planned Maintenance', 'Planned Maintenance');
        woList[0].XC_DeliveryDate__c = Date.newInstance(2030, 12, 31);
        woList[0].XC_AvailabilityDate__c = Date.newInstance(2030, 12, 31);
        woList[0].AssetId = assetList[0].Id;
        woList[0].XC_Address__c = listOfAddress[0].Id;
        woList[0].WorkTypeId = workType.Id;
        woList[0].Street = 'test';
        insert woList;
        Test.startTest();
        List<ServiceAppointment> listOfSa = XC_DF_ServiceAppointment.createServiceAppointment(woList);     
        listOfSa[0].PostalCode = '28080';
        listOfSa[0].XC_WorkTypeLabel__c = 'Planned Maintenance - Gas';
        listOfSa[0].XC_LegalEntity__c = 'EndesaX';
        insert listOfSa;
        List<ServiceAppointment> servAppoInsert = [SELECT Id FROM ServiceAppointment];
        XC_TR_ServiceAppointment_FillFieldByWO_U.forceDateTrigger = false;
        XC_TR_ServiceAppointment_FillFieldByWO_U.setDatesOnRepairWo(wrapp,  wolist[0], servAppoInsert[0]);
        //system.assertEquals(1, servAppoInsert.size());
        Test.stopTest();
    }

     //JJP 01-12-2021 - Start
    @isTest
    static void populateFieldsFromWorkOrderCH() {
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(10,Label.XC_CL_WorkType_Repair);
        insert woList;
        List<ServiceAppointment> listOfSa = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        insert listOfSa;
        Test.startTest();
        XC_TR_ServiceAppointment_U_FillFieldByWO.populateFieldsFromWorkOrderCH(listOfSa);
    }
 	//JJP 01-12-2021 - End
}