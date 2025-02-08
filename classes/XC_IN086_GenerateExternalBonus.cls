/**
 * @author Nicola Mariniello nmariniello@deloitte.it
 * @date Creation 11/02/2022
 * @date Modification dd/mm/yyyy
 * @description – public class with invocable method. It is invoked by a Flow to generate the external bonus voucher.
 */


public without sharing class XC_IN086_GenerateExternalBonus {


    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN086_GenerateExternalBonus');


    /**
     * @description InputWrapper the input wrapper.
     */
    public class InputWrapper {
        @Invocablevariable
        public String stepId;

        @Invocablevariable
        public String recordTypeId;
    }


    /** 
     * @description Invocable method
     * @param inputWrapperList
     */
    @InvocableMethod 
    public static void createExternalBonus(List<InputWrapper> inputWrapperList) {
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering In XC_IN086_GenerateExternalBonus');

        String stepId;
        String recordTypeId;
        for(InputWrapper inputWr : inputWrapperList){                
            stepId = inputWr.stepId;
            recordTypeId = inputWr.recordTypeId;
        }
        if(String.isBlank(stepId)){
            return;
        }

        Map<Id, NE__OrderItem__c> configurationItemMap = new Map<Id, NE__OrderItem__c>([SELECT Id, NE__OrderId__c, NE__OrderId__r.NE__AccountId__c, NE__OrderId__r.XC_LegalEntity__c, NE__OrderId__r.NE__OptyId__c,
                                                                                            NE__OrderId__r.NE__OptyId__r.XC_ContactIdentityNumber__c, NE__OrderId__r.NE__OptyId__r.POD__c,
                                                                                            NE__Catalog__c, NE__CatalogItem__c, NE__CatalogItem__r.NE__Catalog_Category_Name__c,
                                                                                            (SELECT Id, XC_DeveloperName__c, NE__Value__c FROM NE__Order_Item_Attributes__r)
                                                                                        FROM NE__OrderItem__c
                                                                                        WHERE Id IN (SELECT XC_Configuration_Item__c FROM XC_Provisioning_Step__c WHERE Id =: stepId)]);
        if(configurationItemMap.isEmpty()) {
            return;
        }

        Map<String, String> attributesMap = new Map<String, String>();
        for(NE__Order_Item_Attribute__c oia : configurationItemMap.values()[0].NE__Order_Item_Attributes__r) {
            if(String.isNotBlank(oia.XC_DeveloperName__c) && String.isNotBlank(oia.NE__Value__c)) {
                attributesMap.put(oia.XC_DeveloperName__c, oia.NE__Value__c);
            }
        }
        
        // Voucher Creation
        XC_Voucher__c voucher = new XC_Voucher__c();
        voucher.RecordTypeId = (String.isNotBlank(recordTypeId)) ? recordTypeId : Schema.SObjectType.XC_Voucher__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Voucher_RT_ExternalBonus).getRecordTypeId();
        voucher.XC_LegalEntity__c = configurationItemMap.values()[0].NE__OrderId__r.XC_LegalEntity__c;
        voucher.XC_Order__c = configurationItemMap.values()[0].NE__OrderId__c;
        voucher.XC_Opportunity__c = configurationItemMap.values()[0].NE__OrderId__r.NE__OptyId__c;
        voucher.XC_Catalog__c  = configurationItemMap.values()[0].NE__Catalog__c;
        voucher.XC_Product__c = configurationItemMap.values()[0].NE__CatalogItem__c;
        voucher.XC_ProductCategory__c = configurationItemMap.values()[0].NE__CatalogItem__r.NE__Catalog_Category_Name__c;
        voucher.XC_Uses__c = 1;
        voucher.XC_Usage_Counter__c = 0;
        voucher.XC_IdentityNumber__c = configurationItemMap.values()[0].NE__OrderId__r.NE__OptyId__r.XC_ContactIdentityNumber__c;
        voucher.XC_Account__c = configurationItemMap.values()[0].NE__OrderId__r.NE__AccountId__c;
        voucher.XC_PodPdr__c = configurationItemMap.values()[0].NE__OrderId__r.NE__OptyId__r.POD__c;
        voucher.XC_StartDate__c = Date.Today();
        voucher.XC_EndDate__c = Date.Today().addYears(1);
        voucher.XC_SalesChannel__c = (attributesMap.get('CampaignCode') != null) ? attributesMap.get('CampaignCode') : null;
        voucher.XC_Amount__c = (attributesMap.get('BonusSingleValue') != null) ? Decimal.valueOf(attributesMap.get('BonusSingleValue')) : null;
        voucher.XC_ExternalProductName__c = (attributesMap.get('BonusProductName') != null) ? attributesMap.get('BonusProductName') : null;
        voucher.XC_CategoryName__c = (attributesMap.get('CampaignName') != null) ? attributesMap.get('CampaignName') : null;
        voucher.XC_NumberOfQuotas__c = (attributesMap.get('BonusReplicas') != null) ? Decimal.valueOf(attributesMap.get('BonusReplicas')) : null;
        
        // Insert Voucher and Update Step
        XC_UTIL_SObject.WrapperResult resultInsert = XC_UTIL_SObject.insertRecord(voucher);
        XC_Provisioning_Step__c step = new XC_Provisioning_Step__c(Id = stepId,
                                                                    XC_Status__c = (resultInsert.success) ? Label.XC_CL_Completed_OK : Label.XC_CL_Step_CompletedKO,
                                                                    XC_ErrorMessage__c = (resultInsert.success) ? null : resultInsert.errorMessage);
        XC_UTIL_SObject.updateRecord(step);
    }
    
}