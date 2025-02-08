/**
*
* @author :              Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
* @date Creation :       16/01/2019
* @date Modification :   dd/mm/yyyy
* @description :         XC_TR_Conf_U_ManageContract_TEST – test class for XC_TR_Configuration_U_ManageContract
* 
*/

@isTest
public without sharing class XC_TR_Conf_U_ManageContract_TEST {

    @TestSetup
	static void setup(){ 

		OneOrg__c org            = new OneOrg__c(); 
	    org.Name                 = 'OneOrg (User)';
	    org.XC_Spain_Triggers__c = true;
	    insert org;

        List<NE__Product__c> prodList = XC_DF_Product.createProducts(1);
        insert prodList;
        List<NE__Order__c>  orders = XC_DF_Order.createOrders(1, 'InOrder');
        insert orders;
        NE__OrderItem__c ordItem = XC_DF_OrderItem.createOrderItem(orders[0]);
        ordItem.NE__ProdId__c = prodList[0].Id;
        insert ordItem;
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        Contract contractToInsert = new Contract( AccountId = accList[0].Id, StartDate = System.today().addDays(-1), ContractTerm = 12, CurrencyIsoCode = 'EUR' , XC_LegalEntity__c = 'EndesaX'/*, Opportunity__c = accList[0].Opportunities[0].Id*/); 
        insert contractToInsert;
        List<Asset> assetList = XC_DF_Asset.createAssetsFromContract( New List<Contract>{contractToInsert});
        assetList[0].NE__Order_Config__c = orders[0].Id;
        insert assetList;
    }

    @isTest
    private static void manageContractTEST() {

        NE__Order__c ordToUpdate = [SELECT Id, (SELECT Id FROM NE__Order_Items__r) FROM NE__Order__c LIMIT 1];
        ordToUpdate.XC_Status__c = Label.XC_CL_Configuration_OrderInProvisioning;
        ordToUpdate.NE__OrderStatus__c = Label.XC_CL_Order_StatusSent;
        ordToUpdate.NE__Type__c = Label.XC_CL_Configuration_TypeChangeOrder;
        ordToUpdate.XC_Subtype__c = 'Substitution (Change of equipment)';

        NE__OrderItem__c ordItemToUpdate = ordToUpdate.NE__Order_Items__r[0];
        ordItemToUpdate.NE__Action__c = 'Remove';
        update ordItemToUpdate; 

        NE__Product__c prod =  [SELECT id, name from NE__Product__c];
        NE__OrderItem__c ordItem = XC_DF_OrderItem.createOrderItem(ordToUpdate);
        ordItem.NE__Action__c = 'Add';
        ordItem.NE__ProdId__c = prod.Id;
        insert ordItem;


        test.startTest();
        update ordToUpdate; 
        test.stopTest();

        Contract contr = [SELECT Id, XC_VersionNumber__c FROM Contract];
    
        System.assertEquals(contr.XC_VersionNumber__c, 2, 'Wrong assert result');
    }

}