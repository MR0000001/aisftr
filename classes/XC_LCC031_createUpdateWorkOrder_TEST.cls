/**
* @author Luca Tedeschi ltedeschi@deloitte.it
* @date Creation  21/05/2019 
* @description XC_LCC031_createUpdateWorkOrder_TEST – Test class for XC_LCC031_createUpdateWorkOrder_TEST
*/
@istest
public class XC_LCC031_createUpdateWorkOrder_TEST {
    
    //Test Method executeAuthenticationCall
    static testMethod void executeAuthenticationCall(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        XC_LCC031_createUpdateWorkOrder.ResultWrapper rw = new XC_LCC031_createUpdateWorkOrder.ResultWrapper();
        rw.transactionID= 'test';
        rw.systemX='test';
        rw.result='test';
        rw.workOrderID='test';
        rw.note= 'test';
        rw = XC_LCC031_createUpdateWorkOrder.executeAuthenticationCall(new XC_LCC031_createUpdateWorkOrder.FieldWrapper());
        
        System.assertEquals(true, rw!=null);
        Test.stopTest();
        
    }

}