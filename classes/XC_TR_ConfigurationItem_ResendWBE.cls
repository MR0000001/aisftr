/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/
public with sharing class XC_TR_ConfigurationItem_ResendWBE {
    public static void resendKO(Map<Id,NE__OrderItem__c> mapOlds, Map<Id,NE__OrderItem__c> mapNews){
        Map<Id,NE__OrderItem__c> mapIdOrderItemKO = new Map<Id,NE__OrderItem__c>();
        mapIdOrderItemKO = checkStatusIsChanged(mapOlds,mapNews);
        if(mapIdOrderItemKO.isEmpty()){
            return;
        }
        deleteWBETracking(mapIdOrderItemKO);
        recalculateWBE(mapIdOrderItemKO);

    }

    private static Map<Id,NE__OrderItem__c> checkStatusIsChanged(Map<Id,NE__OrderItem__c> mapOlds, Map<Id,NE__OrderItem__c> mapNews){
        Map<Id,NE__OrderItem__c> mapIdOrderItemKO = new Map<Id,NE__OrderItem__c>();
        List<String> listField = new List<String>{'XC_WBE_Status__c'};
        Set<String> setStream = new Set<String>{'B2B','B2G'};
        Set<String> setLegalEntity = new Set<String>{'EnelXItalia','EnelSole','ESCoComuniSrl','YouSaveSpA','EnelXSrl','EnelXMobility','Cogenio'};
        for(Id i :mapNews.keySet()){
            if(setStream.contains(mapNews.get(i).XC_Segment__c)
               &&  mapNews.get(i).XC_WBE_Status__c == 'Sent'
               && mapOlds.get(i).XC_WBE_Status__c == 'Rejected'){
                         mapIdOrderItemKO.put(i,mapNews.get(i));
            }
        }
        return mapIdOrderItemKO;
    }


    private static void deleteWBETracking(Map<Id,NE__OrderItem__c> mapIdOrderItemKO){
        List<XC_WbeTracking__c> listWBeTraking = New List<XC_WbeTracking__c>();
        listWBeTraking = retrieveWbeTraking(mapIdOrderItemKO);
        if(!listWBeTraking.isEmpty() && Schema.sObjectType.XC_WbeTracking__c.isAccessible()){
            delete listWBeTraking;
        }

    }


    private static List<XC_WbeTracking__c> retrieveWbeTraking(Map<Id,NE__OrderItem__c> mapIdOrderItemKO){
        List<XC_WbeTracking__c> listWBeTraking = New List<XC_WbeTracking__c>();
        List<String> ordId = XC_UTIL_SObject.getListFieldValues(mapIdOrderItemKO.values(),'NE__OrderId__c');
        if(Schema.sObjectType.XC_WbeTracking__c.accessible){
            listWBeTraking = [SELECT ID, XC_ConfigurationItemId__c FROM XC_WbeTracking__c WHERE XC_ConfigurationItemId__c IN : mapIdOrderItemKO.keySet() and XC_ConfigurationId__c in :ordId];
        }
        return listWBeTraking;
    }

    private static void recalculateWBE(Map<Id,NE__OrderItem__c> mapIdOrderItemKO){
        List<NE__OrderItem__c> listItems = new List<NE__OrderItem__c>();
        if (Schema.sObjectType.NE__OrderItem__c.isAccessible()) {
            listItems = [select Id, NE__Item_Code__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__CatalogItem__r.XC_ProductLine__c, NE__CatalogItem__r.XC_ProductServiceType__c,
                    NE__OrderId__r.NE__OptyId__r.XC_SalesChannel__c, NE__ProdName__c,NE__OrderId__r.Name, RecordType.DeveloperName,NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c, NE__OrderId__r.NE__OptyId__r.XC_ProductCategoryOfInterest__c,
                    NE__OrderId__r.XC_Subtype__c, RecordType.name,XC_Product_Subtype__c,NE__Parent_Order_Item__c, XC_BillingModel__c, NE__OrderId__r.XC_Segment__c,
                    NE__OrderId__r.NE__OptyId__r.XC_ContractStartDate__c,
                    NE__OrderId__r.NE__OptyId__r.XC_ContractEndDate__c,
                    NE__OrderId__r.NE__OptyId__r.XC_RevenueFullLife__c,
                    NE__OrderId__r.NE__OptyId__r.XC_GrossMarginFullLife__c,
                    NE__OrderId__r.NE__OptyId__r.Contract.XC_ContractType__c,
                    NE__OrderId__r.NE__AccountId__r.IdentityType__c,
                    NE__OrderId__r.NE__AccountId__r.IdentityNumber__c,
                    NE__OrderId__r.NE__AccountId__r.Name,
                    XC_Installation_Address__r.XC_PostalCode__c,
                    NE__OrderId__r.NE__OptyId__r.XC_ModeOfEngagement__c,
                    NE__OrderId__r.NE__OptyId__r.XC_LOT__c,
                    NE__OrderId__r.NE__OptyId__r.XC_Zone__c ,
                    XC_Segment__c,
                    XC_LegalEntity__c,
                    XC_BlockWBE_User__c,
                    NE__OrderId__r.XC_PlantOwnership__c,
                    NE__OrderId__r.XC_UpdateWBE_FromButton__c,
                    XC_WBE_Status__c,
                    XC_RecurringDuration__c, NE__OrderId__r.XC_Calculation_Channel_WBE_EC__c,XC_Country__c,NE__OrderId__c, //[ mario.a.giordano@accenture.com, 13/06/2022, add fields for incident INC000088671223 ]
                    NE__OrderId__r.NE__OptyId__r.XC_Segment__c, NE__RecurringChargeOv__c, NE__OneTimeFeeOv__c, XC_EstimatedRevenue__c, XC_RevenueFullLife__c, XC_CostFullLife__c, NE__CatalogItem__r.NE__Item_Header__c, XC_CapexFullLife__c
            from NE__OrderItem__c
            //  where NE__OrderId__c = :recordId
            where id IN :mapIdOrderItemKO.keySet() AND RecordType.DeveloperName != 'Technical_Item'/* AND NE__ProdName__c != :Constants.B2B_PROJECT AND NE__ProdName__c != :Constants.B2G_PROJECT AND RecordType.DeveloperName != :Constants.B2W_RECORDTYPE_TECHNICALITEM*/
            ];
            XC_LCC_056_CalculateWBS_New.generateAutoNumber(listItems);
        
        String wbe = XC_LCC_056_CalculateWBS_New.calculateWBE(listItems);

        }
    }


}