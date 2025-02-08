/**
 * The Class XC_REST_CheckCoupon_D.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 19/06/2020
 * @date Modification : dd/mm/yyyy
 * @description       : Util class for Rest Resource for Check Coupon/Voucher
 **/


public without sharing class XC_REST_CheckCoupon_D {


    public class UtilWrapper {
        public Map<String, XC_Voucher__c> codeVoucherMap;
        public Map<String, Id> keyAccountIdMap;
    }


    /**
     * CheckAccountByKeys.
     *
     * @param accountId the account id
     * @param primaryEmail the primary email
     * @param identityNumber the identity number
     * @return the account
     * @description method to check Account
     */
    public static UtilWrapper checkSetKeys(Map<String, Set<String>> keysMap) {

        Set<String> couponCodeSet = keysMap.get('couponCodeSet');
        Set<String> accountIdSet = keysMap.get('accountIdSet');
        Set<String> emailSet = keysMap.get('emailSet');
        Set<String> identityNumberSet = keysMap.get('identityNumberSet');

        Map<Id, XC_Voucher__c> voucherMap = new Map<Id, XC_Voucher__c>([SELECT Id, XC_Account__c, XC_Status__c, XC_Usage_Counter__c, XC_Uses__c, XC_VoucherCode__c, XC_Amount__c, XC_Type_of_Discount__c,
                                                                            XC_StartDate__c, XC_EndDate__c, XC_SalesChannel__c, Name, XC_Product__c, XC_ProductCategory__c, XC_Billing_Model__c,
                                                                            XC_PurseExpirationMonths__c, XC_PurseExpirationDate__c, XC_NumberOfQuotas__c, XC_UnitOfMeasure__c, XC_FinalDiscount__c,
                                                                            XC_Threshold__c, XC_ProductsCompatibleFamily__c, XC_IdentityNumber__c, XC_PodPdr__c, XC_CategoryName__c,
                                                                            XC_ExternalProductName__c, XC_ExternalStatus__c, XC_ExternalMessage__c, XC_Order__r.Name,
                                                                            XC_Order__r.NE__OptyId__r.XC_Address__c, XC_Order__r.NE__OptyId__r.XC_Address__r.XC_StreetTypeText__c,
                                                                            XC_Order__r.NE__OptyId__r.XC_Address__r.XC_Address__c, XC_Order__r.NE__OptyId__r.XC_Address__r.XC_StreetNumber__c,
                                                                            XC_Order__r.NE__OptyId__r.XC_Address__r.XC_PostalCode__c, XC_Order__r.NE__OptyId__r.XC_Address__r.XC_City__c,
                                                                            XC_Order__r.NE__OptyId__r.XC_Address__r.XC_AddressCountry__c, XC_Order__r.NE__OptyId__r.XC_Address__r.XC_Category__c,
                                                                            XC_Order__r.NE__OptyId__r.XC_Address__r.XC_Stair__c, XC_Order__r.NE__OptyId__r.XC_Address__r.XC_Floor__c,
                                                                            XC_Order__r.NE__OptyId__r.XC_Address__r.XC_Door__c, XC_Order__r.NE__OptyId__r.XC_Address__r.XC_AddressProvince__c,
                                                                            XC_Order__r.NE__OptyId__r.XC_Address__r.XC_DeliveryAddress__c, XC_Order__r.NE__OptyId__r.XC_Address__r.XC_InstallationAddress__c,
                                                                            XC_Order__r.NE__OptyId__r.XC_Address__r.XC_BillingAddress__c, XC_Order__r.NE__OptyId__r.XC_Address__r.XC_Municipality__c,
                                                                            XC_Order__r.NE__OptyId__r.XC_Address__r.XC_ClarificatorType__c, XC_Order__r.NE__OptyId__r.XC_Address__r.XC_ClarificatorValue__c,
                                                                            XC_Order__r.NE__OptyId__r.XC_Address__r.XC_AddressValidated__c, XC_Order__r.NE__OptyId__r.XC_Address__r.XC_Region__c,
                                                                            (SELECT Id, XC_Account__c FROM Voucher_Utilization__r)
                                                                        FROM XC_Voucher__c
                                                                        WHERE XC_VoucherCode__c IN: couponCodeSet]);
        List<XC_Voucher__c> voucherList = voucherMap.values();

        Map<String, XC_Voucher__c> codeVoucherMap = new Map<String, XC_Voucher__c>();
        for(XC_Voucher__c v : voucherMap.values()) {
            codeVoucherMap.put(v.XC_VoucherCode__c, v);
        }

        Map<String, Id> keyAccountIdMap = checkAccountBySetKeys(accountIdSet, emailSet, identityNumberSet);

        UtilWrapper utilWr = new UtilWrapper();
        utilWr.codeVoucherMap = codeVoucherMap;
        utilWr.keyAccountIdMap = keyAccountIdMap;
        return utilWr;
    }


    /**
     * CheckAccountByKeys.
     *
     * @param accountId the account id
     * @param primaryEmail the primary email
     * @param identityNumber the identity number
     * @return the account
     * @description method to check Account
     */
    public static Map<String, Id> checkAccountBySetKeys(Set<String> accountIdSet, Set<String> emailSet, Set<String> identityNumberSet) {

        Map<String, Id> keyAccountIdMap = new Map<String, Id>();

        if(accountIdSet.isEmpty() && emailSet.isEmpty() && identityNumberSet.isEmpty()) {
            return keyAccountIdMap;
        }

        String query = 'SELECT Id, IdentityNumber__c, PrimaryEmail__c FROM Account';
        
        Boolean check = false;
        if(!accountIdSet.isEmpty()) {
            query += ' WHERE Id IN: accountIdSet';
            check = true;
        }

        if (!emailSet.isEmpty() && !check) {
            query += ' WHERE PrimaryEmail__c IN :emailSet';
            check = true;
        } else if (!emailSet.isEmpty()) {
            query += ' OR PrimaryEmail__c IN :emailSet';
        }

        if (!identityNumberSet.isEmpty() && !check) {
            query += ' WHERE IdentityNumber__c IN :identityNumberSet';
            check = true;
        } else if (!identityNumberSet.isEmpty()) {
            query += ' OR IdentityNumber__c IN :identityNumberSet';
        }

        if(!check) {
            return keyAccountIdMap;
        }

        List<Account> accList = (List<Account>) Database.query(String.escapeSingleQuotes(query));
        for(Account acc : accList) {
            keyAccountIdMap.put(acc.Id, acc.Id);
            if(String.isNotBlank(acc.PrimaryEmail__c)) {
                keyAccountIdMap.put(acc.PrimaryEmail__c, acc.Id);
            }
            if(String.isNotBlank(acc.IdentityNumber__c)) {
                keyAccountIdMap.put(acc.IdentityNumber__c, acc.Id);
            }
        }

        return keyAccountIdMap;
    }


    /**
     * CheckAccountByKeys.
     *
     * @param accountId the account id
     * @param primaryEmail the primary email
     * @param identityNumber the identity number
     * @return voucher list
     * @description method to get Vouchers
     */
    public static List<XC_Voucher__c> getVouchers(XC_REST_CheckCoupon_W.WrapperRequestElement requestElement) {

        String legalEntity = requestElement.LegalEntity;
        String recordTypeName = requestElement.RecordTypeName;
        String status = requestElement.Status;
        String externalStatus = requestElement.ExternalStatus;
        Decimal limitRow = requestElement.LimitRow;

        Id recordTypeId = (Schema.SObjectType.XC_Voucher__c.getRecordTypeInfosByName().get(recordTypeName) != null) ? Schema.SObjectType.XC_Voucher__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId() : null;
        if(recordTypeId == null) {
            return new List<XC_Voucher__c>();
        }

        String query = 'SELECT Id, XC_Account__c, XC_Status__c, XC_Usage_Counter__c, XC_Uses__c, XC_VoucherCode__c, XC_Amount__c, XC_Type_of_Discount__c, ' +
                            'XC_StartDate__c, XC_EndDate__c, XC_SalesChannel__c, Name, XC_Product__c, XC_ProductCategory__c, XC_Billing_Model__c, ' +
                            'XC_PurseExpirationMonths__c, XC_PurseExpirationDate__c, XC_NumberOfQuotas__c, XC_UnitOfMeasure__c, XC_FinalDiscount__c, ' +
                            'XC_Threshold__c, XC_ProductsCompatibleFamily__c, XC_IdentityNumber__c, XC_PodPdr__c, XC_CategoryName__c, ' +
                            'XC_ExternalProductName__c, XC_ExternalStatus__c, XC_ExternalMessage__c, XC_Order__r.Name, ' +
                            'XC_Order__r.NE__OptyId__r.XC_Address__c, XC_Order__r.NE__OptyId__r.XC_Address__r.XC_StreetTypeText__c, ' +
                            'XC_Order__r.NE__OptyId__r.XC_Address__r.XC_Address__c, XC_Order__r.NE__OptyId__r.XC_Address__r.XC_StreetNumber__c, ' +
                            'XC_Order__r.NE__OptyId__r.XC_Address__r.XC_PostalCode__c, XC_Order__r.NE__OptyId__r.XC_Address__r.XC_City__c, ' +
                            'XC_Order__r.NE__OptyId__r.XC_Address__r.XC_AddressCountry__c, XC_Order__r.NE__OptyId__r.XC_Address__r.XC_Category__c, ' +
                            'XC_Order__r.NE__OptyId__r.XC_Address__r.XC_Stair__c, XC_Order__r.NE__OptyId__r.XC_Address__r.XC_Floor__c, ' +
                            'XC_Order__r.NE__OptyId__r.XC_Address__r.XC_Door__c, XC_Order__r.NE__OptyId__r.XC_Address__r.XC_AddressProvince__c, ' +
                            'XC_Order__r.NE__OptyId__r.XC_Address__r.XC_DeliveryAddress__c, XC_Order__r.NE__OptyId__r.XC_Address__r.XC_InstallationAddress__c, ' +
                            'XC_Order__r.NE__OptyId__r.XC_Address__r.XC_BillingAddress__c, XC_Order__r.NE__OptyId__r.XC_Address__r.XC_Municipality__c, ' +
                            'XC_Order__r.NE__OptyId__r.XC_Address__r.XC_ClarificatorType__c, XC_Order__r.NE__OptyId__r.XC_Address__r.XC_ClarificatorValue__c, ' +
                            'XC_Order__r.NE__OptyId__r.XC_Address__r.XC_AddressValidated__c, XC_Order__r.NE__OptyId__r.XC_Address__r.XC_Region__c, ' +
                            '(SELECT Id, XC_Account__c FROM Voucher_Utilization__r) ' +
                        'FROM XC_Voucher__c ' +
                        'WHERE XC_LegalEntity__c =: legalEntity AND RecordTypeId =: recordTypeId AND XC_RecordTypeName__c =: recordTypeName';
        query += (String.isNotBlank(status)) ? ' AND XC_Status__c =: status' : '';
        query += (String.isNotBlank(externalStatus)) ? ' AND XC_ExternalStatus__c =: externalStatus' : '';
        query += (limitRow == null) ? ' ORDER BY CreatedDate desc' : ' ORDER BY CreatedDate desc LIMIT ' + limitRow;
        query = String.escapeSingleQuotes(query);
        
        return ((List<XC_Voucher__c>) Database.query(query));
    }


    /**
     * ManageSpecificAccountPUT.
     *
     * @param voucher the voucher
     * @param wrElementResp the wrapper response
     * @description method to manage the voucher with a Specific Account for PUT method
     */
    public static void manageSpecificAccountPUT(XC_Voucher__c voucher, XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrElementResp) {

        XC_Voucher__c voucherToUpdate = new XC_Voucher__c();
        voucherToUpdate.Id = voucher.Id;
        voucherToUpdate.XC_Usage_Counter__c = voucher.XC_Usage_Counter__c + 1;
        voucherToUpdate.XC_ExternalStatus__c = voucher.XC_ExternalStatus__c;
        if(voucher.XC_PurseExpirationDate__c == null && voucher.XC_PurseExpirationMonths__c != null){
            voucherToUpdate.XC_PurseExpirationDate__c = Date.today().addMonths(Integer.valueOf(voucher.XC_PurseExpirationMonths__c));
            voucher.XC_PurseExpirationDate__c = Date.today().addMonths(Integer.valueOf(voucher.XC_PurseExpirationMonths__c));
        }
        if(voucher.XC_Uses__c - voucherToUpdate.XC_Usage_Counter__c == 0) {
            voucherToUpdate.XC_Status__c = 'Burnt';
        }

        wrElementResp.voucherToUpdate = voucherToUpdate;

        voucher.XC_Usage_Counter__c = voucherToUpdate.XC_Usage_Counter__c;
        XC_REST_CheckCoupon_U.createResponseSpecificAccount(voucher, 'PUT', wrElementResp);
    }


    /**
     * ManageNOspecificAccountPUT.
     *
     * @param voucher the voucher
     * @param acc the account
     * @param wrResp the wrapper response
     * @description method to manage the voucher without a Specific Account for PUT method
     */
    public static void manageNOspecificAccountPUT(XC_Voucher__c voucher, String accountId, XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrElementResp) {

        for(XC_VoucherUtilization__c voucherUtil : voucher.Voucher_Utilization__r) {
            if(voucherUtil.XC_Account__c == accountId) {
                wrElementResp.outcome = 'KO';
                wrElementResp.outcomeCode = 'EMOB003';
                wrElementResp.outcomeDescription = Label.XC_CL_Coupon_ErrorActivate;
                wrElementResp.logError = wrElementResp.outcomeDescription;
                return;
            }
        }

        XC_VoucherUtilization__c utilization = new XC_VoucherUtilization__c();
        utilization.XC_Account__c = accountId;
        utilization.XC_Voucher__c = voucher.Id;
        wrElementResp.utilizationToInsert = utilization;

        XC_Voucher__c voucherToUpdate = new XC_Voucher__c();
        voucherToUpdate.Id = voucher.Id;
        voucherToUpdate.XC_Usage_Counter__c = voucher.XC_Usage_Counter__c + 1;
        voucherToUpdate.XC_ExternalStatus__c = voucher.XC_ExternalStatus__c;
        if(voucher.XC_Uses__c - voucherToUpdate.XC_Usage_Counter__c == 0) {
            voucherToUpdate.XC_Status__c = 'Burnt';
        }
        wrElementResp.voucherToUpdate = voucherToUpdate;

        wrElementResp.outcome = 'OK';
        wrElementResp.outcomeCode = 'EMOB005';
        wrElementResp.outcomeDescription = Label.XC_CL_Coupon_Associated;
        wrElementResp.logError = wrElementResp.outcomeDescription;
        wrElementResp.CouponCode = voucher.XC_VoucherCode__c;
        wrElementResp.isActive = true;
        wrElementResp.name = voucher.Name;
        wrElementResp.catalogItem = voucher.XC_Product__c;
        wrElementResp.catalogCategory = voucher.XC_ProductCategory__c;
        wrElementResp.paymentModel = voucher.XC_Billing_Model__c;
        wrElementResp.counter = String.valueOf(voucher.XC_Uses__c - voucherToUpdate.XC_Usage_Counter__c);
        wrElementResp.value = String.valueOf(voucher.XC_Amount__c);
        wrElementResp.couponType = voucher.XC_Type_of_Discount__c;
        wrElementResp.sellingChannel = voucher.XC_SalesChannel__c;
        wrElementResp.startDate = String.valueOf(voucher.XC_StartDate__c);
        wrElementResp.endDate = (voucher.XC_PurseExpirationDate__c != null) ? String.valueOf(voucher.XC_PurseExpirationDate__c) : (voucher.XC_PurseExpirationMonths__c != null) ? String.valueOf(Date.today().addMonths(Integer.valueOf(voucher.XC_PurseExpirationMonths__c))) : String.valueOf(voucher.XC_EndDate__c);
        wrElementResp.sellingChannel = voucher.XC_SalesChannel__c;
        wrElementResp.CouponFamily = String.valueOf(voucher.XC_ProductsCompatibleFamily__c);
    }


    /**
     * ManageActiveCoupon.
     *
     * @param parameters the params map
     * @param voucherList the voucher list
     * @param wrResp the wrapper response
     * @description method to manage active coupon
     */
    public static Boolean checkAccountParameters(Map<String, String> parameters) {

        if (String.isBlank(parameters.get('AccountID')) && String.isBlank(parameters.get('PrimaryEmail')) && String.isBlank(parameters.get('IdentityNumber'))) {
            return false;
        }
        
        return true;
    }

}