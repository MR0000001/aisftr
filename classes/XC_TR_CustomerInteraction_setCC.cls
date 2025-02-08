/** 
    *@author Andrea Di Cicco
	*@description setCC on customer interaction
    *@param listNew
    *@return 
    **/
    public without sharing class XC_TR_CustomerInteraction_setCC {
	
        /** 
        *@author Andrea Di Cicco
        *@description set CC on the customer Interaction
        *@param listNew
        **/
        public static void setCCRecipient(List<XC_Customer_Interaction__c> listNew){ 
            List<XC_Customer_Interaction__c> internalNoticeOfExpCI = new List<XC_Customer_Interaction__c>();
            Map<String, String> sohoTypeMapping = new Map<String, String>();
            sohoTypeMapping.put('Public Administrations', 'B2G');
            sohoTypeMapping.put('Associated Companies', 'B2B');
            sohoTypeMapping.put('B2B', 'B2B'); 
            List<XC_CM_CustomerInteractionConfiguration__mdt> 
                    ciConfList = [SELECT XC_CCRecipients__c, XC_Stream__c, XC_LegalEntity__c 
                    FROM XC_CM_CustomerInteractionConfiguration__mdt 
                    WHERE XC_CommunicationType__c = 'Internal_Notice_Of_Expiration' ];
            Map<Id, Account> accountStream = 
                    new Map<Id, Account>([
                        SELECT XC_SohoType__c, Owner.Email, Owner.XC_LegalEntity__c, Owner.Name
                        FROM Account 
                        WHERE Id IN: XC_UTIL_Sobject.getListFieldValues(listNew, 'XC_AccountId__c')]);
            Map<Id, Contact> contactList = 
                    new Map<Id, Contact>([
                        Select Name from Contact
                        WHERE Id 
                        IN : XC_UTIL_Sobject.getListFieldValues(listNew, 'XC_ContactId__c')]);
            for(XC_Customer_Interaction__c ci : listNew){
                if(ci.XC_Communication_Type__c == 'Internal_Notice_Of_Expiration' 
                        && accountStream.get(ci.XC_AccountId__c).XC_SohoType__c != null 
                        && sohoTypeMapping.get(accountStream.get(ci.XC_AccountId__c).XC_SohoType__c)!= null 
                          && contactList.get(ci.XC_ContactId__c) != null){
                        ci.XC_Email__c = accountStream.get(ci.XC_AccountId__c).Owner.Email;
                        ci.XC_Recipient__c = contactList.get(ci.XC_ContactId__c).Name;
                        for(XC_CM_CustomerInteractionConfiguration__mdt cm : ciConfList){
                            if(sohoTypeMapping.get(accountStream.get(ci.XC_AccountId__c).XC_SohoType__c) == cm.XC_Stream__c
                                && accountStream.get(ci.XC_AccountId__c).Owner.XC_LegalEntity__c == cm.XC_LegalEntity__c){
                                ci.XC_CCRecipients__c = cm.XC_CCRecipients__c;  
                                continue;
                            }
                    }
                }
            }
        }
        
    }