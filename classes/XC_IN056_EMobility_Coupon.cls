/**
 * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation 16/06/2020
 * @date Modification dd/mm/yyyy
 * @description – public class with invocable method. It is invoked by a Flow to create a single use vouchers
 */ 
 

public without sharing class XC_IN056_EMobility_Coupon {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN056_EMobility_Coupon');

    /** 
    * @description InputWrapper the input wrapper.
    */
    public class InputWrapper{ 
        @Invocablevariable
        public String stepId;       
    }

    /** 
     * @description UtilWrapper util wrapper for the class.
     */
    private class UtilWrapper {
        Integer quantity;
        Decimal kwatt;
        Date startDate;
        Date endDate;
        String b2bAccountId;
        String orderId;
        String companyCode;
        String costCenter;
        String legalEntity;
    }


    /** 
    * @description Invocable method to launch the creation of a customer interaction
    * @param inputWrapperList
    */
    @InvocableMethod 
    public static void createCoupons(List<InputWrapper> inputWrapperList) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering In XC_IN056_EMobility_Coupon');

        List<UtilWrapper> utilWrList = getInfos(inputWrapperList);

        List<XC_Voucher__c> voucherListToInsert = new List<XC_Voucher__c>();
        String recordTypeId = Schema.SObjectType.XC_Voucher__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Voucher_RT_eMobilitySingleUse).getRecordTypeId();
        for(UtilWrapper wr : utilWrList) {
            for(Integer i = 1; i <= wr.quantity; i++) {
                XC_Voucher__c voucher = new XC_Voucher__c();
                voucher.RecordTypeId = recordTypeId;
                voucher.XC_B2BCustomer__c = wr.b2bAccountId;
                voucher.XC_Order__c = wr.orderId;
                voucher.XC_Voucher_To_Be_Created__c = 1;
                voucher.XC_Uses__c = 1;
                voucher.XC_Usage_Counter__c = 0;
                voucher.XC_SalesChannel__c = Label.XC_CL_VoucherSalesChannel_FREEKWH;
                voucher.XC_StartDate__c = wr.startDate;
                voucher.XC_EndDate__c = wr.endDate;
                voucher.XC_Type_of_Discount__c = 'kWh';
                voucher.XC_Amount__c = wr.kwatt;
                voucher.XC_CompanyCode__c = wr.companyCode;
                voucher.XC_CostCenter__c = wr.costCenter;
                voucher.XC_LegalEntity__c = wr.legalEntity;
                voucherListToInsert.add(voucher);
            }
        }
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'voucherListToInsert: ' + voucherListToInsert);
        List<XC_UTIL_SObject.WrapperResult> results = XC_UTIL_SObject.insertListRecords(voucherListToInsert);

        XC_Provisioning_Step__c step = new XC_Provisioning_Step__c(Id = inputWrapperList[0].stepId, XC_Status__c = Label.XC_CL_Completed_OK);
        for(XC_UTIL_SObject.WrapperResult wr : results) {
            if(!wr.success) {
                step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
                step.XC_ErrorMessage__c = wr.errorMessage;
                break;
            }
        }

        XC_UTIL_SObject.updateRecord(step);
    }


    /**
     * @description Gets the info from step.
     * @param inputWrapperList the input wrapper list
     * @return List<UtilWrapper>
     **/
    public static List<UtilWrapper> getInfos(List<InputWrapper> inputWrapperList) {

        Set<Id> setStepIds = new Set<Id>(); 
        for(InputWrapper inputWr : inputWrapperList){                
            setStepIds.add(inputWr.stepId);
        } 
   
        Map<Id, XC_Provisioning_Step__c> mapSteps = new Map<Id, XC_Provisioning_Step__c>([SELECT XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c
                                                                                            FROM XC_Provisioning_Step__c 
                                                                                            WHERE Id IN: setStepIds]);
        List< XC_Provisioning_Step__c> listSteps =  mapSteps.values();

        Set<Id> configurationIds = new Set<Id>(); 
        for(XC_Provisioning_Step__c step : listSteps){
            if(!String.isBlank(step.XC_Configuration_Item__r.NE__OrderId__c)){
                configurationIds.add(step.XC_Configuration_Item__r.NE__OrderId__c);
            }
        }
        
        Map<Id, NE__OrderItem__c> configurationItemMap = new Map<Id, NE__OrderItem__c>([SELECT Id, NE__Qty__c, NE__OrderId__c, NE__OrderId__r.XC_LegalEntity__c, NE__OrderId__r.XC_Company_Code__c,
                                                                                            NE__OrderId__r.XC_Cost_Center__c, NE__OrderId__r.NE__OptyId__r.AccountId,
                                                                                            (SELECT Id, XC_DeveloperName__c, NE__Value__c FROM NE__Order_Item_Attributes__r)
                                                                                        FROM NE__OrderItem__c 
                                                                                        WHERE XC_Product_Type__c =: Label.XC_CL_OrderItem_ProductType
                                                                                            AND XC_Product_Subtype__c =: Label.XC_CL_OrderItemSubtype_Coupon
                                                                                            AND NE__OrderId__c IN: configurationIds]);

        List<UtilWrapper> utilWrList = new List<UtilWrapper>();
        for(NE__OrderItem__c oi : configurationItemMap.values()) {
            UtilWrapper wr = new UtilWrapper();
            wr.quantity = Integer.valueOf(oi.NE__Qty__c);
            wr.b2bAccountId = oi.NE__OrderId__r.NE__OptyId__r.AccountId;
            wr.orderId = oi.NE__OrderId__c;
            wr.companyCode = oi.NE__OrderId__r.XC_Company_Code__c;
            wr.costCenter = oi.NE__OrderId__r.XC_Cost_Center__c;
            wr.legalEntity = oi.NE__OrderId__r.XC_LegalEntity__c;
            for(NE__Order_Item_Attribute__c oia : oi.NE__Order_Item_Attributes__r) {
                if(oia.XC_DeveloperName__c == Label.XC_CL_OIA_DeveloperName_MaxKwh) {
                    wr.kwatt = Decimal.valueOf(oia.NE__Value__c);
                } else if(oia.XC_DeveloperName__c == Label.XC_CL_OIA_DeveloperName_ActivationDateline && oia.NE__Value__c != null) {
                    wr.startDate = Date.valueOf(oia.NE__Value__c);
                } else if(oia.XC_DeveloperName__c == Label.XC_CL_OIA_DeveloperName_ExpirationDate && oia.NE__Value__c != null) {
                    wr.endDate = Date.valueOf(oia.NE__Value__c);
                }
            }
            utilWrList.add(wr);
        }

        return utilWrList;
    }

}