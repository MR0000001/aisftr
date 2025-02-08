/**
 * @File Name          : XC_LCC191_ExternalOTPSignature.cls
 * @Description        : 
 * @Author             : Francesco Imperioli - fimperioli@deloitte.it
 * @Group              : 
 * @Last Modified By   : Francesco Imperioli - fimperioli@deloitte.it
 * @Last Modified On   : 9/6/2020, 17:17:08
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    9/6/2020   Francesco Imperioli - fimperioli@deloitte.it     Initial Version
**/
public without sharing class XC_LCC191_ExternalOTPSignature {

    /**
    * @description create a new XC_DocumentSignature__c 
    * fake record to bypass OTP verification in case of signature done externally from the crm
    * @author Francesco Imperioli - fimperioli@deloitte.it | 9/6/2020 
    * @param recordId 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String,Object> manageExternalOTP(String recordId){
        Map<String,Object> result = new Map<String,Object>();

        XC_DocumentSignature__c fakeDs = new XC_DocumentSignature__c(
            XC_Step__c = '3',
            XC_Order__c = recordId,
            XC_DossierId__c = XC_UTIL_UUID.newGuid(),
            XC_DocumentName__c = Label.XC_CL_LCP191_ExtOTPSignatureDocName + ' - ' + DateTime.now(),
            XC_UrlCustomer__c = XC_UTIL_UUID.newGuid()
        );

        XC_UTIL_Sobject.WrapperResult insertRes = XC_UTIL_Sobject.insertRecord(fakeDs);
        result.put('success',insertRes.success);
        result.put('errorMsg',insertRes.errorMessage);

        //inserting platform event to update the document signature component
        XC_DigitalSignature__e deEvent = new XC_DigitalSignature__e(
            XC_SignerId__c = recordId
        );
        EventBus.publish(deEvent);

        return result;
    }

}