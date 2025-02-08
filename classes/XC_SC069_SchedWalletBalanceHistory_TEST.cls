/**
 * @author ECina
 * @date Creation 07/07/2022
 * @date Modification  dd/mm/yyyy
 * @description XC_SC067_SchedWalletBalanceHistory_TEST test class of XC_SC067_ScheduleWalletBalanceHistory 
 * – This schedule class is used to send an email template on Accounts that have realated Safety point wallet with status 'Active' or 'Suspended'
 */
@isTest
public class XC_SC069_SchedWalletBalanceHistory_TEST {
 @isTest
   	private static void sendEmailtoAccountTest(){

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
        	Test.startTest();
        	XC_SC069_ScheduleWalletBalanceHistory.sendEmailtoAccount();
        	Test.stopTest();
    	}
                            
                   
   }