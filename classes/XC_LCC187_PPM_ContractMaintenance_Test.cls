/*
* @author Nicola Arrigo -
* @date Creation 29/06/2020
* @date Modification 
* @description XC_LCC187_PPM_ContractMaintenance_Test 
*/
@isTest
public with sharing class XC_LCC187_PPM_ContractMaintenance_Test {
    @TestSetup 
    static void setup(){
    List<NE__Order__c> listOrders = XC_DF_Order.createOrders(1,'InOrder');
    listOrders[0].XC_Country__c = 'Colombia';
    insert listOrders;
    XC_UTIL_Contract.ContractIFWrapper cW = new XC_UTIL_Contract.ContractIFWrapper();
    XC_UTIL_Contract.createContracts(listOrders);
    }
    @isTest
		static void CreateProjectTest(){
            Contract c=[select id,Account.XC_Country__c,XC_Project__c,ContractNumber  from contract limit 1];
            Test.startTest();
            string st=XC_LCC187_PPM_ContractMaintenanceService.createProject(c.id);  
            system.assertEquals(st,'Project is created');
	  	    Test.stopTest();
        }
}