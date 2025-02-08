public class XC_VFC013_WalletBalanceHistoryTemplate {
        public Id accountId {get;set;}
    	public List<XC_Safety_Point_Wallet_History__c> getwallethistory(){
        List<XC_Safety_Point_Wallet_History__c> wallethistory;
        wallethistory = [SELECT Id, RecordType.Name, CreatedDate, XC_Actual_Balance__c, XC_Previous_Balance__c, XC_Account__c
  						FROM XC_Safety_Point_Wallet_History__c WHERE (XC_Account__c =: accountId 
                         AND RecordType.Name != 'Cambiamenti Licenza' 
                         AND RecordType.Name != 'Cambiamenti Wallet'
                         AND XC_Actual_Balance__c != null
                         AND XC_Previous_Balance__c != null)
                         Order by CreatedDate ASC];
        for(Integer i = (wallethistory.size()-1) ; i>= 0 ; i--){
            XC_Safety_Point_Wallet_History__c history = wallethistory[i];
            if((Date.valueOf(history.CreatedDate)).daysBetween(system.today()) > 31){
                wallethistory.remove(i);
            }
        }
        return wallethistory;
    }

}