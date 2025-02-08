/**
 * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @date 17/03/2020
 * @description XC_SC027_CreateCaseBarCode_TEST - Test class for batch XC_SC027_CreateCaseBarCode
 */

@isTest
private class XC_SC027_CreateCaseBarCode_TEST {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC027_CreateCaseBarCode_TEST');

    @isTest
    private static void onExecute() {
        insert new OneOrg__c(Name = 'OneOrg (User)', XC_Spain_Triggers__c = true);
        List<ServiceAppointment> listSa = XC_DF_ServiceAppointment.createServiceAppointment(1, Label.XC_CL_WorkType_DeliveryInstallation);
        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(1);
        insert listOrderItem;
        listSa[0].XC_Configuration_Item__c = listOrderItem[0].Id;
        listSa[0].XC_Payment_Type__c = Label.XC_CL_Barcode;
        insert listSa;
        listSa[0].Status = Label.XC_CL_ServiceAppointment_Scheduled;
        listSa[0].SchedStartTime = Datetime.now();
        listSa[0].SchedEndTime = Datetime.now().addDays(10);
        update listSa;
        XC_Provisioning_Step__c ps = new XC_Provisioning_Step__c();
        ps.XC_Configuration_Item__c = listOrderItem[0].Id;
        ps.XC_Flow_API_Name__c = Label.XC_CL_ProvisioningPaymentCheck_Flow;
        ps.XC_Status__c = Label.XC_CL_Provisioning_Step_InProgress;
        insert ps;
        List<ServiceAppointment> listSaCheck = new List<ServiceAppointment>([
            SELECT Id, XC_Configuration_Item__c, ParentRecordId 
            FROM ServiceAppointment 
            WHERE Status = 'Scheduled' AND 
                (SchedStartTime = NEXT_N_DAYS:2 or SchedStartTime = TODAY) AND 
                XC_Payment_Type__c = :Label.XC_CL_Barcode AND XC_WorkTypeCategory__c = :Label.XC_CL_WorkType_DeliveryInstallation
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ List ServiceAppointment to test -> ' + listSaCheck);
        System.assert(!listSaCheck.isEmpty());

        Test.startTest();
        Database.executeBatch(new XC_SC027_CreateCaseBarCode());
        Test.stopTest();
    }

}