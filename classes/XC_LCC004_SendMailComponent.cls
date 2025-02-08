/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation  31/08/2018
* @date Modification 06/05/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_LCC004_SendMailComponent – Controller XC_LCP004_SendMailComponent
*/
public without sharing  class XC_LCC004_SendMailComponent {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC004_SendMailComponent');
    
    /** @description emailWrapper */
    public class emailWrapper {
        /** The email id. */
        public string emailId;
        /** The to. */
        public string to;
        /** The from mail. */
        public string fromMail;
        /** The bcc. */
        public string bcc;
        /** The subj. */
        public string subj;
        /** The body. */
        public string body;
        /** The retated to id. */
        public string retatedToId;
    }

    /**
     * @param mapCustomerString - String
     * @description send an Email to the Customer
     * @return the string
     */
    @AuraEnabled
    public static String sendMailtoCustomer(String mapCustomerString) {
        // Modifica Salvatore Agrillo (06/05/2019)
        if(String.isBlank(mapCustomerString)){
            return 'NO DATA';
        } 
        Map<String,Object> mapCustomer = (Map<String, Object>) JSON.deserializeUntyped(mapCustomerString);
        String emailId = (String) mapCustomer.get('emailId'); 
        String to = (String) mapCustomer.get('to');
        String fromMail = (String) mapCustomer.get('fromMail');
        String bcc = (String) mapCustomer.get('bcc'); 
        String subj = (String) mapCustomer.get('subj');
        String body = (String) mapCustomer.get('body');
        String retatedToId = (String) mapCustomer.get('retatedToId');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ data from component @@@ :'+emailId+'@@to: '+ to+ '@@from: ' +fromMail +'@@bcc: '+
                                                     bcc +'@@sub: ' +subj +'@@body: '+body +'@@relatedTo: '+retatedToId);

        Map<Id,emailMessage> mailToSendMap = new Map<Id,emailMessage>([SELECT  id, MessageDate, HasAttachment, Subject,
                                           RelatedToId,FromAddress,CcAddress,BccAddress,
                                           ToAddress,TextBody, XC_Has_Attachment__c,
                                           (SELECT id, Contentdocument.LatestPublishedVersionId 
                                           FROM ContentDocumentLinks) 
                                   FROM emailMessage 
                                   WHERE Id =: emailId 
                                   limit 1]);

        emailMessage mailToSend = new emailMessage();
        if(!mailToSendMap.values().isEmpty()) {
            mailToSend = mailToSendMap.values();  
        }
             
        List<String> attachList = new List<String>();
        for(Integer i=0;i < mailToSend.ContentDocumentLinks.size(); i++) {
            attachList.add(mailToSend.ContentDocumentLinks[i].Contentdocument.LatestPublishedVersionId);
        }
        if(mailToSend.ContentDocumentLinks.size() > 0) {
            mailToSend.XC_Has_Attachment__c = true;
        }
        mailToSend.Subject = subj;       
        mailToSend.FromAddress = 'xc_es_enelxsupport@t-2467zechvc9sok4i7jodeaaya9nhpz3qgruqjauavnwwueh6ll.1w-nu3eam.cs105.apex.sandbox.salesforce.com';
        mailToSend.BccAddress = bcc;
        mailToSend.ToAddress = to;
        mailToSend.TextBody = body;
        mailToSend.MessageDate = DateTime.now();
        //update mailToSend;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@result = '+mailToSend.ToAddress);
         
        try{
            String result = XC_UTIL_OpportunityEmail.sendMail(mailToSend, attachList);
            XC_UTIL_Sobject.updateRecord(mailToSend);
            return result;
        }
        catch(Exception e) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Exception :'+e.getMessage()+' at line: '+e.getLineNumber());
            return 'KO';
        }
     }
    
    /**
     * @description insert an Email Message record
     * @param relatedToObj the related to obj
     * @return the string
     */
    @AuraEnabled
    public static String insertEmailMessage(String relatedToObj) { 
        List<emailMessage> oldMail = new List<emailMessage>();
        try{
            Map<Id,emailMessage> oldMailMap = new Map<Id,emailMessage>([SELECT id,Subject,FromAddress,CcAddress,BccAddress,ToAddress,TextBody
                                                                        FROM emailMessage 
                                                                        WHERE RelatedToId =: relatedToObj 
                                                                        AND Subject = null 
                                                                        AND ToAddress = null
                                                                        LIMIT 1 ]);
            oldmail = oldmailMap.values();
        }
        catch(Exception e) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Exception : '+e.getMessage()+' at line: '+e.getLineNumber()); 
        }
        
        Map<Id,Account> listAccountMap = new Map<Id,Account>([SELECT PrimaryEmail__c FROM Account WHERE ID IN (SELECT AccountId FROM Opportunity WHERE ID = :relatedToObj)]);
        List<Account> listAccount = listAccountMap.values();
        if(oldMail.isEmpty()) {
            emailMessage mail = new emailMessage();
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ email Account ' + mail.ToAddress);

            if(!listAccount.isEmpty()) {
                mail.ToAddress = listAccount.get(0).PrimaryEmail__c;
            }

            mail.RelatedToId = relatedToObj;
            XC_UTIL_Sobject.insertRecord(mail);
            String emailId = mail.Id;
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ new mail @@@'+emailId);
            
            return JSON.serialize(mail);
            
        } else {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ oldMail @@@'+oldMail[0].Id);
            //return oldMail[0].Id;
            if(!listAccount.isEmpty()) {
                oldMail[0].ToAddress = listAccount.get(0).PrimaryEmail__c;
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@' + JSON.serializepretty(oldmail[0], true));
            return JSON.serializepretty(oldMail[0], true);
        } 
    }
}