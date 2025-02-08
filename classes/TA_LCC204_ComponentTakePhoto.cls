public without sharing class TA_LCC204_ComponentTakePhoto {

    public class InfoBag {
        @AuraEnabled
        public List<TA_Doxee_Url_Management__c> getFileResponse {get;set;}
        @AuraEnabled
        public String deleteFileResponse {get;set;}
        @AuraEnabled
        public TA_Doxee_Url_Management__c uploadFileResponse {get;set;}
        @AuraEnabled
        public String error {get;set;}
        @AuraEnabled
        public WorkOrder workOrder {get;set;}
    }

    @AuraEnabled
    public static String getFile(WorkOrder workOrder, String customConfigSerialized) {
        InfoBag infoBag = new InfoBag();
        infoBag.getFileResponse = new List<TA_Doxee_Url_Management__c>();
        try {
            Map<String, Object> customConfig = (Map<String, Object>) JSON.deserializeUntyped(customConfigSerialized);
            String fileCategory = String.valueOf(customConfig.get('fileCategory'));

            TA_UTIL_LogManagement.createLog('TA_LCC204_ComponentTakePhoto', 'getFile', fileCategory, 0, fileCategory, null);
            infoBag.getFileResponse = [SELECT Id, TA_Work_Order__c, TA_DoxeeURL__c, TA_Type__c, TA_isPdf__c, TA_FileName__c, TA_isDoc__c
                                        FROM TA_Doxee_Url_Management__c
                                        WHERE TA_Work_Order__c = :workOrder.Id
                                        AND TA_Type__c = :fileCategory];
            //JS - ENXCRM-214 - 28/04/2022 - START
            /*infoBag.workOrder = [SELECT ID,XC_WasteDisposal__c, XC_ExtraCost__c
                                    FROM WorkOrder
                                    WHERE ID =: workOrder.Id][0];*/
            infoBag.workOrder = [SELECT ID,XC_WasteDisposal__c, XC_ExtraCost__c, CaseId
                                    FROM WorkOrder
                                    WHERE ID =: workOrder.Id][0];
            //JS - ENXCRM-214 - 28/04/2022 - END
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC204_ComponentTakePhoto] getFile - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC204_ComponentTakePhoto', 'getFile', errorMessage, 0, errorMessage, null);
            infoBag.error = errorMessage;
        }
        return JSON.serialize(infoBag);
    }

    @AuraEnabled
    public static String deleteFile(String doxeeUrlManagementId) {
        InfoBag infoBag = new InfoBag();
        try {
            delete new TA_Doxee_Url_Management__c(Id = doxeeUrlManagementId);
            infoBag.deleteFileResponse = doxeeUrlManagementId;
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC204_ComponentTakePhoto] deleteFile - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC204_ComponentTakePhoto', 'deleteFile', errorMessage, 0, errorMessage, null);
            infoBag.error = errorMessage;
        }
        return JSON.serialize(infoBag);
    }

    @AuraEnabled
    public static String uploadFile(String fileWrapper, Boolean isPdf, Boolean isDoc) {
        InfoBag infoBag = new InfoBag();
        try {
            XC_REST_DoxeeFileSend_U.RequestWrapper rw = new XC_REST_DoxeeFileSend_U.RequestWrapper();

            rw.File = (XC_REST_DoxeeFileSend_U.FileWrapper) JSON.deserialize(fileWrapper, XC_REST_DoxeeFileSend_U.FileWrapper.class);
            rw.File.FileCreationDate = DateTime.now().format('yyyyMMdd') + 'T' + DateTime.now().format('HH:mm:ss');

            XC_LCC066_Doxee.WrapperUser wrapperUser = new XC_LCC066_Doxee.WrapperUser();
            if(Test.isRunningTest()){
                wrapperUser.company = 'ENELXITALIA-B2C';
                wrapperUser.country = 'Italy';
            } else {
                XC_UTIL_ResultWrapper fetchUser = XC_LCC066_Doxee.fetchUser(rw.File.ObjectID);
                wrapperUser = (XC_LCC066_Doxee.WrapperUser) JSON.deserialize(fetchUser.objectInfo, XC_LCC066_Doxee.WrapperUser.class);
            }

            rw.File.Company	= wrapperUser.company;
            rw.File.Country	= wrapperUser.country;
            //START FIX [ADC27/05/2021] ENXCRM-118 aggiunta estensione per i pdf
            //Boolean isPdf = rw.File.FileName.endsWithIgnoreCase('.pdf')? true: false;
            //END FIX [ADC27/05/2021] ENXCRM-118 aggiunta estensione per i pdf

            XC_REST_DoxeeFileSend_U.ResponseWrapper resp = XC_REST_DoxeeFileSend.createFile(rw);          

            if((resp.Result.ErrorCode == '0' && resp.File != null) || Test.isRunningTest()) {
                //START FIX [ADC27/05/2021] ENXCRM-118 aggiunta estensione per i pdf | BGO 16062022 ENXCRM-214
                //TA_Doxee_Url_Management__c doxeeUrlManagement = new TA_Doxee_Url_Management__c(TA_Work_Order__c = rw.File.ObjectId, TA_DoxeeURL__c = resp.File.Purl);
                TA_Doxee_Url_Management__c doxeeUrlManagement = new TA_Doxee_Url_Management__c(
                    //TA_Work_Order__c = rw.File.ObjectId,
                    TA_DoxeeURL__c = resp.File.Purl,
                    TA_isPdf__c = isPdf,
                    TA_isDoc__c = isDoc,
                    TA_FileName__c = rw.File.FileName,
                    TA_Type__c = rw.File.FileCategory
                );
                if( rw.File.ObjectType == 'WORKORDER' ){
                    doxeeUrlManagement.TA_Work_Order__c = rw.File.ObjectId;
                } else {
                    doxeeUrlManagement.TA_ObjectId__c = rw.File.ObjectId;
                }
                //END FIX [ADC27/05/2021] ENXCRM-118 aggiunta estensione per i pdf | BGO 16062022 ENXCRM-214
                insert doxeeUrlManagement;
                infoBag.uploadFileResponse = doxeeUrlManagement;
            } else {
                infoBag.error = resp.Result.Message;
            }
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC204_ComponentTakePhoto] uploadFile - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC204_ComponentTakePhoto', 'uploadFile', errorMessage, 0, errorMessage, null);
            infoBag.error = errorMessage;
        }
        return JSON.serialize(infoBag);
    }

    @AuraEnabled
    public static Map<String, String> updateWasteDisposal(String woSerialized) {
        try {
            WorkOrder wo = (WorkOrder) JSON.deserialize(woSerialized, WorkOrder.class);
            Map<String, String> params = new Map<String, String>();
            List<TA_Doxee_Url_Management__c> doxeeUrlManagements = [SELECT Id 
                                                                    FROM TA_Doxee_Url_Management__c 
                                                                    WHERE TA_Work_Order__c = :wo.Id
                                                                    AND TA_Type__c IN ('SF_WASTE_IDENTIFICATION_FORM','SF_TRANSPORT_DOCUMENT')];
            wo.XC_WasteDisposal__c = !doxeeUrlManagements.isEmpty() ? true : false;
            update wo;
            params.put('numberOfDocs', JSON.serialize(doxeeUrlManagements.size()));
            params.put('woSerialized', JSON.serialize(wo));
            return params;
        } catch(Exception e) {
            String errorMessage = 'An exception has occured: ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC204_ComponentTakePhoto] updateWasteDisposal - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC204_ComponentTakePhoto', 'updateWasteDisposal', errorMessage, 0, errorMessage, null);
        }
        return null;
    }
}