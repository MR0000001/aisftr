/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com , Riccardo Cossu riccardo.cossu@nttdata.com
* @date Creation 07/03/2019
* @date Modification dd/mm/yyyy
* @description Populate the original order and order item on the asset.
*/
public without sharing class XC_TR_Asset_U_PopulateOriginalOrder {

    /**
     * @description Populate original order and order item.
     * @param listNew the list new
     */
    public static void populateOriginalOrderAndOrderItem(List<Asset> listNew){
        List<String> configurationListId = new List<String>();
        List<Asset> assetToUpdate = new List<Asset>();
        for(Asset ast : listNew){
            configurationListId = XC_UTIL_Sobject.getListFieldValues(listNew, 'XC_Configuration_Item__c');
        }
        
        if(configurationListId.isEmpty()){
            return;
        }
        Map<Id,Asset> assetListMap = new Map<Id,Asset>([SELECT Id,XC_Configuration_Item__r.NE__OrderId__c, XC_Configuration_Item__r.NE__OrderId__r.NE__Type__c,
                                        XC_Configuration_Item__r.NE__BillingProfId__c, XC_Original_Creation_Order_Lookup__c, XC_Original_Creation_OrderItem_Lookup__c
                                                FROM Asset
                                                WHERE XC_Configuration_Item__c IN: configurationListId]) ;
        List<Asset> assetList = assetListMap.values();
        for(Asset ast : assetList){
            System.debug('ORDERITEM -->' + ast.XC_Configuration_Item__c);

            System.debug('ORDER -->' + ast.XC_Configuration_Item__r.NE__OrderId__c);
            System.debug('TYPE -->' + ast.XC_Configuration_Item__r.NE__OrderId__r.NE__Type__c);
			
            //if(ast.XC_Configuration_Item__c != null && !String.isBlank(ast.XC_Configuration_Item__r.NE__OrderId__r.NE__Type__c) && ast.XC_Configuration_Item__r.NE__OrderId__r.NE__Type__c == Label.XC_CL_Configuration_TypeInOrder	){
            if(ast.XC_Configuration_Item__c != null && !String.isBlank(ast.XC_Configuration_Item__r.NE__OrderId__r.NE__Type__c) ){ // NM - LR  30/05/2019 
                ast.XC_Original_Creation_OrderItem__c = ast.XC_Configuration_Item__c;
                ast.XC_Original_Creation_Order__c =  ast.XC_Configuration_Item__r.NE__OrderId__c;
                ast.XC_Original_Configuration_Item__c =  ast.XC_Configuration_Item__c; // Lookup Field
                if(ast.XC_Configuration_Item__r.NE__BillingProfId__c != null){
                    ast.XC_OriginalBillingProfile__c = ast.XC_Configuration_Item__r.NE__BillingProfId__c;
                }
                if(ast.XC_Configuration_Item__r.NE__OrderId__r.NE__Type__c.equals(Label.XC_CL_Configuration_TypeInOrder) && 
                    String.isBlank(ast.XC_Original_Creation_Order_Lookup__c) && String.isBlank(ast.XC_Original_Creation_OrderItem_Lookup__c)){
                    ast.XC_Original_Creation_Order_Lookup__c = ast.XC_Configuration_Item__r.NE__OrderId__c;
                    ast.XC_Original_Creation_OrderItem_Lookup__c = ast.XC_Configuration_Item__c;
                }
                assetToUpdate.add(ast);
                System.debug('@@@## ast.XC_Original_Creation_OrderItem__c -- >' + ast.XC_Original_Creation_OrderItem__c);
                System.debug('@@@## ast.XC_Original_Creation_Order__c -- >' + ast.XC_Original_Creation_Order__c); 
            }
        }
        XC_UTIL_Sobject.updateListRecords(assetToUpdate);  
    }
}