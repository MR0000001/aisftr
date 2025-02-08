/**
* @author 
* @date Creation 
* @date Modification dd/mm/yyyy
* @description XC_UTIL_OpportunityEmail 
**/ 
public without sharing class XC_UTIL_OpportunityEmail {
    
public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_OpportunityEmail');
    /**
     *@author  
     *@description Method to sendMail
     *@param emailToSend 
     *@param attachmentList
     *@return string  
    **/
    public static String sendMail(emailMessage emailToSend, List<String> attachmentList) {
        
        if(emailToSend != null && emailToSend.ToAddress != null) {
            
            System.debug('@@@ emailtosend @@@: '+emailToSend);        
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            List<String> emailList = new List<String>(); 
            
            emailList.add(emailToSend.ToAddress);
            if(null != emailToSend.BccAddress && '' != emailToSend.BccAddress) {
                List<String> bccList = new List<String>{emailToSend.BccAddress}; 
                    message.setBccAddresses(bccList);
            }        
            message.setSenderDisplayName('servizio clienti');
            message.toAddresses = emailList;
            //message.setReplyTo('createtaskservice@21bpk09eyu9vzpmpjpr2w02wta3mcuor4yqbcg8kri4e2g4vmb.0y-1dtabuae.eu11.apex.salesforce.com');
            message.setReplyTo('xc_es_enelxsupport@t-2467zechvc9sok4i7jodeaaya9nhpz3qgruqjauavnwwueh6ll.1w-nu3eam.cs105.apex.sandbox.salesforce.com');
            message.optOutPolicy = 'FILTER';
            
            message.setEntityAttachments(attachmentList);
            message.subject = emailToSend.Subject +'-- Identificativo ;' +emailToSend.RelatedToId;
            message.setHtmlBody(emailToSend.TextBody);
            Map<Id, OrgWideEmailAddress> oweaMap = new Map<Id, OrgWideEmailAddress>([select Id from OrgWideEmailAddress where Address = 'xc_es_enelxsupport@t-2467zechvc9sok4i7jodeaaya9nhpz3qgruqjauavnwwueh6ll.1w-nu3eam.cs105.apex.sandbox.salesforce.com']);
            List<OrgWideEmailAddress> owea = oweaMap.values();
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            System.debug('@@@ mailMessage @@@ : '+message);
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message}; 
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if (results[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: '
                             + results[0].errors[0].message);
            }
            

            return 'OK';
        }
        else {
            return 'KO';
        }
        
    }

}