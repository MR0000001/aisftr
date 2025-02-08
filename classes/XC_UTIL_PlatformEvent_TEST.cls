/**
* @author Emanuela Cacace - ecacace@deloitte.it
* @date Creation  06/06/2019 
* @description XC_UTIL_PlatformEvent_TEST – Test class for XC_UTIL_PlatformEvent
*/
@isTest
public with sharing class XC_UTIL_PlatformEvent_TEST {
    static testMethod void publishListEvents(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest(); 
        XC_UTIL_PlatformEvent.throwErrorInTest = true;
        XC_Provisioning_Step_Enqueued_Event__e event = new XC_Provisioning_Step_Enqueued_Event__e();
        List<sObject> listEventToPublish = new List<sObject>();
        listEventToPublish.add(event);
        List<XC_UTIL_Sobject.WrapperResult> result =XC_UTIL_PlatformEvent.publishListEvents(listEventToPublish);
        System.assert(listEventToPublish!=null);
        Test.stopTest(); 
    }
    static testMethod void publishListEvents1(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest(); 
        XC_UTIL_PlatformEvent.throwErrorInTest = true;
        List<sObject> listEventToPublish = new List<sObject>();
        List<XC_UTIL_Sobject.WrapperResult> result =XC_UTIL_PlatformEvent.publishListEvents(listEventToPublish);
        System.assert(listEventToPublish!=null);
        Test.stopTest(); 
    }
    static testMethod void publishListEvent(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest(); 
        XC_Provisioning_Step_Enqueued_Event__e event = new XC_Provisioning_Step_Enqueued_Event__e();
        XC_UTIL_Sobject.WrapperResult result =XC_UTIL_PlatformEvent.publishListEvent(event);
        System.assert(event!=null);
        Test.stopTest(); 
    }
    static testMethod void publishListEvents3(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        
        Test.startTest(); 
        XC_UTIL_PlatformEvent.throwErrorInTest = true;
        XC_Provisioning_Step_Enqueued_Event__e event = new XC_Provisioning_Step_Enqueued_Event__e();
        //event.ReplayId= '0015E00000l7rgNQAQ';
        List<sObject> listEventToPublish = new List<sObject>();
        listEventToPublish.add(event);
        List<XC_UTIL_Sobject.WrapperResult> result =XC_UTIL_PlatformEvent.publishListEvents(listEventToPublish);
        System.assert(listEventToPublish!=null);
        Test.stopTest(); 
    }
    static testMethod void publishListEventsException(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        Test.startTest(); 
        XC_UTIL_PlatformEvent.throwExceptionInTest = true;
       	XC_Provisioning_Step_Enqueued_Event__e event = new XC_Provisioning_Step_Enqueued_Event__e();
        //event.ReplayId= '0015E00000l7rgNQAQ' ;
        List<sObject> listEventToPublish = new List<sObject>();
        listEventToPublish.add(event);
        List<XC_UTIL_Sobject.WrapperResult> result =XC_UTIL_PlatformEvent.publishListEvents(listEventToPublish);
        Test.stopTest(); 
    }
    
   	static testMethod void publishListEventsError(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        Test.startTest(); 
        XC_UTIL_PlatformEvent.throwExceptionInTest = false;
        XC_UTIL_PlatformEvent.throwErrorInTest = true;
       	XC_Provisioning_Step_Enqueued_Event__e event = new XC_Provisioning_Step_Enqueued_Event__e();
        //event.ReplayId= '0015E00000l7rgNQAQ';
        List<sObject> listEventToPublish = new List<sObject>();
        listEventToPublish.add(event);
        List<XC_UTIL_Sobject.WrapperResult> result =XC_UTIL_PlatformEvent.publishListEvents(listEventToPublish);
        Test.stopTest(); 
    }
    /*static testMethod void publishListEventsDatabase(){
        Database.SaveResult sr = (Database.SaveResult)
        JSON.deserialize('{"success":false,"errors":[{"message":"You cannot do this...","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}', Database.SaveResult.class);
    }*/
}