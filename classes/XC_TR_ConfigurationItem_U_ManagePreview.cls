/**
* @author dpalamides
* @date 16/06/2020
* @description classes.XC_TR_ConfigurationItem_U_ManagePreview
*/


public without sharing class XC_TR_ConfigurationItem_U_ManagePreview {
/**
    * @description manages total billing preview metrics on configuration
    * @author dpalamides
    * @param mapOld
    * @param mapNew
    * @return void
    **/
    public static void populateAmountsOnOrder(Map<Id, NE__OrderItem__c> mapOld, Map<Id, NE__OrderItem__c> mapNew){

        List<NE__OrderItem__c> updatedOis = XC_UTIL_Sobject.getListChanged(new List<String>{ 'XC_Charge_Amount__c',
                                                                                        'XC_Tax_AmountBillingPreviw__c',
                                                                                        'NE__RecurringChargeOv__c',
                                                                                        'NE__OneTimeFeeOv__c',
                                                                                        'NE__BaseRecurringCharge__c',
                                                                                        'NE__BaseOneTimeFee__c', 'NE__Qty__c'},mapOld,mapNew);

        if(updatedOis.isEmpty()){
            return;
        }


        Set<NE__Order__c> ordersToUpdate = new Set<NE__Order__c>();
        Map<id,List<NE__OrderItem__c>> getItemsByOrder = getItemsByOrder(updatedOis);
        Map<id,NE__Order__c> allOrders = new Map<id,NE__Order__c>([SELECT Id,XC_Charge_Amount__c,XC_TexVAT__c ,XC_BillingPreviewStatus__c, ownerID FROM NE__Order__c WHERE Id in :XC_UTIL_Sobject.getListFieldValues(updatedOis,'NE__OrderId__c')]);

        for (NE__Order__c theOrder : allOrders.values()) {
            Boolean isPreviewReady = false;
            List<NE__OrderItem__c> siblings = getItemsByOrder.get(theOrder.Id);
			if(siblings == null){
                continue;
            }
            for(NE__OrderItem__c sib : siblings){
                if(sib.XC_BillingModel__c == 'Capex'){
                    continue;
                }
                Boolean isSameItem = mapNew.get(sib.Id)!= null && mapNew.get(sib.Id).Id == sib.Id;
                Boolean previewOutOfDate = mapNew.containsKey(sib.Id) && (
                                                                            mapNew.get(sib.Id).NE__RecurringChargeOv__c   != mapOld.get(sib.Id).NE__RecurringChargeOv__c   ||
                                                                            mapNew.get(sib.Id).NE__OneTimeFeeOv__c        != mapOld.get(sib.Id).NE__OneTimeFeeOv__c        ||
                                                                            mapNew.get(sib.Id).NE__BaseRecurringCharge__c != mapOld.get(sib.Id).NE__BaseRecurringCharge__c ||
                                                                            mapNew.get(sib.Id).NE__BaseOneTimeFee__c      != mapOld.get(sib.Id).NE__BaseOneTimeFee__c      ||
                                                                            mapNew.get(sib.Id).NE__Qty__c                 != mapOld.get(sib.Id).NE__Qty__c
                                                                         );
                if(previewOutOfDate){
                    theOrder.XC_BillingPreviewStatus__c = 'Out of date';
                    ordersToUpdate.add(theOrder);
                    isPreviewReady = false;
                    break;
                }
                else if((sib.XC_Tax_AmountBillingPreviw__c == null || sib.XC_Charge_Amount__c==null) && !isSameItem){
                    isPreviewReady = false;
                    break;
                }
                else{
                    Double amount = isSameItem ?  mapNew.get(sib.Id).XC_Charge_Amount__c : sib.XC_Charge_Amount__c;
                    Double tax    = isSameItem ?  mapNew.get(sib.Id).XC_Tax_AmountBillingPreviw__c : sib.XC_Tax_AmountBillingPreviw__c;

                    if(amount != null && tax != null){
                        theOrder.XC_Charge_Amount__c = theOrder.XC_Charge_Amount__c != null ? theOrder.XC_Charge_Amount__c + amount : amount;
                        theOrder.XC_TexVAT__c = theOrder.XC_TexVAT__c != null ? theOrder.XC_TexVAT__c + tax : tax;
                        isPreviewReady = true;
                    }
                }
            }
            if(isPreviewReady){
                theOrder.XC_BillingPreviewStatus__c = 'OK';

                ordersToUpdate.add(theOrder);
            }
        }



        if (!ordersToUpdate.isEmpty()) {
            generateBellNotification(ordersToUpdate);
            XC_UTIL_Sobject.updateListRecords(new List<NE__Order__c>(ordersToUpdate));
        }

    }


    private static Map<id,List<NE__OrderItem__c>> getItemsByOrder(List<NE__OrderItem__c> items){
        Map<id,List<NE__OrderItem__c>> ret = new Map<id,List<NE__OrderItem__c>>();
        Map<Id, NE__OrderItem__c> itemsMap = new Map<Id, NE__OrderItem__c>([
                SELECT Id,XC_Charge_Amount__c,
                        XC_Tax_AmountBillingPreviw__c,
                        NE__RecurringChargeOv__c,
                        NE__OneTimeFeeOv__c,
                        NE__BaseRecurringCharge__c, NE__Qty__c,
                        NE__BaseOneTimeFee__c, NE__OrderId__c, NE__OrderId__r.XC_BillingPreviewStatus__c,
                        NE__OrderId__r.XC_Charge_Amount__c, NE__OrderId__r.XC_TexVAT__c,
            			XC_BillingModel__c
                FROM NE__OrderItem__c
                WHERE NE__OrderId__c in :XC_UTIL_Sobject.getListFieldValues(items,'NE__OrderId__c') and RecordType.DeveloperName != 'Technical_Item' and XC_BillingModel__c != 'Capex' and (NE__Parent_Order_Item__c != null or XC_BillingModel__c = 'Milestone')
        ]);

        for(NE__OrderItem__c oi : itemsMap.values()){
            if(ret.get(oi.NE__OrderId__c)==null){
                ret.put(oi.NE__OrderId__c,new List<NE__OrderItem__c>());
            }
            ret.get(oi.NE__OrderId__c).add(oi);
        }

        return ret;
    }

    private static void generateBellNotification(Set<NE__Order__c> ordersToUpdate){
        List<FeedItem> ll = new List<FeedItem>();
        for(NE__Order__c order : ordersToUpdate){
            FeedItem t = new FeedItem();
            t.ParentId = order.OwnerId;
            t.Body = Label.XC_CL_BillingPreviewIsOK;
            t.Title = Label.XC_CL_BillingPreviewIsOK;
            t.LinkUrl = '/' + order.Id;
            ll.add(t);
        }

        if(!ll.isEmpty()){
            XC_UTIL_Sobject.insertListRecords(new List<FeedItem>(ll));
        }

    }
}