/**
* @author Giuseppe Di Bonito gdibonito@deloitte.it
* @date Creation  20/09/2019 
* @description XC_REST_UrgentWONotification_TEST – Test class for XC_REST_UrgentWONotification
*/ 
@isTest
public class XC_REST_UrgentWONotification_TEST {
    
	//Test Method calloutTest
    static testMethod void calloutTest(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.setMock(HttpCalloutMock.class, new XC_REST_UrgentWONotification_Mock());
        Test.startTest();
        XC_REST_UrgentWONotification.WrapperRequest wrr = new XC_REST_UrgentWONotification.WrapperRequest();
        XC_REST_UrgentWONotification.WrapperResult wr = XC_REST_UrgentWONotification.callout(wrr);
        
    	System.assert(wr !=null );
    	Test.stopTest();
        
    }
}