/**
 * @author Marina Ciavarra - mciavarra@deloitte.it
 * @date Creation 11/10/2021
 * @description XC_SC061_CheckActiveContract_TEST – Test class for XC_SC061_CheckActiveContract 
 */

@isTest
public class XC_SC061_CheckActiveContract_TEST {

    @TestSetup
    static void setup(){
        List<Account> accountList = XC_DF_Account.insertPartnerAccounts(2, 'Active');
        for(Account acc :accountList){
            acc.XC_Segment__c='B2C';
        }
        update accountList;

        List<Contract> contractList = new List<Contract>();

        Contract contr1 = new Contract();
        contr1.AccountId = accountList[0].Id;
        contr1.StartDate = System.today().addDays(-1);
        contr1.EndDate = System.today().addMonths(3);
        contractList.add(contr1);
        
        Contract contr2 = new Contract();
        contr2.AccountId = accountList[0].Id;
        contr2.StartDate = System.today().addDays(-4);
        contr2.EndDate = System.today().addDays(-2);
        contractList.add(contr2);

        Contract contr3 = new Contract();
        contr3.AccountId = accountList[1].Id;
        contr3.StartDate = System.today().addDays(-1);
        contractList.add(contr3);

        insert contractList;
    }

    @isTest
    static void testBatch(){
        
        Test.startTest();
        String chron = '0 0 23 * * ?';
        system.schedule('Test Sched061', chron,  new XC_SC061_CheckActiveContract());
        Test.stopTest();
    }

}