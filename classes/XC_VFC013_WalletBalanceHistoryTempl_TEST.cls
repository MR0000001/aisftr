/**
 * @author Francisca & Erlinda
 * @date Creation 20/07/2022
 * @date Modification  dd/mm/yyyy
 * @description XC_VFC013_WalletBalanceHistoryTempl_TEST test class of XC_VFC013_WalletBalanceHistoryTemplate 
 * – This controller class is used to send an email template on Accounts that have realated Safety point wallet with status 'Active' or 'Suspended'
 */
@isTest
public class XC_VFC013_WalletBalanceHistoryTempl_TEST {
  @isTest
    private static void getwallethistoryTest(){

                List<Account> lstAccounts = XC_DF_Account.insertPartnerAccounts(1); 
        		for (Account acc : lstAccounts) {
            	acc.Gruppo_Merceologico__c = 'LCRI05';
            	acc.XC_Partner_Contract_Standby__c = false;
            	acc.XC_SafetyPointsLicenseEnabled__c = false;
            	acc.XC_Country__c = 'Italy';
            	acc.XC_PartnerType__c = 'Field Service;';
            	acc.XC_Segment__c = 'B2C';
            	acc.XC_ContractStatus__c = 'Active';
                acc.XC_SafetyPointsLicenseEmail__c = 'test@gmail.com';
        	}
        	update lstAccounts;	
			XC_SafetyPointWallet__c sfw = XC_UTIL_SafetyPointsWalletManagement.createSingleSafetyPointsWallet(lstAccounts[0].Id,1,40,'Active');//String accountId, Integer walletNumber, Integer balance,String status
        	insert sfw;
        	XC_Safety_Point_Wallet_History__c wallethistory = new XC_Safety_Point_Wallet_History__c();
        	wallethistory.XC_Actual_Balance__c = 5 ;
        	wallethistory.XC_Previous_Balance__c = 3;
        	wallethistory.XC_Account__c = lstAccounts[0].Id;
        	wallethistory.RecordTypeId = Schema.SObjectType.XC_Safety_Point_Wallet_History__c.getRecordTypeInfosByDeveloperName().get('XC_Quality_Check_KPI').getRecordTypeId();
        	insert wallethistory;
        
        	Test.startTest();
				XC_VFC013_WalletBalanceHistoryTemplate  testwallet = new XC_VFC013_WalletBalanceHistoryTemplate();
        		testwallet.accountId = lstAccounts[0].Id;
				testwallet.getwallethistory();
        	Test.stopTest();
		}
    }