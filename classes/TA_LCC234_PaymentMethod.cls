public without sharing class TA_LCC234_PaymentMethod {

    public class InfoBag {
        @AuraEnabled
        public Id orderItemId {get; set;}
        @AuraEnabled
        public List<PicklistStructure> billingAddressList {get; set;}
        @AuraEnabled
        public List<PicklistStructure> paymentsAllowedList {get; set;}
        @AuraEnabled
        public BillingProfileWrapper billingProfileWrapper {get; set;}
        @AuraEnabled
        public List<NE__Billing_Profile__c> billingProfiles {get; set;}
        @AuraEnabled
        public Map<String, List<XC_BillingProfileLineItem__c>> billingProfileLineItemMap {get; set;}
    }

    // wrapper used for insert a new billing profile
    public class BillingProfileWrapper {
        @AuraEnabled
        public String AccountID {get; set;}
        @AuraEnabled
        public String OrderID {get; set;}
        @AuraEnabled
        public String InvoicePreferredLanguage {get; set;}
        @AuraEnabled
        public String PaymentMethod {get; set;}
        @AuraEnabled
        public String InvoiceDeliveryPref {get; set;}
        @AuraEnabled
        public String IBAN {get; set;}
        @AuraEnabled
        public String SEPAMandateType {get; set;}
        @AuraEnabled
        public String Action {get; set;}
        @AuraEnabled
        public String LegalEntity {get; set;}
        @AuraEnabled
        public String SEPABIC {get; set;}
        @AuraEnabled
        public String AddressID {get; set;}
        @AuraEnabled
        public String ContactID {get; set;}
        @AuraEnabled
        public String BillingProfileId {get; set;}
        @AuraEnabled
        public String BillingAddressID {get; set;}
        @AuraEnabled
        public String SoldAddressID {get; set;}
    }

    public class PicklistStructure {
        @AuraEnabled
        public String id {get; set;}
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public Boolean selected {get; set;}
    }

    @AuraEnabled
    public static String initialize(String workOrderSerialized) {
        InfoBag infoBag = new InfoBag();
        infoBag.billingAddressList = new List<PicklistStructure>();
        infobag.paymentsAllowedList = new List<PicklistStructure>();
        infoBag.billingProfileWrapper = new BillingProfileWrapper();
        infoBag.billingProfileLineItemMap = new Map<String, List<XC_BillingProfileLineItem__c>>();

        try {
            WorkOrder workOrder = (WorkOrder) JSON.deserialize(workOrderSerialized, WorkOrder.class);
            String parameters = workOrder.TA_Parameters__c;
            Map<String, Object> paramMap = (Map<String, Object>) JSON.deserializeUntyped(parameters);
            Id orderId;

            if(workOrder.XC_Configuration__c != null) {
                orderId = workOrder.XC_Configuration__c;
            } else if(paramMap.containsKey('quoteToAccept')) {
                orderId = String.valueOf(paramMap.get('quoteToAccept'));
            }

            if(orderId != null) {
                List<NE__Order__c> currentOrderList = [SELECT Id,
                                                            XC_LegalEntity__c,
                                                            NE__AccountId__c,
                                                            NE__AccountId__r.XC_Preference_Language__c,
                                                            XC_DeliveryAddress__c,
                                                            XC_OrderBillingAddress__c,
                                                            (SELECT XC_AllowablePaymentTypes__c
                                                                FROM NE__Order_Items__r
                                                                WHERE XC_PaymentMethodNeeded__c = true
                                                                    AND XC_HasBillingProfile__c = false
                                                                    AND XC_PaymentMethod__c != 'No Payment Required')
                                                        FROM NE__Order__c
                                                        WHERE Id = :orderId];

                if(currentOrderList.size() > 0) {
                    NE__Order__c currentOrd = currentOrderList[0];

                    //START FIX [20210706AL] - Retrieve billing profiles
                    infoBag.billingProfiles = [SELECT Id, Name, NE__Payment__c, NE__Iban__c, XC_MandateType__c 
                    FROM NE__Billing_Profile__c
                    WHERE NE__Account__c =:workOrder.AccountId];
                    //END FIX [20210706AL] - Retrieve billing profiles

                    infoBag.billingAddressList = retrieveBillingAddress(workOrder.AccountId, currentOrd.XC_OrderBillingAddress__c);
                    PicklistStructure paymentsAllowedEmpty = new PicklistStructure();
                    paymentsAllowedEmpty.id = null;
                    paymentsAllowedEmpty.name = null;
                    paymentsAllowedEmpty.selected = true;
                    infobag.paymentsAllowedList.add(paymentsAllowedEmpty);

                    List<String> allowedPaymentSplitted = new List<String>();
                    if(currentOrd.NE__Order_Items__r.size() > 0) {
                        infoBag.orderItemId = currentOrd.NE__Order_Items__r[0].Id;
                        allowedPaymentSplitted.addAll(currentOrd.NE__Order_Items__r[0].XC_AllowablePaymentTypes__c.split(','));

                        for(String payment : allowedPaymentSplitted) {
                            PicklistStructure paymentsAllowed = new PicklistStructure();
                            paymentsAllowed.id = payment.trim();
                            paymentsAllowed.name = payment.trim();
                            paymentsAllowed.selected = false;
                            infobag.paymentsAllowedList.add(paymentsAllowed);
                        }
                    }

                    BillingProfileWrapper billingProfileWrapper = new BillingProfileWrapper();
                    billingProfileWrapper.AccountID = currentOrd.NE__AccountId__c;
                    billingProfileWrapper.OrderID = currentOrd.ID;
                    billingProfileWrapper.InvoicePreferredLanguage = currentOrd.NE__AccountId__r.XC_Preference_Language__c;
                    billingProfileWrapper.LegalEntity = currentOrd.XC_LegalEntity__c;
                    billingProfileWrapper.AddressID = workOrder.XC_Address__c;
                    billingProfileWrapper.ContactID = workOrder.ContactId;
                    infoBag.billingProfileWrapper = billingProfileWrapper;

                    if(currentOrd.XC_OrderBillingAddress__c != null) {
                        infoBag.billingProfileLineItemMap = retrieveBillingProfileLineItem(
                            infoBag.billingProfileWrapper.AccountID,
                            currentOrd.XC_OrderBillingAddress__c,
                            currentOrd.XC_DeliveryAddress__c,
                            infoBag.billingProfileWrapper.LegalEntity
                        );
                    }
                }
            }
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('TA_LCC234_PaymentMethod initialize - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC234_PaymentMethod', 'initialize', errorMessage, 0, errorMessage, null);
        }
        return JSON.serialize(infoBag);
    }

    @AuraEnabled
    public static List<PicklistStructure> retrieveBillingAddress(Id accountId, Id orderBillingAddress) {
        List<PicklistStructure> billingAddressList = new List<PicklistStructure>();
        try {
            List<XC_Address__c> accountAddressList = [SELECT Id, Name FROM XC_Address__c WHERE XC_Account__c = :accountId];

            if(orderBillingAddress == null) {
                PicklistStructure accountAddressMap = new PicklistStructure();
                accountAddressMap.id = null;
                accountAddressMap.name = null;
                accountAddressMap.selected = true;

                billingAddressList.add(accountAddressMap);
            }

            for(XC_Address__c accountAddress : accountAddressList) {
                PicklistStructure accountAddressMap = new PicklistStructure();
                accountAddressMap.id = accountAddress.Id;
                accountAddressMap.name = accountAddress.Name;
                Boolean selected = accountAddress.Id == orderBillingAddress ? true : false;
                accountAddressMap.selected = selected;

                billingAddressList.add(accountAddressMap);
            }
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('TA_LCC234_PaymentMethod retrieveBillingAddress - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC234_PaymentMethod', 'retrieveBillingAddress', errorMessage, 0, errorMessage, null);
        }
        return billingAddressList;
    }

    @AuraEnabled
    public static Map<String, List<XC_BillingProfileLineItem__c>> retrieveBillingProfileLineItem(Id accountId, Id billingAddressId, Id deliveryAddressId, String legalEntity) {
        Map<String, List<XC_BillingProfileLineItem__c>> billingProfileLineItemMap = new Map<String, List<XC_BillingProfileLineItem__c>>();
        try {
            List<XC_BillingProfileLineItem__c> billingProfileLineItemList = [SELECT Id,
                                                                                XC_MandateType__c,
                                                                                XC_BillingProfile__c,
                                                                                XC_BillingProfile__r.NE__Payment__c,
                                                                                XC_BillingProfile__r.NE__Iban__c
                                                                            FROM XC_BillingProfileLineItem__c
                                                                            WHERE XC_BillingProfile__r.NE__Account__c = :accountId
                                                                                AND XC_BillToAddress__c = :billingAddressId
                                                                                AND XC_SoldToAddress__c = :deliveryAddressId
                                                                                AND XC_Status__c IN ('Active','Waiting External Activation','Sent To Zuora')
                                                                                AND XC_LegalEntity__c = :legalEntity];

            for(XC_BillingProfileLineItem__c billingProfileLineItem : billingProfileLineItemList) {
                List<XC_BillingProfileLineItem__c> billProfileLineItemListByBillingProfile = new List<XC_BillingProfileLineItem__c>();
                if(billingProfileLineItemMap.containsKey(billingProfileLineItem.XC_BillingProfile__r.NE__Payment__c)) {
                    billProfileLineItemListByBillingProfile = billingProfileLineItemMap.get(billingProfileLineItem.XC_BillingProfile__r.NE__Payment__c);
                }
                billProfileLineItemListByBillingProfile.add(billingProfileLineItem);
                billingProfileLineItemMap.put(billingProfileLineItem.XC_BillingProfile__r.NE__Payment__c, billProfileLineItemListByBillingProfile);
            }
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('TA_LCC234_PaymentMethod retrieveBillingProfileLineItem - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC234_PaymentMethod', 'retrieveBillingProfileLineItem', errorMessage, 0, errorMessage, null);
        }
        return billingProfileLineItemMap;
    }

    @AuraEnabled
    public static String selectBillingAddress(String infoBagSerialized, Id addressId) {
        InfoBag infoBag = (InfoBag) JSON.deserialize(infoBagSerialized, InfoBag.class);
        try {
            List<NE__Order__c> currentOrderList = [SELECT Id,
                                                        XC_LegalEntity__c,
                                                        NE__AccountId__c,
                                                        XC_DeliveryAddress__c
                                                    FROM NE__Order__c
                                                    WHERE Id = :infoBag.billingProfileWrapper.OrderID];
            if(currentOrderList.size() > 0) {
                NE__Order__c currentOrd = currentOrderList[0];
                currentOrd.XC_OrderBillingAddress__c = addressId;
                update currentOrd;
    
                infoBag.billingAddressList = retrieveBillingAddress(
                    currentOrd.NE__AccountId__c,
                    currentOrd.XC_OrderBillingAddress__c
                );
    
                if(currentOrd.XC_OrderBillingAddress__c != null) {
                    infoBag.billingProfileLineItemMap = retrieveBillingProfileLineItem(
                        currentOrd.NE__AccountId__c,
                        currentOrd.XC_OrderBillingAddress__c,
                        currentOrd.XC_DeliveryAddress__c,
                        currentOrd.XC_LegalEntity__c
                    );
                }
            }
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('TA_LCC234_PaymentMethod selectBillingAddress - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC234_PaymentMethod', 'selectBillingAddress', errorMessage, 0, errorMessage, null);
        }
        return JSON.serialize(infoBag);
    }

    @AuraEnabled
    public static String insertBillingProfile(String bpWrapper) {
        System.debug('TA_LCC234_PaymentMethod: enter insertBillingProfile');
        try{
            List<String> paymentMethodListForFieldAction = new List<String>{'Bank Transfer', 'Credit Card', 'Direct Debt'};
            BillingProfileWrapper billingProfileWrapper = (BillingProfileWrapper) JSON.deserialize(bpWrapper, BillingProfileWrapper.class);
            XC_REST_Account_W.WrapperResponse wrResp = new XC_REST_Account_W.WrapperResponse();
            XC_REST_Account_W.WrapperRequest wrReq = new XC_REST_Account_W.WrapperRequest();
            wrReq.Account.AccountID = billingProfileWrapper.AccountID;
            wrReq.Address = null;
            XC_UTIL_BillingProfile.BillingProfileIFWrapper bp = new XC_UTIL_BillingProfile.BillingProfileIFWrapper();
            bp.PaymentMethod = billingProfileWrapper.PaymentMethod;
            bp.InvoicePreferredLanguage = billingProfileWrapper.InvoicePreferredLanguage;
            bp.InvoiceDeliveryPref = billingProfileWrapper.InvoiceDeliveryPref;
            bp.IBAN = billingProfileWrapper.IBAN;
            bp.SEPABIC =  billingProfileWrapper.SEPABIC;
            bp.SEPAMandateType = billingProfileWrapper.SEPAMandateType;
            bp.Action = paymentMethodListForFieldAction.contains(billingProfileWrapper.PaymentMethod) ? 'ToSendToPH': null;
            bp.LegalEntity = billingProfileWrapper.LegalEntity;

            //STAR FIX [20210706AL] - Manage External Financing
            bp.BillingProfileID = billingProfileWrapper.BillingProfileId;
            bp.BillingAddressID = billingProfileWrapper.BillingAddressID;
            bp.SoldAddressID = billingProfileWrapper.SoldAddressID;
            //END FIX [20210706AL] - Manage External Financing 
            
            wrReq.BillingProfile.add(bp);
            Map<String,String> mapHeader = new Map<String,String>{
                                    'ClientSystem' => 'XInstaller'			                   
                                };

            XC_REST_Account_U.manageUpdate(wrReq, wrResp, mapHeader);              
            return JSON.serialize(wrResp);
        }
        catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();           
            System.debug('TA_LCC234_PaymentMethod insertBillingProfile - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC234_PaymentMethod', 'insertBillingProfile', errorMessage, 0, errorMessage, null);
            return null;
        }
    }

    // @auraenabled
    // public static string updateorderitembillingprofile_old (string workorderid, string orderid, string orderitemid, string billingprofilelineitemid, string paymenttype, map<string, string> parameters) {
    //     system.savepoint savepoint = database.setsavepoint();
    //     xc_rest_order_u.wrapperres wrresp = new xc_rest_order_u.wrapperres();

    //     try {
    //         if(string.isnotblank(orderid) && string.isnotblank(orderitemid) && string.isnotblank(billingprofilelineitemid) && string.isnotblank(paymenttype)) {
    //             xc_rest_order_u.wrapperputrequest wrreq = new xc_rest_order_u.wrapperputrequest();
    //             ne__order__c ordertoupdate = [select recordtype.developername, xc_status__c,
    //                                                 (select id from ne__order_items__r where id = :orderitemid or ne__bundle_configuration__c = :orderitemid)
    //                                             from ne__order__c
    //                                             where id =: orderid];

    //             xc_util_order.orderifwrapper orderifwrapper = new xc_util_order.orderifwrapper();
    //             orderifwrapper.orderid = orderid;
    //             wrreq.order = orderifwrapper;

    //             for(ne__orderitem__c oi : ordertoupdate.ne__order_items__r) {
    //                 xc_util_order.orderitemwrapper orderitemwrapper = new xc_util_order.orderitemwrapper();
    //                 orderitemwrapper.orderitemid = oi.id;
    //                 orderitemwrapper.billingprofilelineitemid = billingprofilelineitemid;
    //                 orderitemwrapper.paymenttype = paymenttype;
    //                 wrreq.order.orderitem.add(orderitemwrapper);
    //             }

    //             map<string,string> header = new map<string,string> {
    //                 'clientsystem' => 'xinstaller',
    //                 'datetimemessage' => datetime.now().format('yyyymmddhhmmsssss'),
    //                 'transactionid' => 'acceptquote',
    //                 'operation' => 'update',
    //                 'functionality' => 'updateorder',
    //                 'serversystem' => 'xcustomerb2c'
    //             };

    //             map<string, object> maputil = new map<string, object> {
    //                 'header'=> header,
    //                 'wrreq' => wrreq,
    //                 'direction'=> 'inbound'
    //             };

    //             xc_util_integration.wrapperresult responsevalidation = xc_util_restinbound.checkobjectpermission('ne__order__c', 'update');
    //             if(responsevalidation.errorflag) {
    //                 wrresp.result.message = responsevalidation.errormessage;
    //                 wrresp.result.errorcode = '400';
    //             }

    //             map<string, list<ne__order_item_attribute__c>> maporditemidoia = new  map<string, list<ne__order_item_attribute__c>>();
    //             map<string, object> maporder = new map<string, object> {
    //                 'maporditemidoia'=> maporditemidoia,
    //                 'wrreq' => wrreq,
    //                 'clientsystem' => header.get('clientsystem')
    //             };


    //             system.debug('queries >>> ' + limits.getqueries());
    //             xc_rest_order_zz.checkconfigurationobjectsid(maporder, wrresp);

    //             responsevalidation = xc_rest_order_z.validatereq(maputil);
    //             if(responsevalidation.errorflag) {
    //                 wrresp.result.message = 'error. ' + responsevalidation.errormessage;
    //                 wrresp.result.errorcode = (responsevalidation.errorcode != '401' && responsevalidation.errorcode != '402') ? '400' : responsevalidation.errorcode;
    //                 wrresp.order = null;
    //             } else {
    //                 system.debug('queries 2 >>> ' + limits.getqueries());
    //                 xc_rest_order_u.updateorders(maporder, wrresp);

    //                 if(wrresp.result.errorcode == '0') {
    //                     wrreq.order.orderstatus = 'accepted';
    //                     map<string, object> maponlyorder = new map<string, object> {
    //                         'maporditemidoia'=> maporditemidoia,
    //                         'wrreq' => wrreq,
    //                         'clientsystem' => header.get('clientsystem')
    //                     };
    //                     system.debug('queries 3 >>> ' + limits.getqueries());
    //                     xc_rest_order_zz.checkconfigurationobjectsid(maponlyorder, wrresp);
    //                     system.debug('queries 4 >>> ' + limits.getqueries());
    //                     xc_rest_order_u.updateorders(maponlyorder, wrresp);
    //                     system.debug('queries 5 >>> ' + limits.getqueries());

    //                     update new user(id = userinfo.getuserid(), xc_enabledtoskip__c = true);    
    //                     update new workorder(id = workorderid, xc_configuration__c = wrresp.order.orderid);
    //                     update new user(id = userinfo.getuserid(), xc_enabledtoskip__c = false);    

    //                     if(wrresp.result.errorcode == '0') {
    //                         workorder wo = [select worktypeid,
    //                                             worktype.name,
    //                                             xc_legalentity__c,
    //                                             postalcode,
    //                                             country,
    //                                             xc_country__c,
    //                                             city,
    //                                             accountid,
    //                                             street,
    //                                             xc_configuration__c,
    //                                             contactid,
    //                                             xc_opportunity__c,
    //                                             xc_worktypelabel__c,
    //                                             xc_address__c 
    //                                         from workorder
    //                                         where id =: workorderid];

    //                         string worktypefromparameters = string.isnotblank(wo.worktypeid) ? parameters.get(wo.worktype.name): null;
    //                         system.debug('worktypefromparameters: ' + worktypefromparameters);
    //                         if(string.isnotblank(worktypefromparameters)) {
    //                             //xc_rest_workorder_w.wrapper wrrespsiteinspection = createsiteinspection(wo,worktypefromparameters);
    //                             createsiteinspection(json.serialize(wo), worktypefromparameters);
    //                             /*if (wrrespsiteinspection.result.errorcode == '500') {
    //                                 wrresp.result.message = wrrespsiteinspection.result.message;
    //                                 database.rollback(savepoint);
    //                             }*/
    //                         }
    //                     } else {
    //                         database.rollback(savepoint);
    //                     }
    //                 } else {
    //                     database.rollback(savepoint);
    //                 }
    //             }
    //             return json.serialize(wrresp);
    //         }
    //         return null;
    //     } catch (exception e) {
    //         string errormessage = 'an exception has occured : ' + e.getmessage() + ' ' + e.getlinenumber() + ' ' + e.getstacktracestring();
    //         system.debug('[ta_lcc234_paymentmethod] updateorderitembillingprofile - exception handler: ' + errormessage);
    //         ta_util_logmanagement.createlog('ta_lcc234_paymentmethod', 'updateorderitembillingprofile', errormessage, 0, errormessage, null);
    //         database.rollback(savepoint);
    //         wrresp.result.errorcode = '500';
    //         wrresp.result.message = errormessage;
    //         return json.serialize(wrresp);
    //     }
    // }

    @AuraEnabled
    public static String updateOrderItemBillingProfile(String workOrderId, String orderId, String orderItemId, String billingProfileLineItemId, String paymentType) {
        System.Savepoint savepoint = Database.setSavepoint();
        XC_REST_Order_U.WrapperRes wrResp = new XC_REST_Order_U.WrapperRes();
        Map<String, Object> resp_map = new Map<String, Object>();
        try {
            if(String.isNotBlank(orderId) && String.isNotBlank(orderItemId) && String.isNotBlank(billingProfileLineItemId) && String.isNotBlank(paymentType)) {
                XC_REST_Order_U.WrapperPUTRequest wrReq = new XC_REST_Order_U.WrapperPUTRequest();
                NE__Order__c orderToUpdate = [SELECT RecordType.DeveloperName, XC_Status__c,
                                                    (SELECT Id FROM NE__Order_Items__r WHERE Id = :orderItemId OR NE__Bundle_Configuration__c = :orderItemId)
                                                FROM NE__Order__c
                                                WHERE Id =: orderId];

                XC_UTIL_Order.OrderIFWrapper orderIfWrapper = new XC_UTIL_Order.OrderIFWrapper();
                orderIfWrapper.OrderID = orderId;
                wrReq.Order = orderIfWrapper;

                for(NE__OrderItem__c oi : orderToUpdate.NE__Order_Items__r) {
                    XC_UTIL_Order.OrderItemWrapper orderItemWrapper = new XC_UTIL_Order.OrderItemWrapper();
                    orderItemWrapper.OrderItemID = oi.Id;
                    orderItemWrapper.BillingProfileLineItemID = billingProfileLineItemId;
                    orderItemWrapper.PaymentType = paymentType;
                    wrReq.Order.OrderItem.add(orderItemWrapper);
                }

                Map<String,String> header = new Map<String,String> {
                    'ClientSystem' => 'XInstaller',
                    'DateTimeMessage' => DateTime.now().format('yyyyMMddHHmmssSSS'),
                    'TransactionID' => 'acceptQuote',
                    'Operation' => 'Update',
                    'Functionality' => 'UpdateOrder',
                    'ServerSystem' => 'XCustomerB2C'
                };

                Map<String, Object> mapUtil = new Map<String, Object> {
                    'header'=> header,
                    'wrReq' => wrReq,
                    'direction'=> 'Inbound'
                };

                XC_UTIL_Integration.WrapperResult responseValidation = XC_UTIL_RESTInbound.checkObjectPermission('NE__Order__c', 'update');
                if(responseValidation.errorFlag) {
                    wrResp.Result.Message = responseValidation.errorMessage;
                    wrResp.Result.ErrorCode = '400';
                }

                Map<String, List<NE__Order_Item_Attribute__c>> mapOrdItemIdOIA = new  Map<String, List<NE__Order_Item_Attribute__c>>();
                Map<String, Object> mapOrder = new Map<String, Object> {
                    'mapOrdItemIdOIA'=> mapOrdItemIdOIA,
                    'wrReq' => wrReq,
                    'clientSystem' => header.get('ClientSystem')
                };


                System.debug('queries >>> ' + Limits.getQueries());
                XC_REST_Order_ZZ.checkConfigurationObjectsId(mapOrder, wrResp);

                responseValidation = XC_REST_Order_Z.validateReq(mapUtil);
                if(responseValidation.errorFlag) {
                    wrResp.Result.Message = 'ERROR. ' + responseValidation.errorMessage;
                    wrResp.Result.ErrorCode = (responseValidation.errorCode != '401' && responseValidation.errorCode != '402') ? '400' : responseValidation.errorCode;
                    wrResp.Order = null;
                } else {
                    System.debug('queries 2 >>> ' + Limits.getQueries());
                    XC_REST_Order_U.updateOrders(mapOrder, wrResp);
                }
                resp_map.put('wrReq', wrReq);
                resp_map.put('wrResp', wrResp);
                return JSON.serialize(resp_map);
            }
            return null;
        } catch (Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC234_PaymentMethod] updateOrderItemBillingProfile - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC234_PaymentMethod', 'updateOrderItemBillingProfile', errorMessage, 0, errorMessage, null);
            Database.rollback(savepoint);
            wrResp.Result.ErrorCode = '500';
            wrResp.Result.Message = errorMessage;
            resp_map.put('wrResp', wrResp);
            return JSON.serialize(resp_map);
        }
    }

    @AuraEnabled
    public static string updateOrderItemBillingProfile_step2(String wrRespSerialized, String wrReqSerialized, String workOrderId, Map<String, String> parameters){    
        
        System.Savepoint savepoint = Database.setSavepoint();
        XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) JSON.deserialize(wrRespSerialized, XC_REST_Order_U.WrapperRes.class);
        XC_REST_Order_U.WrapperPUTRequest wrReq = (XC_REST_Order_U.WrapperPUTRequest) JSON.deserialize(wrReqSerialized, XC_REST_Order_U.WrapperPUTRequest.class);

        Map<String, List<NE__Order_Item_Attribute__c>> mapOrdItemIdOIA = new  Map<String, List<NE__Order_Item_Attribute__c>>();
        Map<String,String> header = new Map<String,String> {
            'ClientSystem' => 'XInstaller',
            'DateTimeMessage' => DateTime.now().format('yyyyMMddHHmmssSSS'),
            'TransactionID' => 'acceptQuote',
            'Operation' => 'Update',
            'Functionality' => 'UpdateOrder',
            'ServerSystem' => 'XCustomerB2C'
        };

        try {
            if(wrResp.Result.ErrorCode == '0') {
                wrReq.Order.OrderStatus = 'Accepted';
                Map<String, Object> mapOnlyOrder = new Map<String, Object> {
                    'mapOrdItemIdOIA'=> mapOrdItemIdOIA,
                    'wrReq' => wrReq,
                    'clientSystem' => header.get('ClientSystem')
                };
                System.debug('queries 3 >>> ' + Limits.getQueries());
                XC_REST_Order_ZZ.checkConfigurationObjectsId(mapOnlyOrder, wrResp);
                System.debug('queries 4 >>> ' + Limits.getQueries());
                XC_REST_Order_U.updateOrders(mapOnlyOrder, wrResp);
                System.debug('queries 5 >>> ' + Limits.getQueries());

                update new User(Id = UserInfo.getUserId(), XC_EnabledToSkip__c = true);    
                update new WorkOrder(Id = workOrderId, XC_Configuration__c = wrResp.Order.OrderID);
                update new User(Id = UserInfo.getUserId(), XC_EnabledToSkip__c = false);    

                if(wrResp.Result.ErrorCode == '0') {
                    WorkOrder wo = [SELECT WorkTypeId,
                                        WorkType.Name,
                                        XC_LegalEntity__c,
                                        PostalCode,
                                        Country,
                                        XC_Country__c,
                                        City,
                                        AccountId,
                                        Street,
                                        XC_Configuration__c,
                                        ContactId,
                                        XC_Opportunity__c,
                                        XC_WorkTypeLabel__c,
                                        XC_Address__c 
                                    FROM WorkOrder
                                    WHERE id =: workOrderId];

                    String workTypeFromParameters = String.isNotBlank(wo.WorkTypeId) ? parameters.get(wo.WorkType.Name): null;

                    if(String.isNotBlank(workTypeFromParameters)) {
                        createSiteInspection(JSON.serialize(wo), workTypeFromParameters);
                    }
                } else {
                    Database.rollback(savepoint);
                }
            } else {
                Database.rollback(savepoint);
            }

            return JSON.serialize(wrResp);

        } catch (Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC234_PaymentMethod] updateOrderItemBillingProfile_step2 - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC234_PaymentMethod', 'updateOrderItemBillingProfile_step2', errorMessage, 0, errorMessage, null);
            Database.rollback(savepoint);
            wrResp.Result.ErrorCode = '500';
            wrResp.Result.Message = errorMessage;
            return JSON.serialize(wrResp);
        }
    }

    @AuraEnabled
    public static String createDoc(String orderId){        
        // 05/02/2021 aggiornamento campo XC_BillingModel__c per generazione contratto    
        System.debug('@@@@ enter createDoc ');
        try{            
            List<NE__OrderItem__c> oiListToUpdateBlank = [SELECT id, XC_BillingModel__c
                                                            FROM NE__OrderItem__c 
                                                            WHERE NE__OrderId__c =: orderId];
            List<NE__OrderItem__c> oiListToRestore = oiListToUpdateBlank.deepClone(true);
            for(NE__OrderItem__c oiToUpdate : oiListToUpdateBlank){             
                oiToUpdate.XC_BillingModel__c = '';
                oiToUpdate.NE__Billing_Description__c = 'createDoc';
            }
            System.debug('@@@@ oiListToUpdateBlank: ' + oiListToUpdateBlank);
            System.debug('@@@@ oiListToRestore: ' + oiListToRestore);
            update oiListToUpdateBlank;
            update new User(Id = UserInfo.getUserId(), XC_EnabledToSkip__c = true);
            update oiListToRestore;
            update new User(Id = UserInfo.getUserId(), XC_EnabledToSkip__c = false);
            return 'OK';

        } catch (Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();           
            System.debug('[TA_LCC234_PaymentMethod] createDoc - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC234_PaymentMethod', 'createDoc', errorMessage, 0, errorMessage, null);
            return 'KO';
        }                  
 
    }
    
    @future(callout = true)
    public static void createSiteInspection(String woSerialized, String workTypeFromParameters) {
        System.debug('TA_LCC234_PaymentMethod: enter createSiteInspection');

        WorkOrder wo = (WorkOrder) JSON.deserialize(woSerialized, WorkOrder.class);

        try{
            String logError = '';
            
            XC_REST_WorkOrder_W.Wrapper wrReq = new XC_REST_WorkOrder_W.Wrapper();
            XC_REST_WorkOrder_W.Wrapper wrRespSiteInspection = new XC_REST_WorkOrder_W.Wrapper();

            wrReq.WorkOrder = new XC_UTIL_WorkOrder.WorkOrderWrapper();
            //wrReq.WorkOrder.WorkType = workTypeFromParameters;
            wrReq.WorkOrder.LegalEntity = wo.XC_LegalEntity__c;
            wrReq.WorkOrder.PostalCode = wo.PostalCode;
            wrReq.WorkOrder.Country = String.isBlank(wo.XC_Country__c) ? wo.Country : wo.XC_Country__c;
            wrReq.WorkOrder.City = wo.City;
            wrReq.WorkOrder.AccountId = wo.AccountId;
            wrReq.WorkOrder.Street = wo.Street;
            wrReq.WorkOrder.Status = 'New';
            //wrReq.WorkOrder.Priority = 'Bajo';
            wrReq.WorkOrder.Priority = 'Low';
            wrReq.WorkOrder.OrderId = wo.XC_Configuration__c;
            wrReq.WorkOrder.ContactId = wo.ContactId;
            wrReq.WorkOrder.OpportunityId = wo.XC_Opportunity__c;            
            wrReq.WorkOrder.WorkType = XC_UTIL_WorkType.getWorkTypeByNameAndLE(workTypeFromParameters, wrReq.WorkOrder.LegalEntity);
            System.debug('##### WorkType: ' + wrReq.WorkOrder.WorkType);
            WorkOrder resWo = XC_REST_WorkOrder_U.createWorkOrder(wrReq.WorkOrder, new WorkOrder());
            // START FIX [ADC05/07/2021] populate address on site inspection
            resWo.XC_Address__c = wo.XC_Address__c;
            // END FIX [ADC05/07/2021] populate address on site inspection
            System.debug('##### resWo: ' + resWo);
            XC_UTIL_Sobject.WrapperResult resInsertWO = XC_UTIL_Sobject.insertrecord(resWo);
            //update new WorkOrder(Id = resInsertWO.recordId, TA_Phase__c = 'PreService');
            System.debug('##### resInsertWO: ' + resInsertWO);

            if(!resInsertWO.success) {
                wrRespSiteInspection.result.message = 'INTERNAL ERROR';
                wrRespSiteInspection.result.errorCode = '500'; 
                logError = 'Error on insert WorkOrder: '+resInsertWO.errorMessage;               
                
            } else {            
                wrRespSiteInspection.workorder = new XC_UTIL_WorkOrder.WorkOrderWrapper();
                wrRespSiteInspection.workorder.WorkOrderNumber = [SELECT WorkOrderNumber FROM WorkOrder WHERE Id =: resInsertWO.recordid][0].WorkOrderNumber ;  
                wrRespSiteInspection.workorder.WorkOrderID = resInsertWO.recordid;
                wrRespSiteInspection.workorder.WorkType = resWo.WorkType.Name;
                wrRespSiteInspection.workOrder.status = resWo.status; 
                wrRespSiteInspection.workOrder.AccountID = resWo.AccountId;
                wrRespSiteInspection.WorkOrder.AssetID = resWo.AssetID;
                wrRespSiteInspection.WorkOrder.Comments = resWo.XC_Comments__c;
                wrRespSiteInspection.result.message = 'Operation completed successfully';
                wrRespSiteInspection.result.errorCode = '0';    
                System.debug('##### wrRespSiteInspection: ' + wrRespSiteInspection);        
                
            }    
            
            TA_UTIL_LogManagement.createLog('TA_LCC234_PaymentMethod', 'wrReq.WorkOrder', JSON.serialize(wrReq.WorkOrder), 0, JSON.serialize(wrReq.WorkOrder), null);
            TA_UTIL_LogManagement.createLog('TA_LCC234_PaymentMethod', 'resInsertWO', JSON.serialize(resInsertWO), 0, JSON.serialize(resInsertWO), null);
            TA_UTIL_LogManagement.createLog('TA_LCC234_PaymentMethod', 'wrRespSiteInspection', JSON.serialize(wrRespSiteInspection), 0, JSON.serialize(wrRespSiteInspection), null);
            
            //return wrRespSiteInspection;      

        } catch (Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();           
            System.debug('[TA_LCC234_PaymentMethod] createSiteInspection - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC234_PaymentMethod', 'createSiteInspection', errorMessage, 0, errorMessage, null);
            //return null;
        }

    }

}