/**
* @author Andrea Bravaccino - andrea.bravaccino@nttdata.com
* @date Creation  24/06/2019 
* @description XC_TR_ContrLineItem_Hand_TEST – Test class for XC_TR_ContractLineItem_Handler
*/ 
@isTest
public class XC_TR_ContrLineItem_Hand_TEST {
    static testMethod void test1(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();     
        
        
        List<Contract> lstc = XC_DF_Contract.createContracts(1);
        contract c = lstc[0];
        insert c;        
        XC_ContractLineItem__c cli = new XC_ContractLineItem__c();
		cli.XC_Contract__c= c.Id;
        insert cli;
        update cli;
        delete cli;
        System.assert(lstc != null);
        Test.stopTest();
        
    }
}