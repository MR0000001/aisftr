/**
* @author : Valeria Martino - valeria.martino@nttdata.com
* @date Creation 24/09/2019
* @date Modification dd/mm/yyyy
* @description – XC_TR_ConfigurationItem_U_FillProdFields
*/
public without sharing class XC_TR_ConfigurationItem_U_FillProdFields {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ConfigurationItem_U_FillProdFields');

    /**
    * @description onUpdate
    * @author Valeria Martino - valeria.martino@nttdata.com
    * @param listNew - List<NE__OrderItem__c>
    * @param mapOld - Map<Id,NE__OrderItem__c>
    * @param mapNew - Map<Id,NE__OrderItem__c>
    **/
    public static void onUpdate(List<NE__OrderItem__c> listNew, Map<Id,NE__OrderItem__c> mapOld, Map<Id,NE__OrderItem__c> mapNew) {

        List<String> fieldList = new List<String>{'NE__ProdId__c'};
        List<NE__Product__c> product = new List<NE__Product__c>();
        List<NE__OrderItem__c> orderItemChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(orderItemChanged.isEmpty()){
            return;
        }
        for(NE__OrderItem__c orderItem : orderItemChanged) {
            if(orderItem.NE__ProdId__c == null) {
                return;
            }
        }
        LIst<String> listConfItemIds = new List<String>();
        //XC_UTIL_Sobject.getIds(orderItemChanged);
        List<String> idProduct = new List<String>();
        for(NE__OrderItem__c orderItem : orderItemChanged) {
            idProduct.add(orderItem.NE__ProdId__c);
            listConfItemIds.add(orderItem.id);

        }
        
        product =new List<NE__Product__c>([SELECT Id, name, XC_Product_Type__c, XC_Product_Subtype__c, NE__Description__c, (SELECT Id, XC_Product_Type__c, XC_Product_Subtype__c  FROM NE__Order_Items__r WHERE id IN :listConfItemIds) FROM NE__Product__c WHERE Id IN :idProduct]);
        Map<String, NE__Product__c> mapOrderItemProd = new Map<String, NE__Product__c>();
        for(NE__OrderItem__c orderItem : orderItemChanged) {
            for(NE__Product__c prod : product) {
                if(prod.Id == orderItem.NE__ProdId__c) {
                    mapOrderItemProd.put(orderItem.id, prod);
                }
            }
        }

        for(NE__OrderItem__c orderItem : orderItemChanged){
            populateProdFields(orderItem, mapOrderItemProd.get(orderItem.id));
        }

    }
    /**
    * @description onInsert
    * @author Valeria Martino - valeria.martino@nttdata.com
    * @param listNew - List<NE__OrderItem__c>
    **/
    public static void onInsert(List<NE__OrderItem__c> listNew){
        List<String> idProduct = new List<String>();
        for(NE__OrderItem__c orderItem : listNew) {
            idProduct.add(orderItem.NE__ProdId__c);
        }
        if(idProduct.isEmpty()) {
            return;
        }
        Map<Id, NE__Product__c> mapProduct = new Map<Id, NE__Product__c>([
                SELECT Id, XC_Product_Type__c, XC_Product_Subtype__c,name, NE__Description__c
                FROM NE__Product__c WHERE Id IN :idProduct
        ]);

        for(NE__OrderItem__c orderItem : listNew) {
            populateProdFields(orderItem, mapProduct.get(orderItem.NE__ProdId__c) );
        }

        XC_TR_ConfigurationItem_U_FillFields.setProductOwner(idProduct, listNew);

    }



    /**
    * @description populateProdFields
    * @author Valeria Martino - valeria.martino@nttdata.com 
    * @param confItem - NE__OrderItem__c
    * @param product - NE__Product__c
    **/
    public static void populateProdFields(NE__OrderItem__c confItem, NE__Product__c product ){
        if(product != null && String.isBlank(confItem.XC_Product_Type__c) && String.isBlank(confItem.XC_Product_Subtype__c) && !String.isBlank(product.XC_Product_Type__c) && !String.isBlank(product.XC_Product_Subtype__c) ) {
            confItem.XC_Product_Type__c = product.XC_Product_Type__c;
            confItem.XC_Product_Subtype__c = product.XC_Product_Subtype__c;
        }
        if(product != null && confItem!=null){
            confItem.XC_ProdNameText__c = product.name;
            confItem.XC_TranslatedProductDescription__c = product.NE__Description__c;
        }

    }

    /**
    * @description fillB2WFields
    * @author Simone Trenta - strenta@deloitte.it
    * @param listNew - List<NE__OrderItem__c>
    **/
    public static void fillB2WFields(List<NE__OrderItem__c> listNew){
        List<XC_CM_CountryLegalEntityAssociation__mdt> legalEntityCategory = [SELECT ID,DeveloperName,XC_LegalEntity__c,XC_Category__c
        FROM XC_CM_CountryLegalEntityAssociation__mdt
        WHERE XC_LegalEntity__c = : XC_UTIL_User.getLegalEntityFromUser()];
        if(legalEntityCategory[0].XC_Category__c=='B2C'){
        List<NE__OrderItem__c> ordItToUpdate = new List<NE__OrderItem__c>();
        for(NE__OrderItem__c oi:listNew){
            if(oi.XC_Segment__c=='B2C' && false){
            if(String.isBlank(oi.NE__Configuration_item_update_key__c)){
                if(String.isBlank(oi.NE__Item_Code__c)) {
                    NE__OrderItem__c n = new NE__OrderItem__c(Id = oi.Id);
                    n.NE__Item_Code__c = oi.Id;
                    ordItToUpdate.add(n);
                  }
                }
            }
        }
        if(!ordItToUpdate.isEmpty()){
            XC_UTIL_Sobject.updateListRecords(ordItToUpdate);
            }
        }
    }

 



}