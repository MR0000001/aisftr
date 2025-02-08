/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation  31/08/2018
* @date Modification dd/mm/yyyy
* @description XC_LCC004_EmailMessageTable – Controller of XC_LCP004_EmailMessageTable
*/

public without sharing class XC_LCC004_EmailMessageTable {
    
    /**
     * Data query.
     *
     * @param recordId the record id
     * @return the list
     * @description Query the necessary metadata
     */
    @AuraEnabled
    public static List<EmailMessage> dataQuery(String recordId){

        if(!Schema.SObjectType.EmailMessage.isAccessible()) {
            return new List<EmailMessage>();
        }


        Map<ID,EmailMessage> messagesMap = new Map<Id,EmailMessage>([SELECT  id, Subject, FromAddress, Headers, ToAddress, MessageDate , Status, XC_Has_Attachment__c,
                                                (SELECT Contentdocument.LatestPublishedVersionId 
                                                FROM ContentDocumentLinks)
        FROM EmailMessage WHERE RelatedToId=:recordId and MessageDate != null ORDER BY MessageDate]);

        List<EmailMessage> messages = messagesMap.values();


        for(EmailMessage msg : messages){
            //da creare un campo custom per ribaltare la URL ed un altro campo custom di tipo test
            msg.Headers = URL.getSalesforceBaseUrl().toExternalForm() +'/' +msg.Id;
        }

        System.debug('@@@ messages ' + messages);

        //update messages;
        return messages;
    }
}