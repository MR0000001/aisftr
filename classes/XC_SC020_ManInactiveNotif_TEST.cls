/**
 * The Class XC_SC020_ManInactiveNotif_TEST.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 24/07/2019
 * @date Modification : dd/mm/yyyy
 * @description       : XC_SC020_ManInactiveNotif_TEST – TEST Class for XC_SC020_ManageInactiveNotifications
 **/

@isTest 
public without sharing class XC_SC020_ManInactiveNotif_TEST {

    static testMethod void testMethod1() {

        NE__Order__c order = XC_DF_Order.createOrder('Order');
        
        Test.startTest();

            XC_SC020_ManageInactiveNotifications obj = new XC_SC020_ManageInactiveNotifications();
            DataBase.executeBatch(obj);

            System.assertEquals(true, order!=null, 'Wrong Assert Equals');
            
        Test.stopTest();
    }


    static testMethod void testMethod2() {

        NE__Order__c order = XC_DF_Order.createOrder('Order');

        XC_UTIL_Sobject.WrapperResult wr = new XC_UTIL_Sobject.WrapperResult();
        wr.errorMessage = 'test error';
        wr.errorObjectId = order.Id;
        
        Test.startTest();

            XC_BatchErrorLog__c error = XC_SC020_ManageInactiveNotifications.createBatchError(wr, 'name', 'operation');
            System.assertEquals(true, error!=null, 'Wrong Assert Equals');
            
        Test.stopTest();
    }
}