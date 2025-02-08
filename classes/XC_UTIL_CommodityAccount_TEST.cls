/**
* @author Luca Tedeschi ltedeschi@deloitte.it - Monica Cutillo monica.cutillo@nttdata.com
* @date Creation  21/06/2019 
* @description XC_UTIL_CommodityAccount_TEST – Test class for XC_UTIL_CommodityAccount
*/
@isTest
public class XC_UTIL_CommodityAccount_TEST {
    
    static testMethod void populateWrapperResponseAddress(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        	XC_UTIL_Account.AccountIFWrapper account = new XC_UTIL_Account.AccountIFWrapper();
        	List<XC_LCC011_U_NewAddress.WrapperResponseAddress> lwr = XC_UTIL_CommodityAccount.populateWrapperResponseAddress(account);
         	System.assert(lwr!=null);
        Test.stopTest();
    }
   
    static testMethod void checkStatus(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Account> account = XC_DF_Account.createResidentialAccounts(1);
        account[0].IdentityNumber__c = '41550260R';
        account[0].IdentityType__c = 'NIF';
        insert account;
        
        Test.startTest();
            List<Map<String,Object>> addressValues = new List<Map<String,Object>>();
            List<List<Map<String,Object>>> posValues = new List<List<Map<String,Object>>>();
        	XC_UTIL_Address.AddressWrapper adwr= XC_UTIL_CommodityAccount.populateAddressFromCommodityFields(account[0].Id, addressValues,  posValues);
            System.assert(adwr!=null);
        Test.stopTest();
    }

    static testMethod void populateWrapperResponseAddressWithData(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        Test.startTest();
            String commodityFakeResp = XC_REST_ReadAccont.getCommodityFakeAccountResponse();
            XC_REST_Account_W.WrapperResponseGET wrResp = (XC_REST_Account_W.WrapperResponseGET) JSON.deserialize(commodityFakeResp, XC_REST_Account_W.WrapperResponseGET.class);
            List<XC_LCC011_U_NewAddress.WrapperResponseAddress> adwr= XC_UTIL_CommodityAccount.populateWrapperResponseAddress(wrResp.Account[0]);
            System.assert(adwr!=null);
        Test.stopTest();
    }
}