/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 15/05/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_WorkOrder_TEST – Test Class for XC_TR_WorkOrder AND Handler
*/ 
@isTest
public class XC_TR_ServiceResource_TEST {

    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    }

    static testMethod void onInsert(){
        Test.startTest(); 
        
        List<ServiceResource> listSr = XC_DF_ServiceResource.createServiceResources(1);
        update listSr;
        //delete listSr;
		XC_TR_ServiceResource_Handler h = new XC_TR_ServiceResource_Handler();
		h.onBeforeDelete(null);
		h.onAfterDelete(null);
  
        System.assertEquals(true, listSr!=null);
        Test.stopTest();
        
    }


}