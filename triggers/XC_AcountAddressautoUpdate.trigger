/*------------------------------------------------------------
  Author      :  Lokesh Pokuri
  Trigger     :  XC_AcountAddressautoUpdate
  Description :  This trigger is added as part of XC-19 on Account object to ensure that XC Address field is mandatory when the Account type field is End User or Utility
---------------------------------------------------------------*/
trigger XC_AcountAddressautoUpdate on Account(before update) {
    String recid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global B2B').getRecordTypeId();
    for (Account acc : Trigger.new) {
        if( acc.RecordTypeId == recid && (acc.XC_Account_Type__c=='End User' || acc.XC_Account_Type__c=='Utility'))
        {
            if(acc.XC_Addresss__c == null){
               acc.addError('Finance Billing Information Address field is mandatory when Account Type is Utility or End User'); 
            }
        }
            
    }
    
}