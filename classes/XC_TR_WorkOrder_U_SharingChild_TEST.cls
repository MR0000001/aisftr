/**
 * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
 * @date 31/03/2020
 * @description XC_TR_WorkOrder_U_SharingChild_TEST - Test Class for XC_TR_WorkOrder_U_SharingChild
 */

@isTest
private class XC_TR_WorkOrder_U_SharingChild_TEST {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_WorkOrder_U_SharingChild_TEST');

    @isTest
    static void onShare() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Account> partners = XC_DF_Account.insertPartnerAccounts(2);
        List<ServiceTerritory> st = XC_DF_ServiceTerritory.createServiceTerritories(partners);
        insert st;
        List<WorkOrder> listWo = XC_DF_WorkOrder.createWorkOrders(2, Label.XC_CL_WorkType_Diagnostic);
        insert listWo;
        
        
        listWo[0].ServiceTerritoryId = st[0].Id; 
        listWo[1].ParentWorkOrderId = listWo[0].Id;
        listWo[1].ServiceTerritoryId = st[1].Id;

        Test.startTest(); 
        update listWo;
        System.assertNotEquals(listWo[1], null);
        Test.stopTest();
    }

}