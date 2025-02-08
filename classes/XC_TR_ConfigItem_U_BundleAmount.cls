/**
 * The Class XC_TR_ConfigItem_U_BundleAmount.
 *
 * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation 02/04/2020
 * @date Modification
 * @description Class to calculate Bundle Total Amount
 */


public without sharing class XC_TR_ConfigItem_U_BundleAmount {


    /**
     * @description calculate Bundle Total Amount
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void calculateBundleTotalAmountOnUpdate(Map<Id, NE__OrderItem__c> mapOld, Map<Id, NE__OrderItem__c> mapNew) {

        List<String> fieldList = new List<String>{'NE__Bundle_Configuration__c'};       
        List<NE__OrderItem__c> confItemListChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(confItemListChanged.isEmpty()) {
            return;
        }

        calculateBundleTotalAmount(confItemListChanged);
    }


    /**
     * @description calculate Bundle Total Amount
     * @param mapOld the map old
     * @param mapNew the map new
     */
    private static void calculateBundleTotalAmount(List<NE__OrderItem__c> confItemToProcess) {

        Set<Id> oiBundleFatherIds = XC_UTIL_Sobject.getSetIdsOnField(confItemToProcess, 'NE__Bundle_Configuration__c');
        Map<Id, NE__OrderItem__c> oiMap = new Map<Id, NE__OrderItem__c>([SELECT Id, NE__Bundle_Configuration__c,XC_ProductName__c,NE__Qty__c, NE__OneTimeFeeOv__c, XC_BundleTotalOTAmount__c
                                                                            FROM NE__OrderItem__c
                                                                            WHERE (Id IN :oiBundleFatherIds OR NE__Bundle_Configuration__c IN :oiBundleFatherIds) AND
                                                                                NE__Action__c != 'Remove' /*AND NE__OrderId__r.RecordType.Name = 'Order'*/]);
        if(oiMap.isEmpty()) {
            return;
        }

        Map<Id, List<NE__OrderItem__c>> fatherChildsMap = new Map<Id, List<NE__OrderItem__c>>();
        for(NE__OrderItem__c oi : oiMap.values()) {
            if(String.isNotBlank(oi.NE__Bundle_Configuration__c)) {
                if(fatherChildsMap.get(oi.NE__Bundle_Configuration__c) == null) {
                    fatherChildsMap.put(oi.NE__Bundle_Configuration__c, new List<NE__OrderItem__c>{oi});
                } else {
                    fatherChildsMap.get(oi.NE__Bundle_Configuration__c).add(oi);
                }
            }
        }

        List<NE__OrderItem__c> fathersToUpdate = new List<NE__OrderItem__c>();
        for(Id fatherId : fatherChildsMap.keySet()) {
            //add products name concat management on bundle FI
            List<String> childProdNames = new List<String>();

            Decimal totalAmount = 0;
            for(NE__OrderItem__c child : fatherChildsMap.get(fatherId)) {
                totalAmount += (child.NE__OneTimeFeeOv__c == null) ? 0 : (child.NE__OneTimeFeeOv__c * child.NE__Qty__c);
                if(String.isNotBlank(child.XC_ProductName__c)){
                    childProdNames.add(child.XC_ProductName__c);
                }
            }

            if(oiMap.get(fatherId).XC_BundleTotalOTAmount__c != totalAmount) {
                fathersToUpdate.add(
                        new NE__OrderItem__c(
                            Id = fatherId, 
                            XC_BundleTotalOTAmount__c = totalAmount,
                            XC_BundleProducts__c = String.join(childProdNames,';')
                            )
                    );
            }
        }

        XC_UTIL_SObject.updateListRecords(fathersToUpdate);
    }


    /**
     * @description calculate Bundle Total Amount on delete
     * @param mapOld the map old
     */
    public static void calculateBundleTotalAmountAfterDelete(Map<Id, NE__OrderItem__c> mapOld) {
        
        Map<Id, List<NE__OrderItem__c>> bundleItemsMap = new Map<Id, List<NE__OrderItem__c>>();
        for(NE__OrderItem__c oi : mapOld.values()) {
            if(String.isNotBlank(oi.NE__Bundle_Configuration__c)) {
                if(bundleItemsMap.containsKey(oi.NE__Bundle_Configuration__c)) {
                    bundleItemsMap.get(oi.NE__Bundle_Configuration__c).add(oi);
                } else {
                    bundleItemsMap.put(oi.NE__Bundle_Configuration__c, new List<NE__OrderItem__c>{oi});
                }
            }
        }

        if(bundleItemsMap.isEmpty()) {
            return;
        }

        Map<Id, NE__OrderItem__c> oiBundleMap = new Map<Id, NE__OrderItem__c>([SELECT Id, XC_BundleTotalOTAmount__c
                                                                            FROM NE__OrderItem__c
                                                                            WHERE Id IN :bundleItemsMap.keySet()]);
        if(oiBundleMap.isEmpty()) {
            return;
        }

        for(NE__OrderItem__c bundle : oiBundleMap.values()) {
            Decimal amount = (bundle.XC_BundleTotalOTAmount__c != null) ? bundle.XC_BundleTotalOTAmount__c : 0;
            for(NE__OrderItem__c child : bundleItemsMap.get(bundle.Id)) {
                amount -= (child.NE__OneTimeFeeOv__c * child.NE__Qty__c);
            }
            bundle.XC_BundleTotalOTAmount__c = amount;
        }

        XC_UTIL_SObject.updateListRecords(oiBundleMap.values());
    }
}