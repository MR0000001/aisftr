/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 23/05/2019
* @date  
* @description XC_SC011_RenewContractLineItem_TEST – Test class for XC_SC011_RenewContractLineItem
*/
@isTest
public class XC_SC011_RenewContractLineItem_TEST {
    @TestSetup
    static void setup()
    {	
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        
        List<Asset> assetToInsert = new List<Asset>();
        List<XC_ContractLineItem__c> cliList = new List<XC_ContractLineItem__c>();
        List<Account> accs = XC_DF_Account.createResidentialAccounts(1);
        Account accnt = accs[0];
        accnt.Name = 'Test Account';
        insert accnt;
        NE__Bundle__c  bundle = new NE__Bundle__c(NE__RecurringChargeFrequency__c = 'Monthly', NE__Start_Date__c = Date.Today());
        insert bundle;
		NE__Product__c product = new NE__Product__c(Name = 'OK Gas'); 
        product.XC_Product_Subtype__c = 'Boiler';
        product.XC_Product_Type__c = 'Equipment';
        insert product;
        List<Asset> assetList = XC_DF_Asset.createAssets(2);
        Asset assetWithOkGas = assetList[0];
        Asset assetWithBundle = assetList[1];
        assetWithOkGas.NE__ProdId__c = product.Id;
        assetWithBundle.NE__Bundle__c = bundle.Id; 
        assetToInsert.add(assetWithOkGas);
        assetToInsert.add(assetWithBundle);
        insert assetToInsert; 
        
        Contract contract = new Contract(AccountId = accnt.Id);
        insert contract;
        
    	XC_ContractLineItem__c cli1 = new XC_ContractLineItem__c(XC_Asset__c = assetWithOkGas.Id, XC_EndDate__c = Date.Today(), XC_Contract__c  = contract.Id);
        XC_ContractLineItem__c cli2 = new XC_ContractLineItem__c(XC_Asset__c = assetWithBundle.Id, XC_EndDate__c = Date.Today(), XC_Contract__c  = contract.Id);
        cliList.add(cli1);
        cliList.add(cli2);
        insert cliList;
        
    }
    
    
    /*static testMethod void callBatch(){
        List<Asset> assetList = [SELECT Id FROM Asset];
        Test.startTest();     
        Database.executeBatch(new XC_SC011_RenewContractLineItem(), 200);
        Test.stopTest();
        System.assertEquals(2, assetList.size());
    }*/
}