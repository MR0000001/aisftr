/**
* @author Chiara Turco cturco@deloitte.it
* @date Creation  03/06/2019 
* @description XC_REST_AddressByPOD_TEST – Test class for XC_REST_AddressByPOD
*/
@isTest
public class XC_REST_AddressByPOD_TEST {
    
    //Test Method callToAddressByPOD
    static testMethod void callToAddressByPODactive(){
        insert XC_DF_OneOrg.createOneOrg('Spain');

        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test1';
        ic.Name = Label.XC_CL_AddressByPOD;
        ic.XC_interfaceName__c = Label.XC_CL_AddressByPOD;
        insert ic;
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_AddressByPOD_Mock());
        
        Test.startTest();
        
        XC_REST_AddressByPOD.ResultWrapper rw = XC_REST_AddressByPOD.callToAddressByPOD('cup');
        
        
        System.assert(rw!=null);
        Test.stopTest();
        
    }
    
    //Test Method callToAddressByPOD
    static testMethod void callToAddressByPODactive1(){
        insert XC_DF_OneOrg.createOneOrg('Spain');

        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test2';
        ic.Name = Label.XC_CL_AddressByPOD;
        ic.XC_interfaceName__c = Label.XC_CL_AddressByPOD;
        insert ic;
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_AddressByPOD_Mock());
        
        Test.startTest();
        
        XC_REST_AddressByPOD.ResultWrapper rw = XC_REST_AddressByPOD.callToAddressByPOD('cup');
 
        System.assert(rw!=null);
        Test.stopTest();
        
    }
    
      //Test Method callToAddressByPOD
    static testMethod void callToAddressByPODInactive(){
        insert XC_DF_OneOrg.createOneOrg('Spain');

        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = false;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_AddressByPOD;
        ic.XC_interfaceName__c = Label.XC_CL_AddressByPOD;
        insert ic;
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_AddressByPOD_Mock());
        
        Test.startTest(); 
        XC_REST_AddressByPOD.ResultWrapper rw = XC_REST_AddressByPOD.callToAddressByPOD('test');
        
        System.assert(rw!=null);
        Test.stopTest();
        
    }
    
    //Test Method callToAddressByPOD
    static testMethod void callToAddressByPODactiveNull(){
        insert XC_DF_OneOrg.createOneOrg('Spain');

        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_AddressByPOD;
        ic.XC_interfaceName__c = Label.XC_CL_AddressByPOD;
        insert ic;
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_AddressByPOD_Mock());
        
        Test.startTest();
        XC_REST_AddressByPOD.ResultWrapper rw = XC_REST_AddressByPOD.callToAddressByPOD('');
        
        System.assert(rw!=null);
        Test.stopTest();
        
    }
    
    
    
    //Test Method zzzzzzzzzzzzzzzzzzz
    static testMethod void zzzzzzzzzzzzzzzzzzzzzz(){
    insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
		ic.XC_activeInterface__c = true;
		ic.Name = 'test';
        ic.XC_URL_Required__c  = '';
		ic.XC_interfaceName__c = Label.XC_CL_AddressByPOD; 
        insert ic;
        
        Test.startTest();
        String podValue='ES0021000003149909NX';
        XC_REST_AddressByPOD.ResultWrapper rw = XC_REST_AddressByPOD.callToAddressByPOD(podValue);
       // System.assert(String.isNotBlank(result));
  
        Test.stopTest();
    }

}