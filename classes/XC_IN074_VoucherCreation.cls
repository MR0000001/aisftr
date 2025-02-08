/**
*@author Marina Ciavarra - mciavarra@deloitte.it
*@date Creation 02/04/2021
*@description XC_IN074_VoucherCreation – public class with invocable method.
*/
public without sharing class XC_IN074_VoucherCreation {

    
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN074_VoucherCreation');
	
	/**
    *@description InputWrapper
    **/  
    public class InputWrapper{ 
        @Invocablevariable
        public String stepId;
    }

    
    /** 
     * @description UtilWrapper util wrapper for the class.
     */
    private class UtilWrapper{
        String customerType;
        String accountId;
        String contactId;
        String contactName;
        String orderId;
        String orderItemId;
        String optyId;
        String workorderId;
        String preferredlanguage; 
        String productId;
        String email;
        String legalEntity;
    }

    /**
     *@description 
     *@param inputWrapperList the input wrapper list
     */
    @InvocableMethod 
    public static void voucherCreation(List<InputWrapper> inputWrapperList) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In XC_IN072_CallCommodityAPI');
		if(!inputWrapperList.isEmpty()){
            List<String> listStepIds = new List<String>();
            List<String> listConfigItem = new List<String>();
			for(InputWrapper inputWr : inputWrapperList){
                listStepIds.add(inputWr.stepId);
            }
            
            Map<Id, XC_Provisioning_Step__c> mapSteps = new Map<Id, XC_Provisioning_Step__c>([SELECT ID, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c, 
                                                                                            XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__c, XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c,
                                                                                            XC_Configuration_Item__r.NE__CatalogItem__c, XC_Configuration_Item__r.NE__CatalogItem__r.NE__Catalog_Category_Name__c, 
                                                                                            XC_Configuration_Item__r.NE__Catalog__c, XC_Configuration_Item__r.NE__ProdName__c, 
                                                                                            XC_Configuration_Item__r.NE__Account__c, XC_Configuration_Item__r.NE__ProdId__c,
                                                                                            XC_Configuration_Item__r.NE__OneTimeFeeOv__c, XC_Configuration_Item__r.NE__OneTimeFeeDiscounted__c
                                                                                            FROM XC_Provisioning_Step__c 
                                                                                            WHERE Id IN: listStepIds]); 
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapSteps -> ' + mapSteps);
            listConfigItem = populateListConfigItem(mapSteps);

            Map<Id, WorkOrder> mapWO = new Map<Id, WorkOrder>([SELECT Id, XC_Result__c, XC_MaxWallboxPower__c,XC_Configuration_Item__c, ContactId,
                                                                Contact.Name, Contact.Email, Contact.XC_Preferredlanguageofcontact__c
                                                                FROM WorkOrder 
                                                                WHERE XC_Configuration_Item__c IN: listConfigItem
                                                                AND XC_WorkTypeCategory__c=: Label.XC_CL_WorkType_SiteInspection]); 
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapWO -> ' + mapWO);
            Map<Id, WorkOrder> mapConfigItemWO = populateMapWO(mapWO);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapCIWO -> ' + mapConfigItemWO);

            

            Id recordTypeId = Schema.SObjectType.XC_Voucher__c.getRecordTypeInfosByDeveloperName().get('XC_Voucher_General').getRecordTypeId();
            List<XC_Provisioning_Step__c> stepToUpdate = new List<XC_Provisioning_Step__c>();
            for(InputWrapper inputWr : inputWrapperList){
                XC_Provisioning_Step__c step = mapSteps.get(inputWr.stepId);
                Id configItem = mapSteps.get(inputWr.stepId).XC_Configuration_Item__c;
                WorkOrder wo = mapConfigItemWO.get(configItem);

                if(wo.XC_Result__c == 'KO') {
                    step.XC_Status__c = Label.XC_CL_Step_Skipped;
                } else {
                    //create the voucher
                    XC_Voucher__c voucher = new XC_Voucher__c();
                    voucher.RecordTypeId = recordTypeId;
                    voucher.XC_Order__c = mapSteps.get(inputWr.stepId).XC_Configuration_Item__r.NE__OrderId__c;
                    voucher.XC_Uses__c = 1;
                    voucher.XC_Usage_Counter__c = 0;
                    voucher.XC_StartDate__c = Date.Today();
                    voucher.XC_EndDate__c = Date.Today().addYears(1);
                    voucher.XC_Type_of_Discount__c = 'Absolute';
                    voucher.XC_Amount__c = (mapSteps.get(inputWr.stepId).XC_Configuration_Item__r.NE__OneTimeFeeDiscounted__c != null && mapSteps.get(inputWr.stepId).XC_Configuration_Item__r.NE__OneTimeFeeDiscounted__c != 0) ? mapSteps.get(inputWr.stepId).XC_Configuration_Item__r.NE__OneTimeFeeDiscounted__c : mapSteps.get(inputWr.stepId).XC_Configuration_Item__r.NE__OneTimeFeeOv__c;
                    //voucher.XC_Product__c = mapSteps.get(inputWr.stepId).XC_Configuration_Item__r.NE__CatalogItem__c;
                    //voucher.XC_ProductCategory__c= mapSteps.get(inputWr.stepId).XC_Configuration_Item__r.NE__CatalogItem__r.NE__Catalog_Category_Name__c;
                    voucher.XC_Catalog__c = mapSteps.get(inputWr.stepId). XC_Configuration_Item__r.NE__Catalog__c;
                    voucher.XC_LegalEntity__c = mapSteps.get(inputWr.stepId).XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c;
                    voucher.XC_ProductsCompatibleFamily__c = wo.XC_MaxWallboxPower__c;
                    voucher.XC_Threshold__c = 0.01;
                    voucher.XC_Status__c = 'Active';

                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'voucherToInsert: ' + voucher);
                    XC_UTIL_SObject.insertRecord(voucher);

                    //create the CI
                    UtilWrapper wrapper = new UtilWrapper(); 
                    wrapper.customerType = mapSteps.get(inputWr.stepId).XC_Configuration_Item__r.NE__ProdName__c;
                    wrapper.legalEntity = mapSteps.get(inputWr.stepId).XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c;
                    wrapper.orderId = mapSteps.get(inputWr.stepId).XC_Configuration_Item__r.NE__OrderId__c;
                    wrapper.orderItemId = mapSteps.get(inputWr.stepId).XC_Configuration_Item__c;
                    wrapper.optyId = mapSteps.get(inputWr.stepId).XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__c;
                    wrapper.productId = mapSteps.get(inputWr.stepId).XC_Configuration_Item__r.NE__ProdId__c;
                    wrapper.workorderId = wo.Id;
                    wrapper.preferredlanguage = XC_UTIL_CustomerInteractionGeneration_U.getPreferredLanguage(wo.Contact.XC_Preferredlanguageofcontact__c); 
                    wrapper.email = wo.Contact.Email;
                    wrapper.accountId = mapSteps.get(inputWr.stepId).XC_Configuration_Item__r.NE__Account__c ;
                    wrapper.contactId = wo.ContactId;
                    wrapper.contactName = wo.Contact.Name;

                    createCustomerInteraction(wrapper);

                    step.XC_Status__c = Label.XC_CL_Completed_Ok;
                }

                stepToUpdate.add(step);
            }

            if(!stepToUpdate.isEmpty()){
                XC_UTIL_Sobject.updateListRecords(stepToUpdate);
            }
        }
    }

    private static List<String> populateListConfigItem(Map<Id, XC_Provisioning_Step__c> mapSteps){
        List<String> listBPLI = new List<String>();
        for(Id stepId : mapSteps.keySet()){
            listBPLI.add(mapSteps.get(stepId).XC_Configuration_Item__c);
        }
        return listBPLI;
    }

    private static Map<Id, WorkOrder> populateMapWO(Map<Id, WorkOrder> mapWO){
        Map<Id, WorkOrder> mapCIWO = new Map<Id, WorkOrder>();
        for(Id woId :mapWO.keySet()){
            Id key = mapWO.get(woId).XC_Configuration_Item__c;
            WorkOrder value= mapWO.get(woId);
            mapCIWO.put(key, value);
        }
        return mapCIWO;
    }

    /**
     * @description Method to get voucher codes.
     * @param orderId
     **/
    private static String getVoucherCodes(String orderId) {

        String codes = '';

        Map<Id, XC_Voucher__c> voucherMap = new Map<Id, XC_Voucher__c>([SELECT Id, XC_VoucherCode__c FROM XC_Voucher__c WHERE XC_Order__c =: orderId AND XC_RecordTypeName__c = 'Campaign General Voucher' ]);
        for(XC_Voucher__c coupon : voucherMap.values()) {
            codes += (String.isNotBlank(coupon.XC_VoucherCode__c)) ? coupon.XC_VoucherCode__c + ';' : '';
        }

        return codes.removeEnd(';');
    }

    private static void createCustomerInteraction(UtilWrapper wrapper) {
        List<Map<String,Object>> interactions = new List<Map<String,Object>>();
        String communicationType = 'SiteInspection_Voucher';
        Map<String,Object> data = new Map<String,Object>();
        data.put('additionalInfo1', getVoucherCodes(wrapper.orderId));
        data.put('customerType', communicationType);
        data.put('skipComunication', false);
        data.put('preferredlanguage', wrapper.preferredlanguage);
        data.put('accountId', wrapper.accountId);
        data.put('contactId', wrapper.contactId);
        data.put('fullName', wrapper.contactName);
        data.put('orderId', wrapper.orderId);
        data.put('orderItemID', wrapper.orderItemId);
        data.put('opportunityId', wrapper.optyId);
        data.put('workorderId', wrapper.workorderId);
        data.put('email', wrapper.email);
        data.put('productId', wrapper.productId);
        data.put('sent', false);
        data.put('legalEntity', wrapper.legalEntity); 
        
        
        

        interactions.add(data);

        XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromWorkOrder(interactions);
    }
}