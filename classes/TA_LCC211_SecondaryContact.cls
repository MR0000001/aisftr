public without sharing class TA_LCC211_SecondaryContact {
    public class InfoBag {
        @AuraEnabled
        public List<ContactWrapper> contactWrapperList  {get;set;}
        @AuraEnabled
        public List<FieldStructure> fieldStructureList  {get;set;}
        @AuraEnabled
        public List<GdprStructure>  gdprStructureList   {get;set;}
        @AuraEnabled
        public String               error               {get;set;}
    }

    public class ContactWrapper {
        @AuraEnabled
        public Id       id          {get;set;}
        @AuraEnabled
        public String   name        {get;set;}
        @AuraEnabled
        public String   email       {get;set;}
        @AuraEnabled
        public Boolean  selected    {get;set;}
    }

    public class FieldStructure {
        @AuraEnabled
        public String                       label               {get;set;}
        @AuraEnabled
        public String                       apiName             {get;set;}
        @AuraEnabled
        public String                       value               {get;set;}
        @AuraEnabled
        public List<Map<String, String>>    availableValues     {get;set;}
        @AuraEnabled
        public String                       type                {get;set;}
        @AuraEnabled
        public Boolean                      required            {get;set;}
        @AuraEnabled
        public String                       mappingIntegration  {get;set;}
        @AuraEnabled
        public String                       error               {get;set;}
    }

    public class GdprStructure {
        @AuraEnabled
        public String   title               {get;set;}
        @AuraEnabled
        public String   description         {get;set;}
        @AuraEnabled
        public String   apiName             {get;set;}
        @AuraEnabled
        public Boolean  value               {get;set;}
        @AuraEnabled
        public String   mappingIntegration  {get;set;}
        @AuraEnabled
        public Boolean  required            {get;set;}
    }

    @AuraEnabled
    public static String initialize(String inputParameter, Id workOrderId) {
        InfoBag infoBag = new InfoBag();
        try {
            infoBag.fieldStructureList = new List<FieldStructure>();
            infoBag.gdprStructureList = new List<GdprStructure>();
            Map<String, Object> mapParameter = (Map<String, Object>) JSON.deserializeUntyped(inputParameter);

            if(mapParameter.containsKey('object')) {
                String objectName = String.valueOf(mapParameter.get('object'));
                SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
                Map<String, Schema.SObjectField> mapObjectFields = objectType.getDescribe().fields.getMap();

                if(mapParameter.containsKey('fields')) {
                    List<Object> objectApiNameFieldList = (List<Object>) mapParameter.get('fields');

                    for(Object objectApiNameField : objectApiNameFieldList) {
                        String apiNameField = String.valueOf(objectApiNameField);
                        if(mapObjectFields.containsKey(apiNameField)) {
                            Schema.SObjectField field = mapObjectFields.get(apiNameField);
                            FieldStructure fieldStructure = new FieldStructure();
                            fieldStructure.label = String.valueOf(field.getDescribe().getLabel());
                            fieldStructure.apiName = apiNameField;
                            fieldStructure.value = '';
                            fieldStructure.type = String.valueOf(field.getDescribe().getType());
                            fieldStructure.required = Boolean.valueOf(field.getDescribe().isNillable());
                            fieldStructure.error = '';
                            if(fieldStructure.type == 'PICKLIST') {
                                List<Schema.PicklistEntry> picklistValueList = field.getDescribe().getPicklistValues();
                                fieldStructure.availableValues = new List<Map<String, String>>();
                                fieldStructure.availableValues.add(new Map<String, String> {
                                    'value' => '',
                                    'label' => 'None'
                                });
                                for(Schema.PicklistEntry picklistValue : picklistValueList) {
                                    fieldStructure.availableValues.add(new Map<String, String> {
                                        'value' => picklistValue.getValue(),
                                        'label' => picklistValue.getLabel()
                                    });
                                }
                            }
                            infoBag.fieldStructureList.add(fieldStructure);
                        }
                    }
                }
            }

            List<WorkOrder> workOrderList = [SELECT Id, XC_LegalEntity__c FROM WorkOrder WHERE Id = :workOrderId];
            if(workOrderList.size() > 0) {
                WorkOrder currentWorkOrder = workOrderList[0];

                List<XC_ConsentDescription__c> consentDescriptionList = [SELECT Id,
                                                                            XC_DescriptionGiveDataToLE__c,
                                                                            XC_DescriptionMarketing__c,
                                                                            XC_DescriptionProfiling__c,
                                                                            XC_DescriptionThirdParties__c
                                                                        FROM XC_ConsentDescription__c
                                                                        WHERE XC_LegalEntity__c = :currentWorkOrder.XC_LegalEntity__c
                                                                            AND XC_ConsentStatus__c = 'Active'
                                                                            AND XC_DescriptionLanguage__c = :UserInfo.getLanguage()];

                if(consentDescriptionList.size() > 0) {
                    GdprStructure giveDataToLE = new GdprStructure();
                    giveDataToLE.title = 'Authorization data for legal entity';
                    giveDataToLE.description = consentDescriptionList[0].XC_DescriptionGiveDataToLE__c;
                    giveDataToLE.apiName = 'giveDataToLE';
                    giveDataToLE.value = false;
                    giveDataToLE.mappingIntegration = 'Contact.GDPR.LegalEntity[].GiveDataToLegalEntity';
                    giveDataToLE.required = true;
                    infoBag.gdprStructureList.add(giveDataToLE);

                    GdprStructure thirdParties = new GdprStructure();
                    thirdParties.title = 'Third party authorization';
                    thirdParties.description = consentDescriptionList[0].XC_DescriptionThirdParties__c;
                    thirdParties.apiName = 'thirdParties';
                    thirdParties.value = false;
                    giveDataToLE.mappingIntegration = 'Contact.GDPR.GiveDataToThirdParties';
                    infoBag.gdprStructureList.add(thirdParties);

                    GdprStructure marketing = new GdprStructure();
                    marketing.title = 'Authorization for data commercialization';
                    marketing.description = consentDescriptionList[0].XC_DescriptionMarketing__c;
                    marketing.apiName = 'marketing';
                    marketing.value = false;
                    giveDataToLE.mappingIntegration = 'Contact.GDPR.LegalEntity[].GiveDataForMarketing';
                    infoBag.gdprStructureList.add(marketing);

                    GdprStructure profiling = new GdprStructure();
                    profiling.title = 'Authorization data for profiling';
                    profiling.description = consentDescriptionList[0].XC_DescriptionProfiling__c;
                    profiling.apiName = 'profiling';
                    profiling.value = false;
                    giveDataToLE.mappingIntegration = 'Contact.GDPR.LegalEntity[].GiveDataForProfiling';
                    infoBag.gdprStructureList.add(profiling);
                }
            }
        } catch (Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC211_SecondaryContact] EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC211_SecondaryContact', 'initialize', errorMessage, 0, errorMessage, null);
            infoBag.error = errorMessage;
        }
        System.debug('infoBag >> ' + JSON.serialize(infoBag));
        return JSON.serialize(infoBag);
    }

    @AuraEnabled
    public static String loadContact(String infoBagSerialized, Id accountId, Id contactId) {
        InfoBag infoBag = (InfoBag) JSON.deserialize(infoBagSerialized, InfoBag.class);
        try {
            infoBag.contactWrapperList = new List<ContactWrapper>();
            List<Contact> contactList = [SELECT Id, Name, Email FROM Contact WHERE AccountId = :accountId ORDER BY FirstName, LastName];
            for(Contact contact : contactList) {
                ContactWrapper contactWrapper = new ContactWrapper();
                contactWrapper.id = contact.Id;
                contactWrapper.name = contact.Name;
                contactWrapper.email = contact.Email;
                if(contactId == contact.Id) {
                    contactWrapper.selected = true;
                } else {
                    contactWrapper.selected = false;
                }
                infoBag.contactWrapperList.add(contactWrapper);
            }
        } catch (Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC211_SecondaryContact] EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC211_SecondaryContact', 'loadContact', errorMessage, 0, errorMessage, null);
            infoBag.error = errorMessage;
        }
        System.debug('infoBag >> ' + JSON.serialize(infoBag));
        return JSON.serialize(infoBag);
    }

    @AuraEnabled
    public static void updateContact(String infoBagSerialized, Id workOrderId, Id newContactId) {
        try {
            WorkOrder currentWorkOrder = new WorkOrder(Id = workOrderId);
            currentWorkOrder.ContactId = newContactId;
            update currentWorkOrder;
        } catch (Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC211_SecondaryContact] EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC211_SecondaryContact', 'updateContact', errorMessage, 0, errorMessage, null);
        }
    }

    @AuraEnabled
    public static String saveNewContact(String infoBagSerialized, String newContact) {
        InfoBag infoBag = (InfoBag) JSON.deserialize(infoBagSerialized, InfoBag.class);
        try {
            Savepoint sp = Database.setSavepoint();

            Map<String, String> mapHeader = new Map<String, String> {
                'ClientSystem' => 'XInstaller'
            };

            Id currentUserId = UserInfo.getUserId();
            User currentUser = [SELECT Country__c, XC_LegalEntity__c FROM User WHERE Id =: currentUserId][0];

            XC_REST_Account_W.WrapperRequest wrReq = (XC_REST_Account_W.WrapperRequest) JSON.deserialize(newContact, XC_REST_Account_W.WrapperRequest.class);
            XC_REST_Account_W.WrapperResponse wrResp = new XC_REST_Account_W.WrapperResponse();

            for(XC_UTIL_Account.ContactIFWrapper contactWrapper : wrReq.Contact) {
                contactWrapper.Country = currentUser.Country__c;
                for(XC_UTIL_Account.LegalEntityWrapper legalEntityWrapper : contactWrapper.GDPR.LegalEntity) {
                    legalEntityWrapper.LegalEntity = currentUser.XC_LegalEntity__c;
                }
            }

            XC_REST_Account_U.manageUpdate(wrReq, wrResp, mapHeader);

            TA_UTIL_LogManagement.createLog('TA_LCC211_SecondaryContact', 'saveNewContact', String.valueOf(wrResp), 0, String.valueOf(wrResp), null);
            if(wrResp.Result.ErrorCode != '0') {
                infoBag.error = wrResp.Result.Message;
                Database.rollback(sp);
            } else {
                infoBag = (InfoBag) JSON.deserialize(loadContact(infoBagSerialized, wrResp.Account.AccountID, wrResp.Contact[0].ContactID), InfoBag.class);
            }
        } catch (Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC211_SecondaryContact] EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC211_SecondaryContact', 'saveNewContact', errorMessage, 0, errorMessage, null);
        }
        System.debug('infoBag >> ' + JSON.serialize(infoBag));
        return JSON.serialize(infoBag);
    }

    @AuraEnabled
    public static String reloadDocumentTypePicklist(String masterPicklistApiName, String dependantPicklistApiName) {
        Map<String,List<String>> fieldsValues = XC_UTIL_DependentPicklist.getDependentPicklist('Contact', masterPicklistApiName, dependantPicklistApiName).pickListMap;
        String serializedfieldsValues = JSON.serialize(fieldsValues);
        return serializedfieldsValues;
    }
}