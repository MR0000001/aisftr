public without sharing class TA_LCC240_CartDiscountCode {
    public TA_LCC240_CartDiscountCode() {}

    @AuraEnabled
    public static String getVoucherCode(String voucherCode, String catalogId) {
        if(String.isNotBlank(voucherCode)) {
            List<XC_Voucher__c> vouchers = [SELECT Id, XC_VoucherCode__c, XC_Product__c, XC_Type_of_Discount__c, XC_Status__c, Name, 
                                            XC_Amount__c, XC_Voucher_To_Be_Created__c, XC_ProductCategory__c, XC_Billing_Model__c, XC_StartDate__c, 
                                            XC_EndDate__c, XC_Territories__c, XC_NumberOfQuotas__c 
                                            FROM XC_Voucher__c 
                                            WHERE XC_StartDate__c <= TODAY and XC_EndDate__c >= TODAY 
                                            AND (XC_Type_of_Discount__c = 'Percentage' or XC_Type_of_Discount__c ='Absolute') 
                                            AND (XC_RecordTypeName__c = 'Campaign General Voucher' or XC_RecordTypeName__c ='Campaign Individual Voucher') 
                                            AND XC_Status__c ='Active' and XC_VoucherCode__c = :voucherCode
                                            AND XC_Catalog__c = :catalogId];
            if(!vouchers.isEmpty()) {
                XC_Voucher__c selectedVoucher = vouchers[0];
                return JSON.serialize(selectedVoucher);
            }
        }
        return null;
    }

   /* @AuraEnabled
    public static List<ne__matrix_parameter_row__c> getSubsidies(String workOrderId) {
        try {
            if(String.isNotBlank(workOrderId)) {
                List<WorkOrder> workOrders = [SELECT Id, XC_Country__c, XC_Opportunity__r.CreatedDate 
                                              FROM WorkOrder 
                                              WHERE Id = :workOrderId];
                if(!workOrders.isEmpty()) {

                    Id currentUserProfileId = UserInfo.getUserId();
                    List<PermissionSetAssignment> currentUserPermissionSetList = [SELECT PermissionSet.Name
                                                                                  FROM PermissionSetAssignment
                                                                                  WHERE AssigneeId =: currentUserProfileId
                                                                                  AND PermissionSet.Description = 'TA_Configuration_Language'];
                    if(!currentUserPermissionSetList.isEmpty()) {
                        String currentUserPermissionSetName = currentUserPermissionSetList[0].PermissionSet.Name;

                        List<TA_Cart_Matrix_Parameter__c> cartMatrxiParameters = [SELECT Id, TA_Matrix_Parameter_Name__c
                                                                                  FROM TA_Cart_Matrix_Parameter__c
                                                                                  WHERE TA_Configuration_Set__c = :currentUserPermissionSetName];
                                                                                  
                        System.debug('currentUserPermissionSetName -- ' + currentUserPermissionSetName);
                        System.debug('currentUserProfileId -- ' + currentUserProfileId);
                        System.debug('cartMatrxiParameters -- ' + cartMatrxiParameters);

                        if(!cartMatrxiParameters.isEmpty()) {
                            return [SELECT id, XC_Country__c, XC_Value4__c, XC_Region__c, XC_Discount__c, XC_Name1__c,
                                            XC_Value1__c,XC_Value2__c, XC_Name3__c, XC_Value3__c, XC_Usagecode__c, 
                                            XC_Promo_Name__c, XC_Payment_model__c, XC_valueReadOnly__c, XC_Value5__c, 
                                            XC_Value6__c, XC_Name2__c
                                    FROM ne__matrix_parameter_row__c
                                    WHERE product_lic_name__c = 'Subvencion' 
                                    AND XC_Rule_type__c = 'Promotion' 
                                    AND XC_Matrix_Parameter_Name__c = :cartMatrxiParameters[0].TA_Matrix_Parameter_Name__c
                                    AND NE__Active__c = true 
                                    AND (NE__Start_Date__c < :Date.valueOf(workOrders[0].XC_Opportunity__r.CreatedDate) 
                                        OR NE__End_Date__c > :Date.valueOf(workOrders[0].XC_Opportunity__r.CreatedDate))
                                    AND (XC_Country__c = :workOrders[0].XC_Country__c
                                        OR XC_Country__c = null)];
                        }
                    }
                }
            }
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC240_CartDiscountCode] init - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC240_CartDiscountCode', 'getSubsidies', errorMessage, 0, errorMessage, null);
        }
        return null;
    }*/
}