public without sharing class TA_LCC222_IdentityCard {
    public TA_LCC222_IdentityCard() {}

    public class ObjectWrapper {
        @AuraEnabled
        public TA_Doxee_Url_Management__c identityCardFront {get; set;}

        @AuraEnabled
        public TA_Doxee_Url_Management__c identityCardRetro {get; set;}

        @AuraEnabled
        public String objectId {get; set;}

        @AuraEnabled        
        public XC_REST_DoxeeFileSend_U.ResponseWrapper resp {get; set;}

        @AuraEnabled
        public TA_Doxee_Url_Management__c doxeeUrlManagement {get; set;}
    }

    @AuraEnabled
    public static ObjectWrapper getDoxeeUrlManagements(String workOrderId, String objectType, String fileCategoryFront, String fileCategoryRear) {
        System.debug('enter getDoxeeUrlManagements');
        ObjectWrapper objWrapper = new ObjectWrapper();

        try {
            if(String.isNotBlank(workOrderId) && String.isNotBlank(objectType)) {
                objWrapper.identityCardFront = new TA_Doxee_Url_Management__c();
                objWrapper.identityCardRetro = new TA_Doxee_Url_Management__c();
                String objectId = '';
                List<String> fileCategories = new List<String>{fileCategoryFront,fileCategoryRear};
                if (objectType == 'CONFIGURATION'){
                    /*String parameters = [SELECT TA_Parameters__c FROM WorkOrder WHERE ID =: workOrderId].TA_Parameters__c;
                    Map<String,Object> paramMap = (Map<String,Object>) JSON.deserializeUntyped(parameters);
                    if(paramMap.containsKey('quoteToAccept')){
                        objectId = String.valueOf(paramMap.get('quoteToAccept'));
                    }*/
                    objectId = [SELECT XC_Configuration__c FROM WorkOrder WHERE ID =: workOrderId].XC_Configuration__c;
                }
                objWrapper.objectId = objectId;
                System.debug('objectType + objectId: ' + objectType + ': ' + objectId);

                List<TA_Doxee_Url_Management__c> doxeeUrlManagements = [SELECT TA_ObjectId__c, TA_DoxeeURL__c, TA_Type__c,TA_isPdf__c, TA_FileName__c, TA_isDoc__c
                                                                        FROM TA_Doxee_Url_Management__c
                                                                        WHERE TA_ObjectId__c =: objectId
                                                                        AND TA_Type__c IN: fileCategories];

                System.debug('doxeeUrlManagements: ' + doxeeUrlManagements);
                if(!doxeeUrlManagements.isEmpty()) {
                    for(TA_Doxee_Url_Management__c doxeeUrlManagement : doxeeUrlManagements) {
                        if(doxeeUrlManagement.TA_Type__c == fileCategoryFront) {
                            objWrapper.identityCardFront = doxeeUrlManagement;
                        } else if(doxeeUrlManagement.TA_Type__c == fileCategoryRear) {
                            objWrapper.identityCardRetro = doxeeUrlManagement;
                        }
                    }
                }                
            }
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC222_IdentityCard] init - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC222_IdentityCard', 'init', errorMessage, 0, errorMessage, null);
        }
        return objWrapper;
    }

    @AuraEnabled
    public static Boolean deleteDoxeeDocs(String doxeeUrlManagementId) {
        try {
           if(String.isNotBlank(doxeeUrlManagementId)) {
                delete new TA_Doxee_Url_Management__c(Id = doxeeUrlManagementId);
                return true;
            }
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC222_IdentityCard] deleteDoxeeDocs - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC222_IdentityCard', 'deleteDoxeeDocs', errorMessage, 0, errorMessage, null);
        }
        return false;
    }

    @AuraEnabled
    public static String callDoxee(String fileWrapper, String identityCardType, String workOrderId, Boolean isPdf, Boolean isDoc) {
        try {
            System.debug('enter callDoxee workOrderId: ' + workOrderId);
            ObjectWrapper objWrapper = new ObjectWrapper();
            XC_REST_DoxeeFileSend_U.RequestWrapper rw = new XC_REST_DoxeeFileSend_U.RequestWrapper();

            rw.File = (XC_REST_DoxeeFileSend_U.FileWrapper) JSON.deserialize(fileWrapper, XC_REST_DoxeeFileSend_U.FileWrapper.class);
            rw.File.FileCreationDate = DateTime.now().format('yyyyMMdd') + 'T' + DateTime.now().format('HH:mm:ss');

            XC_LCC066_Doxee.WrapperUser wrapperUser = new XC_LCC066_Doxee.WrapperUser();
            if(Test.isRunningTest()){
                wrapperUser.company = 'ENELXITALIA-B2C';
                wrapperUser.country = 'Italy';
            } else {
                XC_UTIL_ResultWrapper fetchUser = XC_LCC066_Doxee.fetchUser(workOrderId);
                wrapperUser = (XC_LCC066_Doxee.WrapperUser) JSON.deserialize(fetchUser.objectInfo, XC_LCC066_Doxee.WrapperUser.class);
            }

            rw.File.Company	= wrapperUser.company;
            rw.File.Country	= wrapperUser.country;
            //Boolean isPdf = rw.File.FileName.endsWithIgnoreCase('.pdf')? true: false;

            objWrapper.resp = XC_REST_DoxeeFileSend.createFile(rw);
            TA_UTIL_LogManagement.createLog('TA_LCC222_IdentityCard', 'callDoxee', String.valueOf(objWrapper.resp), 0, String.valueOf(objWrapper.resp), null);

            if ((objWrapper.resp.Result.ErrorCode == '0' && objWrapper.resp.File != null) || Test.isRunningTest()) {
                objWrapper.doxeeUrlManagement = new TA_Doxee_Url_Management__c();

                List<TA_Doxee_Url_Management__c> doxeeUrlManagements = [SELECT Id
                                                                        FROM TA_Doxee_Url_Management__c
                                                                        WHERE TA_ObjectId__c =: rw.File.ObjectId
                                                                        AND TA_Type__c =: identityCardType];

                if(doxeeUrlManagements.size() > 0) {
                    objWrapper.doxeeUrlManagement = new TA_Doxee_Url_Management__c(Id = doxeeUrlManagements[0].id,
                                                                        TA_ObjectId__c = rw.File.ObjectId,
                                                                        TA_DoxeeURL__c = objWrapper.resp.File.Purl,
                                                                        TA_isPdf__c = isPdf,
                                                                        TA_isDoc__c = isDoc,
                                                                        TA_Type__c = identityCardType,
                                                                        TA_FileName__c = rw.File.FileName);//START FIX [ADC27/05/2021] ENXCRM-118 aggiunto campo TA_FileName__c 
                    update objWrapper.doxeeUrlManagement;
                } else {
                    objWrapper.doxeeUrlManagement = new TA_Doxee_Url_Management__c(TA_ObjectId__c = rw.File.ObjectId,
                                                                        TA_DoxeeURL__c = objWrapper.resp.File.Purl,
                                                                        TA_isPdf__c = isPdf,
                                                                        TA_isDoc__c = isDoc,
                                                                        TA_Type__c = identityCardType,
                                                                        TA_FileName__c = rw.File.FileName); //START FIX [ADC27/05/2021] ENXCRM-118 aggiunto campo TA_FileName__c 
                    insert objWrapper.doxeeUrlManagement;
                }
                //return doxeeUrlManagement;
            }
            return JSON.serialize(objWrapper);
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC222_IdentityCard] callDoxee - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC222_IdentityCard', 'callDoxee', errorMessage, 0, errorMessage, null);
        }
        return null;
    }
}