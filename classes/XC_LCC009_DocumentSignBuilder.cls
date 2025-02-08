/**
* The Class XC_LCC009_DocumentSignBuilder.
* @author Roberta Cossiga - rcossiga@deloitte.it
* @description XC_LCC009_DocumentSignBuilder 
*/
public without sharing class XC_LCC009_DocumentSignBuilder {

    /**
     * Upload signature.
     * @description upload a Signature
     * @param contactId the contact id
     * @param b64SignData the b 64 sign data
     * @return the string
     */
    @AuraEnabled
    public static String uploadSignature(String contactId, String b64SignData){
        try {

            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; 
            //conVer.PathOnClient = attach.Name;
            conVer.PathOnClient = 'Signature_'+String.valueOf(Date.today()).substring(0,10) +'.jpeg';
            //conVer.Title = attach.Name; 
            conVer.Title= 'Signature_'+String.valueOf(Date.today()).substring(0,10) +'.jpeg';
            //conVer.VersionData = attach.body; 
            conVer.VersionData = EncodingUtil.base64Decode(b64SignData); 
          
            XC_UTIL_Sobject.insertRecord(conVer);

            if(!Schema.SObjectType.ContentVersion.isAccessible()) {
            return 'NO ACCESS';
        }
			
            // First get the content document Id from ContentVersion
			Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
            
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = conDoc;           
            cdl.ShareType = 'V';                 
            XC_UTIL_Sobject.insertRecord(cdl);
            
            return '';
            //return attach.id;
        }
        catch (Exception e)
        {
            String errorMessage = e.getMessage();
            
            Integer occurence;
            if (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                //occurence = errorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 34;     
                //errorMessage = errorMessage.mid(occurence, errorMessage.length());
                occurence = errorMessage.lastIndexOf(':');
                errorMessage = errorMessage.mid(0, occurence);
            }
            system.debug('Error: '+e);
            system.debug('Error: '+errorMessage);
            
            return errorMessage;
        }
    }
}