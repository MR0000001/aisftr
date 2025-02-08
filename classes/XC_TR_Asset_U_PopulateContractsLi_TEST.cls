/**
* The Class XC_TR_Asset_U_PopulateContractsLi_TEST.
*
* @author            : Giuseppe Di Bonito - gdibonito@deloitte.it
* @date Creation     : 18/03/2020
* @date Modification : dd/mm/yyyy
* @description       : Test Class for XC_TR_Asset_U_PopulateContractsLineItem
**/


@isTest
public without sharing class XC_TR_Asset_U_PopulateContractsLi_TEST {
    
    @TestSetup
    static void setup(){ 
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;

        List<NE__Bundle__c> listBundle = XC_DF_Bundle.createBundleRecords(1);
        insert listBundle;

        List<NE__Product__c> listProducts = XC_DF_Product.createProducts(1);
        listProducts[0].XC_Product_SubType__c = 'Bundle';
        listProducts[0].XC_Product_Type__c = 'Bundle';
        insert listProducts;
        
        List<Account> listAccount = XC_DF_Account.createResidentialAccounts(2);
        insert listAccount;

        Test.startTest();

        
        List<XC_Address__c> addressList = XC_DF_Address.createAddress(listAccount);
        insert addressList;

        NE__Order__c order =  new NE__Order__c();
        List<Opportunity> o = XC_DF_Opportunity.createOpportunity(1, false);
        insert o;

        order.NE__Type__c = 'InOrder';
        order.NE__OptyId__c = o[0].Id;
        order.XC_DeliveryAddress__c = o[0].XC_Address__c;
        //order.XC_InstallationAddress__c = o[0].XC_Address__c;
       // order.XC_Subtype__c = 'End of supply';
        order.NE__AccountId__c = o[0].AccountId;
        order.XC_Country__c = 'Italy';
        order.XC_Segment__c = 'B2B';
        insert order;
         NE__Order__c order2 =  new NE__Order__c();
        List<Opportunity> o2 = XC_DF_Opportunity.createOpportunity(1, false);
        insert o2;
        order2.NE__Type__c = 'InOrder';
        order2.NE__OptyId__c = o2[0].Id;
        order2.XC_DeliveryAddress__c = o2[0].XC_Address__c;
        order2.NE__AccountId__c = o2[0].AccountId;
        order2.XC_Country__c = 'Italy';
        order2.XC_Segment__c = 'B2B';
        insert order2;
       /* NE__Order__c order2 = XC_DF_Order.createOrder('InOrder');      //  NE__Order__c order2 = XC_DF_Order.createOrder('ChangeOrder');*/
        List<Contract> listContract = XC_DF_Contract.createCondominiumContract(listAccount);
        listContract[0].XC_Configurations__c = order.Id;
        listContract[1].XC_Configurations__c = order2.Id;
        insert listContract;

        Test.stopTest();
        List<Asset> listAsset = XC_DF_Asset.createAssetWithBundleRecords(listProducts, listBundle[0], addressList[0]);
        listAsset[0].XC_Contract__c = listContract[0].Id;
        listAsset[0].NE__Order_Config__c = order.Id;
        insert listAsset;

        List<Asset> assList = XC_DF_Asset.createAssets(3);
        assList[0].XC_PaymentMethod__c = 'Bank Transfer';
        assList[0].XC_Contract__c = listContract[1].Id;
        assList[0].NE__Order_Config__c = order2.Id;

        insert assList;


    }

    @isTest
    static void populateCLItest(){
        test.startTest();
        List<Asset> assList = new List<Asset>([SELECT id, NE__Order_Config__c, NE__Bundle_element__c, NE__Root_Order_Item__c,NE__Parent_Order_Item__c, XC_PaymentMethod__c FROM Asset where XC_PaymentMethod__c!= null limit 1]);
        XC_TR_Asset_U_PopulateContractsLineItem.manageAssetCreation(asslist);
        Test.stopTest(); 
        //System.assertequals(assList.size(), 3);
    }

    @isTest
    static void populateContractEndDate(){
        test.startTest();
        List<Asset> assList = new List<Asset>([SELECT id, NE__Order_Config__c, NE__Bundle_element__c, NE__Root_Order_Item__c,NE__Parent_Order_Item__c, XC_PaymentMethod__c FROM Asset where XC_Contract__c!= null limit 1]);
        assList[0].XC_ContractEndDate__c = Date.Today();
        update assList;
        Test.stopTest(); 
       // System.assertequals(assList.size(), 3);
    }

    @isTest
    static void updateStatus(){
        test.startTest();
        List<Asset> assList = new List<Asset>([SELECT id, NE__Order_Config__c, NE__Bundle_element__c, NE__Root_Order_Item__c,NE__Parent_Order_Item__c, XC_PaymentMethod__c FROM Asset where XC_Contract__c!= null limit 1]);
        for(Asset a : assList){
            a.Status = 'Inactive';
        }
        update assList;
        for(Asset a : assList){
            a.Status = 'Active';
        }
        update assList;
        Test.stopTest(); 
        //System.assertequals(assList.size(), 3);
    }

    


}