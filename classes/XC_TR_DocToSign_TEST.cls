/**
* @author Giuseppe Di Bonito - gdibonito@deloitte.it
* @date Creation  06/02/2020 
* @description XC_TR_DocToSign_TEST – Test class for XC_TR_DocumentToSign_U_Notifications
*/ 
@isTest
public class XC_TR_DocToSign_TEST {
        
    @isTest 
    static void dtsTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
		XC_Document_to_sign__c dts = new XC_Document_to_sign__c();
        dts.XC_Signed__c = false;
        NE__Order__c o = XC_DF_Order.createOrder('Opty');
        dts.XC_ConfigurationID__c = o.id;
		insert dts;
        dts.XC_Signed__c = true;
        update dts;
		System.assertEquals(true, dts.XC_Signed__c);        
        delete dts;
        
    }
}