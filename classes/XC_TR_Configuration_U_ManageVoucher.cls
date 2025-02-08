/**
* @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
* @date Creation 27/11/2018
* @date Modification 29/11/2018
* @description XC_TR_Configuration_U_ManageVoucher - Manage Voucher for order status changing
*/

public without sharing class XC_TR_Configuration_U_ManageVoucher {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Configuration_U_ManageVoucher');

    /** @description Wrapper to check Voucher */
    private class CheckVoucherWrapper {
        XC_Voucher__c voucher;
        NE__Order__c conf;
        List<XC_VoucherUtilization__c> voucherUtilToDelete = new List<XC_VoucherUtilization__c>();
        List<XC_Voucher__c> voucherListToUpdate = new List<XC_Voucher__c>();
    }


    /**
     * @description Before order update
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void beforeOrderUpdate(List<NE__Order__c> listNew, Map<Id,NE__Order__c> mapOld, Map<Id,NE__Order__c> mapNew) {
        List<String> fieldListRT = new List<String>{'RecordTypeId'};
        List<NE__Order__c> listChangedRecordType = XC_UTIL_Sobject.getListChanged(fieldListRT, mapOld, mapNew);
        Set<Id> orderRecordTypeIds = XC_UTIL_SObject.getSetIds(listChangedRecordType);

        List<String> fieldListS = new List<String>{'XC_Status__c', 'NE__OrderStatus__c'};
        List<NE__Order__c> listChangedStatus = XC_UTIL_Sobject.getListChanged(fieldListS, mapOld, mapNew);
        Set<Id> orderStatusIds = XC_UTIL_SObject.getSetIds(listChangedStatus);

        listChangedRecordType.addAll(listChangedStatus);
        if(!listChangedRecordType.isEmpty()) {
            Map<String, Object> params = new Map<String, Object>{'listNew' => listChangedRecordType,
                                                                'orderRecordTypeIds' => orderRecordTypeIds,
                                                                'orderStatusIds' => orderStatusIds};
            checkAndBurnVoucher(params, mapNew);
        }
    }


    /**
     * @param listNew the list new
     * @param mapNew the map new
     * @description Method to check if the Voucher can be used
     */
    public static void checkAndBurnVoucher(Map<String, Object> params, Map<Id,NE__Order__c> mapNew) {

        List<NE__Order__c> listNew = (List<NE__Order__c>) params.get('listNew');
        Set<Id> orderRecordTypeIds = (Set<Id>) params.get('orderRecordTypeIds');
        Set<Id> orderStatusIds = (Set<Id>) params.get('orderStatusIds');

        Id optyRTId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Opty').getRecordTypeId();
        Map<NE__Order__c, NE__OrderItem__c> mapOrderToCoupon = getCouponFromConfiguration(listNew);
        Map<String, XC_Voucher__c> mapVoucher = getVoucher(mapOrderToCoupon.values());

        List<XC_Voucher__c> voucherListToUpdate = new List<XC_Voucher__c>();
        List<XC_VoucherUtilization__c> voucherUtilListToInsert = new List<XC_VoucherUtilization__c>();

        for(NE__Order__c conf : mapOrderToCoupon.keySet()) {
            if((orderRecordTypeIds.contains(conf.Id) && conf.RecordTypeId != optyRTId)    // For creation of Quote or Order
                || (orderStatusIds.contains(conf.Id) && conf.NE__Type__c == 'ChangeOrder' && conf.XC_Subtype__c == 'Promocode application' &&      // For ChangeOrder - Promocode Application in 'In Provisioning'
                conf.XC_Status__c == Label.XC_CL_Configuration_OrderInProvisioning && conf.NE__OrderStatus__c == Label.XC_CL_Order_StatusSent)) {
                
                    Boolean toBurn = true;

                    String voucherCode = mapOrderToCoupon.get(conf).NE__Order_Item_Attributes__r[0].NE__Value__c;
                    XC_Voucher__c voucher = mapVoucher.get(voucherCode);

                    /*if(!voucher.XC_Unlimited__c && voucher.RecordType.DeveloperName != 'XC_Voucher_Unlimited' && (voucher.XC_Usage_Counter__c >= voucher.XC_Uses__c)) {
                        mapNew.get(conf.Id).addError(Label.XC_CL_Voucher_CannotBeUsed);
                    } else {
                        for(XC_VoucherUtilization__c voucherUtil : voucher.Voucher_Utilization__r) {
                            if(conf.NE__AccountId__c == voucherUtil.XC_Account__c && conf.NE__OptyId__c != voucherUtil.XC_Opportunity__c) {
                                mapNew.get(conf.Id).addError(Label.XC_CL_Voucher_AlreadyUsedByAccount);
                            } else if(conf.NE__AccountId__c == voucherUtil.XC_Account__c && conf.NE__OptyId__c == voucherUtil.XC_Opportunity__c) {
                                toBurn = false;
                            }
                        }
                    }*/

                    for(XC_VoucherUtilization__c voucherUtil : voucher.Voucher_Utilization__r) {
                        if(conf.NE__AccountId__c == voucherUtil.XC_Account__c && conf.NE__OptyId__c != voucherUtil.XC_Opportunity__c) {
                            mapNew.get(conf.Id).addError(Label.XC_CL_Voucher_AlreadyUsedByAccount);
                        } else if(conf.NE__AccountId__c == voucherUtil.XC_Account__c && conf.NE__OptyId__c == voucherUtil.XC_Opportunity__c) {
                            toBurn = false;
                        }
                    }

                    if(toBurn) {
                        if(!voucher.XC_Unlimited__c && voucher.RecordType.DeveloperName != 'XC_Voucher_Unlimited' && (voucher.XC_Usage_Counter__c >= voucher.XC_Uses__c)) {
                            mapNew.get(conf.Id).addError(Label.XC_CL_Voucher_CannotBeUsed);
                        }

                        Map<String, Object> utilMap = new Map<String, Object>{'voucher' => voucher, 'conf' => conf};
                        burnCoupon(utilMap, voucherListToUpdate, voucherUtilListToInsert);
                    }
            }
        }

        if(!voucherUtilListToInsert.isEmpty()) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'voucherUtilListToInsert -> ' + voucherUtilListToInsert);
            XC_UTIL_SObject.insertListRecords(voucherUtilListToInsert);
        }
        if(!voucherListToUpdate.isEmpty()) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'voucherListToUpdate -> ' + voucherListToUpdate);
            XC_UTIL_SObject.updateListRecords(voucherListToUpdate);
        }
    }


    /**
     * @param confList the conf list
     * @return the coupon from configuration
     * @description Method to link orders to order items with Coupon type
     */
    public static Map<NE__Order__c, NE__OrderItem__c> getCouponFromConfiguration(List<NE__Order__c> confList) {
        List<Id> listOrderId = XC_UTIL_SObject.getIds(confList);
        Map<Id, NE__OrderItem__c> mapOrderIdToCoupon = getCouponFromConfigurationId(listOrderId);

        Map<NE__Order__c, NE__OrderItem__c> mapOrderToCoupon = new Map<NE__Order__c, NE__OrderItem__c>();
        for(NE__Order__c conf : confList) {
            if(mapOrderIdToCoupon.containsKey(conf.Id)) {
                mapOrderToCoupon.put(conf, mapOrderIdToCoupon.get(conf.Id));
            }
        }

        return mapOrderToCoupon;
    }


    /**
     * @param orderIdList the order id list
     * @return the coupon from configuration id
     * @description Method to link order ids to order items with Coupon type
     */
    public static Map<Id, NE__OrderItem__c> getCouponFromConfigurationId(List<Id> orderIdList) {
        if(!Schema.sObjectType.NE__OrderItem__c.isAccessible()){
           return new Map<Id, NE__OrderItem__c>();
        }
        System.debug('@@@ orderIdList -> '+ orderIdList);
        Map<Id, NE__OrderItem__c> mapOrderItem = new Map<Id, NE__OrderItem__c>([SELECT Id, Name, NE__OrderId__c, NE__OrderId__r.NE__Configuration_Type__c, NE__OrderId__r.NE__OrderStatus__c, NE__OrderId__r.RecordTypeId,
                                                                                    NE__OrderId__r.NE__AccountId__c, NE__OrderId__r.NE__OptyId__c, NE__ProdId__r.Name,
                                                                                    (SELECT Id, Name, NE__Value__c, XC_DeveloperName__c 
                                                                                    FROM NE__Order_Item_Attributes__r 
                                                                                    WHERE XC_DeveloperName__c =: Label.XC_CL_OrderItemAttribute_Coupon)
                                                                                FROM NE__OrderItem__c
                                                                                WHERE NE__OrderId__c IN: orderIdList 
                                                                                AND NE__ProdId__r.XC_LIC_Product_Name__c =: Label.XC_CL_CommercialProduct_Coupon
                                                                                AND NE__OrderId__r.NE__Configuration_Type__c =: Label.XC_CL_Configuration_TypeNew]);
        System.debug('@@@@2506 mapOrderItem->'+ mapOrderItem);
        List<NE__OrderItem__c> orderItemList = mapOrderItem.values();
        Map<Id, NE__OrderItem__c> mapOrderIdToCoupon = new Map<Id, NE__OrderItem__c>();
        for(NE__OrderItem__c orItem : orderItemList) {
            mapOrderIdToCoupon.put(orItem.NE__OrderId__c, orItem);
        }

        return mapOrderIdToCoupon;
    }


    /**
     * @param orderItemList the order item list
     * @return the voucher
     * @description Method to link Voucher Codes to Vouchers
     */
    public static Map<String, XC_Voucher__c> getVoucher(List<NE__OrderItem__c> orderItemList) {
        List<String> voucherCodeList = getVoucherCode(orderItemList);
        if(!Schema.sObjectType.XC_Voucher__c.isAccessible() || voucherCodeList.isEmpty()){
            return new Map<String, XC_Voucher__c>();
        }
        System.debug('@@@@2506 voucherCodeList->'+ voucherCodeList);  
        Map<Id, XC_Voucher__c> mapVoucherQuery = new Map<Id, XC_Voucher__c>([SELECT Id, XC_VoucherCode__c, RecordType.DeveloperName, XC_Usage_Counter__c, XC_Voucher_To_Be_Created__c, XC_Unlimited__c, XC_Uses__C, XC_Status__c,
                                                                                (SELECT Id, XC_Account__c, XC_Opportunity__c FROM Voucher_Utilization__r)
                                                                            FROM XC_Voucher__c
                                                                            WHERE XC_VoucherCode__c IN: voucherCodeList]);
        List<XC_Voucher__c> voucherList = mapVoucherQuery.values();
        System.debug('@@@@2506 voucherList->'+ voucherList);          
        Map<String, XC_Voucher__c> mapVoucher = new Map<String, XC_Voucher__c>();
        for(XC_Voucher__c voucher : voucherList) {
            mapVoucher.put(voucher.XC_VoucherCode__c, voucher);
        }

        return mapVoucher;
    }


    /**
     * @param orderItemList the order item list
     * @return the voucher code
     * @description Method to get Vouchers Code by Order Items
     */
    public static List<String> getVoucherCode(List<NE__OrderItem__c> orderItemList) {
        System.debug('@@@@2506 orderItemList->'+ orderItemList);
        List<String> voucherCodeList = new List<String>();
        for(NE__OrderItem__c orItem : orderItemList) {
            voucherCodeList.add(orItem.NE__Order_Item_Attributes__r.get(0).NE__Value__c);
        }
        return voucherCodeList;
    }


    /**
     * @param params the map of parameters
     * @param voucherListToUpdate the voucher list to update
     * @param voucherUtilListToInsert the voucher utilization list to insert
     * @description Method to burn the coupon
     */
    public static void burnCoupon(Map<String, Object> params, List<XC_Voucher__c> voucherListToUpdate, List<XC_VoucherUtilization__c> voucherUtilListToInsert) {
        
        XC_Voucher__c voucher = (XC_Voucher__c) params.get('voucher');
        NE__Order__c conf = (NE__Order__c) params.get('conf');

        if (!voucher.XC_Unlimited__c && voucher.RecordType.DeveloperName != 'XC_Voucher_Unlimited') {
            voucher.XC_Usage_Counter__c ++; 
        }

        if ((voucher.RecordType.DeveloperName == 'XC_Voucher_General') || (voucher.RecordType.DeveloperName == 'XC_Voucher_Individual')){
            if (voucher.XC_Usage_Counter__c >= voucher.XC_Uses__c) {
                voucher.XC_Status__c = 'Burnt';
            }
        }

        voucherListToUpdate.add(voucher);

        XC_VoucherUtilization__c voucherUtilToInsert = new XC_VoucherUtilization__c();
        voucherUtilToInsert.XC_Voucher__c = voucher.Id;
        voucherUtilToInsert.XC_Account__c = conf.NE__AccountId__c;
        voucherUtilToInsert.XC_Opportunity__c = conf.NE__OptyId__c;
        voucherUtilListToInsert.add(voucherUtilToInsert);
    }

    


    /**
     * @description After order update
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    /*public static void afterOrderUpdate(List<NE__Order__c> listNew, Map<Id,NE__Order__c> mapOld, Map<Id,NE__Order__c> mapNew) {
        System.debug('In XC_TR_Configuration_U_ManageVoucher.afterOrderUpdate');
        List<String> fieldList = new List<String>{'XC_Status__c', 'NE__OrderStatus__c'};
        List<NE__Order__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()) {
            manageVoucherForStatusChanging(listChanged, mapNew);
        }
    }

    
    /**
     * @param listNew the list new
     * @param mapNew the map new
     * @description   Method to manage Voucher when the order status changed
     *                STATUS Cancelled -> Restore Voucher and delete the related voucher utilization
     *                STATUS In Provisioning -> Increare the Voucher use and add the related voucher utilization
     */
    /*public static void manageVoucherForStatusChanging(List<NE__Order__c> listNew, Map<Id,NE__Order__c> mapNew) {
        Id orderRTId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Configuration_RtOrder).getRecordTypeId();
        Map<NE__Order__c, NE__OrderItem__c> mapOrderToCoupon = getCouponFromConfiguration(listNew);
        Map<String, XC_Voucher__c> mapVoucher = getVoucher(mapOrderToCoupon.values());
        String voucherCode;
        XC_Voucher__c voucher;
        List<XC_Voucher__c> voucherListToUpdate = new List<XC_Voucher__c>();
        List<XC_VoucherUtilization__c> voucherUtilToDelete = new List<XC_VoucherUtilization__c>();
        List<XC_VoucherUtilization__c> voucherUtilListToInsert = new List<XC_VoucherUtilization__c>();
        XC_VoucherUtilization__c voucherUtilToInsert;

        for(NE__Order__c conf : mapOrderToCoupon.keySet()) {

            if (conf.RecordTypeId != orderRTId) {
                continue;
            }

            if(conf.XC_Status__c == Label.XC_CL_Configuration_OrderCancelled && conf.NE__OrderStatus__c == Label.XC_CL_Order_StatusCancelled) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '--> STATUS CANCELLED <--');
                voucherCode = mapOrderToCoupon.get(conf).NE__Order_Item_Attributes__r.get(0).NE__Value__c;
                voucher = mapVoucher.get(voucherCode);
                CheckVoucherWrapper wrapper = new CheckVoucherWrapper();
                wrapper.voucher = voucher;
                wrapper.conf = conf;
                wrapper.voucherUtilToDelete = voucherUtilToDelete;
                wrapper.voucherListToUpdate = voucherListToUpdate;
                checkVoucher(wrapper);
                voucherUtilToDelete = wrapper.voucherUtilToDelete;
                voucherListToUpdate = wrapper.voucherListToUpdate;
                
            } /*else if (conf.XC_Status__c == Label.XC_CL_Configuration_OrderInProvisioning && conf.NE__OrderStatus__c == Label.XC_CL_Order_StatusSent) {

                XC_UTIL_Debug.debug(DEBUGACTIVE, '--> STATUS IN PROVISIONING <--');
                voucherCode = mapOrderToCoupon.get(conf).NE__Order_Item_Attributes__r.get(0).NE__Value__c;
                voucher = mapVoucher.get(voucherCode);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ VOUCHER DeveloperName -> ' + voucher.RecordType.DeveloperName);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ VOUCHER UsageCounter -> ' + voucher.XC_Usage_Counter__c);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ VOUCHER Uses -> ' + voucher.XC_Uses__c);

                if (!voucher.XC_Unlimited__c && voucher.RecordType.DeveloperName != 'XC_Voucher_Unlimited') {
                    voucher.XC_Usage_Counter__c ++; 
                }

                if ((voucher.RecordType.DeveloperName == 'XC_Voucher_General') || (voucher.RecordType.DeveloperName == 'XC_Voucher_Individual')){
                    if (voucher.XC_Usage_Counter__c >= voucher.XC_Uses__c) {
                        voucher.XC_Status__c = 'Burnt';
                    }
                }

                voucherListToUpdate.add(voucher);

                voucherUtilToInsert = new XC_VoucherUtilization__c();
                voucherUtilToInsert.XC_Voucher__c = voucher.Id;
                voucherUtilToInsert.XC_Account__c = conf.NE__AccountId__c;
                voucherUtilListToInsert.add(voucherUtilToInsert);
            }*/
        /*}

        
        if(!voucherUtilListToInsert.isEmpty()) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'voucherUtilListToInsert -> ' + voucherUtilListToInsert);
            XC_UTIL_SObject.insertListRecords(voucherUtilListToInsert);
        }
        if(!voucherListToUpdate.isEmpty()) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'voucherListToUpdate -> ' + voucherListToUpdate);
            XC_UTIL_SObject.updateListRecords(voucherListToUpdate);
        }
        if(!voucherUtilToDelete.isEmpty()) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'voucherUtilToDelete -> ' + voucherUtilToDelete);
            XC_UTIL_SObject.deleteListRecords(voucherUtilToDelete);
        }
    }

    /**
     * @param wrapper - CheckVoucherWrapper
     * @description Method to check if the Voucher can be used
     */
    /*public static void checkVoucher(CheckVoucherWrapper wrapper) {
        for(XC_VoucherUtilization__c voucherUtil : wrapper.voucher.Voucher_Utilization__r) {
            if(wrapper.conf.NE__AccountId__c == voucherUtil.XC_Account__c) {
                wrapper.voucherUtilToDelete.add(voucherUtil);

                if(!wrapper.voucher.XC_Unlimited__c && wrapper.voucher.RecordType.DeveloperName != 'XC_Voucher_Unlimited' && wrapper.voucher.XC_Usage_Counter__c != 0) {
                    wrapper.voucher.XC_Usage_Counter__c = (wrapper.voucher.XC_Usage_Counter__c - 1);
                    wrapper.voucherListToUpdate.add(wrapper.voucher);
                }
            }
        }
    }*/    
    
}