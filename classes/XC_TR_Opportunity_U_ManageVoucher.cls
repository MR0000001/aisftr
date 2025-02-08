/**
* @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
* @date Creation 04/12/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_Configuration_UXC_TR_Opportunity_U_ManageVoucher_ManageVoucher - Manage Voucher for Opportunity status changing
*/

public without sharing class XC_TR_Opportunity_U_ManageVoucher {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Opportunity_U_ManageVoucher');
    
    /** @description Wrapper to check Voucher */
    private class CheckVoucherWrapper {
        XC_Voucher__c voucher;
        NE__Order__c conf;
        List<XC_VoucherUtilization__c> voucherUtilToDelete = new List<XC_VoucherUtilization__c>();
        List<XC_Voucher__c> voucherListToUpdate = new List<XC_Voucher__c>();
    }


    /**
     * @description After opportunity update
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
    */
    public static void afterOpportunityUpdate(List<Opportunity> listNew, Map<Id,Opportunity> mapOld, Map<Id,Opportunity> mapNew) {
        System.debug('In XC_TR_Opportunity_U_ManageVoucher.afterOpportunityUpdate');
        List<String> fieldList = new List<String>{'StageName'};
        List<Opportunity> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        Map<Id,Opportunity> oppClosedLostMap = new Map<Id,Opportunity>();
        if(!listChanged.isEmpty()) {
            for(Opportunity opp: listChanged){
                if(opp.StageName == Label.XC_CL_Opportunity_ClosedLost){
                    oppClosedLostMap.put(opp.id, opp);
                }
            }
            if(!oppClosedLostMap.isEmpty()){
                manageVoucherForStatusChanging(oppClosedLostMap);
            }
        }
    }


    /**
     * @param oppClosedLostMap the oppClosedLost map
     * @description   Method to manage Voucher when the opportunity status changed
     *                STATUS Closed Lost -> Restore Voucher and delete the related voucher utilization
    */
    public static void manageVoucherForStatusChanging(Map<Id,Opportunity> oppClosedLostMap) {
    
        Map<Id, NE__Order__c> oppIdOpty = getOptyOrderFromOpportunity(oppClosedLostMap.keySet());
        if(!oppIdOpty.isEmpty()){
            Map<NE__Order__c, NE__OrderItem__c> mapOrderToCoupon = getCouponFromConfiguration(oppIdOpty.values());
            Map<String, XC_Voucher__c> mapVoucher = getVoucher(mapOrderToCoupon.values());
            String voucherCode;
            XC_Voucher__c voucher;
            List<XC_Voucher__c> voucherListToUpdate = new List<XC_Voucher__c>();
            List<XC_VoucherUtilization__c> voucherUtilToDelete = new List<XC_VoucherUtilization__c>();
            List<XC_VoucherUtilization__c> voucherUtilListToInsert = new List<XC_VoucherUtilization__c>();
            XC_VoucherUtilization__c voucherUtilToInsert;

            for(NE__Order__c conf : mapOrderToCoupon.keySet()) {
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
            }
            
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
        
    }


    /**
     * @param oppClosedLostids the opportunity closed lost ids 
     * @return  Map<Id, NE__Order__c> the map with opportunity id as key and Opty Order as value
     * @description   Method to get Opty Order from Opportunity
    */
    public static Map<Id, NE__Order__c> getOptyOrderFromOpportunity(Set<Id> oppClosedLostids){

        Map<Id, Opportunity> oppMap = new Map<Id,Opportunity>([SELECT Id, 
                                                              (SELECT Id, RecordTypeId, NE__Type__c, NE__AccountId__c FROM NE__Orders__r) 
                                                               FROM Opportunity WHERE Id IN: oppClosedLostids]);
        Id optyRTId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Order_RecordTypeOpty).getRecordTypeId();

        Map<Id, NE__Order__c> oppIdOpty = new Map<Id, NE__Order__c>();
        for(Opportunity opp : oppMap.values()){
            Boolean disconnectionOrderFound = false;
            NE__Order__c optyOrd;
            for(NE__Order__c ord : opp.NE__Orders__r){
                if(ord.RecordTypeId == optyRTId){
                   optyOrd = ord; 
                }
                if(ord.NE__Type__c == Label.XC_CL_Configuration_TypeDisconnection){
                    disconnectionOrderFound = true;
                }
            }
            if(!disconnectionOrderFound && optyOrd != null){
                oppIdOpty.put(opp.Id, optyOrd);
            }
        }         
        return oppIdOpty;                                           
    }


    /**
     * @param confList the conf list
     * @return the coupon from configuration
     * @description Method to link orders to order items with Coupon type
    */
    private static Map<NE__Order__c, NE__OrderItem__c> getCouponFromConfiguration(List<NE__Order__c> confList) {
        List<Id> listOrderId = XC_UTIL_SObject.getIds(confList);
        Map<Id, NE__OrderItem__c> mapOrderIdToCoupon = getCouponFromConfigurationId(listOrderId);

        Map<NE__Order__c, NE__OrderItem__c> mapOrderToCoupon = new Map<NE__Order__c, NE__OrderItem__c>();
        for(NE__Order__c conf : confList) {
         if(mapOrderIdToCoupon.containsKey(conf.Id)) {
            mapOrderToCoupon.put(conf, mapOrderIdToCoupon.get(conf.Id)); // ?????
           }
        }

        return mapOrderToCoupon;
    }


    /**
     * @param orderIdList the order id list
     * @return the coupon from configuration id
     * @description Method to link order ids to order items with Coupon type
    */
    private static Map<Id, NE__OrderItem__c> getCouponFromConfigurationId(List<Id> orderIdList) {
        if(!Schema.sObjectType.NE__OrderItem__c.isAccessible()){
           return new Map<Id, NE__OrderItem__c>();
        }
        System.debug('@@@ XC_CL_Configuration_TypeDisconnection - orderIdList -> '+ orderIdList);
        Map<Id, NE__OrderItem__c> mapOrderItem = new Map<Id, NE__OrderItem__c>([SELECT Id, Name, NE__OrderId__c, NE__OrderId__r.NE__Configuration_Type__c, NE__OrderId__r.NE__OrderStatus__c, NE__OrderId__r.RecordTypeId, NE__ProdId__r.Name,
                                                                                    (SELECT Id, Name, NE__Value__c, XC_DeveloperName__c 
                                                                                    FROM NE__Order_Item_Attributes__r 
                                                                                    WHERE XC_DeveloperName__c =: Label.XC_CL_OrderItemAttribute_Coupon)
                                                                                FROM NE__OrderItem__c
                                                                                WHERE NE__OrderId__c IN: orderIdList 
                                                                                AND NE__ProdId__r.XC_LIC_Product_Name__c =: Label.XC_CL_CommercialProduct_Coupon
                                                                                AND NE__OrderId__r.NE__Configuration_Type__c =: Label.XC_CL_Configuration_TypeNew]);
        System.debug('@@@@XC_CL_Configuration_TypeDisconnection - mapOrderItem->'+ mapOrderItem);
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
    private static Map<String, XC_Voucher__c> getVoucher(List<NE__OrderItem__c> orderItemList) {
        List<String> voucherCodeList = getVoucherCode(orderItemList);
        if(!Schema.sObjectType.XC_Voucher__c.isAccessible()){
            return new Map<String, XC_Voucher__c>();
        }
        System.debug('@@@@ voucherCodeList->'+ voucherCodeList);  
        Map<Id, XC_Voucher__c> mapVoucherQuery = new Map<Id, XC_Voucher__c>([SELECT Id, XC_VoucherCode__c, RecordType.DeveloperName, XC_Usage_Counter__c, XC_Voucher_To_Be_Created__c, XC_Unlimited__c, XC_Uses__C, XC_Status__c,
                                                                                (SELECT Id, XC_Account__c 
                                                                                FROM Voucher_Utilization__r)
                                                                            FROM XC_Voucher__c
                                                                            WHERE XC_VoucherCode__c IN: voucherCodeList]);
        List<XC_Voucher__c> voucherList = mapVoucherQuery.values();
        System.debug('@@@@ voucherList->'+ voucherList);          
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
    private static List<String> getVoucherCode(List<NE__OrderItem__c> orderItemList) {
        System.debug('@@@@ getVoucherCode - orderItemList->'+ orderItemList);
        List<String> voucherCodeList = new List<String>();
        for(NE__OrderItem__c orItem : orderItemList) {
            voucherCodeList.add(orItem.NE__Order_Item_Attributes__r.get(0).NE__Value__c);
        }
        return voucherCodeList;
    }


    /**
     * @param wrapper - CheckVoucherWrapper
     * @description Method to check if the Voucher can be used
    */
    public static void checkVoucher(CheckVoucherWrapper wrapper) {
        for(XC_VoucherUtilization__c voucherUtil : wrapper.voucher.Voucher_Utilization__r) {
            if(wrapper.conf.NE__AccountId__c == voucherUtil.XC_Account__c) {
                wrapper.voucherUtilToDelete.add(voucherUtil);

                if(!wrapper.voucher.XC_Unlimited__c && wrapper.voucher.RecordType.DeveloperName != 'XC_Voucher_Unlimited' && wrapper.voucher.XC_Usage_Counter__c != 0) {
                    wrapper.voucher.XC_Usage_Counter__c = (wrapper.voucher.XC_Usage_Counter__c - 1);
                    wrapper.voucherListToUpdate.add(wrapper.voucher);
                }
            }
        }
    }


}