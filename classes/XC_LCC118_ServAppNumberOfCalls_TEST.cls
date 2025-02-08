/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 15/05/2019
* @date Modification 
* @description XC_LCC118_ServAppNumberOfCalls_TEST test class for XC_LCC118_ServAppNumberOfCalls
*/  
@isTest
public class XC_LCC118_ServAppNumberOfCalls_TEST {

    static testMethod void increaseNumberOfCallsTest(){
        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(1);
        insert saList;
        Test.startTest();
        XC_UTIL_ResultWrapper rw = XC_LCC118_ServAppNumberOfCalls.increaseNumberOfCalls(salist[0].Id);
        System.assertEquals(rw.success , true);
        Test.stopTest();
    }
    static testMethod void increaseNumberOfCallsTest2(){
        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(1);
        saList[0].XC_NumberOfCalls__c = null;
        insert saList;
        Test.startTest();
        XC_UTIL_ResultWrapper rw = XC_LCC118_ServAppNumberOfCalls.increaseNumberOfCalls(salist[0].Id);
        System.assertEquals(rw.success , false);
        Test.stopTest();
    }
}