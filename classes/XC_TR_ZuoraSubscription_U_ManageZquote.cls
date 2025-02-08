/**
 * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation 02/10/2019
 * @date Modification 08/04/2020
 * @description XC_TR_ZuoraSubscription_U_ManageZquote – Class to manage SubscriptionId on zquote
 */


public without sharing class XC_TR_ZuoraSubscription_U_ManageZquote {


    /**
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @description method to update the SubscriptionId and/or Name on zQuote
     * @param listnew the Subscription List
    */ 
    //20211119_DD_SO_14 - start
    //public static void updateZquotesAssetsOnInsert(List<Zuora__Subscription__c> listNew) {
    public static void updateZquotesAssetsOnInsert(List<Zuora__Subscription__c> listNew, List<Zuora__Subscription__c> allSubscription) {
    //20211119_DD_SO_14 - end

        Map<String, Zuora__Subscription__c> subOldNew = new Map<String, Zuora__Subscription__c>();
        Map<String, Zuora__Subscription__c> subOldNameNew = new Map<String, Zuora__Subscription__c>();
        Map<String, Zuora__Subscription__c> subOriginalNew = new Map<String, Zuora__Subscription__c>();
        for(Zuora__Subscription__c sub : listNew) {
            subOldNew.put(sub.Zuora__PreviousSubscriptionId__c, sub);
            subOldNameNew.put(sub.Zuora__SubscriptionNumber__c, sub);
            subOriginalNew.put(sub.Zuora__OriginalId__c, sub);
        }

        Map<Id, zqu__quote__c> zquoteMap = new Map<Id, zqu__quote__c>([SELECT Id, zqu__ZuoraSubscriptionID__c, XC_LastSubscriptionId__c, XC_SubscriptionName__c
                                                                        FROM zqu__quote__c
                                                                        WHERE zqu__ZuoraSubscriptionID__c IN :subOldNew.keySet()
                                                                            OR XC_LastSubscriptionId__c IN :subOldNew.keySet()
                                                                            OR XC_SubscriptionName__c IN :subOldNameNew.keySet()
                                                                            OR zqu__ZuoraSubscriptionID__c IN :subOriginalNew.keySet()]);
        if(zquoteMap.isEmpty()) {
            retriveAndUpdateSubscriptionFieldonAsset(!allSubscription.isEmpty() ? allSubscription : listNew); //20211119_DD_SO_14 
            return;
        }

        List<zqu__quote__c> quotesToUpdate = new List<zqu__quote__c>();
        Map<Id, Zuora__Subscription__c> zqIdSubMap  = new Map<Id, Zuora__Subscription__c>();
        for(zqu__quote__c quote : zquoteMap.values()) {

            Zuora__Subscription__c sub = new Zuora__Subscription__c();
            if(subOldNew.get(quote.zqu__ZuoraSubscriptionID__c) != null) {
                sub = subOldNew.get(quote.zqu__ZuoraSubscriptionID__c);
            } else if(subOldNew.get(quote.XC_LastSubscriptionId__c) != null) {
                sub = subOldNew.get(quote.XC_LastSubscriptionId__c);
            } else if(subOldNameNew.get(quote.XC_SubscriptionName__c) != null) {
                sub = subOldNameNew.get(quote.XC_SubscriptionName__c);
            } else if(subOriginalNew.get(quote.zqu__ZuoraSubscriptionID__c) != null) {
                sub = subOriginalNew.get(quote.zqu__ZuoraSubscriptionID__c);
            }

            zqIdSubMap.put(quote.Id, sub);
            String lastSubscription = sub.Zuora__External_Id__c;
            String subscriptionName = sub.Zuora__SubscriptionNumber__c;

            Boolean updateZquote = false;
            if(String.isBlank(quote.XC_SubscriptionName__c) && String.isNotBlank(subscriptionName)){
                quote.XC_SubscriptionName__c = subscriptionName;
                updateZquote = true;
            }

            if(String.isNotBlank(lastSubscription) && quote.XC_LastSubscriptionId__c != lastSubscription && quote.zqu__ZuoraSubscriptionID__c != lastSubscription) {
                quote.XC_LastSubscriptionId__c = lastSubscription;
                updateZquote = true;
            }

            if(updateZquote) {
                quotesToUpdate.add(quote);
            }
        }

        if(!quotesToUpdate.isEmpty()) {
            XC_UTIL_SObject.updateListRecords(quotesToUpdate);
        }

        // CALL Method to update Subscription Field on Asset
        updateSubscriptionOnAsset(zqIdSubMap, !allSubscription.isEmpty() ? allSubscription : listNew);
    }
   
    
    /**
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @description method to update the SubscriptionId and/or Name on zQuote
     * @param mapOld the old Subscription Map
     * @param mapNew the new Subscription Map
    */ 
    public static void updateZquotesAssetsOnUpdate(Map<Id, Zuora__Subscription__c> mapOld, Map<Id, Zuora__Subscription__c> mapNew) {

        List<String> fieldList = new List<String>{'Zuora__External_Id__c', 'Zuora__Version__c'};
        List<Zuora__Subscription__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()) {
            retriveAndUpdateSubscriptionFieldonAsset(mapNew.values()); //20211119_DD_SO_14 
            return;
        }

        updateZquotesAssetsOnInsert(listChanged, mapNew.values()); //20211119_DD_SO_14 
    }


    /**
     * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @description method that update the Subscription field on the assets related to the zQuote
     * @param zqIdSubMap the zQuoteId - Subscription MAP
    */ 
    public static void updateSubscriptionOnAsset(Map<Id, Zuora__Subscription__c> zqIdSubMap, List<Zuora__Subscription__c> listnew) { //20211119_DD_SO_14 
        
        
        Map<Id, Asset> assetQueryMap  = new Map<Id, Asset>([SELECT Id, XC_Original_Configuration_Item__r.XC_ZQuoteId__c, XC_ZQuoteId__c, XC_Subscription__c, XC_SubscriptionName__c 
                                                            FROM Asset 
                                                            WHERE XC_Original_Configuration_Item__r.XC_ZQuoteId__c IN: zqIdSubMap.keySet() 
                                                                  OR XC_Configuration_Item__r.XC_ZQuoteId__c IN: zqIdSubMap.keySet()]); 
                                                                //OR XC_ZQuoteId__c IN: zqIdSubMap.keySet()]); //20220404 

        System.debug('$$ Assets Query Map: ' + assetQueryMap);
        
        if(assetQueryMap.isEmpty()){
            //20211119_DD_SO_14 - start
            retriveAndUpdateSubscriptionFieldonAsset(!listnew.isEmpty()? listnew: zqIdSubMap.values()); //20211119_DD_SO_14 
            return;
            //20211119_DD_SO_14 - end
        }

        //Creating a map that match the zqu__quote__c IDs to the list of Assets related 
        Map<Id, List<Asset>> zqAssetMap  = new Map<Id, List<Asset>>();
        for(String zqID : zqIdSubMap.keySet()){
            List<Asset> assList = new List<Asset>();
            for(Asset ass : assetQueryMap.values()){
                if(zqID == ass.XC_Original_Configuration_Item__r.XC_ZQuoteId__c || zqID == ass.XC_ZQuoteId__c){
                    assList.add(ass);
                }
            }
            zqAssetMap.put(zqID, assList);
        }
        System.debug('$$ Map zqId - Asset list: ' + zqAssetMap);

        //Updating XC_Subscription__c field on assets and adding them to a map
        Map<Id, Asset> assetsToUpdate = new Map<Id, Asset>();
        for(Id zqi : zqAssetMap.keySet()){
            for(Asset ass : zqAssetMap.get(zqi)) {
                if(ass.XC_Subscription__c != zqIdSubMap.get(zqi).Id || ass.XC_SubscriptionName__c != zqIdSubMap.get(zqi).Zuora__SubscriptionNumber__c) {
                    ass.XC_Subscription__c = zqIdSubMap.get(zqi).Id;
                    ass.XC_SubscriptionName__c = zqIdSubMap.get(zqi).Zuora__SubscriptionNumber__c;
                    assetsToUpdate.put(ass.Id, ass);
                }
            }
        }

        //20211119_DD_SO_14 - start
        List<String> subNames = new List<String>();
        for(Zuora__Subscription__c s : listnew){
            subNames.add(s.Name);
        }
        Map<Id, Asset> retrivedAssetsMap  = new Map<Id, Asset>([SELECT Id, XC_Subscription__c, XC_SubscriptionName__c 
                                                                FROM Asset 
                                                                WHERE XC_SubscriptionName__c IN: subNames
                                                                AND XC_Subscription__c = null 
                                                                AND Id NOT IN:assetsToUpdate.KeySet()
                                                                ]);
        if(!retrivedAssetsMap.isEmpty()){
            for(Zuora__Subscription__c s : listnew){
                for(Asset a : retrivedAssetsMap.values()){
                    if(String.isBlank(a.XC_Subscription__c) && s.Zuora__SubscriptionNumber__c == a.XC_SubscriptionName__c){
                        a.XC_Subscription__c = s.id;
                        assetsToUpdate.put(a.id, a);
                    }
                }
            }
        }
        //20211119_DD_SO_14 - end

        // Update Assets
        System.debug('$$ Update asset Map: ' + assetsToUpdate);
        if(!assetsToUpdate.isEmpty()) {
            //20211119_DD_SO_14 - start
            XC_TR_Asset_Handler.bypassBeforeUpdate = true;
            XC_TR_Asset_Handler.bypassAfterUpdate = true;
            //20211119_DD_SO_14 - end
            XC_UTIL_SObject.updateListRecords(assetsToUpdate.values());
        }
    }


    /**
     * @author Giuseppe Di Bonito gdibonito@deloitte.it
     * @description method that update the Subscription field on the assets with the same Subscription Name
     * @date Creation 20/03/2020
     * @param listnew 
    */ 
    public static void retriveAndUpdateSubscriptionFieldonAsset(List<Zuora__Subscription__c> listnew) {

        List<String> subNames = new List<String>();
        for(Zuora__Subscription__c s : listnew){
            subNames.add(s.Name);
        }

        Map<Id, Asset> retrivedAssetsMap  = new Map<Id, Asset>([SELECT Id, XC_Subscription__c, XC_SubscriptionName__c 
                                                                FROM Asset 
                                                                WHERE XC_SubscriptionName__c in: subNames
                                                                AND XC_Subscription__c = null //20211119_DD_SO_14 
                                                                ]);
        //20211119_DD_SO_14 - start
        if(retrivedAssetsMap.isEmpty()){
            return;
        }
        //20211119_DD_SO_14 - end
        List<Asset> assetsToUpdate = new List<Asset>();
        for(Zuora__Subscription__c s : listnew){
            for(Asset a : retrivedAssetsMap.values()){
                if(String.isBlank(a.XC_Subscription__c) && s.Zuora__SubscriptionNumber__c == a.XC_SubscriptionName__c){
                    a.XC_Subscription__c = s.id;
                    assetsToUpdate.add(a);
                }
            }
        }

        if(!assetsToUpdate.isEmpty()) {
            //20211119_DD_SO_14 - start
            XC_TR_Asset_Handler.bypassBeforeUpdate = true;
            XC_TR_Asset_Handler.bypassAfterUpdate = true;
            //20211119_DD_SO_14 - end
            XC_UTIL_SObject.updateListRecords(assetsToUpdate);
        }
    }



    /**
     * @author Giuseppe Di Bonito gdibonito@deloitte.it
     * @description method that update the Subscription field on the assets related to the zqu__quote inserted
     * @param listnew 
    */ 
    /*public static void updateSubscriptionFieldInsert(List<Zuora__Subscription__c> listnew) {
        System.debug('$$ GDB');
        List<String> subId = new List<String>();
        for(Zuora__Subscription__c zs : listnew){
            subId.add(zs.Zuora__External_Id__c);
        }
        System.debug('$$ Subscription Id List: ' + subId);
        if(subId.isEmpty()){
            return;
        }

        Map<Id, zqu__quote__c> zQuoQueryMap  = new Map<Id, zqu__quote__c>([SELECT Id, XC_LastSubscriptionId__c, zqu__ZuoraSubscriptionID__c 
                                                                           FROM zqu__quote__c 
                                                                           WHERE XC_LastSubscriptionId__c in: subId
                                                                           OR zqu__ZuoraSubscriptionID__c in: subId]);
        System.debug('$$ zQuote Query Map: ' + zQuoQueryMap);                                                                   

        Map<Id, String> zqSUBs = new Map<Id, String>();
        for(zqu__quote__c zq : zQuoQueryMap.values()){
            if(!String.isBlank(zq.XC_LastSubscriptionId__c)){ //Prio to XC_LastSubscriptionId__c
                zqSUBs.put(zq.Id, zq.XC_LastSubscriptionId__c);

            } else if(!String.isBlank(zq.zqu__ZuoraSubscriptionID__c)){
                zqSUBs.put(zq.Id, zq.zqu__ZuoraSubscriptionID__c);
            }
        }
        System.debug('$$ zQuote Composed Map: ' + zqSUBs);

        if(zqSUBs.isEmpty()){
            return;
        }
        //Query to retrive the Assets related to the zqu__quote__c triggered
        Map<Id, Asset> assetQueryMap  = new Map<Id, Asset>([SELECT Id, XC_Original_Configuration_Item__r.XC_ZQuoteId__c, XC_Subscription__c 
                                                        FROM Asset 
                                                        WHERE XC_Original_Configuration_Item__r.XC_ZQuoteId__c in: zqSUBs.keySet()]);  
        System.debug('$$ Assets Query Map: ' + assetQueryMap);
        
        //assetQueryMap empty check
        if(assetQueryMap.isEmpty()){
            return;
        }   
        //Creating a map that match the zqu__quote__c IDs to the list of Assets related 
        Map<Id, List<Asset>> zqAssetMap  = new Map<Id, List<Asset>>();
        for(String zqID : zqSUBs.keySet()){
            List<Asset> assList = new List<Asset>();
            for(Asset ass : assetQueryMap.values()){
                if(zqID == ass.XC_Original_Configuration_Item__r.XC_ZQuoteId__c){
                    assList.add(ass);
                }
            }
            zqAssetMap.put(zqID, assList);
        }
        System.debug('$$ Map zqId - Asset list: ' + zqAssetMap);

        //Query to retrive the Salesforce IDs of the Zuora__Subscription__c related to zqu__quote__c     
        Map<Id, Zuora__Subscription__c> zSubQueryMap  = new Map<Id, Zuora__Subscription__c>([SELECT Id, Zuora__External_Id__c 
                                                                                    FROM Zuora__Subscription__c 
                                                                                    WHERE Zuora__External_Id__c in: zqSUBs.values()]);
        System.debug('$$ Query Map SUB: ' + zSubQueryMap);

        //Creating a map that match the zqu__quote__c IDs to the Zuora__Subscription__c IDs
        Map<Id, Zuora__Subscription__c> zqSUBidMap  = new Map<Id, Zuora__Subscription__c>();

        for(Id zqi : zqSUBs.keySet()){
            for(Zuora__Subscription__c zs : listnew){
                if(zqSUBs.get(zqi) == zs.Zuora__External_Id__c){
                    zqSUBidMap.put(zqi, zs);
                }
            }
        }
        System.debug('$$ Map zqId - SUBid: ' + zqSUBidMap);

        //Updating XC_Subscription__c field on assets and adding them to an unique list
        List<Asset> assetListToUpdate = new List<Asset>();
        for(Id zqi : zqAssetMap.keySet()){
            for(Asset ass : zqAssetMap.get(zqi)){
                ass.XC_Subscription__c = zqSUBidMap.get(zqi).Id;
                ass.XC_SubscriptionName__c =  zqSUBidMap.get(zqi).Name;
            }
            assetListToUpdate.addAll(zqAssetMap.get(zqi));
        }
        //Update
        System.debug('$$ Update asset List: ' + assetListToUpdate);
        XC_UTIL_SObject.updateListRecords(assetListToUpdate);
    }*/
    
}