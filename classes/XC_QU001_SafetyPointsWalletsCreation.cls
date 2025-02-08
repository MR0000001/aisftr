/**
 * @description       : queueable class called through XC_TR_Account_U_CheckSPW to create Safety points wallets
 * @author            : pedro.danielalmeida@nttdata.com
 * @group             : 
 * @last modified on  : 17-05-2022
 * @last modified by  : pedro.danielalmeida@nttdata.com
**/
public without sharing class XC_QU001_SafetyPointsWalletsCreation implements Queueable {
    private List<Account> lstAccounts;
    
    public XC_QU001_SafetyPointsWalletsCreation(List<Account> lstAccounts) {
        this.lstAccounts = lstAccounts;
    }

    public void execute(QueueableContext context){
        for (Account acc : lstAccounts) {
            XC_UTIL_SafetyPointsWalletManagement.callFlowUpsertSafetyPointWallet(acc);
        }
    }
}