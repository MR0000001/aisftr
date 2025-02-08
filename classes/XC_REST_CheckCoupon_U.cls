/**
 * The Class XC_REST_CheckCoupon_U.
 *
 * @author            : Federico Amici federico.amici@nttdata.com
 * @date Creation     : 12/12/2018
 * @date Modification : 26/04/2019 by Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @description       : Util class for Rest Resource for Check Coupon/Voucher
 **/

        
public without sharing class XC_REST_CheckCoupon_U {


        /**
         * Manage Coupon.
         *
         * @param parameters the params map
         * @param wrResp the wrapper response
         * @description method to manage coupon
         */
        public static void checkCouponGET(Map<String, String> parameters, XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrResp) {
                
                XC_REST_CheckCoupon_D.UtilWrapper utilWr = XC_REST_CheckCoupon_D.checkSetKeys(new Map<String, Set<String>>{'couponCodeSet' => new Set<String>{parameters.get('couponCode')},
                                                                                                                        'accountIdSet' => (String.isNotBlank(parameters.get('AccountID'))) ? new Set<String>{parameters.get('AccountID')} : new Set<String>{},
                                                                                                                        'emailSet' => (String.isNotBlank(parameters.get('PrimaryEmail'))) ? new Set<String>{parameters.get('PrimaryEmail')} : new Set<String>{},
                                                                                                                        'identityNumberSet' => (String.isNotBlank(parameters.get('IdentityNumber'))) ? new Set<String>{parameters.get('IdentityNumber')} : new Set<String>{}});
                parameters.put('codeVoucherMap', JSON.serialize(utilWr.codeVoucherMap));
                parameters.put('keyAccountIdMap', JSON.serialize(utilWr.keyAccountIdMap));

                manageCoupon(parameters, wrResp);
        }


        /**
         * ManageCoupon.
         *
         * @param parameters the params map
         * @param voucherList the voucher list
         * @param wrElementResp the wrapper response
         * @description method to manage active coupon
         */
        public static void manageCoupon(Map<String, String> parameters, XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrElementResp) {

                String couponCode = parameters.get('couponCode');
                Map<String, XC_Voucher__c> codeVoucherMap = (Map<String, XC_Voucher__c>) JSON.deserialize(parameters.get('codeVoucherMap'), Map<String, XC_Voucher__c>.class);
                
                if(codeVoucherMap.containsKey(couponCode)) {
                                
                        XC_Voucher__c coupon = codeVoucherMap.get(couponCode);
                        wrElementResp.CouponCode = couponCode;

                        if(coupon.XC_Status__c == 'Active' && coupon.XC_StartDate__c <= Date.Today() && coupon.XC_EndDate__c >= Date.Today()) {
                                
                                wrElementResp.isActive = true;

                                manageActiveCoupon(parameters, coupon, wrElementResp);

                        } else {
                                wrElementResp.outcome = 'KO';
                                wrElementResp.outcomeCode = 'EMOB001';
                                wrElementResp.outcomeDescription = Label.XC_CL_Coupon_CodeNotValid + ' \'' + couponCode + '\'';
                                wrElementResp.logError = wrElementResp.outcomeDescription;
                        }

                } else {
                        wrElementResp.outcome = 'KO';
                        wrElementResp.outcomeCode = 'EMOB001';
                        wrElementResp.outcomeDescription = Label.XC_CL_Coupon_CodeNotValid + ' \'' + couponCode + '\'';
                        wrElementResp.couponCode = couponCode;
                        wrElementResp.logError = wrElementResp.outcomeDescription;
                }

        }


        /**
         * ManageActiveCoupon.
         *
         * @param parameters the params map
         * @param voucherList the voucher list
         * @param wrElementResp the wrapper response
         * @description method to manage active coupon
         */
        public static void manageActiveCoupon(Map<String, String> parameters, XC_Voucher__c voucher, XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrElementResp) {

                String method = parameters.get('method');
                String accountId = parameters.get('AccountID');
                String primaryEmail = parameters.get('PrimaryEmail');
                String identityNumber = parameters.get('IdentityNumber');
                String externalStatus = parameters.get('ExternalStatus');

                if(voucher.XC_Usage_Counter__c < voucher.XC_Uses__c) {
                        
                        if(!XC_REST_CheckCoupon_D.checkAccountParameters(parameters)) { // Nel caso in cui non ci siano parametri dell'Account (ci troviamo nella GET/POST)
                                createResponseSpecificAccount(voucher, method, wrElementResp);
                                return;
                        }

                        Map<String, Id> keyAccountIdMap = (Map<String, Id>) JSON.deserialize(parameters.get('keyAccountIdMap'), Map<String, Id>.class);
                        String foundAccountID = '';
                        if(String.isNotBlank(accountId)) {
                                foundAccountID = keyAccountIdMap.get(accountId);
                        } else if(String.isNotBlank(primaryEmail)) {
                                foundAccountID = keyAccountIdMap.get(primaryEmail);
                        } else if(String.isNotBlank(identityNumber)) {
                                foundAccountID = keyAccountIdMap.get(identityNumber);
                        }

                        if(String.isBlank(foundAccountId)) {
                                wrElementResp.outcome = 'KO';
                                wrElementResp.outcomeDescription = Label.XC_CL_Account_NotValid;
                                wrElementResp.outcomeCode = 'EMOB002';
                                wrElementResp.logError = wrElementResp.outcomeDescription;
                                return;
                        }

                        wrElementResp.AccountID = foundAccountId;

                        wrElementResp.outcome = method;
                        voucher.XC_ExternalStatus__c = String.isNotBlank(externalStatus) ? externalStatus : voucher.XC_ExternalStatus__c;
                        manageActiveCouponPlusOne(foundAccountId, voucher, wrElementResp);

                } else {
                        wrElementResp.outcome = 'KO';
                        wrElementResp.outcomeCode = (method == 'GET' || method == 'POST') ? 'EMOB001' : 'EMOB004';
                        wrElementResp.outcomeDescription = (method == 'GET' || method == 'POST') ? Label.XC_CL_Coupon_CodeNotValid+' \''+voucher.XC_VoucherCode__c+'\'' : Label.XC_CL_Voucher_MaxUses;
                        wrElementResp.logError = wrElementResp.outcomeDescription;
                        return;
                }
        }


        /**
         * ManageActiveCouponPlus.
         *
         * @param acc the account
         * @param voucher the voucher
         * @param wrResp the wrapper response
         * @description method to manage active coupon
         */
        public static void manageActiveCouponPlusOne(String accountId, XC_Voucher__c voucher, XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrElementResp) {
                
                String method = wrElementResp.outcome;

                System.debug('##specif account' + voucher.XC_Account__c);
                if(String.isNotBlank(voucher.XC_Account__c) && voucher.XC_Account__c != accountId) {
                        // With Specific Account but not equal to Account in input
                        wrElementResp.outcome = 'KO';
                        wrElementResp.outcomeCode = (method == 'GET' || method == 'POST') ? 'EMOB002' : 'EMOB003';
                        wrElementResp.outcomeDescription = (method == 'GET' || method == 'POST') ? Label.XC_CL_Account_NotValid : Label.XC_CL_Coupon_ErrorActivate;
                        wrElementResp.logError = wrElementResp.outcomeDescription;
                        return;
                        
                } else {
                        wrElementResp.outcome = method;
                        manageActiveCouponPlusTwo(accountId, voucher, wrElementResp);
                }
        }


        /**
         * ManageActiveCouponPlus.
         *
         * @param acc the account
         * @param voucher the voucher
         * @param wrElementResp the wrapper response
         * @description method to manage active coupon
         * @return the Wrapper CheckCouponResponse
         */
        public static XC_REST_CheckCoupon_W.WrapperCheckCouponResponse manageActiveCouponPlusTwo(String accountId, XC_Voucher__c voucher, XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrElementResp) {
                
                String method = wrElementResp.outcome;

                if (String.isNotBlank(voucher.XC_Account__c) && voucher.XC_Account__c == accountId) {
                        // With Specific Account and equal to Account in input
                        
                        if(method == 'GET' || method == 'POST') {     // GET - POST
                                createResponseSpecificAccount(voucher, method, wrElementResp);

                        } else {        // PUT
                                XC_REST_CheckCoupon_D.manageSpecificAccountPUT(voucher, wrElementResp);
                        }
                        
                } else {
                        // Without Specific Account

                        if(method == 'GET' || method == 'POST') {     // GET - POST
                                manageNOspecificAccountGET(voucher, accountId, wrElementResp);

                        } else {        // PUT
                                XC_REST_CheckCoupon_D.manageNOspecificAccountPUT(voucher, accountId, wrElementResp);
                        }
                }

                return wrElementResp;
        }


        /**
         * CreateResponseSpecificAccount.
         *
         * @param voucher the voucher
         * @param method the http method
         * @param wrElementResp the wrapper response
         * @description method to create the wrapper response for a Specific Account
         */
        public static void createResponseSpecificAccount(XC_Voucher__c voucher, String method, XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrElementResp) {

                wrElementResp.outcome = 'OK';
                wrElementResp.outcomeCode = (method == 'GET' || method == 'POST') ? 'EMOB000' : 'EMOB005';
                wrElementResp.outcomeDescription = (method == 'GET' || method == 'POST') ? Label.XC_CL_Coupon_CodeOK : Label.XC_CL_Coupon_Associated;
                wrElementResp.logError = wrElementResp.outcomeDescription;
                wrElementResp.CouponCode = voucher.XC_VoucherCode__c;
                wrElementResp.isActive = true;
                wrElementResp.name = voucher.Name;
                wrElementResp.catalogItem = voucher.XC_Product__c;
                wrElementResp.catalogCategory = voucher.XC_ProductCategory__c;
                wrElementResp.paymentModel = voucher.XC_Billing_Model__c;
                wrElementResp.counter = (voucher.XC_Uses__c != null && voucher.XC_Usage_Counter__c != null) ? String.valueOf(voucher.XC_Uses__c - voucher.XC_Usage_Counter__c) : null;
                wrElementResp.value = String.valueOf(voucher.XC_Amount__c);
                wrElementResp.couponType = voucher.XC_Type_of_Discount__c;
                wrElementResp.sellingChannel = voucher.XC_SalesChannel__c;
                wrElementResp.startDate = String.valueOf(voucher.XC_StartDate__c);
                wrElementResp.endDate = (voucher.XC_PurseExpirationDate__c != null) ? String.valueOf(voucher.XC_PurseExpirationDate__c) : (voucher.XC_PurseExpirationMonths__c != null) ? String.valueOf(Date.today().addMonths(Integer.valueOf(voucher.XC_PurseExpirationMonths__c))) : String.valueOf(voucher.XC_EndDate__c);
                wrElementResp.Duration = integer.valueOf(voucher.XC_NumberOfQuotas__c);
                wrElementResp.FinalPrice = integer.valueOf(voucher.XC_FinalDiscount__c);
                wrElementResp.UnitOfMeasure = voucher.XC_UnitOfMeasure__c;
                wrElementResp.Threshold = voucher.XC_Threshold__c;
                wrElementResp.CouponFamily = String.valueOf(voucher.XC_ProductsCompatibleFamily__c);
                wrElementResp.IdentityNumber = voucher.XC_IdentityNumber__c;
                wrElementResp.PodPdr = voucher.XC_PodPdr__c;
                wrElementResp.CategoryName = voucher.XC_CategoryName__c;
                wrElementResp.ExternalProductName = voucher.XC_ExternalProductName__c;
                wrElementResp.OrderNumber = voucher.XC_Order__r.Name;
                wrElementResp.ExternalStatus = voucher.XC_ExternalStatus__c;
                wrElementResp.ExternalMessage = voucher.XC_ExternalMessage__c;
        }


        /**
         * ManageNOspecificAccountGET.
         *
         * @param voucher the voucher
         * @param acc the account
         * @param wrElementResp the wrapper response
         * @description method to manage the voucher without a Specific Account for GET method
         */
        public static void manageNOspecificAccountGET(XC_Voucher__c voucher, String accountId, XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrElementResp) {

                for(XC_VoucherUtilization__c voucherUtil : voucher.Voucher_Utilization__r) {
                        if(voucherUtil.XC_Account__c == accountId) {
                                wrElementResp.outcome = 'KO';
                                wrElementResp.outcomeDescription = Label.XC_CL_Coupon_CodeNotValid + ' \'' + voucher.XC_VoucherCode__c + '\'';
                                wrElementResp.outcomeCode = 'EMOB001';
                                wrElementResp.logError = wrElementResp.outcomeDescription;
                                return;
                        }
                }

                wrElementResp.outcome = 'OK';
                wrElementResp.outcomeCode = 'EMOB000';
                wrElementResp.outcomeDescription = Label.XC_CL_Coupon_CodeOK;
                wrElementResp.logError = wrElementResp.outcomeDescription;
                wrElementResp.CouponCode = voucher.XC_VoucherCode__c;
                wrElementResp.isActive = true;
                wrElementResp.name = voucher.Name;
                wrElementResp.catalogItem = voucher.XC_Product__c;
                wrElementResp.catalogCategory = voucher.XC_ProductCategory__c;
                wrElementResp.paymentModel = voucher.XC_Billing_Model__c;
                wrElementResp.counter = String.valueOf(voucher.XC_Uses__c - voucher.XC_Usage_Counter__c);
                wrElementResp.value = String.valueOf(voucher.XC_Amount__c);
                wrElementResp.couponType = voucher.XC_Type_of_Discount__c;
                wrElementResp.sellingChannel = voucher.XC_SalesChannel__c;
                wrElementResp.startDate = String.valueOf(voucher.XC_StartDate__c);
                wrElementResp.endDate = (voucher.XC_PurseExpirationDate__c != null) ? String.valueOf(voucher.XC_PurseExpirationDate__c) : (voucher.XC_PurseExpirationMonths__c != null) ? String.valueOf(Date.today().addMonths(Integer.valueOf(voucher.XC_PurseExpirationMonths__c))) : String.valueOf(voucher.XC_EndDate__c);
                wrElementResp.Duration = integer.valueOf(voucher.XC_NumberOfQuotas__c);
                wrElementResp.FinalPrice = integer.valueOf(voucher.XC_FinalDiscount__c);
                wrElementResp.UnitOfMeasure = XC_UTIL_Integration_U.convertFromStringToPicklist(voucher.XC_UnitOfMeasure__c);
                wrElementResp.Threshold = integer.valueOf(voucher.XC_Threshold__c);
                wrElementResp.CouponFamily = String.valueOf(voucher.XC_ProductsCompatibleFamily__c);
                wrElementResp.IdentityNumber = voucher.XC_IdentityNumber__c;
                wrElementResp.PodPdr = voucher.XC_PodPdr__c;
                wrElementResp.CategoryName = voucher.XC_CategoryName__c;
                wrElementResp.ExternalProductName = voucher.XC_ExternalProductName__c;
                wrElementResp.OrderNumber = voucher.XC_Order__r.Name;
                wrElementResp.ExternalStatus = voucher.XC_ExternalStatus__c;
                wrElementResp.ExternalMessage = voucher.XC_ExternalMessage__c;
        }


        /**
         * Manage Coupon POST/PUT.
         *
         * @param wrReq the wrapper request
         * @param wrResp the wrapper response
         * @param method the http method
         * @description method to manage coupon
         */
        public static void checkCouponPostPut(XC_REST_CheckCoupon_W.WrapperCheckCouponRequest wrReq, XC_REST_CheckCoupon_W.WrapperResponse wrResp, String method) {
                
                Set<String> couponCodeSet = new Set<String>();
                Set<String> accountIdSet = new Set<String>();
                Set<String> emailSet = new Set<String>();
                Set<String> identityNumberSet = new Set<String>();
                for(XC_REST_CheckCoupon_W.WrapperRequestElement wrElement : wrReq.requestElement) {

                        if(method == 'PUT' && couponCodeSet.contains(wrElement.CouponCode)) {
                                XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrElementResp = new XC_REST_CheckCoupon_W.WrapperCheckCouponResponse();
                                wrElementResp.outcome = 'KO';
                                wrElementResp.outcomeCode = '500';
                                wrElementResp.outcomeDescription = 'ERROR. Coupon Code \'' + wrElement.CouponCode + '\' is present several times in the request';
                                wrElementResp.logError = null;
                                wrResp.logError = wrElementResp.outcomeDescription;
                                wrResp.errorCode = '400';
                                wrResp.counterError++;
                                wrElementResp.couponCode = wrElement.CouponCode;
                                wrResp.responseElement.add(wrElementResp);
                                return;
                        }

                        couponCodeSet.add(wrElement.CouponCode);
                        if(String.isNotBlank(wrElement.AccountID)) {
                                accountIdSet.add(wrElement.AccountID);
                        }
                        if(String.isNotBlank(wrElement.PrimaryEmail)) {
                                emailSet.add(wrElement.PrimaryEmail);
                        }
                        if(String.isNotBlank(wrElement.IdentityNumber)) {
                                identityNumberSet.add(wrElement.IdentityNumber);
                        }
                }
                
                XC_REST_CheckCoupon_D.UtilWrapper utilWr = XC_REST_CheckCoupon_D.checkSetKeys(new Map<String, Set<String>>{'couponCodeSet' => couponCodeSet,
                                                                                                                                'accountIdSet' => accountIdSet,
                                                                                                                                'emailSet' => emailSet,
                                                                                                                                'identityNumberSet' => identityNumberSet});
                Map<String, XC_Voucher__c> codeVoucherMap = utilWr.codeVoucherMap;
                Map<String, Id> keyAccountIdMap = utilWr.keyAccountIdMap;

                List<XC_Voucher__c> vouchersToUpdate = new List<XC_Voucher__c>();
                Map<Id, XC_VoucherUtilization__c> utilizationsToInsert = new Map<Id, XC_VoucherUtilization__c>();
                Map<String, Integer> voucherIdCounterMap = new Map<String, Integer>();
                Integer i = 0;
                for(XC_REST_CheckCoupon_W.WrapperRequestElement wrElement : wrReq.requestElement) {

                        XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrElementResp = new XC_REST_CheckCoupon_W.WrapperCheckCouponResponse();

                        Map<String, String> parameters = new Map<String, String>{'method' => method,
                                                                                'couponCode' => wrElement.couponCode,
                                                                                'AccountID' => wrElement.AccountID,
                                                                                'PrimaryEmail' => wrElement.PrimaryEmail,
                                                                                'IdentityNumber' => wrElement.IdentityNumber,
                                                                                'ExternalStatus' => wrElement.ExternalStatus,
                                                                                'codeVoucherMap' => JSON.serialize(codeVoucherMap),
                                                                                'keyAccountIdMap' => JSON.serialize(keyAccountIdMap)};
                        manageCoupon(parameters, wrElementResp);
                        
                        if(wrElementResp.voucherToUpdate != null) {
                                vouchersToUpdate.add(wrElementResp.voucherToUpdate);
                                voucherIdCounterMap.put(wrElementResp.voucherToUpdate.Id, i);
                                wrElementResp.voucherToUpdate = null;
                        }
                        if(wrElementResp.utilizationToInsert != null) {
                                utilizationsToInsert.put(wrElementResp.utilizationToInsert.XC_Voucher__c, wrElementResp.utilizationToInsert);
                                wrElementResp.utilizationToInsert = null;
                        }

                        if(wrElementResp.outcome == 'KO') {
                                wrResp.logError = wrElementResp.logError;
                                wrResp.errorCode = (wrElementResp.outcomeCode == 'EMOB001' || wrElementResp.outcomeCode == 'EMOB002' || wrElementResp.outcomeCode == 'EMOB003' || wrElementResp.outcomeCode == 'EMOB004') ? '400' : wrElementResp.outcomeCode;
                                wrResp.counterError++;

                                wrElementResp.isActive = null;
                                wrElementResp.counter = null;
                                wrElementResp.value = null;
                                wrElementResp.couponType = null;
                                wrElementResp.sellingChannel = null;
                                wrElementResp.startDate = null;
                                wrElementResp.catalogItem = null;
                                wrElementResp.catalogCategory = null;
                                wrElementResp.name = null;
                        }
                        wrElementResp.logError = null;
                        wrElementResp.FinalPrice = null;
                        wrElementResp.UnitOfMeasure = null;
                        wrElementResp.Threshold = null;
                        
                        wrResp.responseElement.add(wrElementResp);
                        i++;
                }

                if(!vouchersToUpdate.isEmpty()) {
                        List<XC_UTIL_Sobject.WrapperResult> voucherRes = XC_UTIL_DML.updateRecords(vouchersToUpdate, false);
                        for(XC_UTIL_Sobject.WrapperResult result : voucherRes) {
                                if(!result.success) {
                                        wrResp.responseElement[voucherIdCounterMap.get(result.errorObjectId)].outcome = 'KO';
                                        wrResp.responseElement[voucherIdCounterMap.get(result.errorObjectId)].outcomeCode = '500';
                                        wrResp.responseElement[voucherIdCounterMap.get(result.errorObjectId)].outcomeDescription = 'ERROR. ' + result.errorMessage;
                                        wrResp.responseElement[voucherIdCounterMap.get(result.errorObjectId)].logError = 'ERROR. ' + result.errorMessage;
                                        utilizationsToInsert.remove(result.errorObjectId);
                                }
                        }
                }
                if(!utilizationsToInsert.isEmpty()) {
                        XC_UTIL_DML.insertRecords(utilizationsToInsert.values(), false);
                }
        }


        /**
         * Check Coupon ReadBulk.
         *
         * @param wrReq the wrapper request
         * @param wrResp the wrapper response
         * @description method to get coupons
         */
        public static void checkCouponReadBulk(XC_REST_CheckCoupon_W.WrapperCheckCouponRequest wrReq, XC_REST_CheckCoupon_W.WrapperResponse wrResp) {

                List<XC_Voucher__c> vouchersList = XC_REST_CheckCoupon_D.getVouchers(wrReq.requestElement[0]);

                if(vouchersList.isEmpty()) {
                        XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrElementResp = new XC_REST_CheckCoupon_W.WrapperCheckCouponResponse();
                        wrElementResp.outcome = 'KO';
                        wrElementResp.outcomeCode = '400';
                        wrElementResp.outcomeDescription = 'ERROR. No coupons available';
                        wrElementResp.logError = null;
                        wrResp.logError = wrElementResp.outcomeDescription;
                        wrResp.errorCode = '400';
                        wrResp.counterError++;
                        wrResp.responseElement.add(wrElementResp);
                        return;
                }

                for(XC_Voucher__c coupon : vouchersList) {
                        XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrElementResp = new XC_REST_CheckCoupon_W.WrapperCheckCouponResponse();
                        createResponseSpecificAccount(coupon, 'POST', wrElementResp);
                        wrElementResp.AccountID = coupon.XC_Account__c;
                        wrElementResp.isActive = (coupon.XC_Status__c == 'Active') ? true : false;
                        wrElementResp.outcome = (!wrElementResp.isActive) ? 'KO' : 'OK';
                        wrElementResp.outcomeDescription = (!wrElementResp.isActive) ? Label.XC_CL_Coupon_CodeNotValid : wrElementResp.outcomeDescription;
                        wrElementResp.outcomeCode = (!wrElementResp.isActive) ? 'EMOB001' : wrElementResp.outcomeCode;

                        if(wrElementResp.outcome == 'KO') {
                                wrResp.logError = wrElementResp.outcomeDescription;
                                wrResp.errorCode = (wrElementResp.outcomeCode == 'EMOB001' || wrElementResp.outcomeCode == 'EMOB002' || wrElementResp.outcomeCode == 'EMOB003' || wrElementResp.outcomeCode == 'EMOB004') ? '400' : wrElementResp.outcomeCode;
                                wrResp.counterError++;
                        }
                        wrElementResp.logError = null;
                        wrElementResp.FinalPrice = null;
                        wrElementResp.UnitOfMeasure = null;
                        wrElementResp.Threshold = null;

                        if(String.isNotBlank(coupon.XC_Order__r.NE__OptyId__r.XC_Address__c)) {
                                wrElementResp.Address = new XC_UTIL_Address.AddressWrapper();
                                wrElementResp.Address.AddressID = coupon.XC_Order__r.NE__OptyId__r.XC_Address__c;
                                wrElementResp.Address.StreetType = coupon.XC_Order__r.NE__OptyId__r.XC_Address__r.XC_StreetTypeText__c;
                                wrElementResp.Address.Address = coupon.XC_Order__r.NE__OptyId__r.XC_Address__r.XC_Address__c;
                                wrElementResp.Address.StreetNumber = coupon.XC_Order__r.NE__OptyId__r.XC_Address__r.XC_StreetNumber__c;
                                wrElementResp.Address.ZipCode = coupon.XC_Order__r.NE__OptyId__r.XC_Address__r.XC_PostalCode__c;
                                wrElementResp.Address.City = coupon.XC_Order__r.NE__OptyId__r.XC_Address__r.XC_City__c;
                                wrElementResp.Address.Country = coupon.XC_Order__r.NE__OptyId__r.XC_Address__r.XC_AddressCountry__c;
                                wrElementResp.Address.Category = coupon.XC_Order__r.NE__OptyId__r.XC_Address__r.XC_Category__c;
                                wrElementResp.Address.Stair = coupon.XC_Order__r.NE__OptyId__r.XC_Address__r.XC_Stair__c;
                                wrElementResp.Address.Floor = coupon.XC_Order__r.NE__OptyId__r.XC_Address__r.XC_Floor__c;
                                wrElementResp.Address.Door = coupon.XC_Order__r.NE__OptyId__r.XC_Address__r.XC_Door__c;
                                wrElementResp.Address.Province = coupon.XC_Order__r.NE__OptyId__r.XC_Address__r.XC_AddressProvince__c;
                                wrElementResp.Address.DeliveryAddress = coupon.XC_Order__r.NE__OptyId__r.XC_Address__r.XC_DeliveryAddress__c;
                                wrElementResp.Address.InstallationAddress = coupon.XC_Order__r.NE__OptyId__r.XC_Address__r.XC_InstallationAddress__c;
                                wrElementResp.Address.BillingAddress = coupon.XC_Order__r.NE__OptyId__r.XC_Address__r.XC_BillingAddress__c;
                                wrElementResp.Address.Municipality = coupon.XC_Order__r.NE__OptyId__r.XC_Address__r.XC_Municipality__c;
                                wrElementResp.Address.ClarifierType = coupon.XC_Order__r.NE__OptyId__r.XC_Address__r.XC_ClarificatorType__c;
                                wrElementResp.Address.ClarifierValue = coupon.XC_Order__r.NE__OptyId__r.XC_Address__r.XC_ClarificatorValue__c;
                                wrElementResp.Address.isPartner = null;
                                wrElementResp.Address.PickupPoint = null;
                                wrElementResp.Address.Warehouse = null;
                                wrElementResp.Address.PointOfSales = null;
                                wrElementResp.Address.AddressValidated = coupon.XC_Order__r.NE__OptyId__r.XC_Address__r.XC_AddressValidated__c;
                                wrElementResp.Address.Region = coupon.XC_Order__r.NE__OptyId__r.XC_Address__r.XC_Region__c;
                        }
                        
                        wrResp.responseElement.add(wrElementResp);
                }
        }

}