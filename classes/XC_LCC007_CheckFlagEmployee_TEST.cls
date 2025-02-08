/**
* @author Chiara Turco cturco@deloitte.it
* @date Creation  23/05/2019 
* @description XC_LCC007_CheckFlagEmployee_TEST – Test class for XC_LCC007_CheckFlagEmployee
*/
@isTest
public class XC_LCC007_CheckFlagEmployee_TEST {
    //Test Method retrieveAccount
    static testMethod void retrieveAccount(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        List<Account> lista = XC_DF_Account.createResidentialAccounts(1);
        insert lista;
        
        Account acc = XC_LCC007_CheckFlagEmployee.retrieveAccount(lista[0].Id);
        System.assertEquals(true, acc!=null);
        Test.stopTest();
    }
    
    //Test Method updateAccount
    static testMethod void updateAccount(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        List<Account> lista = XC_DF_Account.createResidentialAccounts(1);
        insert lista;
        
       XC_LCC007_CheckFlagEmployee.updateAccount(lista[0]);
        System.assertEquals(true, lista[0]!=null);
        Test.stopTest();
    }
    
    //Test Method callExternalSystem
    static testMethod void callExternalSystem(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        List<Account> lista = XC_DF_Account.createResidentialAccounts(1);
        insert lista;
        
       XC_UTIL_ResultWrapper rw = XC_LCC007_CheckFlagEmployee.callExternalSystem(lista[0].Id);
        System.assertEquals(true, rw!=null);
        Test.stopTest();
    }
    
    //Test Method callExternalSystem1
    static testMethod void callExternalSystem1(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        List<Account> lista = XC_DF_Account.createResidentialAccounts(1);
        insert lista;
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.Name = 'CheckFlagEmployee';
        ic.XC_interfaceName__c = 'CheckFlagEmployee';
        insert ic;
        
       XC_UTIL_ResultWrapper rw = XC_LCC007_CheckFlagEmployee.callExternalSystem(lista[0].Id);
        System.assertEquals(true, rw!=null);
        Test.stopTest();
    }
    
    // Test Method callExternalSystem2
    static testMethod void callExternalSystem2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        List<Account> lista = XC_DF_Account.createResidentialAccounts(1);
        lista[0].XC_isEmployee__c =true;
        insert lista;

       XC_UTIL_ResultWrapper rw = XC_LCC007_CheckFlagEmployee.callExternalSystem(lista[0].Id);
        
        XC_LCC007_CheckFlagEmployee.resultWrapper resw = new XC_LCC007_CheckFlagEmployee.resultWrapper();
        resw.errorCode='test';
        resw.message='test1';
        
        XC_LCC007_CheckFlagEmployee.employeeWrapper emw = new XC_LCC007_CheckFlagEmployee.employeeWrapper();
        emw.personID=1;
        emw.personNumber=2;
        emw.firstName='test1';
        emw.lastName='test2';
            
        System.assertEquals(true, rw!=null);
        Test.stopTest();
    }

}