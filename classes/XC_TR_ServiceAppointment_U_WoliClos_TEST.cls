/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 08/04/2020
* @description XC_TR_ServiceAppointment_U_WoliClos_TEST –Test Class for XC_TR_ServiceAppointment_U_WoliClosure
*/

@isTest
public class XC_TR_ServiceAppointment_U_WoliClos_TEST {
    @TestSetup
    static void testSetupM() {
        List<NE__OrderItem__c> oiList = XC_DF_OrderItem.createOrderItems(1);
        oiList[0].XC_Product_Subtype__c = Label.XC_CL_ProductSubtypeIncentive;
        insert oiList;
    }
    
	static testMethod void manageChangeStatus() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        insert XC_DF_ServiceAppointment.createServiceAppointment(1);        
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        List<ServiceResource> servRes = XC_DF_ServiceResource.createServiceResources(1);
        List<ServiceAppointment> servAppoInsert = [SELECT Id, ParentRecordId FROM ServiceAppointment];
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(10, Label.XC_CL_WorkType_DeliveryInstallation);
        woList[0].ParentWorkOrderId =servAppoInsert[0].ParentRecordId;
        woList[0].XC_ProductSubType__c ='Wallbox';
        woLisT[0].XC_ConfigurationItemIncentive__c = [SELECT ID FROM NE__OrderItem__c WHERE XC_Product_Subtype__c =: Label.XC_CL_ProductSubtypeIncentive LIMIT 1].Id;
        insert woList;
        
        
        for(ServiceAppointment sa : servAppoInsert){
            sa.Status = 'Scheduled';
            sa.SchedStartTime=  (System.now()).addHours(2);
            sa.SchedEndTime = (System.now()).addHours(4);
            sa.ArrivalWindowEndTime =(System.now()).addHours(8);
            sa.ArrivalWindowStartTime = (System.now()).addHours(4);
            sa.XC_LegalEntity__c = 'EnelXItalia';
            sa.XC_WorkTypeCategory__c ='Delivery & Installation';
        }
        //update servAppoInsert;
         
        for(ServiceAppointment sa : servAppoInsert){
            sa.Status = 'Completed';
        }
        
        Test.startTest();
        try{
            XC_TR_ServiceAppointment_U_WoliClosure.checkOnWOLIClosure(servAppoInsert);
        }catch(Exception e){
            System.debug('In Catch');
        }
		
        Test.stopTest();
    }
}