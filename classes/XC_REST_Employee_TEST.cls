/**
* @author Chiara Turco cturco@deloitte.it
* @date Creation  28/05/2019 
* @description XC_REST_Employee_TEST – Test class for XC_REST_Employee
*/
@isTest
public class XC_REST_Employee_TEST {
    //Test Method callToGetEmployee
    static testMethod void callToGetEmployee(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_Employee;
        ic.XC_interfaceName__c = Label.XC_CL_Employee;
        insert ic;
        
        XC_REST_Employee.WrapperResponse rw;
        try{
           rw = XC_REST_Employee.callToGetEmployee('TEST');
            
        }catch(exception e){
            System.assert(e!=null);
        }
        
        
        System.assertEquals(false, rw!=null);
        Test.stopTest();
    }
    
    //Test Method callToGetEmployee1
    static testMethod void callToGetEmployee1(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = false;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_Employee;
        ic.XC_interfaceName__c = Label.XC_CL_Employee;
        insert ic;
        
        XC_REST_Employee.WrapperResponse rw = XC_REST_Employee.callToGetEmployee('TEST');
        System.assertEquals(true, rw!=null);
        Test.stopTest();
    }

}