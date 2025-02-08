/**
 * The class XC_REST_DataExtractor
 *
 * @author            : Simone Trenta - strenta@deloitte.it
 * @date Creation     : 22/07/2020
 * @date Modification : dd/mm/yyyy
 * @description       : rest class XC_REST_DataExtractor
 **/

public without sharing class XC_REST_DataExtractor_U {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_REST_DataExtractor');

    public class WrapperRequest {
        public DataExtractorWrapper FILE;
    }

    public class WrapperResponse {
        public XC_UTIL_Integration.Result Result = new XC_UTIL_Integration.Result();
        public DataExtractorWrapper FILE = new DataExtractorWrapper();
    }

    public class DataExtractorWrapper {
        public DocumentWrapper DOCUMENT = new DocumentWrapper();
    }

    public class DocumentWrapper {
        public TemplateWrapper TEMPLATE = new TemplateWrapper();
    }

    public class TemplateWrapper {
        public DaWrapper DA = new DaWrapper();
    }

    public class DaWrapper {
       public String OBJECT_ID;
       public String OBJECT_TYPE;
       public String CATEGORY;
       public String ENEL_DOCUMENT_ISSUE_DATE;
       public String ENEL_COMPANY;
       public String ENEL_COUNTRY;
       public String FILE_NAME;
       public Integer SIZE;
       public String FILE_DESCRIPTION;
       public String FILE_BASE64;
       public String DATA_S;
       public String DATA_E;
    }

    /** 
     * validateRequest.
     *
     * @param mapHeader the header
     * @param wrReq the request
     * @return the wrapper result
     * @description method to check the required parameters and header
     */
    public static XC_UTIL_Integration.WrapperResult validateRequest(Map<String, String> mapHeader, WrapperRequest wrReq){
        XC_UTIL_Integration.WrapperResult validateResult = XC_UTIL_Integration.validateHeader(mapHeader);
        if(validateResult.errorFlag) {
            return validateResult;
        }

        if(wrReq.FILE == null) {
            validateResult.errorMessage = Label.XC_CL_MandatoryField +'FILE';
            validateResult.errorFlag = true;
            return validateResult;
        }

        if(wrReq.FILE.DOCUMENT == null) {
            validateResult.errorMessage = Label.XC_CL_MandatoryField +'FILE.DOCUMENT';
            validateResult.errorFlag = true;
            return validateResult;
        }

        if(wrReq.FILE.DOCUMENT.TEMPLATE == null) {
            validateResult.errorMessage = Label.XC_CL_MandatoryField +'FILE.DOCUMENT.TEMPLATE';
            validateResult.errorFlag = true;
            return validateResult;
        }

        if(wrReq.FILE.DOCUMENT.TEMPLATE.DA == null) {
            validateResult.errorMessage = Label.XC_CL_MandatoryField +'FILE.DOCUMENT.TEMPLATE.DA';
            validateResult.errorFlag = true;
            return validateResult;
        }

        if(String.isBlank(wrReq.FILE.DOCUMENT.TEMPLATE.DA.OBJECT_ID)){
            validateResult.errorMessage = Label.XC_CL_MandatoryField +'FILE.DOCUMENT.TEMPLATE.DA.OBJECT_ID';
            validateResult.errorFlag = true;
            return validateResult;
        }

        if(String.isNotBlank(wrReq.FILE.DOCUMENT.TEMPLATE.DA.DATA_S)&&!XC_UTIL_RESTInbound.checkDateISO(wrReq.FILE.DOCUMENT.TEMPLATE.DA.DATA_S)){
            validateResult.errorMessage = 'Date format is not valid:'+ wrReq.FILE.DOCUMENT.TEMPLATE.DA.DATA_S;
            validateResult.errorFlag = true;
            return validateResult;
        }

        if(String.isNotBlank(wrReq.FILE.DOCUMENT.TEMPLATE.DA.DATA_E)&&!XC_UTIL_RESTInbound.checkDateISO(wrReq.FILE.DOCUMENT.TEMPLATE.DA.DATA_E)){
            validateResult.errorMessage = 'Date format is not valid:'+ wrReq.FILE.DOCUMENT.TEMPLATE.DA.DATA_E;
            validateResult.errorFlag = true;
            return validateResult;
        }

        if(String.isBlank(wrReq.FILE.DOCUMENT.TEMPLATE.DA.DATA_S)!=String.isBlank(wrReq.FILE.DOCUMENT.TEMPLATE.DA.DATA_E)){
            validateResult.errorMessage = 'Fill both dates: FILE.DOCUMENT.TEMPLATE.DA.DATA_S, FILE.DOCUMENT.TEMPLATE.DA.DATA_E';
            validateResult.errorFlag = true;
            return validateResult;
        }

        return validateResult;
    }

    /** 
     * getFile.
     *
     * @param wrReq the request
     * @return the wrapper result
     * @description method to get file
     */
    private static List<ContentDocumentLink> getFile(WrapperRequest wrReq){
        List<ContentDocumentLink> res = new List<ContentDocumentLink>();

        String objId = wrReq.FILE.DOCUMENT.TEMPLATE.DA.OBJECT_ID;
        String cat = wrReq.FILE.DOCUMENT.TEMPLATE.DA.CATEGORY;
        String dateS = wrReq.FILE.DOCUMENT.TEMPLATE.DA.DATA_S;
        String dateE = wrReq.FILE.DOCUMENT.TEMPLATE.DA.DATA_E;

        String condition = 'LinkedEntityId =: objId'; 

        if(String.isNotBlank(cat)){
            condition += ' AND Contentdocument.LatestPublishedVersion.XC_Category__c =: cat';
        }

        if(String.isNotBlank(dateS)){
            Datetime s = XC_UTIL_Sobject.stringToDateTimeGmt(dateS);
            Datetime e = XC_UTIL_Sobject.stringToDateTimeGmt(dateE);
            condition += ' AND ContentDocument.CreatedDate >: s AND ContentDocument.CreatedDate <: e';
        }

        String queryString =  
            'SELECT Id, ContentDocument.CreatedDate, Contentdocument.LatestPublishedVersion.Id, Contentdocument.LatestPublishedVersion.XC_Category__c, '+
                'Contentdocument.LatestPublishedVersion.PathOnClient, Contentdocument.LatestPublishedVersion.ContentSize, '+
                'Contentdocument.LatestPublishedVersion.Description, Contentdocument.LatestPublishedVersion.versiondata, '+
                'LinkedEntityId, ContentDocument.FileExtension '+
            'FROM ContentDocumentLink WHERE '+ condition +
            ' order by ContentDocument.CreatedDate desc';

        return Database.query( String.escapeSingleQuotes(queryString) );
    }

    /** 
     * getFile.
     *
     * @param wrReq the request
     * @return the wrapper result
     * @description method to get file
     */
    public static WrapperResponse getFileResponse(WrapperRequest wrReq){
        WrapperResponse wrResp = new WrapperResponse();

        List<ContentDocumentLink> resList = getFile(wrReq);

        if(resList.isEmpty()){
            wrResp.Result.Message = 'ERROR. File not found';
            wrResp.Result.ErrorCode = '400'; 
            wrResp.FILE = null;
            return wrResp;
        }

        wrResp.result.message = 'Operation completed successfully';
        wrResp.result.errorCode = '0';   

        String leg = '';
        String seg = '';
        ContentDocumentLink doc = resList[0];

        if(doc.LinkedEntityId.getSobjectType().getDescribe().getName() == 'NE__Order__c') {
            wrResp.FILE.DOCUMENT.TEMPLATE.DA.OBJECT_TYPE = 'CONFIGURATION';

            NE__Order__c order = [
                SELECT XC_LegalEntity__c, XC_Segment__c   
                FROM NE__Order__c 
                WHERE id =: doc.LinkedEntityId ];

            leg = order.XC_LegalEntity__c;
            seg = order.XC_Segment__c;

        } else if(doc.LinkedEntityId.getSobjectType().getDescribe().getName() == 'Workorder') {
            wrResp.FILE.DOCUMENT.TEMPLATE.DA.OBJECT_TYPE = 'WORKORDER';

            Workorder wo = [
                SELECT XC_LegalEntity__c, XC_Segment__c  
                FROM Workorder 
                WHERE id =: doc.LinkedEntityId ];

            leg = wo.XC_LegalEntity__c;
            seg = wo.XC_Segment__c;

        } else if(doc.LinkedEntityId.getSobjectType().getDescribe().getName() == 'NE__Billing_Profile__c'){
            wrResp.FILE.DOCUMENT.TEMPLATE.DA.OBJECT_TYPE = 'BILLING_PROFILE';

            NE__Billing_Profile__c bp = [
                SELECT XC_LegalEntity__c, XC_Segment__c  
                FROM NE__Billing_Profile__c 
                WHERE id =: doc.LinkedEntityId ];

            leg = bp.XC_LegalEntity__c;
            seg = bp.XC_Segment__c;
          
        } else {
            wrResp.FILE.DOCUMENT.TEMPLATE.DA.OBJECT_TYPE = doc.LinkedEntityId.getSobjectType().getDescribe().getName().toUpperCase();
        }

        string orgId = UserInfo.getOrganizationId();

        Map<Id,XC_CM_LegalEntity_Configuration__mdt> configurationLE = new Map<Id,XC_CM_LegalEntity_Configuration__mdt>([
            SELECT  XC_DoxeeCompany__c, XC_DoxeeCountry__c 
            FROM  XC_CM_LegalEntity_Configuration__mdt 
            WHERE XC_OrgId__c =: orgId AND  XC_LegalEntity__c  =: leg AND XC_Stream__c  =: seg 
        ]);

        if(!configurationLE.values().isEmpty()){
            wrResp.FILE.DOCUMENT.TEMPLATE.DA.ENEL_COMPANY = configurationLE.values()[0].XC_DoxeeCompany__c;
            wrResp.FILE.DOCUMENT.TEMPLATE.DA.ENEL_COUNTRY = configurationLE.values()[0].XC_DoxeeCountry__c; 
        }

        wrResp.FILE.DOCUMENT.TEMPLATE.DA.OBJECT_ID = doc.LinkedEntityId; 
        wrResp.FILE.DOCUMENT.TEMPLATE.DA.CATEGORY = doc.Contentdocument.LatestPublishedVersion.XC_Category__c; 
        wrResp.FILE.DOCUMENT.TEMPLATE.DA.ENEL_DOCUMENT_ISSUE_DATE = doc.ContentDocument.CreatedDate.formatGMT('YYYY-MM-dd HH:mm:ss')+'.000';  
        wrResp.FILE.DOCUMENT.TEMPLATE.DA.SIZE = doc.Contentdocument.LatestPublishedVersion.ContentSize;
        wrResp.FILE.DOCUMENT.TEMPLATE.DA.FILE_BASE64 = EncodingUtil.base64Encode(doc.Contentdocument.LatestPublishedVersion.versiondata);
        wrResp.FILE.DOCUMENT.TEMPLATE.DA.FILE_NAME = doc.Contentdocument.LatestPublishedVersion.PathOnClient;
        wrResp.FILE.DOCUMENT.TEMPLATE.DA.FILE_DESCRIPTION = doc.Contentdocument.LatestPublishedVersion.Description;

        return wrResp; 
    }



}