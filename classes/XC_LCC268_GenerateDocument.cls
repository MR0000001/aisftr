/**
* @author B.Ramayya -- bulli.bheemanaboyana@accenture.com
* @date Creation 08/02/2022
* @description XC_LCC268_GenerateDocument – Apex Controller for XC_LCP268_GenerateDocument
*/
public without sharing class XC_LCC268_GenerateDocument {
    /**
     * @description retun the callback response to Aura Component
     * @param recordIdContract - String to get fields
     * @return XC_REST_ContractCallback.ContractCallbackResponse
     */
     @AuraEnabled
    public static XC_REST_ContractCallback.ContractCallbackResponse getContractRecordMethod(String recordIdContract) {
        String country;
        String company;
        system.debug('Current contract id:'+recordIdContract);
        List<Contract> contractlist = [SELECT Id, XC_EnelEnergyMARI_ExternalIdDOC__c,XC_CompanyName__c,Description,XC_Generate_Contract_Document__c  FROM Contract WHERE id=:recordIdContract limit 1];
        system.debug('Current contract list:'+contractlist);
        
        XC_REST_ContractCallback.ContractCallbackResponse wcallBackResponse = new XC_REST_ContractCallback.ContractCallbackResponse();
        
        if(contractlist.size()>0 && String.isNotBlank(contractlist[0].XC_EnelEnergyMARI_ExternalIdDOC__c)){
            String info='';
            if(Test.isRunningTest()){
               info='{"userName":"bulli.bheemanaboyana@accenture.com.exdevhub0","uploadNeeded":"false","parentId":"","objectType":"Contract","objectId":"8000D000001Lqe3QAC","error":false,"dossier":{"signers":[{"signer":{"signature-policy":{},"person":{"identity-document":{},"address":{"country":"Colombia","province":null,"city":"Bogotá","zip":"2203","number":"4981-D (4/16)","street":"null Avenida Rodrigo De Araya"}},"default_redirect_url":"http://www.infocert.it","identity_assertion_policy":"inline.devisu","role":"cliente","signer-id":null}},{"signer":{"signature-policy":null,"person":{"legal-id_serial-number":null,"legal-id_serial-type":"TIN","legal-id_country-code":null,"mobile_number":null,"email":"bulli.bheemanaboyana@accenture.com","sex":null,"last-name":"Bheemanaboyana","first-name":"Ramayya"},"default_redirect_url":"http://www.infocert.it","identity_assertion_policy":"none","certificate-domain":null,"certificate-alias":null,"role":"agente","signer-id":"0050D0000043ac5QAA"}}],"serverSystemOTP":"TOP","objects":[{"objectId":"8000D000001Lqe3QAC","objectType":"CONTRACT"}],"dossier-types":["ONESHOT_DEVISU"],"business-id":"Enel X migrazione"},"country":"Italy","company":"ENELXITALIA-B2C","AdditionalInfo":null}';
             }
            else {info = XC_LCC066_Doxee.getUserInformation(recordIdContract);}
            system.debug(info);
          JSONParser  parser = JSON.createParser(info);
          while (parser.nextToken() != null) {
                   if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                       String fieldName = parser.getText();
                           if(fieldName=='Country')
                           {
                           parser.nextToken();
                           country=parser.getText();
                          
                           }
                         if(fieldName=='Company')
                           {
                           parser.nextToken();
                           company=parser.getText();
                           
                           }
                         if(String.isNotBlank(country) && String.isNotBlank(company) ){
                          break;
                      }
                      }
                  }
            system.debug('country:'+country);
            system.debug('company:'+company); 
       
        XC_REST_ContractCallback.ContractCallbackRequest wReq = new XC_REST_ContractCallback.ContractCallbackRequest();
       
        wReq.ObjectId = contractlist[0].id;
        wReq.ExternalDocumentId = contractlist[0].XC_EnelEnergyMARI_ExternalIdDOC__c;
        wReq.DocumentCategory = 'SF_CONTRACT_SIGNED';
        wReq.ObjectType =  (contractlist[0].id.getSObjectType().getDescribe().getName()).toUppercase();
        wReq.Company = company;
        wReq.FileName = 'Contract signed'+' '+contractlist[0].id;
        wReq.Description = contractlist[0].Description;
        wReq.Country = country;
 
        wcallBackResponse = XC_REST_ContractCallback.callToPostContractFromEE(wReq,'XCustomerB2C');
            system.debug('country' + wReq.Country);
            system.debug('sobjecttype :'  +wReq.ObjectType);
            system.debug('*'+contractlist[0].XC_EnelEnergyMARI_ExternalIdDOC__c);
            system.debug('**'+wReq.Company);
            system.debug('***'+contractlist[0].Description);
            system.debug('****'+wReq);
            system.debug('*****'+wcallBackResponse);         
       } else {
        system.debug('in else');
        XC_UTIL_Sobject.WrapperResult wr = new XC_UTIL_Sobject.WrapperResult();
        contractlist[0].XC_Generate_Contract_Document__c = true;
         wr = XC_UTIL_Sobject.updateRecord(contractlist[0]);
        system.debug('contract list:'+contractlist[0]);
        system.debug('line 50:'+wr);
        wcallBackResponse.Error =wr.errorMessage;
       wcallBackResponse.Message =wr.errorMessage;
       }
       return wcallBackResponse;
       
    }
}