/**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @date Creation 15/05/2019
* @date Modification 15/05/2019 Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @description XC_LCC113_CaseOnNbaNbo_TEST test class for XC_LCC113_CaseOnNbaNbo 
*/  
@isTest
public class XC_LCC113_CaseOnNbaNbo_TEST {

 /**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @description  Method to test createCase method
*/
static testMethod void createCaseSTest(){

    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1); 
        insert accList;
    	
        XC_NbaNbo__c nbo = new XC_NbaNbo__c(XC_AccountId__c=accList[0].id, XC_Used__c=false);
        insert nbo;
        XC_UTIL_ResultWrapper rw = XC_LCC113_CaseOnNbaNbo.createCase(nbo.id);
        System.assert(rw.success);
    Test.stopTest();
    
   
    }
/**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @description  Method to test createCase method
*/
static testMethod void createCaseFTest(){

    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
    	
        XC_NbaNbo__c nbo = new XC_NbaNbo__c(XC_AccountId__c=accList[0].id, XC_Used__c=true);
        insert nbo;
        XC_UTIL_ResultWrapper rw = XC_LCC113_CaseOnNbaNbo.createCase(nbo.id);
        System.assert(!rw.success);
    Test.stopTest();
    
   
    }
    
    
}