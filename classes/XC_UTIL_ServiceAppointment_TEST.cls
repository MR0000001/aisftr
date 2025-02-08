/**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 21/05/2019
* @description XC_UTIL_ServiceAppointment_TEST –Test Class 
*/

@isTest
private class XC_UTIL_ServiceAppointment_TEST {
    
    static testMethod void createServiceAppointmentsFromWorkOrders() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        List<XC_Address__c> addressList =  XC_DF_Address.createAddress(1);
        insert addressList;
        
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1,  Label.XC_CL_WorkType_DeliveryInstallation);
        for(WorkOrder wo : woList){ 
            wo.Street ='test';
            wo.XC_Address__c = addressList[0].id;
        }
        insert woList;
        XC_UTIL_ServiceAppointment.createServiceAppointmentsFromWorkOrders(woList);
        System.assertEquals(1, woList.size());
        Test.stopTest();
    }
    static testMethod void createServiceAppointmentsFromWorkOrders1() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        List<XC_Address__c> addressList =  XC_DF_Address.createAddress(1);
        addressList.get(0).XC_StreetTypeText__c = '';
        insert addressList;
        
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1,  Label.XC_CL_WorkType_DeliveryInstallation);
        for(WorkOrder wo : woList){ 
            wo.Street ='test';
            wo.XC_Address__c = addressList[0].id;
        }
        insert woList;
        List<ServiceAppointment>  servApp = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        servApp[0].SchedStartTime = (System.now()).addHours(2);
        servApp[0].SchedEndTime = (System.now()).addHours(4);
        insert servApp;
        XC_UTIL_ServiceAppointment.checkRangeTimeOnServiceAppointment(servApp);
        System.assertEquals(1, woList.size());
        Test.stopTest();
    }
    
      static testMethod void createServiceAppointmentsFromWorkOrders2() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        List<XC_Address__c> addressList =  XC_DF_Address.createAddress(1);
        insert addressList;
        
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1,  Label.XC_CL_WorkType_DeliveryInstallation);
        for(WorkOrder wo : woList){ 
            wo.Street ='test';
            wo.XC_Address__c = addressList[0].id;
        }
        insert woList;
        List<ServiceAppointment>  servApp = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        servApp[0].SchedStartTime = (System.now()).addHours(2);
        servApp[0].SchedEndTime = (System.now()).addHours(4);
        insert servApp;
        XC_UTIL_ServiceAppointment.retriveWOAccountContactInfo(servApp);
        System.assertEquals(1, woList.size());
        Test.stopTest();
    }
     static testMethod void createServiceAppointmentsFromWorkOrders3() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        List<XC_Address__c> addressList =  XC_DF_Address.createAddress(1);
        insert addressList;
          NE__Catalog__c catalog = new NE__Catalog__c();
        insert catalog;
         NE__Catalog_Category__c catalogCat = new NE__Catalog_Category__c();
        catalogCat.Name = 'Boiler';
        catalogCat.NE__CatalogId__c = catalog.Id;
        insert catalogCat;
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1,  Label.XC_CL_WorkType_DeliveryInstallation);
        for(WorkOrder wo : woList){ 
            wo.Street ='test';
            wo.XC_Address__c = addressList[0].id;
            wo.XC_CatalogCategory__c = catalogCat.id;
        }
         insert woList;
        XC_UTIL_ServiceAppointment.getManteinanceDatesForProduct(woList);
        System.assertEquals(1, woList.size());
        Test.stopTest();
    }
    
    static testmethod void getActiveSAFromWo(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        List<XC_Address__c> addressList =  XC_DF_Address.createAddress(1);
        insert addressList;
          NE__Catalog__c catalog = new NE__Catalog__c();
        insert catalog;
         NE__Catalog_Category__c catalogCat = new NE__Catalog_Category__c();
        catalogCat.Name = 'Boiler';
        catalogCat.NE__CatalogId__c = catalog.Id;
        insert catalogCat;
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1,  Label.XC_CL_WorkType_DeliveryInstallation);
        for(WorkOrder wo : woList){ 
            wo.Street ='test';
            wo.XC_Address__c = addressList[0].id;
            wo.XC_CatalogCategory__c = catalogCat.id;
        }
        insert woList;
        
         List<ServiceAppointment> sa = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        insert sa;
        XC_UTIL_ServiceAppointment.getActiveSAFromWo(String.ValueOf(woList.get(0).id));
        Test.stopTest();
    }
    
    static testmethod void getDataActiveSAFromWo(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        List<XC_Address__c> addressList =  XC_DF_Address.createAddress(1);
        insert addressList;
          NE__Catalog__c catalog = new NE__Catalog__c();
        insert catalog;
         NE__Catalog_Category__c catalogCat = new NE__Catalog_Category__c();
        catalogCat.Name = 'Boiler';
        catalogCat.NE__CatalogId__c = catalog.Id;
        insert catalogCat;
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1,  Label.XC_CL_WorkType_DeliveryInstallation);
        for(WorkOrder wo : woList){ 
            wo.Street ='test';
            wo.XC_Address__c = addressList[0].id;
            wo.XC_CatalogCategory__c = catalogCat.id;
        }
        insert woList;
        Set<Id> setId = new Set<Id>();
        List<ServiceAppointment> sa = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        insert sa;
        setId.add(woList.get(0).id);
        XC_UTIL_ServiceAppointment.getDataActiveSAFromWo(setId);
        Test.stopTest();
    }
}