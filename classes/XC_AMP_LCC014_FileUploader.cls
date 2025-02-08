/**
 * @description       : 
 * @author            : Francesco Imperioli - fimperioli@deloitte.it
 * @group             : 
 * @last modified on  : 12-21-2020
 * @last modified by  : Francesco Imperioli - fimperioli@deloitte.it
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   12-21-2020   Francesco Imperioli - fimperioli@deloitte.it   Initial Version
**/
public without sharing class XC_AMP_LCC014_FileUploader {


    /**
    * @description manage upload towrads doxee for uploaded files on automotive portal UI
    * @author Francesco Imperioli - fimperioli@deloitte.it | 12-21-2020 
    * @param paramsMap 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String,Object> uploadFile(Map<String,Object> paramsMap){

        Map<String,Object> result = new Map<String,Object>();
        String doxeeCategory = paramsMap.containsKey('categoryName') && String.isNotBlank(String.valueOf(paramsMap.get('categoryName'))) ? String.valueOf(paramsMap.get('categoryName')) : 'SF_CHECKLIST';
        String opportunityId = String.valueOf(paramsMap.get('opportunityId'));

        Map<String,Object> fileInfo =  (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(paramsMap.get('fileInfo')));
        String contentDocumentId = String.valueOf(fileInfo.get('documentId'));

        if(String.isBlank(opportunityId)){
            result.put('errorMsg', Label.XC_CL_AMP_ErrorOnFileUploading); // opportunity id blank
            return result;
        }

        List<ContentDocument> documentRecord = [SELECT Id,
            (SELECT Id,
            ContentDocumentId,
            LinkedEntityId,
            ContentDocument.LatestPublishedVersionId,
            ContentDocument.LatestPublishedVersion.PathOnClient,
            ContentDocument.LatestPublishedVersion.FileExtension,
            Contentdocument.LatestPublishedVersion.ContentSize,
            Contentdocument.LatestPublishedVersion.Versiondata,
            Contentdocument.LatestPublishedVersion.Description
            FROM ContentDocumentLinks WHERE LinkedEntityId =: opportunityId LIMIT 1) 
        FROM ContentDocument WHERE Id =:contentDocumentId LIMIT 1];

        Opportunity currentOpportunity = (Opportunity) XC_UTIL_Sobject.selectAllFields(opportunityId)[0];

        XC_CM_LegalEntity_Configuration__mdt configurationLE = [SELECT  XC_DoxeeCompany__c, XC_DoxeeCountry__c 
        FROM  XC_CM_LegalEntity_Configuration__mdt 
        WHERE XC_OrgId__c = :UserInfo.getOrganizationId() 
        AND  XC_LegalEntity__c  = :currentOpportunity.XC_LegalEntity__c
        AND XC_Stream__c  = : currentOpportunity.XC_Segment__c];

        if(!documentRecord.isEmpty()){
            result = callDoxeeFileSend(documentRecord[0],doxeeCategory,configurationLE);
        }
        return result;
    }

    /**
    * @description callout to doxee to uploadFile
    * @author Francesco Imperioli - fimperioli@deloitte.it | 12-21-2020 
    * @param fileToUpload 
    * @return Map<String, Object> 
    **/
    private static Map<String,Object> callDoxeeFileSend(ContentDocument fileToUpload,String category,XC_CM_LegalEntity_Configuration__mdt leConf){
        Map<String,Object> result = new Map<String,Object>();

        if(!fileToUpload.ContentDocumentLinks.isEmpty()){
            XC_REST_DoxeeFileSend_U.RequestWrapper fileSendReqWr = new XC_REST_DoxeeFileSend_U.RequestWrapper();
            fileSendReqWr.File.FileSize = fileToUpload.ContentDocumentLinks[0].Contentdocument.LatestPublishedVersion.ContentSize;
            fileSendReqWr.File.FileName = fileToUpload.ContentDocumentLinks[0].Contentdocument.LatestPublishedVersion.PathOnClient;
            if(fileSendReqWr.File.FileName.length() >= 85){
                if(!String.isBlank(fileToUpload.ContentDocumentLinks[0].Contentdocument.FileExtension)){
                    fileSendReqWr.File.FileName = fileSendReqWr.File.FileName.left(85) + '.' + fileToUpload.ContentDocumentLinks[0].Contentdocument.FileExtension;
                } else {
                    fileSendReqWr.File.FileName = fileSendReqWr.File.FileName.left(85);
                }
            }
            fileSendReqWr.File.FileDescription = fileToUpload.ContentDocumentLinks[0].Contentdocument.LatestPublishedVersion.Description;
            fileSendReqWr.File.FileCreationDate = String.valueOf(Datetime.Now().format('yyyyMMddhhmm') +'T'+ Datetime.Now().format('hh:mm:ss'));
            fileSendReqWr.File.FileCategory = category;
            fileSendReqWr.File.FileBase64 = EncodingUtil.base64Encode(fileToUpload.ContentDocumentLinks[0].Contentdocument.LatestPublishedVersion.Versiondata);
            fileSendReqWr.File.ObjectType = 'OPPORTUNITY';
            fileSendReqWr.File.ObjectID = fileToUpload.ContentDocumentLinks[0].LinkedEntityId;
            fileSendReqWr.File.Company = leConf.XC_DoxeeCompany__c;
            fileSendReqWr.File.Country = leConf.XC_DoxeeCountry__c;

            XC_REST_DoxeeFileSend_U.ResponseWrapper fileSendRespWr = XC_REST_DoxeeFileSend.createFile(fileSendReqWr);
            result.put('success',fileSendRespWr.Result.ErrorCode.equalsIgnoreCase('0'));

            if(!Boolean.valueOf(result.get('success'))){
                result.put('errorMsg',fileSendRespWr.Result.Message);
            }
        }else{
            result.put('errorMsg', Label.XC_CL_AMP_ErrorOnFileUploading); // fileToUpload.ContentDocumentLinks linked to the opportunity not found
        }

        return result;
    }


}